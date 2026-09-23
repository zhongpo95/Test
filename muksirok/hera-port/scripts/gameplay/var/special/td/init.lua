-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local pdi_hxnv = false
local pdi_cy = false
local pdi_xyzqjianshi = false
local pdi_alice = false
local pdi_zz = false
local pdi_hf = false
local pdi_tz = false
local pdi_leilv = false
local pdi_angela = false
local pdi_yuzaoqian = false
local pdi_naxida = false
local pdi_urara = false
local pdi_zaomiao = false
local pdi_zaomiao2 = false
local pdi_alicexianjing = false
local pdi_huolingmeng = false
local pdi_yuzhe = false
local pdi_laonanren = false
local pdi_lianlian = false
Chushi_Murasame = false
local pdi_amiya = false
local pdi_anying = false
local pdi_mmt = false
local pdi_yangjian = false
local pdi_ams = false
local pdi_luxifa = false
local pdi_feiai = false
local pdi_aluxi = false

local function smyhget(u)
  u:adddivinity(1)
  u:setdata("特典-神明羽骸")
  u:uivar_add({
    keyname = "神明羽骸",
    keytype = "传奇栏",
    text = "|cFFFFCC33神|r|cFFEBD65C明|r|cFFD6E085羽|r|cFFC2EBAD骸|r\n|cFFFFCC33神性 1|r\n|cFFEBD65C提升3点神力承载上限|r\n|cFFD6E085获得[启示药剂]|r",
    icon = "Ewl_TD_00.tga"
  })
  u:changedata("系统-神力承载上限", 3)
  u:additem("I0J9")
end

local function hexToRGB(hex)
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  return r, g, b
end

local function lerp(a, b, t)
  return math.floor(a + (b - a) * t + 0.5)
end

local function lerpColor(startColor, endColor, t)
  local sr, sg, sb = hexToRGB(startColor)
  local er, eg, eb = hexToRGB(endColor)
  local r = lerp(sr, er, t)
  local g = lerp(sg, eg, t)
  local b = lerp(sb, eb, t)
  return string.format("%02X%02X%02X", r, g, b)
end

local function tddataflash(u, name)
  for index, value in ipairs(AllTDdata) do
    if value.name == name then
      if value.hasbeenget then
        u:sendmessage("|cFFFFCC33[神明特典]已被选取自动替换为[神明羽骸]")
        smyhget(u)
        return
      end
      if not value.isnotonly then
        value.hasbeenget = true
      end
      u:uivar_add({
        keyname = name,
        keytype = "传奇栏",
        text = value.text,
        icon = value.icon
      })
      value.getfunc(u, value)
      break
    end
  end
  u:setdata("特典-" .. name)
  if name == "神明羽骸" then
    smyhget(u)
  end
end

AllTDdata = {
  {
    name = "天之少女",
    text = "|cFF3366FF天|r|cFF5C85FF之|r|cFF85A3FF少|r|cFFADC2FF女|r\n|cFF3366FF水|r|cFF5C85FF |r|cFF85A3FF歌|r|cFFADC2FF姬 唯一|r\n|cFF3366FF提升0.1体力恢复|r\n|cFF5C85FF提升100%水补正|r\n|cFF85A3FF提升100%歌姬补正|r\n|cFFADC2FF升级时提升1%水效果增强与1%歌姬变异增强|r",
    icon = "Ewl_TD_01.tga",
    getfunc = function(u, value)
      local sy = u.ownerid
      u:changedata("水变异数量", 1)
      u:changedata("歌姬变异数量", 1)
      if u:isgirl() then
        u:setdata("特典-天之少女-女主")
        u:changedata("歌姬变异补正", 100)
        u:changedata("水变异补正", 100)
        u:addstexiao(value.name, "英雄升级时效果", function(args)
          u:changedata("效果增强-水", 0.01)
          u:changedata("效果增强-歌姬", 0.01)
        end)
        ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      else
        u:addstexiao(value.name, "英雄升级时效果", function(args)
          ChangeValue(Hero_Tili_Max, sy, 0.5)
        end)
        ChangeValue(Hero_Tili_Huifu, sy, 0.25)
        u:addstexiao(value.name, "决死效果", function(args)
          if args.dt and not u:hasdata("天之少女-决死冷却") then
            args.dt = false
            u:settimedata("天之少女-决死冷却", 600)
            u:buffset(u.handle, 1, "无敌")
            u:sendmessage("|cFF6699FF天之少女-致死抵挡|r")
          end
        end)
        u:setdata("特典-天之少女-男主")
        ac.wait(1000, function()
          u:uivar_change({
            keyname = value.name,
            keytype = "传奇栏",
            text = "|cFF3366FF天|r|cFF5C85FF之|r|cFF85A3FF少|r|cFFADC2FF女|r\n|cFF3366FF水|r|cFF5C85FF |r|cFF85A3FF歌|r|cFFADC2FF姬 唯一|r\n|cFF3366FF提升0.25体力恢复|r\n|cFF5C85FF升级时提升0.5点体力上限|r\n|cFF85A3FF受到致死伤害时抵挡该次伤害并无敌1秒,触发冷却600秒|r"
          })
        end)
      end
    end
  },
  {
    name = "魔歇拉刻印",
    text = "|cFF666666魔歇拉刻印\n精神承载上限锁定为0\n冥王星药剂成功率锁定为0\n提升100%以太药剂成功率\n免疫以太变异抗药性惩罚\n每25级提升1三阶以太上限(上限3个)\n前三个数量的词条均视为主词条|r",
    icon = "Ewl_TD_02.tga",
    getfunc = function(u, value)
      local sy = u.ownerid
      u:changedata("魔歇拉刻印-计数", 1)
      u:changedata("魔歇拉刻印-解锁上限", 0)
      u:addstexiao("魔歇拉刻印", "英雄升级时效果", function(args)
        if u:getdata("魔歇拉刻印-解锁上限") < 3 then
          u:changedata("魔歇拉刻印-计数", 1)
          if u:getdata("魔歇拉刻印-计数") >= 25 then
            u:changedata("魔歇拉刻印-计数", -25)
            u:changedata("以太三阶上限", 1)
            u:changedata("魔歇拉刻印-解锁上限", 1)
            u:sendmessage("|cFF666666[魔歇拉刻印]三阶通用以太槽提升")
          end
        end
      end)
      u:setdata("系统-启动承载上限", 0)
      ac.loop(1000, function()
        u:setdata("系统-启动承载上限", 0)
      end)
    end
  },
  {
    name = "春秋蝉",
    text = "|cFF666666春秋蝉\n唯一\n提升1幸运\n过波时10%提升1神力承载上限\n游戏失败或自身删模时极低概率逆转时光|r\n|cFF949596不过是些许风霜罢了|r",
    icon = "Ewl_TD_03.tga",
    getfunc = function(u, value)
      local sy = u.ownerid
      u:setdata("春秋蝉-触发概率", 24)
      u:changedata("幸运", 1)
      u:addstexiao("春秋蝉", "过波时效果", function(args)
        if GetRandom100(10) then
          u:changedata("系统-神力承载上限", 1)
          u:sendmessage("|cFF666666[春秋蝉]提升神力承载")
        end
      end)
    end
  },
  {
    name = "神秘小瓶",
    text = "|cFF33CC33神|r|cFF33D647秘|r|cFF33E05C小|r|cFF33EB70瓶|r\n|cFF33CC33唯一|r\n|cFF33D647获得物品[神秘小瓶]|r",
    icon = "BTNEwl_TD_Zhangtianping.tga",
    getfunc = function(u, value)
      local sy = u.ownerid
      local wp = u:additem("I0KH")
      local cs = 0
      ac.loop(3000, function(timer)
        if IsTimeNight() then
          cs = cs + 1
        end
        if 20 <= cs then
          cs = 0
          ChangeItemCount(wp, 1)
        end
      end)
    end
  },
  {
    name = "神秘兜帽男",
    text = "|cFF666666神秘兜帽男|r\n|cFF666666唯一\n免疫矿石病症状影响\n矿石病不会爆发\n使全队(除自身)感染矿石病\n提升源石变异获取基础权重\n升级时提升1%源石效果增强\n源石变异加入常规回忆变异池|r",
    icon = "Ewl_Cq_Shenmidoumaonan.tga",
    getfunc = function(u, value)
      local sy = u.ownerid
      u:setdata("变异判定-博士")
      u:addstexiao(value.name, "英雄升级时效果", function(args)
        u:changedata("效果增强-源石", 0.01)
      end)
      ac.wait(15000, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:changeysnd(1)
        end)
      end)
    end
  },
  {
    name = "沙勒教师",
    text = "|cFFFF0006沙|r|cFFFF4D54勒|r|cFFFE9AA1教|r|cFFFEE7EF师|r\n|cFFFF0006唯一|r\n|cFFFEE7EF使全队(除自身)视为学生\n提升100%学生补正|r\n|cFFFF0006【事务处理】|r\n|cFFFEE7EF可以对学生进行事物处理|r",
    icon = "war3mapImported\\BTNEwl_Cq_Laoshi.tga",
    getfunc = function(u, value)
      local sy = u.ownerid
      u:changedata("学生变异补正", 100)
      AddUISkill({
        text = "事务处理",
        u = u,
        cd = 45,
        icon = "Ewl_Skill_Sensei.tga",
        showtext = "|cFFFF0006事务处理|r\n|cFFFEE7EF点击时对随机队友触发以下一项效果\n(如果是学生则提升50%效果,如果是女学生则额外提升50%效果)：\n①提升1~10点全属性\n②提升0.5%全属性\n③提升1~10%伤害修正\n④提升0.5%终结伤害\n⑤提升100~1000基础生命上限\n⑥获得一瓶随机药水\n冷却45秒|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          local sj = GetRandomInt(1, 7)
          local zu = CreateGroupLua()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq.handle ~= u.handle then
              xq:groupadd(zu)
            end
          end)
          if Group_Counts(zu) > 0 then
            local mb = Group_Randomunit(zu)
            if 0 < Group_Counts(Group_Student) and GetRandom100(50) then
              mb = Group_Randomunit(Group_Student)
            end
            local bs = 1
            if mb:isingroup(Group_Student) then
              bs = bs + 0.5
              if mb:isgirl() then
                bs = bs + 0.5
              end
            end
            local sy2 = mb.ownerid
            u:sendmessage("|cFFFF0006处理了与|r" .. mb:getplayername() .. "|cFFFF0006的事务|r")
            mb:sendmessage("|cFFFF0006老师处理了与你相关的事务|r")
            if sj == 1 then
              local add = GetRandomInt(1, 10) * bs
              mb:addallstats(add)
              u:sendmessage("|cFFFF0006提升" .. math.floor(add) .. "点全属性|r")
              mb:sendmessage("|cFFFF0006提升" .. math.floor(add) .. "点全属性|r")
            end
            if sj == 2 then
              mb:changedata("全属性增幅", 0.005 * bs)
              u:sendmessage("|cFFFF0006提升" .. bs .. "%全属性|r")
              mb:sendmessage("|cFFFF0006提升" .. bs .. "%全属性|r")
            end
            if sj == 3 then
              local add = GetRandomInt(1, 10) * bs
              mb:addrandomdamage(add)
              u:sendmessage("|cFFFF0006提升" .. string.format("%.1f", add * 0.1) .. "%伤害加成|r")
              mb:sendmessage("|cFFFF0006提升" .. string.format("%.1f", add * 0.1) .. "%伤害加成|r")
            end
            if sj == 4 then
              ChangeValue(DamageSystem_EndSh, sy2, 0.1 * (0.005 * bs))
              u:sendmessage("|cFFFF0006提升" .. bs .. "%终结伤害|r")
              mb:sendmessage("|cFFFF0006提升" .. bs .. "%终结伤害|r")
            end
            if sj == 5 then
              local add = GetRandomInt(100, 1000) * bs
              mb:changeoriginmaxhp(add)
              u:sendmessage("|cFFFF0006提升" .. math.floor(add) .. "点基础生命上限|r")
              mb:sendmessage("|cFFFF0006提升" .. math.floor(add) .. "点基础生命上限|r")
            end
            if sj == 6 then
              mb:sendmessage("|cFFFF0006获得一瓶随机药水|r")
              for i = 1, bs do
                local a = GetRandomReal(0, 100)
                if a <= 36 then
                  mb:additem("I02F")
                elseif a <= 72 then
                  mb:additem("I02H")
                elseif a <= 81 then
                  mb:additem("I02E")
                elseif a <= 90 then
                  mb:additem("I011")
                else
                  mb:additem("I030")
                end
              end
            end
          else
            u:sendmessage("|cFFFF0006没有学生！|r")
          end
        end
      })
      ac.wait(15000, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq.handle ~= u.handle then
            xq:become("学生")
          end
        end)
      end)
    end
  },
  {
    name = "普罗维登斯的绅士",
    text = "|cFF6699CC普罗维登斯的绅士|r\n|cFF99CCFF唯一\n每720秒提升2启动承载上限\n免疫注视负面效果\n提升200%外域变异补正|r",
    icon = "TD_Lfklft.tga",
    getfunc = function(u, value)
      local sy = u.ownerid
      u:changedata("外域变异补正", 200)
      ac.loop(720000, function()
        u:sendmessage("|cFF6699CC[普罗维登斯的绅士]启动承载上限提升|r")
        u:changedata("系统-启动承载上限", 2)
      end)
    end
  }
}

local function randomPick(source, target)
  local tempData = {}
  for i, v in ipairs(source) do
    if not v.hasbeenget then
      table.insert(tempData, v)
    end
  end
  for i = 1, 2 do
    if #tempData < 2 then
      table.insert(tempData, {
        name = "神明羽骸",
        isnotonly = true,
        text = "|cFFFFCC33神|r|cFFEBD65C明|r|cFFD6E085羽|r|cFFC2EBAD骸|r\n|cFFFFCC33神性 1|r\n|cFFEBD65C提升3点神力承载上限|r\n|cFFD6E085获得[启示药剂]|r",
        icon = "Ewl_TD_00.tga",
        func = function(u)
          local sy = u.ownerid
          tddataflash(u, "神明羽骸")
        end,
        getfunc = function(u, value)
          smyhget(u)
        end
      })
    end
  end
  for i = 1, 2 do
    local index = math.random(1, #tempData)
    table.insert(target, tempData[index])
    table.remove(tempData, index)
  end
end

function TD_Get(u)
  local savedata = {
    {
      name = "神明羽骸",
      isnotonly = true,
      text = "|cFFFFCC33神|r|cFFEBD65C明|r|cFFD6E085羽|r|cFFC2EBAD骸|r\n|cFFFFCC33神性 1|r\n|cFFEBD65C提升3点神力承载上限|r\n|cFFD6E085获得[启示药剂]|r",
      icon = "Ewl_TD_00.tga",
      func = function(u2)
        tddataflash(u2, "神明羽骸")
      end,
      getfunc = function(u2, value)
        smyhget(u2)
      end
    }
  }
  randomPick(AllTDdata, savedata)
  local data = {
    noskip = false,
    desc = "|cFFFFCC66【选择一项】[跳过]放弃本次选择|r",
    options = {}
  }
  for _, v in ipairs(savedata) do
    local dname = v.name
    local dtext = v.text
    local dicon = v.icon
    if dname == "天之少女" and not u:isgirl() then
      dtext = "|cFF3366FF天|r|cFF5C85FF之|r|cFF85A3FF少|r|cFFADC2FF女|r\n|cFF3366FF水|r|cFF5C85FF |r|cFF85A3FF歌|r|cFFADC2FF姬 唯一|r\n|cFF3366FF提升0.25体力恢复|r\n|cFF5C85FF升级时提升0.5点体力上限|r\n|cFF85A3FF受到致死伤害时抵挡该次伤害并无敌1秒,触发冷却600秒|r"
    end
    table.insert(data.options, {
      icon = dicon,
      title = dname,
      rarity = "传说",
      text = dtext,
      func = function(u2)
        tddataflash(u2, dname)
      end
    })
  end
  RLChoose(u, data)
end

local function shilang(u)
  local sy = u.ownerid
  local uidc = CIUC[sy]
  Start_Shilang = true
  u:chat("输给谁都可以，但是，决不能输给自己。")
  if uidc == "-808583347" then
    u:setdata("判定-卫宫士郎")
  end
  u:setdata("变异判定-正义的伙伴")
  u:changedata("光明变异数量", 1)
  u:uivar_add({
    keyname = "士郎初始",
    keytype = "传奇栏",
    text = "|cFFFF0000正义|r|cFFFF3300的|r|cFFFF6600伙伴|r\n|cFFFF0000光明\n士郎的正义|r\n|cFFFF6600[无任何效果]|r\n|cFF949596我要贯彻，正义的伙伴，这条路。|r",
    icon = "war3mapImported\\PASBTNEwl_Teshu_Shilang"
  })
end

local function tuzidong(u)
  pdi_alicexianjing = true
  u:setdata("初始-兔子洞")
  u:playselfsound(alice_tuzidong)
  u:sendmessage("|cFFF55D5C你|r|cFFEC5453掉|r|cFFE34A4A进|r|cFFD94140了|r|cFFD03837兔|r|cFFC72F2E子|r|cFFBE2525洞|r|cFFB51C1C…|r|cFFAB1312…|r")
  u:uivar_add({
    keyname = "兔子洞",
    keytype = "传奇栏",
    text = "|cFFF55D5C兔|r|cFFDE4645子|r|cFFC72E2E洞|r\n|cFFF55D5C解锁特殊启动变异|r",
    icon = "Ewl_Alice_Tuzidong_2"
  })
  ac.wait(300000, function()
    if not u:hasdata("变异判定-梦游仙境") then
      u:sendmessage("|cFFFF0066童话王国？那只是拼好饭被偷前的妄想罢了！|r")
      u:deldata("初始-兔子洞")
      u:uivar_remove("兔子洞", "传奇栏")
    end
  end)
end

local function jiantongying(u)
  local sy = u.ownerid
  Start_Sakura = true
  u:addskill("S06F")
  u:setdata("特殊判定-天之杯")
  if not Start_Shilang then
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq.handle ~= u.handle and xq.type ~= HeroType["切嗣"] then
        xq:groupadd(g)
      end
    end)
    if Group_Counts(g) > 0 then
      shilang(Group_Randomunit(g))
    end
  end
  if Start_Shilang then
    ChangeValue(KillReward_MHp, sy, 1)
    ChangeValue(DamageSystem_Shjc, sy, 0.01)
  else
    ChangeValue(KillReward_MHp, sy, 0.5)
    ChangeValue(DamageSystem_Shjc, sy, 0.005)
  end
  AddAllSTexiao("天之杯", "伤害系统计算效果", function(args)
    local tg = args.tg
    local u = args.u
    local info = args.damageinfo
    if u:ishasbuff("B09O") then
      if Start_Shilang then
        info.lw = info.lw + 0.1
      else
        info.lw = info.lw + 0.05
      end
    end
  end)
  u:uivar_add({
    keyname = "樱初始",
    keytype = "传奇栏",
    text = "|cFFFF33FF天|r|cFFD426DF之|r|cFFA91AC0杯|r\n|cFFD426DF提升0.5%伤害加成\n自身额外提升0.5%伤害加成\n杀敌时提升0.5生命上限|r",
    icon = "war3mapImported\\PASBTNEwl_Sakura_01"
  })
end

function itemc(u)
  local sy = u.ownerid
  local uidc = CIUC[sy]
  if GetRandomInt(1, 520) == 1 and not pdi_hxnv then
    pdi_hxnv = true
    u:setdata("狐仙女友")
    u:sendmessage("|cFFFFCCCC晴天降下的雨|r")
    u:uivar_add({
      keyname = "狐仙女友",
      keytype = "传奇栏",
      text = "|cFFFFD3DB狐|r|cFFFFBDE2仙|r|cFFFFA8E9女|r|cFFFF92F0友|r\n|cFFFFD3DB①有人帮忙精打细算了|r\n|cFFFFBDE2②成长能力提升了|r\n|cFFFFA8E9③运气变得更好了|r\n|cFFFF92F0④被祝福了|r",
      icon = "NewIcon_Yqh",
      ishasphoto = true
    })
  end
  local gl = 1
  if u.type == HeroType["爱丽丝"] then
    gl = 25
  end
  if u:getluckrandom(gl) and not pdi_alicexianjing and u:isgirl() then
    tuzidong(u)
  end
  if ModeSelect_Difficult then
    return
  end
  local id = {
    "1023030663",
    "-2086535450",
    "1932310753",
    "1155201793",
    "-1429600477",
    "4641059"
  }
  if TableContains(id, uidc) then
    local function trg(args)
      if args.chat == "我就是爱丽丝" and Time_M < 2 and not pdi_alicexianjing then
        tuzidong(u)
      end
    end
    
    u:addtrgevent("玩家-聊天", function(args)
      trg(args)
    end)
  end
  if (GetRandomInt(1, 400) == 1 or uidc == "1138730989") and not pdi_urara then
    pdi_urara = true
    u:setdata("乌拉拉-迷路帖")
    u:sendmessage("|cFFFFCCCC想和大家一同前进！|r")
    u:changedata("自然变异补正", 25)
    u:changedata("兽变异补正", 25)
    u:changedata("同奏变异补正", 25)
    local xg = 5
    if uidc == "1138730989" then
      xg = 1
    end
    local tzzq = 0
    ac.loop(3000, function()
      u:changedata("效果增强-兽", -tzzq)
      tzzq = 0.01 * xg * u:getstate("兽变异")
      u:changedata("效果增强-兽", tzzq)
    end)
    if uidc == "1138730989" then
      u:uivar_add({
        keyname = "动物般的少女",
        keytype = "传奇栏",
        text = "|cFFFFFFFF动物|r|cFFFFCCBF般的|r|cFFFF9980少女|r\n|cFFFFFFFF视野能够穿透树林\n提升25%自然变异补正|r\n|cFFFFCCBF提升[1%*兽变异]兽变异效果增强\n提升25%兽变异补正|r\n|cFFFF9980提升25%同奏变异补正|r",
        icon = "war3mapImported\\PASBTNTeshu_Urara"
      })
    else
      u:createrectfogcorrector(RECT_Jiaoqu)
      u:uivar_add({
        keyname = "动物般的少女",
        keytype = "传奇栏",
        text = "|cFFFFFFFF动物|r|cFFFFCCBF般的|r|cFFFF9980少女|r\n|cFFFFFFFF能够穿越树林\n视野能够穿透树林\n提升25%自然变异补正|r\n|cFFFFCCBF提升[5%*兽变异]兽变异效果增强\n提升25%兽变异补正|r\n|cFFFF9980提升25%同奏变异补正|r",
        icon = "war3mapImported\\PASBTNTeshu_Urara"
      })
    end
  end
  if (GetRandomInt(1, 500) == 1 or uidc == "-1735760602" or uidc == "-403162424") and not pdi_yuzaoqian then
    pdi_yuzaoqian = true
    u:setdata("判定-玉藻前")
    u:setdata("玉藻前-永恒的约定")
    u:sendmessage("|cFFFFCCCC这是第几次了？嘛丶算了反正也记不清了。|r")
    if uidc == "-1735760602" or uidc == "-403162424" then
      u:setdata("玉藻前-永恒的约定特殊")
    end
    local mp = 0
    local hp = 0
    ac.loop(3000, function(timer)
      ChangeValue(HeroMenu_MpCure_Inr, sy, -mp)
      ChangeValue(HeroMenu_HpCure_Inr, sy, -hp)
      mp = 0.1 * u:getlevel()
      hp = 1 + 0.2 * u:getlevel()
      ChangeValue(HeroMenu_HpCure_Inr, sy, hp)
      ChangeValue(HeroMenu_MpCure_Inr, sy, mp)
      if not u:hasdata("玉藻前-永恒的约定") then
        ChangeValue(HeroMenu_MpCure_Inr, sy, -mp)
        ChangeValue(HeroMenu_HpCure_Inr, sy, -hp)
        timer:remove()
      end
    end)
    u:uivar_add({
      keyname = "永恒的约定",
      keytype = "传奇栏",
      text = "|cFFFFCCFF永恒的约定|r\n|cFFFFCCFF「第一;一定要爱惜自己」\n「第二;不要忘记吃早餐」\n「第三;偶尔也交交朋友」\n「第四;绝对不要忘记我」\n「第五;一直一直都想和你在一起，不管是这辈子还是下辈子，一直都要在一起。」|r\n|cFF949596by「MIKON」|r",
      icon = "war3mapImported\\PASBTNEwl_Start_Yuzaoqian.blp"
    })
  end
  if uidc == "1932310753" then
    u:setdata("朝武芳乃-初始")
    u:changedata("光明变异数量", 1)
    u:addskill("S0BL")
    ChangeValue(DamageSystem_Ssjianshao, sy, 0.95, 1)
    ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.25)
    ac.wait(1000, function()
      PlayGlobalSound(Sound_Fangnai_10)
      u:chat("|cFFFFCCFF初|r|cFFFFC2FF次|r|cFFFFB8FF见|r|cFFFFADFF面|r")
      ac.wait(1500, function()
        u:chat("|cFFFFCCFF我|r|cFFFFC5FF是|r|cFFFFBDFF朝|r|cFFFFB6FF武|r|cFFFFAFFF芳|r|cFFFFA8FF乃|r")
      end)
      ac.wait(3500, function()
        u:chat("|cFFFFCCFF请|r|cFFFFC4FF多|r|cFFFFBBFF指|r|cFFFFB2FF教|r|cFFFFAAFF~|r")
      end)
    end)
    u:uivar_add({
      keyname = "朝武芳乃初始",
      keytype = "传奇栏",
      text = "|cFFFF99FF气|r|cFFFC9FFC质|r|cFFF9A6F9非|r|cFFF6ACF6凡|r|cFFF3B2F2的|r|cFFF0B9EF巫|r|cFFEDBFEC女|r\n|cFFFF99FF因为你注意到了我，因为你教会了我|r|cFFEDBFEC，我的心情也能好好地传达给你。|r",
      icon = "Ewl_Cwfn_Cs"
    })
  end
  if uidc == "-403162424" then
    SendMsgAll("|cFFFF0000忍|r|cFFFF801A野|r|cFFFFAA22忍|r|cFFFF2A08：『吾乃铁血的，热血的|r|cFFFF5511，冷血的吸血鬼』|r")
    u:setdata("忍野忍-初始")
    u:setdata("忍野忍-初始杀敌计数", 0)
    u:addstexiao("忍野忍初始", "杀敌效果", function(args)
      u:changedata("忍野忍-初始杀敌计数", 1)
      if u:getdata("忍野忍-初始杀敌计数") >= 30 then
        u:changedata("忍野忍-初始杀敌计数", -30)
        u:additem("I0GL")
      end
    end)
    PlayGlobalSound(Sound_Ryr_Start)
    u:addskill("S09U")
    u:uivar_add({
      keyname = "忍野忍初始",
      keytype = "传奇栏",
      text = "|cFFFF0000久远|r|cFFFF401Aの忆|r|cFFFF8033と绊|r\n|cFFFFFF00曾互相伤害的我们，互相舔伤口，不再完美的我们，开始互相追求，如果你明天死，我愿意生命到明天为止，|r\n|cFFCC0000你今天愿意活着，我今天，也要活着，然后不完美者们的故事开始了，\n遍染鲜红，干凝成黑的，血的故事，绝不能说的，我们的，宝贵的伤的故事|r",
      icon = "war3mapImported\\PASBTNEwl_Ryr_Chushi"
    })
  end
  local id = {
    "241989033",
    "-2086535450"
  }
  if TableContains(id, uidc) and not pdi_laonanren then
    pdi_laonanren = true
    PlayGlobalSound(Sound_Lnr_Start)
    u:chat("|cFFF0CAD5要|r|cFFF1CACA不|r|cFFF2CAC0要|r|cFFF2CAB5来|r|cFFF3CAAA和|r|cFFF4CAA0卡|r|cFFF4CB95莉|r|cFFF5CB8A奥|r|cFFF6CB80斯|r|cFFF7CB75特|r|cFFF8CB6A罗|r|cFFF8CB60，|r|cFFF9CB55一|r|cFFFACB4B~|r|cFFFACB40起|r|cFFFBCB35~|r|cFFFCCC2B玩|r|cFFFDCC20~|r|cFFFECC15？|r")
    local elements = {
      "无",
      "光明",
      "黑暗",
      "雷",
      "水",
      "土",
      "炎"
    }
    u:setdata("词条索引", 1)
    u:addskill("S0C7")
    u:uivar_add({
      keyname = "老男人初始",
      keytype = "传奇栏",
      text = "|cFFF0CAD5世|r|cFFF2CABA界|r|cFFF4CAA0第|r|cFFF6CB85一|r|cFFF8CB6A可|r|cFFF9CB50爱|r|cFFFBCC35！|r\n|cFFF0CAD5要|r|cFFF1CACA不|r|cFFF2CABF要|r|cFFF2CAB3来|r|cFFF3CAA8和|r|cFFF4CB9D卡|r|cFFF5CB92莉|r|cFFF6CB87奥|r|cFFF6CB7B斯|r|cFFF7CB70特|r|cFFF8CB65罗|r|cFFF9CB5A，|r|cFFF9CB4E一|r|cFFFACB43~|r|cFFFBCB38起|r|cFFFCCC2D~|r|cFFFDCC22玩|r|cFFFDCC16~？|r",
      icon = "Lnr_01.tga",
      ishasphoto = true,
      clickfunc = function(u, button)
        local index = u:getdata("词条索引")
        local old_element = elements[index]
        index = index % #elements + 1
        u:setdata("词条索引", index)
        local new_element = elements[index]
        if old_element ~= "无" then
          local old_key = old_element .. "变异数量"
          u:changedata(old_key, -1)
        end
        if not u:hasdata("老男人-BGM播放") then
          u:setdata("老男人-BGM播放")
          PlayBGM({
            bgm = BGM_Lnr_Luodi,
            time = 100,
            ID = 211,
            unit = u.handle
          })
        end
        if new_element ~= "无" then
          local key = new_element .. "变异数量"
          local count = u:getdata(key) or 0
          u:changedata(key, 1)
          u:sendmessage(("|cFFF8CB6A当前词条：[ %s ]|r"):format(new_element))
        else
          u:sendmessage("|cFFF8CB6A切换为无词条|r")
        end
      end
    })
    for i = 1, 6 do
      ChangeValue(Correction_Gold, i, 0.025)
      ChangeValue(Correction_Exp, i, 0.05)
      ChangeValue(Correction_MEDCgl, i, 0.05)
    end
    ChangeValue(Correction_Gold, sy, 0.025)
    local ewys = 0
    ac.loop(3000, function()
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -ewys)
      ewys = Ewaishu[sy]
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, ewys)
    end)
  end
  local id = {"1921922654", "134791749"}
  if TableContains(id, uidc) and not pdi_amiya then
    pdi_amiya = true
    u:uivar_add({
      keyname = "阿米娅初始",
      keytype = "传奇栏",
      text = "|cFF6666CC魔|r|cFF5E5EB2王|r|cFF555599的|r|cFF4C4C80冠|r|cFF444466冕|r\n|cFF6666CC我见诸城，满目疮痍|r\n|cFF5F5FB6我见源石，遍布大地|r\n|cFF5757A0我见你，头顶黑冠，将千万生灵，熬成回忆|r\n|cFF50508A我见魔王，将所有种族，尽数服役|r\n|cFF494975年幼的,魔王.....|r\n|cFF42425F会是大地上最可怖的灾难|r",
      icon = "Ewl_Chushi_Amiya_2.tga",
      cd = 10,
      clickfunc = function(u, button)
        if not u:hasdata("阿米娅初始-已触发") then
          u:setdata("阿米娅初始-已触发")
          local strz = {
            "|cFF6666CC『我见诸城，满目疮痍』|r",
            "|cFF5F5FB6『我见源石，遍布大地』|r",
            "|cFF5757A0『我见你，头顶黑冠，将千万生灵，熬成回忆』|r",
            "|cFF50508A『我见魔王，将所有种族，尽数服役』|r",
            "|cFF494975『年幼的,魔王.....』|r",
            "|cFF42425F『会是大地上最可怖的灾难』|r"
          }
          local cs = 0
          ac.timer(3000, #strz, function()
            cs = cs + 1
            SendMsgAll(strz[cs], 10)
          end)
          PlayBGM({
            bgm = Amiya_BGM_01,
            time = 155,
            ID = 204,
            unit = u.handle
          })
        end
      end
    })
  end
  local id = {
    "-1518814144",
    "1457930646",
    "1887206979",
    "-1981285766"
  }
  if TableContains(id, uidc) and not pdi_aluxi then
    pdi_aluxi = true
    u:setdata("阿露希-初始")
    u:uivar_add({
      keyname = "阿露希初始",
      keytype = "传奇栏",
      icon = "Cq_Aluxi_01.tga",
      text = "|cffff80ff祈|r|cffe397fe愿|r|cffc8aefe诗|r|cffacc5fd篇|r\n        |cffff80ff①『少女祈祷ing～』|r\n        |cffc8aefe②『感觉今天会有好事发生～』|r\n        |cffacc5fd③『诶嘿嘿～』|r",
      ishasphoto = true
    })
    NPCChat({
      name = "|cffc8bdfe阿|r|cffe3b4fe露|r|cffffacff希|r",
      chaticon = "Chat_Aluxi.tga",
      chattext = {
        {
          text = "你知道|cffff0000囚徒|r|cff0080ff困境|r吗?",
          time = 0
        },
        {
          text = "是选择|cff0080ff相信|r同伴分享食物",
          time = 3
        },
        {
          text = "还是选择|cffff0000背叛|r同伴掠夺食物",
          time = 6
        },
        {
          text = "|cffc8bdfe『但是，食物就是要大家一起吃才会更好吃啊』|r",
          time = 9
        },
        {
          text = "|cffc8bdfe『大家肯定都会选择分享的』|r",
          time = 12
        }
      }
    })
    u:changedata("幸运", 1)
    ChangeValue(Correction_MEDCgl, sy, 0.05)
    ChangeValue(Correction_Gold, sy, 0.025)
  end
  local id = {
    "-1588123416"
  }
  if TableContains(id, uidc) and not pdi_feiai then
    pdi_feiai = true
    u:adddivinity(1)
    u:addallstats(5)
    u:getgoddessforce(1)
    ChangeValue(Correction_Exp, sy, 0.05)
    ChangeValue(Correction_Gold, sy, 0.025)
    u:setdata("妃爱-初始")
    u:uivar_add({
      keyname = "妃爱初始",
      keytype = "传奇栏",
      icon = "Ewl_Cq_FeiaiChushi.tga",
      text = "|cFFFFCC33和|r|cFFFFA329泉|r|cFFFF7A1F妃|r|cFFFF5214爱|r\n|cFFFF99FF富婆|r\n|cFFFFA6CC学生会会长|r\n|cFFFFB299世界第一一抹多|r"
    })
    ac.wait(10, function()
      u:uivar_change({
        keyname = "妃爱初始",
        keytype = "传奇栏",
        icon = "Ewl_Cq_FeiaiChushi_Big.tga",
        ishasphoto = true,
        size_h = 0.57,
        dx = 4.5,
        cd = 30,
        smallicon = "Ewl_Cq_FeiaiChushi.tga",
        clickfunc = function(u, button)
          if not u:hasdata("妃爱-初始点击") then
            u:setdata("妃爱-初始点击")
            PlayGlobalSound(Sound_Feiai_01)
            NPCChat({
              name = "|cFFFFFF33和|r|cFFFFCC29泉|r|cFFFF991F妃|r|cFFFF6614爱|r",
              chaticon = "Chat_Feiai.tga",
              chattext = {
                {
                  text = "|cffffb0ff我喜欢你，你是世上最棒的人|r",
                  time = 0
                }
              }
            })
            NameID[sy] = "|cFFFFFF33和|r|cFFFFCC29泉|r|cFFFF991F妃|r|cFFFF6614爱|r"
            Boolean_ColorName[sy] = true
            u:setplayername(NameID[sy])
            ColorName[sy][1] = {
              method = 1,
              name = "和泉妃爱",
              colors = {
                "FFFF33",
                "FF6614",
                "FF6614",
                "FFFF33"
              },
              lengthcd = 30,
              offsetspeed = 0.25
            }
          else
            u:deldata("妃爱-初始点击")
            NameID[sy] = "荷包蛋"
            Boolean_ColorName[sy] = false
            u:setplayername(NameID[sy])
          end
        end
      })
    end)
  end
  local id = {
    "1457930646",
    "1921922654",
    "4641059",
    "-1588123416"
  }
  if TableContains(id, uidc) and not pdi_luxifa then
    pdi_luxifa = true
    u:addskill("S0D5")
    u:adddivinity(1)
    ChangeValue(HeroMenu_HpForever_Inr, sy, 3)
    u:setdata("路西法-初始")
    u:uivar_add({
      keyname = "路西法初始",
      keytype = "传奇栏",
      icon = "Cq_Luxifa_01.tga",
      text = "|cFF949596                 『 堕天司 』\n           “天空为何如此湛蓝”\n\n                  「失乐园」\n\n                    『000』|r"
    })
    ac.wait(10, function()
      u:uivar_change({
        keyname = "路西法初始",
        keytype = "传奇栏",
        icon = "Cq_Luxifa_01_Big.tga",
        ishasphoto = true,
        size_h = 0.685,
        dx = 4.5,
        smallicon = "Cq_Luxifa_01.tga",
        jbtext = function()
          UIYNameCount = 4
          UIYName[1] = {
            method = 1,
            name = "『 堕天司 』",
            colors = {
              "FFCC00",
              "949596",
              "949596",
              "949596",
              "FFCC00"
            },
            length = 5,
            lengthcd = 15,
            math = 1,
            offsetspeed = 0.2,
            starttext = "                 ",
            extratext = "\n"
          }
          UIYName[2] = {
            method = 1,
            name = "“天空为何如此湛蓝”",
            colors = {
              "D2E1FF",
              "6897FF",
              "1E3BE0",
              "6897FF",
              "D2E1FF"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.3,
            starttext = "           ",
            extratext = [[


]]
          }
          UIYName[3] = {
            method = 1,
            name = "「失乐园」",
            colors = {
              "9999FF",
              "6633FF",
              "006699",
              "6633FF",
              "9999FF"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.4,
            starttext = "                  ",
            extratext = [[


]]
          }
          UIYName[4] = {
            method = 1,
            name = "『000』",
            colors = {
              "FFD2D2",
              "FF5454",
              "970000",
              "FF5454",
              "FFD2D2"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.5,
            starttext = "                    "
          }
        end
      })
    end)
    PlayGlobalSound(Sound_Luxifa_01)
    NPCChat({
      name = "|cFF666666『|r|cFF6E5555黑|r|cFF774444い|r|cFF803333翼|r|cFF882222』|r|cFF990000Lucifer|r",
      chaticon = "Chat_Luxifa.tga",
      chattext = {
        {
          text = "|cFF990000「|r|cFF950808终|r|cFF901111末|r|cFF8C1A1A」|r|cFF882222不|r|cFF842A2A久|r|cFF803333后|r|cFF7B3C3C就|r|cFF774444将|r|cFF734C4C达|r|cFF6E5555成。|r",
          time = 0
        },
        {
          text = "|cFF660000这么着急来寻死吗。|r",
          time = 4
        }
      }
    })
  end
  local id = {"-48256776"}
  if TableContains(id, uidc) and not pdi_anying then
    pdi_anying = true
    local data = {
      {text = "魔力!", time = 0},
      {
        text = "魔力……",
        time = 3.2
      },
      {text = "魔力!!", time = 5},
      {
        text = "魔力……",
        time = 9.6
      },
      {
        text = "魔力~……",
        time = 11.1
      },
      {text = "魔力", time = 12.7},
      {text = "魔力", time = 13.6},
      {text = "魔力", time = 14.2},
      {text = "魔力", time = 14.6},
      {text = "魔力", time = 14.98},
      {text = "魔力", time = 15.2},
      {text = "魔力", time = 15.6},
      {text = "魔力", time = 16},
      {text = "魔力!", time = 16.39},
      {text = "魔力!!", time = 16.5},
      {text = "魔力!!!", time = 16.7},
      {text = "魔力!!!!", time = 17},
      {
        text = "魔力-----!!",
        time = 17.3
      }
    }
    ac.wait(1000, function()
      PlayGlobalSound(Sound_Anying_Chushi)
      for i, v in ipairs(data) do
        local t = 0
        if 1 < #data then
          t = (i - 1) / (#data - 1)
        end
        local color = "|cFF" .. lerpColor("9999FF", "6600FF", t)
        u:chat(color .. v.text .. "|r", v.time)
      end
    end)
    u:uivar_add({
      keyname = "暗影初始",
      keytype = "传奇栏",
      text = "|cFFCC99FF想|r|cFFB98BFF要|r|cFFA77DFF成|r|cFF946FFF为|r|cFF8261FF影|r|cFF6F53FF之|r|cFF5D46FF实|r|cFF4A38FF力|r|cFF382AFF者|r|cFF251CFF！|r\n\n|cFF6633FF吾|r|cFF662CF0乃|r|cFF6624E2「|r|cFF661DD3暗|r|cFF6616C5影|r|cFF660FB6」|r\n\n|cFF330099『潜|r|cFF421699伏|r|cFF502C99暗|r|cFF5F4299影|r|cFF6D5799之|r|cFF7C6D99中』|r\n\n|cFFCC99FF『狩|r|cFFD3A0DB猎|r|cFFDBA8B6暗|r|cFFE2AF92影|r|cFFE9B66D之|r|cFFF0BD49人』|r",
      icon = "Cq_Yzsl_Cs.tga",
      clickfunc = function(u)
        if u:hasdata("变异判定-暗影大人") then
          return
        end
        local result = herogetvar(u.handle, {
          Vars_Huiyi_Dz
        }, "次元", "暗影大人")
        if result and result ~= "失败" then
          u:changedata("传奇数量", 1)
        end
      end
    })
    ac.wait(100, function()
      u:uivar_change({
        keyname = "暗影初始",
        keytype = "传奇栏",
        text = "|cFFCC99FF想|r|cFFB98BFF要|r|cFFA77DFF成|r|cFF946FFF为|r|cFF8261FF影|r|cFF6F53FF之|r|cFF5D46FF实|r|cFF4A38FF力|r|cFF382AFF者|r|cFF251CFF！|r\n\n|cFF6633FF吾|r|cFF662CF0乃|r|cFF6624E2「|r|cFF661DD3暗|r|cFF6616C5影|r|cFF660FB6」|r\n\n|cFF330099『潜|r|cFF421699伏|r|cFF502C99暗|r|cFF5F4299影|r|cFF6D5799之|r|cFF7C6D99中』|r\n\n|cFFCC99FF『狩|r|cFFD3A0DB猎|r|cFFDBA8B6暗|r|cFFE2AF92影|r|cFFE9B66D之|r|cFFF0BD49人』|r",
        icon = "Cq_Yzsl_Cs_Big.tga",
        smallicon = "Cq_Yzsl_Cs.tga",
        ishasphoto = true,
        dx = 5,
        size_h = 0.64,
        jbtext = function()
          UIYNameCount = 4
          UIYName[1] = {
            method = 1,
            name = "想要成为影之实力者！",
            colors = {
              "CC99FF",
              "251CFF",
              "251CFF",
              "CC99FF"
            },
            length = 5,
            lengthcd = 15,
            math = 1,
            offsetspeed = 0.5,
            extratext = [[


]]
          }
          UIYName[2] = {
            method = 1,
            name = "吾乃「暗影」",
            colors = {
              "6633FF",
              "6609AC",
              "6609AC",
              "6633FF"
            },
            length = 5,
            lengthcd = 15,
            math = 1,
            offsetspeed = 0.4,
            extratext = [[


]]
          }
          UIYName[3] = {
            method = 1,
            name = "『潜伏暗影之中』",
            colors = {
              "330099",
              "7C6D99",
              "7C6D99",
              "330099"
            },
            length = 5,
            lengthcd = 20,
            math = 1,
            offsetspeed = 0.3,
            extratext = [[


]]
          }
          UIYName[4] = {
            method = 1,
            name = "『狩猎暗影之人』",
            colors = {
              "CC99FF",
              "F0BD49",
              "F0BD49",
              "CC99FF"
            },
            length = 5,
            lengthcd = 20,
            math = 1,
            offsetspeed = 0.2,
            extratext = [[


]]
          }
        end
      })
    end)
    u:changedata("幸运", 1)
    ChangeValue(Correction_Exp, sy, 0.1)
    u:setdata("暗影-初始")
    u:addskill("S0CW")
  end
  local id = {"-242050390"}
  if TableContains(id, uidc) and not pdi_mmt then
    pdi_mmt = true
    u:effectadd("Texiao_An_01.mdx", "origin", -1)
    u:uivar_add({
      keyname = "MMT初始",
      keytype = "传奇栏",
      text = "|cFFFF4B4B你说...我是不是哪里错了...\n\n我以为自己做好了准备,能够坦然赴死\n\n可不可以...\n\n拜托你...\n\n求求你...\n\n救救我...！|r",
      icon = "MMT_Chushi.tga",
      cd = 20,
      clickfunc = function(u, button)
        PlayGlobalSound(Sound_MMT_01)
        u:chat("|cFFFF4B4B呐...我是不是哪里错了...")
        u:chat("|cFFFF4B4B呐...我是不是哪里错了...", 5.6)
        u:chat("|cFFFF4B4B呐...", 10)
        u:chat("|cFFFF4B4B拜托你...", 12)
        u:chat("|cFFFF4B4B求求你...", 14.3)
        u:chat("|cFFFF4B4B救救我...！", 16.7)
        ac.wait(14300, function()
          flashphoto({
            photo = "Ph_mmt.tga",
            timeout = 4,
            timehold = 2,
            timein = 4
          })
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:buffset(u.handle, 10, "绝对闪避")
          end)
          u:uivar_change({
            keyname = "MMT初始",
            keytype = "传奇栏",
            text = "|cFFF0E7E0有些少女挺身而出，对抗教会\n\n有些少女四处奔走，传播希望\n\n有些少女坚定不移，相信人性\n\n星星点点，都是微小的光芒……",
            icon = "MMT_Chushi2.tga",
            cd = 250,
            clickfunc = function(u, button)
              PlayBGM({
                bgm = BGM_MMT_01,
                time = 250,
                ID = 248,
                unit = u.handle
              })
              songtext({
                style = "ktv",
                hidetime = 1,
                text = {
                  {
                    starttime = 16.659,
                    str = "Sky 愛は見つからないね",
                    translation = "Sky 我还是没有寻得爱",
                    words = {
                      {
                        str = "Sky ",
                        starttime = 16.659,
                        endtime = 19.111
                      },
                      {
                        str = "愛は",
                        starttime = 19.111,
                        endtime = 19.701
                      },
                      {
                        str = "見つからないね",
                        starttime = 19.701,
                        endtime = 21.457
                      }
                    }
                  },
                  {
                    starttime = 21.514,
                    str = "ぼくはこの星に一人ぼっち",
                    translation = "在这星球上 踽踽独行",
                    words = {
                      {
                        str = "ぼくは",
                        starttime = 21.514,
                        endtime = 23.956
                      },
                      {
                        str = "この星に",
                        starttime = 24.134,
                        endtime = 24.816
                      },
                      {
                        str = "一人ぼっち",
                        starttime = 24.951,
                        endtime = 26.309
                      }
                    }
                  },
                  {
                    starttime = 26.389,
                    str = "Hello? 虚しさの余韻に溶ける",
                    translation = "Hello？融入空虚的余韵中的今夜",
                    words = {
                      {
                        str = "Hello? ",
                        starttime = 26.389,
                        endtime = 28.8405
                      },
                      {
                        str = "虚しさの",
                        starttime = 28.8405,
                        endtime = 30.261
                      },
                      {
                        str = "余韻に",
                        starttime = 30.261,
                        endtime = 31.321
                      },
                      {
                        str = "溶ける",
                        starttime = 31.321,
                        endtime = 33.312
                      }
                    }
                  },
                  {
                    starttime = 33.392,
                    str = "この夜は優しい",
                    translation = "是如此的温柔",
                    words = {
                      {
                        str = "この夜は",
                        starttime = 33.392,
                        endtime = 34.901
                      },
                      {
                        str = "優しい",
                        starttime = 34.901,
                        endtime = 36.188
                      }
                    }
                  },
                  {
                    starttime = 36.268,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 36.268,
                        endtime = 36.746
                      },
                      {
                        str = "lai ",
                        starttime = 36.746,
                        endtime = 37.192
                      },
                      {
                        str = "la ",
                        starttime = 37.192,
                        endtime = 37.501
                      },
                      {
                        str = "Lai ",
                        starttime = 37.501,
                        endtime = 38.023
                      },
                      {
                        str = "lai ",
                        starttime = 38.023,
                        endtime = 38.425
                      },
                      {
                        str = "li",
                        starttime = 38.425,
                        endtime = 38.733
                      }
                    }
                  },
                  {
                    starttime = 38.813,
                    str = "Into my eyes",
                    translation = "进入我眼",
                    words = {
                      {
                        str = "Into ",
                        starttime = 38.813,
                        endtime = 40.111
                      },
                      {
                        str = "my ",
                        starttime = 40.111,
                        endtime = 40.542
                      },
                      {
                        str = "eyes",
                        starttime = 40.542,
                        endtime = 41.175
                      }
                    }
                  },
                  {
                    starttime = 41.255,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 41.255,
                        endtime = 41.703
                      },
                      {
                        str = "lai ",
                        starttime = 41.703,
                        endtime = 42.123
                      },
                      {
                        str = "la ",
                        starttime = 42.123,
                        endtime = 42.413
                      },
                      {
                        str = "Lai ",
                        starttime = 42.413,
                        endtime = 42.934
                      },
                      {
                        str = "lai ",
                        starttime = 42.934,
                        endtime = 43.281
                      },
                      {
                        str = "li",
                        starttime = 43.281,
                        endtime = 43.57
                      }
                    }
                  },
                  {
                    starttime = 43.65,
                    str = "Give me the light",
                    translation = "予我光亮",
                    words = {
                      {
                        str = "Give ",
                        starttime = 43.65,
                        endtime = 44.597
                      },
                      {
                        str = "me ",
                        starttime = 44.597,
                        endtime = 45.101
                      },
                      {
                        str = "the ",
                        starttime = 45.101,
                        endtime = 45.409
                      },
                      {
                        str = "light",
                        starttime = 45.409,
                        endtime = 45.912
                      }
                    }
                  },
                  {
                    starttime = 45.957,
                    str = "見えないほどに降りしきれ",
                    translation = "尽情降下吧 直至视野模糊",
                    words = {
                      {
                        str = "見えない",
                        starttime = 45.957,
                        endtime = 47.451
                      },
                      {
                        str = "ほどに",
                        starttime = 47.451,
                        endtime = 48.739
                      },
                      {
                        str = "降りしきれ",
                        starttime = 48.739,
                        endtime = 51.475
                      }
                    }
                  },
                  {
                    starttime = 51.5,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 51.5,
                        endtime = 51.925
                      },
                      {
                        str = "lai ",
                        starttime = 51.925,
                        endtime = 52.682
                      },
                      {
                        str = "la ",
                        starttime = 52.682,
                        endtime = 52.964
                      },
                      {
                        str = "Lai ",
                        starttime = 52.964,
                        endtime = 53.2895
                      },
                      {
                        str = "lai ",
                        starttime = 53.2895,
                        endtime = 53.612
                      },
                      {
                        str = "li",
                        starttime = 53.612,
                        endtime = 53.814
                      }
                    }
                  },
                  {
                    starttime = 53.859,
                    time = 3.123,
                    str = "Cry through the night",
                    translation = "彻夜哭泣",
                    words = {
                      {
                        str = "Cry ",
                        starttime = 53.859,
                        endtime = 54.351
                      },
                      {
                        str = "through ",
                        starttime = 54.351,
                        endtime = 54.785
                      },
                      {
                        str = "the ",
                        starttime = 54.785,
                        endtime = 55.122
                      },
                      {
                        str = "night",
                        starttime = 55.122,
                        endtime = 55.982
                      }
                    }
                  },
                  {
                    starttime = 68.239,
                    time = 3.889,
                    str = "降りしきれ",
                    translation = "尽情降下吧",
                    words = {
                      {
                        str = "降り",
                        starttime = 68.239,
                        endtime = 68.941
                      },
                      {
                        str = "しきれ",
                        starttime = 68.941,
                        endtime = 71.128
                      }
                    }
                  },
                  {
                    starttime = 77.682,
                    str = "Slight ないものねだりの憂いで",
                    translation = "Slight 在奢求不得的忧郁中",
                    words = {
                      {
                        str = "Slight ",
                        starttime = 77.682,
                        endtime = 80.154
                      },
                      {
                        str = "ないものねだりの",
                        starttime = 80.154,
                        endtime = 81.84
                      },
                      {
                        str = "憂いで",
                        starttime = 81.84,
                        endtime = 82.654
                      }
                    }
                  },
                  {
                    starttime = 82.717,
                    str = "ぼくは振り回されて分かった",
                    translation = "我在被反复折腾后终于明白",
                    words = {
                      {
                        str = "ぼくは",
                        starttime = 82.717,
                        endtime = 84.802
                      },
                      {
                        str = "振り回されて",
                        starttime = 84.802,
                        endtime = 86.651
                      },
                      {
                        str = "分かった",
                        starttime = 86.651,
                        endtime = 87.789
                      }
                    }
                  },
                  {
                    starttime = 87.962,
                    str = "So what? 乾いた色彩で描く",
                    translation = "So what? 以干涸的色彩描绘的谎言",
                    words = {
                      {
                        str = "So what? ",
                        starttime = 87.962,
                        endtime = 90.003
                      },
                      {
                        str = "乾いた",
                        starttime = 90.003,
                        endtime = 91.041
                      },
                      {
                        str = "色彩で",
                        starttime = 91.041,
                        endtime = 92.5015
                      },
                      {
                        str = "描く",
                        starttime = 92.5015,
                        endtime = 94.624
                      }
                    }
                  },
                  {
                    starttime = 94.704,
                    str = "嘘つきは空しい",
                    translation = "是如此的空虚",
                    words = {
                      {
                        str = "嘘つきは",
                        starttime = 94.704,
                        endtime = 96.363
                      },
                      {
                        str = "空しい",
                        starttime = 96.363,
                        endtime = 97.797
                      }
                    }
                  },
                  {
                    starttime = 97.956,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 97.956,
                        endtime = 98.406
                      },
                      {
                        str = "lai ",
                        starttime = 98.406,
                        endtime = 98.92
                      },
                      {
                        str = "la ",
                        starttime = 98.92,
                        endtime = 99.25
                      },
                      {
                        str = "Lai ",
                        starttime = 99.25,
                        endtime = 99.685
                      },
                      {
                        str = "lai ",
                        starttime = 99.685,
                        endtime = 100.146
                      },
                      {
                        str = "li",
                        starttime = 100.146,
                        endtime = 100.379
                      }
                    }
                  },
                  {
                    starttime = 100.412,
                    str = "Into my eyes",
                    translation = "进入我眼",
                    words = {
                      {
                        str = "Into ",
                        starttime = 100.412,
                        endtime = 101.379
                      },
                      {
                        str = "my ",
                        starttime = 101.379,
                        endtime = 101.694
                      },
                      {
                        str = "eyes",
                        starttime = 101.694,
                        endtime = 102.846
                      }
                    }
                  },
                  {
                    starttime = 102.901,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 102.901,
                        endtime = 103.357
                      },
                      {
                        str = "lai ",
                        starttime = 103.357,
                        endtime = 103.836
                      },
                      {
                        str = "la ",
                        starttime = 103.836,
                        endtime = 104.146
                      },
                      {
                        str = "Lai ",
                        starttime = 104.146,
                        endtime = 104.587
                      },
                      {
                        str = "lai ",
                        starttime = 104.587,
                        endtime = 105.045
                      },
                      {
                        str = "li",
                        starttime = 105.045,
                        endtime = 105.361
                      }
                    }
                  },
                  {
                    starttime = 105.362,
                    str = "Give me the dark",
                    translation = "赐我黑暗",
                    words = {
                      {
                        str = "Give ",
                        starttime = 105.362,
                        endtime = 105.791
                      },
                      {
                        str = "me ",
                        starttime = 105.791,
                        endtime = 106.27
                      },
                      {
                        str = "the ",
                        starttime = 106.27,
                        endtime = 106.593
                      },
                      {
                        str = "dark",
                        starttime = 106.593,
                        endtime = 107.139
                      }
                    }
                  },
                  {
                    starttime = 107.197,
                    str = "消えない傷を抱きしめて",
                    translation = "拥抱不会消失的伤痕",
                    words = {
                      {
                        str = "消えない",
                        starttime = 107.197,
                        endtime = 108.716
                      },
                      {
                        str = "傷を",
                        starttime = 108.716,
                        endtime = 109.929
                      },
                      {
                        str = "抱きしめて",
                        starttime = 109.929,
                        endtime = 112.751
                      }
                    }
                  },
                  {
                    starttime = 112.752,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 112.752,
                        endtime = 113.152
                      },
                      {
                        str = "lai ",
                        starttime = 113.152,
                        endtime = 113.626
                      },
                      {
                        str = "la ",
                        starttime = 113.626,
                        endtime = 113.925
                      },
                      {
                        str = "Lai ",
                        starttime = 113.925,
                        endtime = 114.424
                      },
                      {
                        str = "lai ",
                        starttime = 114.424,
                        endtime = 114.746
                      },
                      {
                        str = "li",
                        starttime = 114.746,
                        endtime = 115.1
                      }
                    }
                  },
                  {
                    starttime = 115.115,
                    time = 3.444,
                    str = "Falling the night",
                    translation = "坠入黑夜",
                    words = {
                      {
                        str = "Falling ",
                        starttime = 115.115,
                        endtime = 116.08
                      },
                      {
                        str = "the ",
                        starttime = 116.08,
                        endtime = 116.406
                      },
                      {
                        str = "night",
                        starttime = 116.406,
                        endtime = 117.559
                      }
                    }
                  },
                  {
                    starttime = 129.41,
                    time = 3.382,
                    str = "Falling the night",
                    translation = "坠入黑夜",
                    words = {
                      {
                        str = "Falling ",
                        starttime = 129.41,
                        endtime = 130.619
                      },
                      {
                        str = "the ",
                        starttime = 130.619,
                        endtime = 131.082
                      },
                      {
                        str = "night",
                        starttime = 131.082,
                        endtime = 131.792
                      }
                    }
                  },
                  {
                    starttime = 153.989,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 153.989,
                        endtime = 154.815
                      },
                      {
                        str = "lai ",
                        starttime = 154.815,
                        endtime = 155.392
                      },
                      {
                        str = "la ",
                        starttime = 155.392,
                        endtime = 155.573
                      },
                      {
                        str = "Lai ",
                        starttime = 155.573,
                        endtime = 156.058
                      },
                      {
                        str = "lai ",
                        starttime = 156.058,
                        endtime = 156.534
                      },
                      {
                        str = "li",
                        starttime = 156.534,
                        endtime = 156.788
                      }
                    }
                  },
                  {
                    starttime = 156.849,
                    str = "Into my eyes",
                    translation = "进入我眼",
                    words = {
                      {
                        str = "Into ",
                        starttime = 156.849,
                        endtime = 157.704
                      },
                      {
                        str = "my ",
                        starttime = 157.704,
                        endtime = 158.039
                      },
                      {
                        str = "eyes",
                        starttime = 158.039,
                        endtime = 159.1075
                      }
                    }
                  },
                  {
                    starttime = 159.1635,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 159.1635,
                        endtime = 159.643
                      },
                      {
                        str = "lai ",
                        starttime = 159.643,
                        endtime = 160.079
                      },
                      {
                        str = "la ",
                        starttime = 160.079,
                        endtime = 160.468
                      },
                      {
                        str = "Lai ",
                        starttime = 160.468,
                        endtime = 160.951
                      },
                      {
                        str = "lai ",
                        starttime = 160.951,
                        endtime = 161.438
                      },
                      {
                        str = "li",
                        starttime = 161.438,
                        endtime = 161.667
                      }
                    }
                  },
                  {
                    starttime = 161.692,
                    str = "Give me the light",
                    translation = "予我光亮",
                    words = {
                      {
                        str = "Give ",
                        starttime = 161.692,
                        endtime = 162.152
                      },
                      {
                        str = "me ",
                        starttime = 162.152,
                        endtime = 162.615
                      },
                      {
                        str = "the ",
                        starttime = 162.615,
                        endtime = 162.915
                      },
                      {
                        str = "light",
                        starttime = 162.915,
                        endtime = 163.54
                      }
                    }
                  },
                  {
                    starttime = 163.62,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 163.62,
                        endtime = 164.596
                      },
                      {
                        str = "lai ",
                        starttime = 164.596,
                        endtime = 164.986
                      },
                      {
                        str = "la ",
                        starttime = 164.986,
                        endtime = 165.285
                      },
                      {
                        str = "Lai ",
                        starttime = 165.285,
                        endtime = 165.79
                      },
                      {
                        str = "lai ",
                        starttime = 165.79,
                        endtime = 166.328
                      },
                      {
                        str = "li",
                        starttime = 166.328,
                        endtime = 166.571
                      }
                    }
                  },
                  {
                    starttime = 166.706,
                    str = "Into my eyes",
                    translation = "进入我眼",
                    words = {
                      {
                        str = "Into ",
                        starttime = 166.706,
                        endtime = 167.5
                      },
                      {
                        str = "my ",
                        starttime = 167.5,
                        endtime = 167.807
                      },
                      {
                        str = "eyes",
                        starttime = 167.807,
                        endtime = 168.512
                      }
                    }
                  },
                  {
                    starttime = 168.905,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 168.905,
                        endtime = 169.508
                      },
                      {
                        str = "lai ",
                        starttime = 169.508,
                        endtime = 169.943
                      },
                      {
                        str = "la ",
                        starttime = 169.943,
                        endtime = 170.203
                      },
                      {
                        str = "Lai ",
                        starttime = 170.203,
                        endtime = 170.72
                      },
                      {
                        str = "lai ",
                        starttime = 170.72,
                        endtime = 171.174
                      },
                      {
                        str = "li",
                        starttime = 171.174,
                        endtime = 171.346
                      }
                    }
                  },
                  {
                    starttime = 171.482,
                    str = "Give me the light",
                    translation = "予我光亮",
                    words = {
                      {
                        str = "Give ",
                        starttime = 171.482,
                        endtime = 171.921
                      },
                      {
                        str = "me ",
                        starttime = 171.921,
                        endtime = 172.456
                      },
                      {
                        str = "the ",
                        starttime = 172.456,
                        endtime = 172.77
                      },
                      {
                        str = "light",
                        starttime = 172.77,
                        endtime = 173.157
                      }
                    }
                  },
                  {
                    starttime = 173.279,
                    str = "見えないほどに降りしきれ",
                    translation = "尽情降下吧 直至视野模糊",
                    words = {
                      {
                        str = "見えない",
                        starttime = 173.279,
                        endtime = 174.796
                      },
                      {
                        str = "ほどに",
                        starttime = 174.796,
                        endtime = 175.9
                      },
                      {
                        str = "降りしきれ",
                        starttime = 175.9,
                        endtime = 178.609
                      }
                    }
                  },
                  {
                    starttime = 178.762,
                    str = "Lai lai la Lai lai li",
                    translation = "Lai lai la Lai lai li",
                    words = {
                      {
                        str = "Lai ",
                        starttime = 178.762,
                        endtime = 179.237
                      },
                      {
                        str = "lai ",
                        starttime = 179.237,
                        endtime = 179.856
                      },
                      {
                        str = "la ",
                        starttime = 179.856,
                        endtime = 180.075
                      },
                      {
                        str = "Lai ",
                        starttime = 180.075,
                        endtime = 180.521
                      },
                      {
                        str = "lai ",
                        starttime = 180.521,
                        endtime = 180.985
                      },
                      {
                        str = "li",
                        starttime = 180.985,
                        endtime = 181.22
                      }
                    }
                  },
                  {
                    starttime = 181.261,
                    time = 3.203,
                    str = "Cry through the night",
                    translation = "彻夜哭泣",
                    words = {
                      {
                        str = "Cry ",
                        starttime = 181.261,
                        endtime = 181.642
                      },
                      {
                        str = "through ",
                        starttime = 181.642,
                        endtime = 182.214
                      },
                      {
                        str = "the ",
                        starttime = 182.214,
                        endtime = 182.548
                      },
                      {
                        str = "night",
                        starttime = 182.548,
                        endtime = 183.464
                      }
                    }
                  },
                  {
                    starttime = 217.633,
                    time = 3.766,
                    str = "降りしきれ",
                    translation = "尽情降下吧",
                    words = {
                      {
                        str = "降り",
                        starttime = 217.633,
                        endtime = 218.502
                      },
                      {
                        str = "しきれ",
                        starttime = 218.558,
                        endtime = 220.399
                      }
                    }
                  },
                  {
                    starttime = 222.497,
                    str = "降りしきれ",
                    translation = "尽情降下吧",
                    words = {
                      {
                        str = "降り",
                        starttime = 222.497,
                        endtime = 223.304
                      },
                      {
                        str = "しきれ",
                        starttime = 223.304,
                        endtime = 225.198
                      }
                    }
                  }
                },
                color = {
                  "FF9E9FBA",
                  "FFF080FF",
                  "FF6D9FFC"
                },
                translation_color = "FF9E9FBA"
              })
            end,
            rightclickfunc = function(u, button)
              PlayBGM({
                bgm = BGM_MMT_02,
                time = 230,
                ID = 249,
                unit = u.handle
              })
              songtext({
                style = "ktv",
                hidetime = 1,
                text = {
                  {
                    starttime = 10.216,
                    str = "月夜に 浮かび輝く宝石",
                    translation = "于月夜中浮现的闪耀宝石",
                    words = {
                      {
                        str = "月夜に ",
                        starttime = 10.216,
                        endtime = 12.322
                      },
                      {
                        str = "浮かび",
                        starttime = 12.322,
                        endtime = 13.345
                      },
                      {
                        str = "輝く",
                        starttime = 13.345,
                        endtime = 15.869
                      },
                      {
                        str = "宝石",
                        starttime = 15.869,
                        endtime = 18.761
                      }
                    }
                  },
                  {
                    starttime = 19.926,
                    str = "ほら瞬いてる 遥か彼方に遠くない…ah…",
                    translation = "看吧 光彩熠熠  位于不遥远的遥远彼方…ah…",
                    words = {
                      {
                        str = "ほら",
                        starttime = 19.926,
                        endtime = 20.668
                      },
                      {
                        str = "瞬いてる ",
                        starttime = 20.668,
                        endtime = 23.22
                      },
                      {
                        str = "遥か彼方に",
                        starttime = 23.22,
                        endtime = 26.795
                      },
                      {
                        str = "遠くない…",
                        starttime = 26.795,
                        endtime = 29.965
                      },
                      {
                        str = "ah…",
                        starttime = 29.965,
                        endtime = 32.705
                      }
                    }
                  },
                  {
                    starttime = 33.118,
                    str = "取り巻く運命に 逆らうように",
                    translation = "为了从重重包围的命运逆反而出",
                    words = {
                      {
                        str = "取り巻く運命に ",
                        starttime = 33.118,
                        endtime = 35.691
                      },
                      {
                        str = "逆らうように",
                        starttime = 35.691,
                        endtime = 38.589
                      }
                    }
                  },
                  {
                    starttime = 38.615,
                    str = "ありのまま生きるわ",
                    translation = "随心所欲的活着",
                    words = {
                      {
                        str = "ありのまま",
                        starttime = 38.615,
                        endtime = 40.003
                      },
                      {
                        str = "生きるわ",
                        starttime = 40.003,
                        endtime = 43.583
                      }
                    }
                  },
                  {
                    starttime = 43.715,
                    str = "暗闇 はじまりでも",
                    translation = "即使起点是一片黑暗",
                    words = {
                      {
                        str = "暗闇 ",
                        starttime = 43.715,
                        endtime = 45.313
                      },
                      {
                        str = "はじまりでも",
                        starttime = 45.313,
                        endtime = 48.01
                      }
                    }
                  },
                  {
                    starttime = 48.15,
                    str = "終わりはきっと 光の中にある",
                    translation = "终点也一定  位于光中",
                    words = {
                      {
                        str = "終わりはきっと ",
                        starttime = 48.15,
                        endtime = 50.825
                      },
                      {
                        str = "光の中にある",
                        starttime = 50.825,
                        endtime = 54.429
                      }
                    }
                  },
                  {
                    starttime = 54.456,
                    str = "叶うなら 私はずっと",
                    translation = "若当实现  我会一直",
                    words = {
                      {
                        str = "叶うなら ",
                        starttime = 54.456,
                        endtime = 56.405
                      },
                      {
                        str = "私はずっと",
                        starttime = 56.405,
                        endtime = 59.167
                      }
                    }
                  },
                  {
                    starttime = 59.206,
                    str = "貴方だけを 祈るEtoile",
                    translation = "为你祈祷  Etoile",
                    words = {
                      {
                        str = "貴方だけを ",
                        starttime = 59.206,
                        endtime = 61.94
                      },
                      {
                        str = "祈る",
                        starttime = 61.94,
                        endtime = 62.33
                      },
                      {
                        str = "Etoile",
                        starttime = 62.33,
                        endtime = 65.705
                      }
                    }
                  },
                  {
                    starttime = 65.925,
                    time = 2,
                    str = "♪♪♪♪♪♪",
                    translation = "",
                    words = {}
                  },
                  {
                    starttime = 98.545,
                    str = "夜明けに 包み込む空気 睡蓮",
                    translation = "于破晓时分包裹着的空气",
                    words = {
                      {
                        str = "夜明けに ",
                        starttime = 98.545,
                        endtime = 100.567
                      },
                      {
                        str = "包み込む空気 ",
                        starttime = 100.567,
                        endtime = 103.996
                      },
                      {
                        str = "睡蓮",
                        starttime = 103.996,
                        endtime = 107.578
                      }
                    }
                  },
                  {
                    starttime = 108.667,
                    str = "水面は揺れてる 降り積もる恋ゆらゆら…ah…",
                    translation = "睡莲在水面摇曳  堆叠的恋心也随之摇曳…ah…",
                    words = {
                      {
                        str = "水面は揺れてる ",
                        starttime = 108.667,
                        endtime = 111.723
                      },
                      {
                        str = "降り積もる恋",
                        starttime = 111.723,
                        endtime = 115.203
                      },
                      {
                        str = "ゆらゆら…",
                        starttime = 115.203,
                        endtime = 118.261
                      },
                      {
                        str = "ah…",
                        starttime = 118.261,
                        endtime = 121.112
                      }
                    }
                  },
                  {
                    starttime = 121.305,
                    str = "拙くてもいい 抱えきれない",
                    translation = "即使笨拙也无妨  无法完全抱住",
                    words = {
                      {
                        str = "拙くてもいい ",
                        starttime = 121.305,
                        endtime = 124.129
                      },
                      {
                        str = "抱えきれない",
                        starttime = 124.129,
                        endtime = 126.809
                      }
                    }
                  },
                  {
                    starttime = 126.887,
                    str = "このままじゃいられない",
                    translation = "这样下去可不行",
                    words = {
                      {
                        str = "このままじゃ",
                        starttime = 126.887,
                        endtime = 128.045
                      },
                      {
                        str = "いられない",
                        starttime = 128.045,
                        endtime = 131.793
                      }
                    }
                  },
                  {
                    starttime = 131.977,
                    str = "100年の眠りにつく いばら姫に",
                    translation = "睡了百年的睡美人",
                    words = {
                      {
                        str = "100年の眠りにつく ",
                        starttime = 131.977,
                        endtime = 136.296
                      },
                      {
                        str = "いばら姫に",
                        starttime = 136.296,
                        endtime = 139.036
                      }
                    }
                  },
                  {
                    starttime = 139.178,
                    str = "私はなれそうに ないみたい",
                    translation = "似乎无法类比到自己身上",
                    words = {
                      {
                        str = "私はなれそうに ",
                        starttime = 139.178,
                        endtime = 142.714
                      },
                      {
                        str = "ないみたい",
                        starttime = 142.714,
                        endtime = 144.617
                      }
                    }
                  },
                  {
                    starttime = 144.719,
                    str = "今この瞬間 貴方のこと",
                    translation = "现在这个瞬间  你的一切",
                    words = {
                      {
                        str = "今この瞬間 ",
                        starttime = 144.719,
                        endtime = 147.385
                      },
                      {
                        str = "貴方のこと",
                        starttime = 147.385,
                        endtime = 150.119
                      }
                    }
                  },
                  {
                    starttime = 150.223,
                    str = "溢れるくらい",
                    translation = "满溢而出",
                    words = {
                      {
                        str = "溢れるくらい",
                        starttime = 150.223,
                        endtime = 154.023
                      }
                    }
                  },
                  {
                    starttime = 154.051,
                    time = 2,
                    str = "♪♪♪♪♪♪",
                    translation = "",
                    words = {}
                  },
                  {
                    starttime = 176.156,
                    str = "幾億の星すべてを 投げ捨てても",
                    translation = "即使数亿繁星全部尽数舍弃",
                    words = {
                      {
                        str = "幾億の星すべてを ",
                        starttime = 176.156,
                        endtime = 180.427
                      },
                      {
                        str = "投げ捨てても",
                        starttime = 180.427,
                        endtime = 183.034
                      }
                    }
                  },
                  {
                    starttime = 183.181,
                    str = "信じた夢がある",
                    translation = "也有想要相信的梦",
                    words = {
                      {
                        str = "信じた夢がある",
                        starttime = 183.181,
                        endtime = 186.864
                      }
                    }
                  },
                  {
                    starttime = 186.893,
                    str = "叶うなら 私はずっと",
                    translation = "如果实现的话  我一定",
                    words = {
                      {
                        str = "叶うなら ",
                        starttime = 186.893,
                        endtime = 188.818
                      },
                      {
                        str = "私はずっと",
                        starttime = 188.818,
                        endtime = 191.566
                      }
                    }
                  },
                  {
                    starttime = 191.612,
                    str = "貴方だけの 光るEtoile",
                    translation = "能成为你唯一的光芒Etoile",
                    words = {
                      {
                        str = "貴方だけの ",
                        starttime = 191.612,
                        endtime = 194.322
                      },
                      {
                        str = "光る",
                        starttime = 194.322,
                        endtime = 194.864
                      },
                      {
                        str = "Etoile",
                        starttime = 194.864,
                        endtime = 198.664
                      }
                    }
                  },
                  {
                    starttime = 199.349,
                    time = 2,
                    str = "♪♪♪♪♪♪",
                    translation = "",
                    words = {}
                  }
                },
                color = {
                  "FFC6BCB8",
                  "FFF080FF",
                  "FFCB7385"
                },
                translation_color = "FFC6BCB8"
              })
            end
          })
        end)
      end
    })
  end
  local id = {
    "-1575679099",
    "1463144872",
    "1921922654"
  }
  if TableContains(id, uidc) and not pdi_yangjian then
    pdi_yangjian = true
    u:setdata("杨间-初始")
    u:addskill("S0CU")
    ChangeValue(HeroMenu_HpChange_Inr, sy, 5)
    ChangeValue(Correction_Gold, sy, 0.025)
    u:uivar_add({
      keyname = "灵异终结者",
      keytype = "传奇栏",
      text = "\n     |cFFCC9999我|r|cFFC58383叫|r|cFFBD6D6D鬼|r|cFFB65757眼|r|cFFAF4242杨|r|cFFA82C2C间|r\n                        |cFFCC0000现|r|cFFAF0000在|r|cFF920000正|r|cFF750000式|r|cFF570000上|r|cFF3A0000线|r\n                        ",
      icon = "Cq_Yangjian_Chushi.tga",
      ishasphoto = true
    })
  end
  local id = {
    "1980608290",
    "-1575679099"
  }
  if TableContains(id, uidc) and not pdi_ams then
    pdi_ams = true
    u:setdata("爱弥斯-初始")
    u:changedata("幸运", 1)
    ChangeValue(HeroMenu_HpForever_Inr, sy, 2)
    u:uivar_add({
      keyname = "因与果",
      keytype = "传奇栏",
      text = "|cFFFF99FF因与果，由此相衔|r\n|cFFD68FFF旅途愉快~|r\n|cFFAD85FF但愿我会让你感到骄傲|r\n|cFF857AFF但愿我没有让你失望|r",
      icon = "Chushi_Ams.tga",
      ishasphoto = true
    })
    if uidc == "1980608290" then
      u:uivar_change({
        keyname = "因与果",
        keytype = "传奇栏",
        text = "|cFFFF99FF因与果，由此相衔|r\n|cFFD68FFF旅途愉快~|r\n|cFFAD85FF但愿我会让你感到骄傲|r\n|cFF857AFF但愿我没有让你失望|r",
        icon = "Chushi_AmsBig2.blp",
        ishasphoto = true,
        dx = 4,
        size_h = 1.54,
        smallicon = "Chushi_Ams01.blp"
      })
      ac.wait(120000, function()
        u:uivar_change({
          keyname = "因与果",
          keytype = "传奇栏",
          clickfunc = function(u, button)
            u:uivar_change({
              keyname = "因与果",
              keytype = "传奇栏",
              isclearclick = true
            })
            u:setdata("判定-小小奇迹")
            u:additem("I0Z3")
            NameID[sy] = "|cFFFF99FF爱|r|cffa58cff弥|r|cff6078ff斯|r"
            u:setplayername(NameID[sy])
            Boolean_ColorName[sy] = true
            ColorName[sy][1] = {
              method = 1,
              name = "我希望",
              colors = {
                "FF99FF",
                "3366FF",
                "FF99FF"
              },
              length = 5,
              lengthcd = 25,
              math = 1,
              offsetspeed = 0.5
            }
            transition_phrases({
              name = {
                "我希望",
                "在你未来漫长的生命中",
                "仍旧能够感知悲伤",
                "也能时常觉得幸福",
                "最后这段旅途 能和你一起走",
                "真是太好了！",
                "但愿我会让你感到骄傲",
                "但愿我没有让你失望"
              },
              sy = sy,
              delay = 30,
              pause_time = 3000
            })
          end
        })
      end)
      u:uivar_add({
        keyname = "因与果2",
        keytype = "传奇栏",
        text = "|cFFFF99FF飞行雪绒|r\n|cFFD68FFF|r\n|cFFAD85FF在门后等待的她，某个小小的梦|r\n|cFF857AFF倘若能与你一同，步入那柔软的春风中|r",
        icon = "Chushi_AmsBig.blp",
        ishasphoto = true,
        dx = 4,
        size_h = 1.54,
        smallicon = "Chushi_Ams02.blp"
      })
    else
      u:uivar_change({
        keyname = "因与果",
        keytype = "传奇栏",
        clickfunc = function()
          Boolean_ColorName[sy] = true
          ColorName[sy][1] = {
            method = 1,
            name = "愿光芒永不迷途",
            colors = {
              "FF99FF",
              "3366FF",
              "FF99FF"
            },
            length = 5,
            lengthcd = 25,
            math = 1,
            offsetspeed = 0.5
          }
          transition_phrases({
            name = {
              "愿光芒永不迷途",
              "我愿星火伴你远足",
              "我愿沿途所历风雨皆成祝福",
              "启程深空纬度",
              "愿勇气永不谢幕"
            },
            sy = sy,
            delay = 30,
            pause_time = 3000
          })
        end
      })
    end
  end
  local id = {
    "800328000",
    "-1201977636",
    "1974422401"
  }
  if TableContains(id, uidc) and not pdi_lianlian then
    u:uivar_add({
      keyname = "初始-古明地恋",
      keytype = "传奇栏",
      text = "|cFFC1DAD7明明是觉妖怪一族的象征，\n但是那只眼睛却不知为何紧闭着。|r",
      icon = "Lianlian_Cs.tga",
      ishasphoto = true
    })
    u:setdata("初始判定-古明地恋")
    u:changedata("幸运", 1)
    ChangeValue(Correction_Gold, sy, 0.025)
    ChangeValue(Correction_MEDCgl, sy, 0.05)
    local cs = 0
    cs = 514
    ac.loop(1000, function(timer)
      if u:isalive() then
        cs = cs + 1
        if 514 <= cs and u:hasdata("变异判定-古明地恋") then
          u:additem("I0PF")
          u:uivar_change({
            keyname = "初始-古明地恋",
            keytype = "传奇栏",
            text = "|cFFC2EEE3恋自己闭上了「觉之瞳」，\n在关于妖怪悟心鬼的传说中，\n也有一种说法是人类无意识下的行为弄坏了悟心鬼的眼睛。|r",
            icon = "Lianlian_CsJj.tga",
            ishasphoto = true
          })
          local strname = "古明地恋初始"
          u:setdata("古明地恋-初始进阶")
          u:changedata("系统-神力承载", 2)
          u:changedata("东方变异数量", 1)
          u:changedata("光明变异数量", 1)
          u:changedata("黑暗变异数量", 1)
          u:changedata("唯一变异数量", 1)
          ChangeValue(Correction_Cbxs, sy, 0.25)
          u:addallstats(100)
          u:changedata("全属性增幅", 0.075)
          local g = {}
          u:setdata("古明地恋-符卡特效组", g)
          local jc = 0
          local endsh = 0
          local sx = 0
          ac.loop(1000, function()
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
            ChangeValue(Damage_Element_Heart, sy, -sx)
            ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
            jc = 0.1 * #g
            sx = 0.01 * #g
            if u:hasdata("神化判定-古明地恋2") then
              sx = sx * 2
              jc = jc * 2
            end
            if u:hasdata("神化判定-古明地恋") then
              sx = sx * 2
              jc = jc * 2
            end
            endsh = 0.01 * #g
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
            ChangeValue(Damage_Element_Heart, sy, sx)
            ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
          end)
          local jd = 0
          ac.loop(30, function()
            if u:getdata("古明地恋-符卡数量") > 0 then
              jd = jd + 2
              local x, y = u:getxy()
              local jg = 360 / #g
              local djd = jd
              for i = 1, #g do
                djd = djd + jg
                local dx, dy = PolarXY(x, y, 100 + 25 * #g, djd)
                SetEffectXY(g[i], dx, dy)
              end
            end
          end)
          u:addstexiao(strname, "抗性破坏阶段", function(args)
            local u = args.u
            local tg = args.tg
            local info = args.damageinfo
            if u:hasdata("武器判定-蔷薇之刃") or u:hasdata("物品-蔷薇之刃") then
              info.wsmy = true
            end
          end)
          u:addstexiao(strname, "暴击系统触发效果", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if (u:hasdata("武器判定-蔷薇之刃") or u:hasdata("物品-蔷薇之刃")) and not tg:hasdata("蔷薇之刃-移除特性") then
              tg:setdata("蔷薇之刃-移除特性")
              tg:eliteschange(-1)
            end
          end)
          u:addstexiao(strname, "伤害格挡效果", function(args)
            if not args.b then
              local u = args.u
              if u:getgedangrandom(30) then
                args.b = true
                u:effectadd("Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl", "chest")
              end
            end
          end)
          u:addstexiao(strname, "直接伤害特效", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if u:getluckrandom(5 * info.txgl) and not u:hasdata("古明地恋符卡" .. "-特效冷却") then
              u:settimedata("古明地恋符卡" .. "-特效冷却", 1)
              u:changedata("古明地恋-符卡数量", 1)
              local x, y = u:getxy()
              local tx = Effectcreate("Lianlian_Tx_Huanrao.mdx", x, y, -1, 1, 50)
              g[#g + 1] = tx
              ac.wait(10000, function()
                u:changedata("古明地恋-符卡数量", -1)
                DestroyEffectLua(g[#g])
                g[#g] = nil
              end)
            end
          end)
          u:addstexiao(strname, "暴击系统计算效果", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if u:hasdata("古明地恋-必暴") then
              info.iscbcrit = true
            end
          end)
          local dcs = 0
          ac.loop(1000, function()
            if u:isalive() then
              dcs = dcs + 1
              if 5 <= dcs then
                dcs = 0
                local count = GetRandomInt(3, 8)
                local g = CreateGroupLua()
                local x, y = u:getxy()
                for _, xq in ac.selector():in_rangexy(x, y, 2000):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                end
                ForGroupLuaNew(Group_Randomunits(g, count), function(xq)
                  local x, y = u:getxy()
                  local x2, y2 = xq:getxy()
                  local angle = AngleXY(x, y, x2, y2)
                  unifycreate({
                    owner = u.handle,
                    model = "Lianlian_Tx_Dm.mdx",
                    modelname = "恋恋-心之弹幕",
                    modelsize = 1,
                    height = 50,
                    damage = 0,
                    damagetype = 2,
                    x = x,
                    y = y,
                    range = 3000,
                    time = 1,
                    volume = 85,
                    angle = angle,
                    angleoffset = 0,
                    attenua = 1,
                    attenuacount = 1,
                    life = 10,
                    isbullet = false,
                    isvest = true,
                    isignorearmor = false,
                    startfunc = function(mj)
                    end,
                    loopfunc = function(mj)
                    end,
                    hitfunc = function(mj, damage)
                      return damage
                    end,
                    hitbeforefunc = function(mj, xq, damage2)
                      return damage2
                    end,
                    hitafterfunc = function(mj, xq, damage2)
                    end,
                    endfunc = function(mj)
                      local txsh = 150 * u:getlevel() + 100 * u:getallattri()
                      local x3, y3 = mj:getxy()
                      for _, xq in ac.selector():in_rangexy(x3, y3, 150):is_enemy(u.handle):ipairs() do
                        xq = getunit(xq)
                        DamageUnit({
                          bj = "古明地恋-心之弹幕",
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 1,
                          type = "物理",
                          isvest = true,
                          isattack = false,
                          isnoarmor = false,
                          element = "心灵",
                          extradata = {
                            "古明地恋-必暴"
                          }
                        })
                      end
                    end
                  })
                end)
              end
            end
          end)
          timer:remove()
        end
      else
        cs = 0
      end
    end)
  end
  local id = {
    "1787153005",
    "-1057334134",
    "-1413566993",
    "1727559346",
    "-933485982",
    "2011283003",
    "-1444060667"
  }
  if (TableContains(id, uidc) and GetRandom100(2) or uidc == "1726349655" and Time_TenSecond or GetRandomInt(1, 500) == 1) and u:isgirl() and not Chushi_Murasame then
    Chushi_Murasame = true
    u:getgoddessforce(1)
    u:setdata("丛雨")
    Qiyue_Murasame_Self = u.handle
    ac.loop(960000, function()
      u:adddivinity(1)
    end)
    
    local function trg(args)
      if args.chat == "锁魂" and not u:hasdata("丛雨-神化") and not u:hasdata("丛雨锁魂") and Hero_Shenhua_Now[sy] == 0 then
        u:setdata("丛雨锁魂")
        u:setdata("锁魂计数", 0)
        u:sendmessage("|cFF66FF99进入锁魂状态|r")
        ac.loop(3000, function(timer)
          if Hero_Shenhua_Left[sy] > 0 and not u:hasdata("丛雨-神化") then
            ChangeValue(Hero_Shenhua_Left, sy, -1)
            u:changedata("锁魂计数", 1)
            u:sendmessage("|cFF66FF99锁魂计数：" .. u:getdata("锁魂计数"))
          end
          if u:hasdata("丛雨-神化") then
            if 1 <= u:getdata("锁魂计数") then
              ChangeValue(Hero_Shenhua_Left, sy, u:getdata("锁魂计数"))
              u:sendmessage("|cFF66FF99解魂计数：" .. u:getdata("锁魂计数"))
            end
            timer:remove()
          end
        end)
      end
    end
    
    u:addtrgevent("玩家-聊天", function(args)
      trg(args)
    end)
    ac.wait(3000, function()
      local sj = GetRandomInt(1, 3)
      if sj == 1 then
        u:playselfsound(Sound_Murasame_01)
        u:sendmessage("|cFF66FF99「除了月亮你以外」|r")
        ac.wait(2300, function()
          u:sendmessage("|cFF66FF99「大家都先于吾辈而去了…」|r")
        end)
        ac.wait(5800, function()
          u:sendmessage("|cFF66FF99「要哭的话」|r")
        end)
        ac.wait(7700, function()
          u:sendmessage("|cFF66FF99「就只能是在你面前」|r")
        end)
        ac.wait(10900, function()
          u:sendmessage("|cFF66FF99「早就这样决定了…」|r")
        end)
      end
      if sj == 2 then
        u:playselfsound(Sound_Murasame_02)
        u:sendmessage("|cFF66FF99「父亲大人…」|r")
        ac.wait(2700, function()
          u:sendmessage("|cFF66FF99「母亲大人…」|r")
        end)
        ac.wait(5000, function()
          u:sendmessage("|cFF66FF99「请您们在天上看着吾辈…」|r")
        end)
        ac.wait(7800, function()
          u:sendmessage("|cFF66FF99「看着绫…」|r")
        end)
      end
      if sj == 3 then
        u:playselfsound(Sound_Murasame_03)
        ac.wait(3100, function()
          u:sendmessage("|cFF66FF99「月亮啊…」|r")
        end)
        ac.wait(5400, function()
          u:sendmessage("|cFF66FF99「也就只有你没有变过了…」|r")
        end)
        ac.wait(12200, function()
          u:sendmessage("|cFF66FF99「都已经不记得了…」|r")
        end)
        ac.wait(16300, function()
          u:sendmessage("|cFF66FF99「当时一起生活过的人，如今都已经不在了…」|r")
        end)
      end
    end)
    ac.loop(250, function(timer)
      if not u:hasdata("丛雨锁魂") and not u:hasdata("丛雨-神化") and Hero_Shenhua_Now[sy] > 0 then
        if GetRandom100(50) then
          PlayGlobalSound(Sound_Murasame_04)
          SendMsgAll("|cFF66FF99「已经不需要再管吾辈了,回去吧」|r")
        else
          PlayGlobalSound(Sound_Murasame_06)
          SendMsgAll("|cFF66FF99「能拉吾辈一把的男人，这世上可是没有的喔~」|r")
        end
        u:uivar_change({
          keyname = "丛雨初始",
          keytype = "传奇栏",
          text = "|cFF66FF99永恒|r|cFF4CBF73轮回|r|cFF33804C的观测|r\n|cFF4CBF73神性 0\n每隔960秒提升1点神性\n每次队友死亡永久增加自身0.1%伤害加成与1点全属性|r\n|cFF949596你这样是不会有小丛雨喜欢你的！|r",
          icon = "war3mapImported\\PASBTNMurasame_Guance_Wuhouxu"
        })
        Boolean_Murasame[1] = true
        timer:remove()
      end
      if u:hasdata("丛雨-神化") then
        timer:remove()
      end
      if Boolean_Murasame[3] and not u:hasdata("丛雨-神化") and (u:ishasshw() or 0 < u:getdata("锁魂计数")) then
        AdvanceGet["丛雨神化"](u)
        timer:remove()
      end
    end)
    u:uivar_add({
      keyname = "丛雨初始",
      keytype = "传奇栏",
      text = "|cFF66FF99永恒|r|cFF4CBF73轮回|r|cFF33804C的观测|r\n|cFF4CBF73神性 0\n每隔960秒提升1点神性\n每次队友死亡永久增加自身0.1%伤害加成与1点全属性\n输入\"锁魂\"禁止自身任何神化(包括再神化)可能,无法取消|r\n|cFF949596by云希|r",
      icon = "war3mapImported\\PASBTNMurasame_Guance"
    })
  end
  local id = {"2011283003"}
  if TableContains(id, uidc) then
    u:addskill("S08O")
    ChangeValue(Correction_Exp, sy, 0.05)
    u:uivar_add({
      keyname = "樱巫女",
      keytype = "传奇栏",
      text = "|cFFCA5C5D樱|r|cFFCA3C6E巫|r|cFFBB464C女|r\n|cFFBB464C手|r|cFF51213B如|r|cFFBB464C柔荑，|r\n |cFFBB464C肤|r|cFF51213B如|r|cFFBB464C凝脂，|r\n  |cFFBB464C领|r|cFF51213B如|r|cFFBB464C蝤蛴，|r\n   |cFFBB464C齿|r|cFF51213B如|r|cFFBB464C瓠犀，|r\n  |cFFCA3C6E螓首|r|cFFBB464C蛾眉，|r\n |cFFBB464C巧笑|r|cFFCA3C6E倩兮，|r\n|cFFCA3C6E美目|r|cFFBB464C盼兮。|r",
      icon = "war3mapImported\\PASBTNChushi_10"
    })
  end
  local id = {"1887206979"}
  if TableContains(id, uidc) then
    u:setdata("特殊判定-百百初始")
    u:addskill("S0BE")
    ChangeValue(Correction_Exp, sy, 0.05)
    ChangeValue(DamageSystem_Shjc, sy, 0.005)
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 10)
    u:uivar_add({
      keyname = "末世歌谣",
      keytype = "传奇栏",
      text = "|cFFCCCCCC末|r|cFFC2C2C2世|r|cFFB8B8B8歌|r|cFFADADAD谣|r\n|cFF999999正体不明|r\n|cFFCCCCCC[与这个世界中的一切高度契合，尽管她并不理解]|r\n|cFF999999遗留之物|r\n|cFFCCCCCC[她究竟留下了什么？]\n[因为，她根本没有在任何地方留下东西]|r\n|cFF999999真名解放|r\n|cFFCCCCCC[数据无权限阅览]|r\n|cFF949596你似乎曾经在哪里见到过她，但究竟是在哪里呢...|r",
      icon = "Ewl_Momo_Cs_2"
    })
  end
  local id = {"1922110331", "-433111054"}
  if TableContains(id, uidc) and not pdi_huolingmeng then
    pdi_huolingmeng = true
    u:setdata("特殊判定-祸灵梦")
    u:addskill("A0G8")
    ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.25)
    PlayGlobalSound(Sound_Hlm_Get_Med)
    SendJbMsgAll({
      strstart = "|cFF990000『",
      strz = "哼哼哼哼哼哼哼",
      strend = "』|r",
      time = 2.2,
      shunxu = 1,
      waittime = 0.15
    })
    SendJbMsgAll({
      strstart = "|cFF990000『",
      strz = "嗯哼哼哼哼哼哼哼",
      strend = "』|r",
      time = 3,
      shunxu = 1,
      waittime = 3.3,
      origintext = "|cFF990000『哼哼哼哼哼哼哼』|r"
    })
    u:uivar_add({
      keyname = "祸灵梦初始",
      keytype = "传奇栏",
      text = "|cFFCC0000魔|r|cFFA30000神|r|cFF7A0000降|r|cFF520000诞|r",
      icon = "Ewl_Hlm_Cs"
    })
  end
  local id = {
    "710193797",
    "-1792202961",
    "749425507"
  }
  if TableContains(id, uidc) and not pdi_xyzqjianshi then
    pdi_xyzqjianshi = true
    u:setdata("特殊判定-学院最强剑士")
    u:addskill("A1E2")
    for i = 1, 6 do
      ChangeValue(HeroMenu_HpForever_Inr, i, 5)
    end
    u:uivar_add({
      keyname = "椿初始",
      keytype = "传奇栏",
      text = "|cFFCCFFFF学院|r|cFFD9BFBF最强の|r|cFFE68080剑士|r\n|cFFD9BFBF提升[5+0.5*等级]点伤害吸血\n提升全队5点生命恢复|r\n|cFF949596被“朱雀院”之名束缚，追求最强之名。脸上总是保持着笑容，即使生气的时候也是笑着发怒。\n在恋爱中追求主动地位，保持着身为”姐姐”的自尊，独占欲强。|r",
      icon = "war3mapImported\\PASBTNEwl_Chun_01"
    })
  end
  local id = {
    "710193797",
    "-1792202961",
    "749425507"
  }
  if TableContains(id, uidc) and not pdi_zz then
    pdi_zz = true
    u:setdata("特殊判定-宇智波复仇者")
    u:setdata("佐助-复仇值", 0)
    ac.loop(60000, function()
      u:changedata("佐助-复仇值", 1)
    end)
    u:addskill("S087")
    ChangeValue(Hero_Tili_Huifu, sy, 0.05)
    PlayGlobalSound(Sound_ZZ__9_u)
    ac.wait(800, function()
      SendMsgAll("  |cff00f7f7去|r|cff1dcdf9外|r|cff3ba3fa面|r|cff587afc试|r|cff7650fd试|r|cff9326ff吧|r      ")
    end)
    ac.wait(3200, function()
      SendMsgAll("  |cff9326ff这|r|cff6e36f3双|r|cff4a46e6眼|r|cff2557da睛|r")
    end)
    ac.wait(5800, function()
      SendMsgAll("  |cffff0000能|r|cffd2070e够|r|cffa60f1c洞|r|cff79162a穿|r|cff4d1e38黑|r|cff202546暗|r")
    end)
    u:uivar_add({
      keyname = "佐助初始",
      keytype = "传奇栏",
      text = "|cFF6666FF宇智波の复仇者|r\n|cFF6666FF提升5%移速\n提升0.05体力恢复|r\n|cFF949596我早已闭上了双眼，我的目的只有在黑暗中才能实现。|r",
      icon = "war3mapImported\\PASBTNEwl_Zz_01.tga"
    })
  end
  if uidc == "4641059" then
    u:setdata("特殊判定-翼")
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
    ChangeValue(Correction_Exp, sy, 0.05)
    u:sendmessage("|cFFFF9900你收到了来自世界之“翼”的邀请|r")
    ac.wait(1000, function()
      if u:islocal() then
        UI_YisiChat:set_normal_image("UI_Chat_Angle.tga")
      end
      local strz = {
        "通讯连线中————",
        "主管，您好。真心欢迎您加入脑叶公司。",
        "如您所知，我司是一家专攻能源生产的公司。",
        "身为一名能源公司的主管，其职责自然是收集能源。",
        "请您牢记一点。身为一家能源公司的主管，您只需专注于能源生产。",
        "无论是员工还是文职，他们都是可以牺牲掉的。",
        "现在，让我们正式开始管理工作吧。"
      }
      for index, value in ipairs(strz) do
        YisiSystem.chat({
          u = u,
          text = value,
          breaktime = 3,
          priority = 2
        })
      end
      ac.wait(30000, function()
        if u:islocal() then
          UI_YisiChat:set_normal_image("UI_Chat_ICON.tga")
        end
      end)
    end)
    u:uivar_add({
      keyname = "翼初始",
      keytype = "传奇栏",
      text = "|cFFFFFF00翼|r\n|cFFFF9900以“世界需要科技”为由，一些公司使用了例如:永不停歇的食品生产线、随意定制创造需要的生物、\n将时间稳定在当前，等等此类打破那看似绝对的物理法则而出现的新技术。\n这些被称为“奇点”的技术表面上看似是在加速世界的发展，然而万物的背后都会有代价，\n但这些被称为世界之“翼”的公司却没能意识到——正向着太阳扑腾翅膀的它们，羽毛正在融化。\n很快，每个人都会想回到一片虚无当中，回到人类诞生前的，那片绝对的寂静之中。|r",
      icon = "war3mapImported\\PASBTNBaoming_Yi"
    })
  end
  local id = {
    "1023030663",
    "-1588123416"
  }
  if TableContains(id, uidc) and not pdi_alice then
    pdi_alice = true
    local cs = 0
    ac.loop(1000, function(timer)
      cs = cs + 1
      if u:getoriginint() >= 5 then
        u:setdata("特殊判定-爱丽丝初始")
        u:addstexiao("特殊判定-爱丽丝初始", "英雄升级时效果", function(args)
          u:addint(1)
          ChangeValue(Correction_MEDCgl, sy, 0.001)
        end)
        SendMsgAll("|cFFFFFF00『|r|cFFF5FA13老|r|cFFEBF525子|r|cFFE1F038就|r|cFFD7EB4A是|r|cFFCDE65D爱|r|cFFC3E16F丽|r|cFFB9DC82丝|r|cFFAFD794！|r|cFFA5D2A7！|r|cFF9BCDB9！|r|cFF91C8CC』|r")
        PlayGlobalSound(ailisi2)
        u:uivar_add({
          keyname = "梦游仙境",
          keytype = "传奇栏",
          text = "|cFF990000梦境体\n升级时提升0.1%药水成功率\n升级时提升1点智力|r",
          icon = "war3mapImported\\BTNEwl_Alice_02.tga"
        })
        timer:remove()
      end
      if cs == 120 then
        timer:remove()
      end
    end)
  end
  if uidc == "-1730738540" then
    u:setdata("特殊判定-桔梗初始")
    ChangeValue(Correction_Exp, sy, 0.05)
    u:addskill("S08K")
    u:sendmessage("|cFFCC66FF爱|r|cFFC56AFF也|r|cFFBD6DFF好|r|cFFB671FF，|r|cFFAF75FF恨|r|cFFA878FF也|r|cFFA07CFF罢|r|cFF997FFF.|r|cFF9283FF.|r|cFF8A87FF.|r|cFF838AFF.|r|cFF7C8EFF.|r|cFF7592FF.|r")
    ac.wait(3000, function()
      u:sendmessage("|cFFCC66FF比|r|cFFC768FF起|r|cFFC26BFF当|r|cFFBD6DFF时|r|cFFB970FF，|r|cFFB472FF现|r|cFFAF75FF在|r|cFFAA77FF我|r|cFFA579FF的|r|cFFA07CFF灵|r|cFF9B7EFF魂|r|cFF9781FF更|r|cFF9283FF加|r|cFF8D86FF地|r|cFF8888FF随|r|cFF838AFF心|r|cFF7E8DFF所|r|cFF798FFF欲|r|cFF7592FF了|r|cFF7094FF。|r")
    end)
    u:uivar_add({
      keyname = "桔梗初始",
      keytype = "传奇栏",
      text = "|cFFCC66FF巫女|r\n|cFFCC66FF提升5%经验获取率|r\n|cFF949596带着强大灵力出生的女子。成为巫女，以纯洁的心净化四魂之玉，将私欲隐藏于内心，持续与众多的妖怪战斗。|r",
      icon = "war3mapImported\\PASBTNTeshu_Jg_S"
    })
  end
  local id = {
    "-1691194058",
    "-808583347",
    "1932310753"
  }
  if TableContains(id, uidc) and not pdi_hf then
    pdi_hf = true
    local hf_choice_removed = false
    
    local function remove_hf_choice()
      if hf_choice_removed then
        return
      end
      hf_choice_removed = true
      u:uivar_remove("HF-间桐樱", "传奇栏")
      u:uivar_remove("HF-卫宫士郎", "传奇栏")
    end
    
    local function choose_sakura(u)
      remove_hf_choice()
      local b = true
      if Start_Sakura then
        b = false
        u:sendmessage("|cFFFF0000已|r|cFFFF2640存|r|cFFFF4C80在|r")
      end
      if u:hasdata("变异判定-正义的伙伴") then
        b = false
        u:sendmessage("|cFFFF0000冲|r|cFFFF111C突|r|cFFFF2239：|r|cFFFF3355正|r|cFFFF4471义|r|cFFFF558E的|r|cFFFF66AA伙|r|cFFFF77C6伴|r")
      end
      if b then
        u:setdata("判定-间桐樱")
        jiantongying(u)
      end
    end
    
    local function choose_shilang(u)
      remove_hf_choice()
      local b = true
      if Start_Shilang then
        b = false
        u:sendmessage("|cFFFF0000已|r|cFFFF2640存|r|cFFFF4C80在|r")
      end
      if u:hasdata("特殊判定-天之杯") then
        b = false
        u:sendmessage("|cFFFF0000冲|r|cFFFF1624突|r|cFFFF2C49：|r|cFFFF426D天|r|cFFFF5792之|r|cFFFF6DB6杯|r")
      end
      if b then
        u:setdata("判定-卫宫士郎")
        shilang(u)
      end
    end
    
    u:uivar_add({
      keyname = "HF-间桐樱",
      keytype = "传奇栏",
      text = "|cFFFF33FF间桐樱|r\n|cFFD426DF选择后获得[天之杯]初始|r\n|cFF949596点击后会同时移除另一个选择|r",
      icon = "war3mapImported\\PASBTNEwl_Sakura_01",
      clickfunc = function(u, button)
        choose_sakura(u)
      end
    })
    u:uivar_add({
      keyname = "HF-卫宫士郎",
      keytype = "传奇栏",
      text = "|cFFFF0000卫宫士郎|r\n|cFFFF6600选择后获得[正义的伙伴]初始|r\n|cFF949596点击后会同时移除另一个选择|r",
      icon = "war3mapImported\\PASBTNEwl_Teshu_Shilang",
      clickfunc = function(u, button)
        choose_shilang(u)
      end
    })
  end
  if uidc == "-587063853" and not Start_Sakura then
    jiantongying(u)
  end
  if (uidc == "848356535" or GetRandomInt(1, 366) == 1) and not Start_Shilang and u.type ~= HeroType["切嗣"] then
    shilang(u)
  end
  local id = {
    "713427182",
    "-403162424",
    "1932310753",
    "-1800543239"
  }
  if (TableContains(id, uidc) or GetRandomInt(1, 432) == 1) and not pdi_tz then
    pdi_tz = true
    u:sendmessage("|cFF3399FF我，对无聊的天人生活已经忍无可忍了|r")
    u:setdata("绯想天-天子")
    u:adddivinity(1)
    u:addskill("S05A")
    local cs = 0
    local xy = 0
    ac.loop(3000, function()
      cs = cs + 1
      if cs == 20 then
        cs = 0
        u:clearbuff()
      end
      u:changedata("幸运", -xy)
      xy = 0.25 * u:getshenxing() + 0.08 * u:getlevel()
      u:changedata("幸运", xy)
    end)
    if TableContains(id, uidc) then
      local jl = 0
      local dx, dy = u:getxy()
      ac.loop(1000, function(timer)
        local dx2, dy2 = u:getxy()
        local dis = DistanceXY(dx, dy, dx2, dy2)
        if 500 <= dis then
          dis = 500
        end
        jl = jl + dis
        if 30000 <= jl then
          SendMsgAll("|cFF6699FF『|r|cFF7395FF以|r|cFF8090FF人|r|cFF8C8CFF之|r|cFF9988FF心|r|cFFA684FF行|r|cFFB280FF走|r|cFFBF7BFF于|r|cFFCC77FF世|r|cFFD973FF间|r|cFFE66EFF』|r")
          ChangeValue(Correction_Exp, sy, 0.05)
          for index, value in ipairs(Pools_Spe) do
            if value.name == "要石" then
              if not value.hasbeenget then
                local item = u:additem("I09L")
                value.hasbeenget = true
              end
              break
            end
          end
          timer:remove()
        end
        dx, dy = u:getxy()
      end)
    end
    u:uivar_add({
      keyname = "天子初始",
      keytype = "传奇栏",
      text = "|cFF3399FF绯想般|r|cFF6699FF远离尘世|r|cFF9999FF的天人|r\n|cFF3399FF神性 1|r\n|cFF6699FF提升[神性*0.25+等级*0.08]幸运|r\n|cFF9999FF每隔60秒清除自身负面状态|r\n|cFF949596人之心|r",
      icon = "war3mapImported\\PASBTNTeshu_Tianren"
    })
  end
  local id = {
    "-2086535450",
    "-1062447428",
    "-1013633388"
  }
  if TableContains(id, uidc) and not pdi_leilv then
    pdi_leilv = true
    u:uivar_add({
      keyname = "雷律初始",
      keytype = "传奇栏",
      text = "|cFF8C46A0正|r|cFFAB81BB义|r\n|cFFAD83BA光|r|cFF8C46A0明|r\n|cFFFFFFFF①|r|cFFE2CAF8誓|r|cFFC495F0约|r\n|cFF3399FF②|r|cFF3973DF雷|r|cFF3F4CC0魂|r\n|cFF4B0080③|r|cFF5B0B98天|r|cFF6A16B1启|r\n|cFF8A2BE2救|r|cFF8527DA世|r|cFF8024D2之|r|cFF7A20CA道|r|cFF751DC1，|r|cFF7019B9即|r|cFF6A15B1为|r|cFF6512A9「|r|cFF600EA1正|r|cFF5B0B99义|r|cFF560790」|r",
      icon = "Ewl_LeilvNew_02",
      clickfunc = function(u, button)
        if not u:hasdata("雷律初始点击") then
          u:setdata("雷律初始点击")
          ac.wait(55000, function()
            if u:getdata("雷律点击次数") == 1 then
              ac.wait(5000, function()
                if u:getdata("雷律点击次数") == 2 then
                  ac.wait(55000, function()
                    if u:getdata("雷律点击次数") == 2 then
                      ac.wait(5000, function()
                        if u:getdata("雷律点击次数") == 3 then
                          u:sendmessage("|cFF8A2BE2救|r|cFF8527DA世|r|cFF8024D2之|r|cFF7A20CA道|r|cFF751DC1，|r|cFF7019B9即|r|cFF6A15B1为|r|cFF6512A9「|r|cFF600EA1正|r|cFF5B0B99义|r|cFF560790」|r")
                          u:setdata("特殊判定-雷律初始")
                          u:changedata("光明变异数量", 1)
                          local hp = 0
                          ac.loop(3000, function(timer)
                            ChangeValue(HeroMenu_HpChange_Inr, sy, -1 * hp)
                            hp = 2 + 3.0E-4 * u:getmaxhp() * u:getstate("雷变异")
                            ChangeValue(HeroMenu_HpChange_Inr, sy, 1 * hp)
                          end)
                          local cs = 0
                          ac.loop(1200000, function(timer)
                            cs = cs + 1
                            u:sendmessage("|cFF7C76D6雷|r|cFF6053AE魂|r")
                            u:changedata("雷变异数量", 1)
                            if cs == 3 then
                              timer:remove()
                            end
                          end)
                        else
                          u:sendmessage("|cFF8C46A0正|r|cFFAB81BB义|r")
                        end
                      end)
                    else
                      u:sendmessage("|cFF5B0B98天|r|cFF6A16B1启|r")
                    end
                  end)
                else
                  u:sendmessage("|cFF3973DF雷|r|cFF3F4CC0魂|r")
                end
              end)
            else
              u:sendmessage("|cFFE2CAF8誓|r|cFFC495F0约|r")
            end
          end)
        end
        u:changedata("雷律点击次数", 1)
      end
    })
  end
  local id = {
    "-1013633388",
    "873810818",
    "-565684037",
    "241989033"
  }
  if TableContains(id, uidc) and not pdi_angela then
    pdi_angela = true
    u:setdata("特殊判定-安吉拉初始")
    u:addstexiao("安吉拉初始", "决死效果", function(args)
      if args.dt and not u:hasdata("安吉拉初始-决死冷却") then
        args.dt = false
        SendMsgAll("|cFF6699FF『|r|cFF5C8AFF重|r|cFF527AFF新|r|cFF476BFF开|r|cFF3D5CFF始|r|cFF334CFF这|r|cFF293DFF一|r|cFF1F2EFF天|r|cFF141FFF』|r")
        u:settimedata("安吉拉初始-决死冷却", 1800)
        u:sethp(100, true)
        u:buffset(u.handle, 1, "无敌")
      end
    end)
    u:uivar_add({
      keyname = "安吉拉初始",
      keytype = "传奇栏",
      text = "|cFF8BB8CB脑叶|r|cFFA2C6D5公司|r|cFFB9D4E0的|r|cFFD1E3EA助手|r\n|cFF8BB8CB你|r|cFF92BCCE好|r|cFF99C0D1，|r|cFF9FC5D4主|r|cFFA6C9D7管|r|cFFADCDDA，|r|cFFB4D1DD你|r|cFFBBD5E0可|r|cFFC2D9E3以|r|cFFC8DEE7相|r|cFFCFE2EA信|r|cFFD6E6ED的|r|cFFDDEAF0只|r|cFFE4EEF3有|r|cFFEBF2F6我|r|cFFF1F7F9。|r",
      icon = "PASBTNAngela_02"
    })
    local bb = getunit(Beibao[sy])
    
    local function chattrg(args)
      if args.chat == "我要继续活下去" and u:isalive() and u:ishasitem("I0J5") and u:hasdata("判定-安吉拉") then
        local wp = u:getitem("I0J5")
        if GetItemCharges(wp) >= 500 then
          u:removeitem(wp)
          u:additem("I0J6")
          u:setdata("变异判定-安吉拉")
          SendMsgAll("|cFF8BB8CB『如今依旧无法离开这里.....』|r")
          SendDtimeMsgAll(3.4, "|cFF8BB8CB『直到最后，我还是没能获得自由....』|r")
          SendDtimeMsgAll(6.6, "|cFF8BB8CB『这悖离命运的梦想，终究是无法实现的吗...？』|r")
          local time = GetTimeOfDay()
          SetTimeOfDay(12)
          DayNightRun = false
          SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2, "Ph_Angela_01.tga", 100, 100, 100, 0.0)
          ac.wait(3000, function()
            ac.wait(1, function()
              local photo = "Ph_Angela_01.tga"
              local tm = 100
              local change = -2
              ac.loop(30, function(timer)
                tm = tm + change
                CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0, photo, tm, tm, tm, 0.0)
                if tm <= 1 then
                  timer:remove()
                end
              end)
            end)
            ac.wait(1806, function()
              local photo = "Ph_Angela_02.tga"
              local tm = 0
              local change = 2
              ac.loop(30, function(timer)
                tm = tm + change
                if 100 <= tm then
                  change = -1
                end
                CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0, photo, tm, tm, tm, 0.0)
                if tm <= 1 then
                  CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 3, photo, tm, tm, tm, 0.0)
                  ac.wait(3000, function()
                    DayNightRun = true
                    SetTimeOfDay(time)
                  end)
                  timer:remove()
                end
              end)
            end)
          end)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:buffset(u.handle, 12, "无敌")
          end)
          PlayGlobalSound(Sound_Angela_10)
          PlayBGM({
            bgm = 0,
            time = 192,
            ID = 174,
            unit = u.handle
          })
          ac.wait(12000, function()
            PlayGlobalSound(BGM_Angela_01)
          end)
          u:setdata("安吉拉-邀请函完成次数", 0)
          u:changedata("传奇数量", 1)
          u:changedata("机械变异数量", 1)
          u:changedata("光明变异数量", 1)
          u:changedata("黑暗变异数量", 1)
          u:changedata("唯一变异数量", 1)
          local sjz = {
            1,
            2,
            3,
            4
          }
          local sjz2 = {
            5,
            6,
            7,
            8,
            9,
            10
          }
          u:setdata("安吉拉-邀请函计数", 0)
          
          local function jiesuocengshu()
            if u:hasdata("变异判定-安吉拉神化") then
              if 0 < #sjz2 then
                local index = GetRandomInt(1, #sjz2)
                local sjs = sjz2[index]
                if sjs == 5 then
                  SendMsgAll("|cFFFF9900『存在意义的憧憬』|r", 15)
                  u:setdata("安吉拉-自然层")
                end
                if sjs == 6 then
                  SendMsgAll("|cFFCC0000『守护他人的决意』|r", 15)
                  u:setdata("安吉拉-语言层")
                end
                if sjs == 7 then
                  SendMsgAll("|cFF6699FF『值得托付的信任』|r", 15)
                  u:setdata("安吉拉-社会层")
                  
                  local function skill(args)
                    if args.skill == S2ID("A0AH") then
                      u:playsound(bac268)
                      local x, y = u:getxy()
                      local x2 = args.x
                      local y2 = args.y
                      local angle = AngleXY(x, y, x2, y2)
                      Effectcreate("war3mapImported\\bbb.mdx", x, y, 0, 2)
                      Effectcreate("Angela_Shao04.mdx", x, y, 0, 2)
                      Effectcreate("Angela_Shao03.mdx", x, y, 0, 1, 0, angle, 0, 0, 2)
                      if u:hasbuff("灼烧") then
                        u:curetili(4)
                        u:curehp(u.handle, 0, 10, 4)
                        u:changetimearmor(10, 30)
                      end
                      u:buffset(u.handle, 3, "灼烧")
                      if not u:hasdata("邵-免疫灼烧负面") then
                        u:settimedata("邵-免疫灼烧负面", 10)
                      end
                      local txsh = 40000 + 500 * u:getstr()
                      unifycreate({
                        owner = u.handle,
                        model = "Angela_Shao01.mdx",
                        modelname = "邵-A弹幕",
                        modelsize = 3,
                        height = 50,
                        damage = 0,
                        damagetype = 1,
                        x = x,
                        y = y,
                        range = 1500,
                        speed = 5000,
                        volume = 275,
                        angle = angle,
                        angleoffset = 0,
                        attenua = 1,
                        attenuacount = 999,
                        life = 10,
                        isbullet = false,
                        isvest = false,
                        isignorearmor = false,
                        hitafterfunc = function(mj, xq, damage2)
                          xq:buffset(u.handle, 3, "灼烧")
                          DamageUnit({
                            bj = "邵灼烧",
                            unit = xq.handle,
                            source = u.handle,
                            damage = txsh,
                            level = 1,
                            type = "物理",
                            isvest = false,
                            isattack = true,
                            isnoarmor = false,
                            element = "火"
                          })
                        end,
                        endfunc = function(mj)
                          local dx, dy = mj:getxy()
                          Effectcreate("Angela_Shao02.mdx", dx, dy, 0, 2)
                        end
                      })
                    end
                    if args.skill == S2ID("A0AI") then
                      u:playsound(bac350)
                      local x, y = u:getxy()
                      Effectcreate("Angela_Shao06.mdx", x, y, 0, 1, 50)
                      Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x, y, 0, 1, 50)
                      u:effectadd("ATX\\[ATxNew]Red_20.mdl", "origin", 1)
                      u:effectadd("Angela_Shao07.mdx", "chest", 1)
                      u:effectadd("AATX\\[AATxNew]Red07.mdx", "origin", 1)
                      u:buffset(u.handle, 0.5, "绝对闪避")
                      u:buffset(u.handle, 2, "灼烧")
                    end
                    if args.skill == S2ID("A0AG") then
                      local x, y = u:getxy()
                      u:setdata("邵-烈斩")
                      weaponuse(u.handle, S2ID("A0AG"), x, y)
                      u:deldata("邵-烈斩")
                    end
                  end
                  
                  u:addtrgevent("单位-发动技能", function(args)
                    skill(args)
                  end)
                  local dskill = S2ID("A09Q")
                  u:byladdskill(dskill, function(args)
                    if args.skill == dskill then
                      local b = true
                      local ewl = getunit(args.unit)
                      if not u:isalive() then
                        b = false
                        u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
                      end
                      if not BossBattle and not ExBossBattle then
                        b = false
                        u:sendmessage("|cFF7DBEF1非BOSS战|r")
                      end
                      if not u:hasdata("安吉拉-情感等级4") then
                        b = false
                        u:sendmessage("|cFF7DBEF1情感等级不足|r")
                      end
                      if u:hasdata("安吉拉-邵EGO") then
                        b = false
                        u:sendmessage("|cFF7DBEF1已存在|r")
                      end
                      if b then
                        if u:hasdata("安吉拉-总类层") and not u:hasdata("安吉拉-总类层增强") then
                          u:setdata("安吉拉-总类层增强")
                          ChangeValue(DamageSystem_Shjc, sy, 0.05)
                          ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
                          ChangeValue(DamageSystem_Sszengjia, sy, 0.2)
                        end
                        u:playsound(bac350)
                        PlayGlobalSound(Sound_Angela_S02)
                        local str = "『我纵茕茕孑立，难避漫漫长夜。』"
                        str = ColorfulMsg(str, {
                          "|cFFCC0000",
                          "|cFFD63300",
                          "|cFFE06600",
                          "|cFFEB9900"
                        })
                        SendMsgAll(str)
                        ac.wait(3500, function()
                          local str = "『然长夜终尽，天将启明……』"
                          str = ColorfulMsg(str, {
                            "|cFFCC0000",
                            "|cFFD63300",
                            "|cFFE06600",
                            "|cFFEB9900"
                          })
                          SendMsgAll(str)
                        end)
                        ac.wait(7000, function()
                          local str = "『惟以平旦之孤星，何胜东方之既白。』"
                          str = ColorfulMsg(str, {
                            "|cFFCC0000",
                            "|cFFD63300",
                            "|cFFE06600",
                            "|cFFEB9900"
                          })
                          SendMsgAll(str)
                        end)
                        ac.wait(12000, function()
                          local str = "『还请觉悟。』"
                          str = ColorfulMsg(str, {
                            "|cFFCC0000",
                            "|cFFD63300",
                            "|cFFE06600",
                            "|cFFEB9900"
                          })
                          SendMsgAll(str)
                        end)
                        ac.wait(13500, function()
                          local str = "『今朝此日，都市一星，势必陨灭。』"
                          str = ColorfulMsg(str, {
                            "|cFFCC0000",
                            "|cFFD63300",
                            "|cFFE06600",
                            "|cFFEB9900"
                          })
                          SendMsgAll(str)
                        end)
                        PlayBGM({
                          bgm = Baoming_BGM_04,
                          time = 240,
                          ID = 178,
                          u = u.handle
                        })
                        ARskillreplace({
                          unit = u.handle,
                          level = -1,
                          skill_A = "A0AH",
                          skill_R = "A0AI",
                          isforce = false,
                          efunc = function()
                            u:setdata("安吉拉-邵EGO")
                            u:banweaponskill()
                            u:addskill("A0AG")
                            gunban(u.handle)
                            ac.loop(3000, function(timer)
                              gunban(u.handle)
                              if not u:hasdata("安吉拉-邵EGO") then
                                u:banweaponskill(true)
                                u:delskill("A0AG")
                                gunban(u.handle, false)
                                timer:remove()
                              end
                            end)
                          end
                        })
                        local x, y = u:getxy()
                        Effectcreate("Angela_Shao06.mdx", x, y, 0, 1, 50)
                        Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x, y, 0, 1, 50)
                        u:effectadd("ATX\\[ATxNew]Red_20.mdl", "origin", 1)
                        u:effectadd("Angela_Shao07.mdx", "chest", 1)
                        u:effectadd("AATX\\[AATxNew]Red07.mdx", "origin", 1)
                        u:buffset(u.handle, 0.5, "绝对闪避")
                        u:buffset(u.handle, 2, "灼烧")
                        local tx = u:effectadd("Angela_Shao08.mdx", "origin", -1)
                        local dtime = 60
                        local add = 0
                        ac.loop(1000, function(timer)
                          dtime = dtime - 1
                          if dtime < 0 then
                            if u:ishasitem("I0J6") then
                              local dwp = u:getitem("I0J6")
                              if GetItemCharges(dwp) >= 2 then
                                ChangeItemCount(dwp, -2)
                              else
                                u:setdata("邵-结束标记")
                              end
                            else
                              u:setdata("邵-结束标记")
                            end
                          end
                          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
                          ChangeValue(Damage_Element_Fire, sy, -add)
                          if u:hasdata("安吉拉-总类层") then
                            add = 0.01 * u:getdata("灼烧层数")
                          else
                            add = 0
                          end
                          ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
                          ChangeValue(Damage_Element_Fire, sy, add)
                          if u:hasdata("邵-结束标记") then
                            u:deldata("邵-结束标记")
                            u:deldata("安吉拉-邵EGO")
                            StopSoundBJ(Baoming_BGM_04, true)
                            DestroyEffectLua(tx)
                            ARskillreplace({
                              unit = u.handle,
                              level = -2,
                              skill_A = "A0AH",
                              skill_R = "A0AI",
                              isforce = false,
                              efunc = function()
                              end
                            })
                            if u:hasdata("安吉拉-总类层增强") then
                              u:deldata("安吉拉-总类层增强")
                              ChangeValue(DamageSystem_Shjc, sy, -0.05)
                              ChangeValue(DamageSystem_EndSh, sy, -0.010000000000000002)
                              ChangeValue(DamageSystem_Sszengjia, sy, -0.2)
                            end
                            timer:remove()
                          end
                        end)
                      else
                        ewl:setskillcd(dskill, 1)
                      end
                    end
                  end)
                end
                if sjs == 8 then
                  SendMsgAll("|cFFCC9900『直面恐惧 斩断循环』|r", 15)
                  u:setdata("安吉拉-哲学层")
                  u:addgold(Time_All)
                  u:addstexiao("安吉拉-哲学层", "被施加Buff时效果-僵直", function(args)
                    if not Keyan_Guomintizhi then
                      args.time = 0.01
                      u:clearbuff("僵直")
                    end
                  end)
                end
                if sjs == 9 then
                  SendMsgAll("|cFF999999『拥抱过去 创造未来』|r", 15)
                  u:setdata("安吉拉-宗教层")
                  ac.loop(60000, function()
                    local add = 1 - GetRandomReal(0.01, 0.05)
                    ChangeValue(DamageSystem_Ssjianshao, sy, add, 1)
                  end)
                end
                if sjs == 10 then
                  SendMsgAll("|cFF666666『纯真的自我』|r", 15)
                  u:setdata("安吉拉-总类层")
                  u:addstexiao("安吉拉-总类层", "终结伤害计算效果", function(args)
                    local tg = args.tg
                    local u = args.u
                    local info = args.damageinfo
                    if u:hasdata("安吉拉-邵EGO") and tg:hasbuff("灼烧") then
                      info.end2 = info.end2 + 0.12
                    end
                  end)
                end
                table.remove(sjz2, index)
              end
            elseif 0 < #sjz then
              local index = GetRandomInt(1, #sjz)
              local sjs = sjz[index]
              if sjs == 1 then
                SendMsgAll("|cFFFFCC33『昂首阔步的信念』|r", 15)
                u:setdata("安吉拉-历史层")
                u:addskill("S0AZ")
                ac.loop(1000, function()
                  if u:isalive() then
                    local x, y = u:getxy()
                    for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local txsh
                      if xq:isnormal() then
                        txsh = 0.01 * xq:getmaxhp()
                      else
                        txsh = 0.001 * xq:gethp()
                      end
                      LossHpUnit({
                        u = u,
                        tg = xq,
                        damage = txsh,
                        perhp = 0,
                        maxhp = 0,
                        bj = "[生命损耗]安吉拉社会层"
                      })
                    end
                  end
                end)
              end
              if sjs == 2 then
                SendMsgAll("|cFF6633FF『卓尔不凡的理性』|r", 15)
                u:setdata("安吉拉-科技层")
                u:addskill("S0AY")
                local jc = 0
                ac.loop(3000, function()
                  ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
                  jc = 0.1 * u:getdata("安吉拉-邀请函完成次数")
                  ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
                end)
              end
              if sjs == 3 then
                SendMsgAll("|cFFCC9933『愈加善良的希望』|r", 15)
                u:setdata("安吉拉-文学层")
                ac.loop(60000, function()
                  u:addrandomstats(u:getdata("安吉拉-邀请函完成次数"))
                end)
              end
              if sjs == 4 then
                SendMsgAll("|cFF339933『生存下去的勇气』|r", 15)
                u:setdata("安吉拉-艺术层")
                ChangeValue(HeroMenu_HpForever_MaxHp, sy, 0.5)
              end
              table.remove(sjz, index)
            end
          end
          
          u:setdata("安吉拉-解锁层数函数", jiesuocengshu)
          u:addstexiao("安吉拉", "杀敌效果", function(args)
            local tg = args.tg
            local x, y = tg:getxy()
            if u:hasdata("安吉拉-邀请函生效中") then
              u:changedata("安吉拉-邀请函所需杀敌数", -1)
              if u:getdata("安吉拉-邀请函所需杀敌数") <= 0 then
                u:sendmessage("|cFFE2BC80完成邀请函任务|r")
                u:deldata("安吉拉-邀请函所需杀敌数")
                u:deldata("安吉拉-邀请函生效中")
                u:changedata("安吉拉-邀请函完成次数", 1)
                ChangeValue(DamageSystem_Shjc, sy, 0.005)
                u:changedata("安吉拉-邀请函计数", 1)
                if u:getdata("安吉拉-邀请函计数") >= 2 then
                  u:changedata("安吉拉-邀请函计数", -2)
                  jiesuocengshu()
                end
              end
            end
            u:changedata("安吉拉-魔弹杀敌", 1)
            if u:getdata("安吉拉-魔弹杀敌") >= 200 and not u:hasdata("魔弹判定结束") then
              u:setdata("魔弹判定结束")
              for index, value in ipairs(Pools_Boxs) do
                if value.name == "魔弹" then
                  if not value.hasbeenget then
                    u:additem("I0J3")
                    value.hasbeenget = true
                  end
                  break
                end
              end
            end
          end)
          u:addstexiao("安吉拉传奇", "直接伤害特效", function(args)
            local u = args.u
            local tg = args.tg
            local info = args.damageinfo
            if not u:hasdata("安吉拉传奇特效冷却") and u:getluckrandom(5 * info.txgl) then
              local x, y = tg:getxy()
              local mfsh = 2000 + u:getlevel() * 600
              for _, xq in ac.selector():in_rangexy(x, y, 375):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "安吉拉传奇附伤",
                  unit = xq.handle,
                  source = u.handle,
                  damage = mfsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "无"
                })
                xq:buffset(u.handle, 0.5, "眩晕")
              end
              u:settimedata("安吉拉传奇特效冷却", 1)
            end
          end)
          local dskill = S2ID("A098")
          u:byladdskill(dskill, function(args)
            if args.skill == dskill then
              local b = true
              local ewl = getunit(args.unit)
              if not u:isalive() then
                b = false
                u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
              end
              if u:hasdata("安吉拉-邀请函生效中") then
                b = false
                u:sendmessage("|cFF7DBEF1已经存在任务|r")
              end
              if b then
                SendMsgAll("|cFFE2BC80『正于此地，愿您找到您想要的书。』|r")
                PlayGlobalSound(Sound_Angela_01)
                u:setdata("安吉拉-邀请函生效中")
                local count = GetRandomInt(1, 99)
                u:sendmessage("|cFFE2BC80任务:击杀" .. count .. "个敌人")
                u:setdata("安吉拉-邀请函所需杀敌数", count)
              else
                ewl:setskillcd(dskill, 1)
              end
            end
          end)
          u:uivar_change({
            keyname = "安吉拉初始",
            keytype = "传奇栏",
            text = "|cFF8BB8CB安|r|cFFA8CAD8吉|r|cFFC5DCE5拉|r\n|cFF8BB8CB我会建起只属于我自己的，最为宝贵的“图书馆”。|r\n|cFF7FA5B9我会与那些迷失了的可怜灵魂同在。|r\n|cFF7393A7人们把它们称作“丑陋的怪物”...|r\n|cFF678095但实际上，这些忠于自我的异想体才是最可爱的存在。|r\n|cFF5C6E84我会和这些被抛弃的存在一起，一页一页地记录下这整个世界。|r\n|cFF505B72正于此地。|r",
            icon = "BTNAngela_04",
            clickfunc = function(u, button)
              if u:hasdata("安吉拉-历史层") and u:hasdata("安吉拉-科技层") and u:hasdata("安吉拉-文学层") and u:hasdata("安吉拉-艺术层") and u:ishasshw() then
                AdvanceGet["安吉拉神化"](u)
              end
            end
          })
        end
      end
    end
    
    u:addtrgevent("玩家-聊天", function(args)
      chattrg(args)
    end)
  end
  local id = {
    "1921922654",
    "1463144872",
    "134791749"
  }
  if TableContains(id, uidc) and not pdi_yuzhe then
    pdi_yuzhe = true
    u:addskill("S0C1")
    u:changedata("幸运", 1)
    u:changedata("幸运系数", 0.05)
    u:setdata("变异判定-愚者初始")
    u:uivar_add({
      keyname = "愚者初始",
      keytype = "传奇栏",
      text = "|cFFFFCC00无|r|cFFF0C516法|r|cFFE2BD2C归|r|cFFD3B642乡|r|cFFC5AF57之|r|cFFB6A86D人|r\n|cFF999999你们可以称呼我为|r\n                  |cFF9999FF「 |r|cFF7A8FEB愚 |r|cFF5C85D6者 |r|cFF3D7AC2」|r",
      icon = "Ewl_Yuzhe_01.tga",
      ishasphoto = true,
      jbtext = function()
        UIYNameCount = 2
        UIYName[1] = {
          method = 1,
          name = "无法归乡之人",
          colors = {
            "FFCC00",
            "949596",
            "949596",
            "949596",
            "FFCC00"
          },
          length = 5,
          lengthcd = 10,
          math = 1,
          offsetspeed = 0.25,
          extratext = "\n" .. "|cFF999999你们可以称呼我为|r" .. [[

                  ]]
        }
        UIYName[2] = {
          method = 1,
          name = "「 愚 者 」",
          colors = {
            "9999FF",
            "6633FF",
            "006699",
            "6633FF",
            "9999FF"
          },
          length = 5,
          lengthcd = 30,
          math = 1,
          offsetspeed = 0.5
        }
      end
    })
    PlayGlobalSound(Sound_Yuzhe_01)
    u:chat("|cFFCCCCCC「 福生玄黄仙尊 」|r")
    ac.wait(2600, function()
      u:chat("|cFF999999「 福生玄黄天君 」|r")
    end)
    ac.wait(4800, function()
      u:chat("|cFF666666「 福生玄黄上帝 」|r")
    end)
    ac.wait(8800, function()
      u:chat("|cFF990000「 福生玄黄天尊 」|r")
    end)
    SendDtimeMsgAll(11.8, "|cFF666699我|r|cFF636399从|r|cFF616199诡|r|cFF5E5E99秘|r|cFF5B5B99中|r|cFF595999醒|r|cFF565699来|r|cFF535399，|r|cFF515199睁|r|cFF4E4E99眼|r|cFF4B4B99看|r|cFF484899见|r|cFF464699这|r|cFF434399个|r|cFF404099世|r|cFF3E3E99界|r|cFF3B3B99…|r|cFF383899…|r", 10)
    SendDtimeMsgAll(14.8, "|cFFCC9966光|r|cFFC89768明|r|cFFC4956A依|r|cFFC1936C旧|r|cFFBD916E照|r|cFFB9906F耀|r|cFFB58E71，|r|cFFB28C73神|r|cFFAE8A75秘|r|cFFAA8877从|r|cFFA68679未|r|cFFA2847B远|r|cFF9F827D离|r|cFF9B807F，|r|cFF977F80这|r|cFF937D82是|r|cFF907B84一|r|cFF8C7986段|r|cFF887788「|r|cFF84758A愚|r|cFF80738C者|r|cFF7D718E」|r|cFF796F90的|r|cFF756E91传|r|cFF716C93说|r|cFF6E6A95。|r", 10)
    ac.wait(240000, function()
      if u:getluckrandom(6.18) then
        u:additem("I0L7")
      end
      if u:getluckrandom(0.618) then
        u:additem("I0L8")
      end
      if u:getluckrandom(0.0618) then
        u:additem("I0L9")
      end
      ac.loop(1000, function(timer)
        if Ewaishu[sy] > 0 then
          u:sendmessage("|cFF3366FF归|r|cFF4471F9乡|r|cFF557DF4-|r|cFF6688EE已|r|cFF7793E8存|r|cFF889FE3在|r|cFF99AADD变|r|cFFAAB5D7异|r")
          timer:remove()
        else
          SetTimeOfDay(0)
          local pools = {
            Vars_Huiyi_Dz
          }
          u:setdata("系统-特殊获取中")
          local str = herogetvar(u.handle, pools, "次元", "愚者传奇")
          u:deldata("系统-特殊获取中")
          u:changedata("传奇数量", 1)
          timer:remove()
        end
      end)
    end)
  end
  local id = {"873810818"}
  if TableContains(id, uidc) and not pdi_naxida then
    pdi_naxida = true
    u:setdata("特殊判定-纳西妲初始")
    u:changedata("幸运", 1)
    ChangeValue(Correction_Exp, sy, 0.05)
    ChangeValue(Correction_Gold, sy, 0.025)
    u:addskill("S0BA")
    u:uivar_add({
      keyname = "纳西妲初始",
      keytype = "传奇栏",
      text = "|cFF66FF99智慧之神的祝福|r\n|cFF66FF99提升1幸运\n提升5%经验获取\n提升2.5%积分获取\n全队提升5%额外移速|r",
      icon = "Ewl_Naxida_Start_2"
    })
  end
  local id = {
    "-48256776",
    "-403162424",
    "-1588123416"
  }
  if TableContains(id, uidc) and not pdi_zaomiao2 then
    pdi_zaomiao2 = true
    local cs = 0
    ac.loop(1000, function(timer)
      if u:isalive() and u:getdata("东风谷早苗-信仰之力") >= 10 then
        for index, value in ipairs(Pools_Spe) do
          if value.name == "风祝の御币" then
            if not value.hasbeenget then
              local item = u:additem("I02B")
              u:sendmessage("|cFF66FFCC你|r|cFF65FFCB感|r|cFF63FFC9受|r|cFF62FFC8到|r|cFF60FFC6，|r|cFF5FFFC5四|r|cFF5DFFC4方|r|cFF5CFFC2清|r|cFF5BFFC1风|r|cFF59FFBF徐|r|cFF58FFBE徐|r|cFF56FFBC苏|r|cFF55FFBB醒|r|cFF54FFBA，|r|cFF52FFB8渐|r|cFF51FFB7渐|r|cFF4FFFB5聚|r|cFF4EFFB4拢|r|cFF4CFFB3翻|r|cFF4BFFB1涌|r|cFF4AFFB0，|r|cFF48FFAE轻|r|cFF47FFAD拂|r|cFF45FFAB巫|r|cFF44FFAA女|r|cFF43FFA9衣|r|cFF41FFA7袂|r|cFF40FFA6，|r|cFF3EFFA4漫|r|cFF3DFFA3过|r|cFF3BFFA2山|r|cFF3AFFA0间|r|cFF39FF9F神|r|cFF37FF9D社|r|cFF36FF9C。|r")
              value.hasbeenget = true
            end
            break
          end
        end
        timer:remove()
      end
    end)
    u:uivar_add({
      keyname = "早苗初始2",
      keytype = "传奇栏",
      text = "|cFF00FFFF清|r|cFF02FFF6风|r|cFF04FFEC为|r|cFF06FFE3信|r|cFF08FFD9，|r\n|cFF09FFD0信|r|cFF0BFFC6仰|r|cFF0DFFBD为|r|cFF0FFFB3光|r|cFF11FFAA，|r\n|cFF13FFA1风|r|cFF15FF97祝|r|cFF17FF8E少|r|cFF19FF84女|r|cFF1AFF7B，|r\n|cFF1CFF71温|r|cFF1EFF68柔|r|cFF20FF5E执|r|cFF22FF55掌|r|cFF24FF4C世|r|cFF26FF42间|r|cFF28FF39温|r|cFF2AFF2F柔|r|cFF2BFF26神|r|cFF2DFF1C迹|r|cFF2FFF13。|r",
      icon = "Cq_Chushi_ZaomiaoNew.tga"
    })
  end
  local id = {
    "241989033",
    "1932310753",
    "-1588123416",
    "-403162424",
    "-48256776"
  }
  if TableContains(id, uidc) and not pdi_zaomiao then
    pdi_zaomiao = true
    u:setdata("东风谷早苗-风祝的巫女")
    u:setdata("东风谷早苗-信仰之力", 0)
    u:changedata("幸运", 1)
    u:adddivinity(1)
    u:addskill("A03U")
    local cs = 0
    ac.loop(1000, function()
      if u:isalive() then
        cs = cs + 1
        if cs == 60 then
          cs = 0
          Zaomiao_xinyangzengjia(u, 1)
        end
      end
    end)
    u:uivar_add({
      keyname = "早苗初始",
      keytype = "传奇栏",
      text = "|cFF33FF99风祝|r|cFF66FF73の|r|cFF99FF4C巫女|r\n|cFF33FF99神性 1\n提升1点幸运|r\n|cFF66FF73风祝|r\n|cFF99FF4C提升周围1800范围单位12%移速与2点生命恢复|r\n|cFF66FF73信仰之力|r\n|cFF99FF4C每层信仰之力随机提升属性\n每60秒[10%+5%*存活人数]提升一层信仰之力\n杀敌时2%提升一层信仰之力\n使用药水时5%提升一层信仰之力,如果成功则概率翻倍|r",
      icon = "war3mapImported\\BTNChushi_Fengzhuwunv.blp"
    })
  end
  local id = {
    "-1671281879"
  }
  if TableContains(id, uidc) then
    local function qiehuan()
      NameID[sy] = "|cFFFFCC33奥|r|cFFFFD24A托|r|cFFFFD760.|r|cFFFFDD77阿|r|cFFFFE38E波|r|cFFFFE8A4卡|r|cFFFFEEBB利|r|cFFFFF4D2斯|r"
      
      u:setplayername(NameID[sy])
      Boolean_ColorName[sy] = true
      ColorName[sy][1] = {
        method = 1,
        name = "生命",
        colors = {
          "FFFFFF",
          "FFCC33",
          "66FF99",
          "FFCC33",
          "FFFFFF"
        },
        length = 5,
        lengthcd = 35,
        math = 1,
        offsetspeed = 0.5
      }
      transition_phrases({
        name = {
          "生命",
          "还真是一种脆弱的东西啊",
          "小时候我的姐姐战死沙场",
          "他们告诉我",
          "她的灵魂不灭",
          "她的精神将升上天堂",
          "一代一代",
          "人类总是乐于用这样的谎言欺骗自己",
          "相信所谓的来世",
          "相信意识的永恒",
          "他们将人世伪装成不存在死亡的样子",
          "直到死亡突然侵入他们的生活",
          "降临在他们所爱的人身上",
          "甚至，到了这种时候",
          "他们会变本加厉地欺骗自己",
          "相信爱可以超脱万物",
          "坚信情可以永恒不灭",
          "呵，的确",
          "爱乃至更广泛的情感",
          "它们都可以引发奇迹",
          "但奇迹的创造者",
          "只能是那时那刻还「活着」的人而已",
          "作为曾被他们蒙骗的普通人",
          "我也曾幻想人的灵魂存在于更高的维度",
          "幻想着有朝一日",
          "我的所爱之人",
          "她可以借助新的身体重归人间",
          "在更好的未来生活下去",
          "可惜世界的规则并不如此",
          "死亡的确是意识的消散",
          "是一切的终结",
          "我们无法继续",
          "那些业已消散的星光。",
          "除非",
          "我们逆转时间",
          "将沉默的坟墓之岛唤醒",
          "将生命的长青之水",
          "重新注入那埋葬一切的过去",
          "二分的道路将在那里再度展开",
          "生与死的选择将自此形成两个世界",
          "而代价",
          "不过是一个人的死亡",
          "一个人的毁灭",
          "以及那本来就想致我们于死地的「崩坏」",
          "只可惜",
          "领悟这个道理的时候",
          "奥托•阿波卡利斯",
          "他早已经是一个举世闻名的恶人",
          "他已经被自己需要的力量憎恨的彻头彻尾",
          "不过，这也确实无妨",
          "「她」确实证明了",
          "出于爱的愤怒",
          "会拥有与爱同等的力量",
          "而在这样的英雄背后",
          "德莉莎，我亲爱的孙女",
          "你正在成为一个伟大的领袖",
          "假以时日，你终将让人们忘记你的爷爷",
          "让他的是非功过，湮灭于历史，消亡于谈资",
          "只是",
          "偶尔也吃一点苦瓜之外的水果和蔬菜吧",
          "你总是熬夜",
          "身体应该补充更丰富的营养才对",
          "啊……",
          "你知道吗",
          "明天的加冕典礼",
          "爷爷给你亲手缝制了大主教的肩衣",
          "如果你不会嫌弃",
          "那么就用它开启属于你的时代",
          "洗去那些爷爷曾留在上面的污渍吧",
          "德莉莎",
          "我的那些「老朋友」们",
          "赤鸢仙人，理之律者……",
          "他们是真正的好人",
          "一定会帮你走出一条属于你自己的道路",
          "而「比安卡」，我最后的学生啊",
          "我操弄了你的人生",
          "规划了你的命途多舛",
          "一边对你付出栽培的真情",
          "一边又把你当作棋子予取予求",
          "你知道吗",
          "我在最后的这十年中对你所展示的一切",
          "不过是像这般寂灭之后",
          "有人能为我立一块无字之碑罢了",
          "呵，我不需要有人能评价我",
          "啊，他如今已抵达了旅途的尽头",
          "他所要完成的、所要见证的、所要救赎的",
          "它们已经在虚数之树中生根发芽",
          "只等待着那迷路的信使",
          "将最后的消息在一切都结束前送达",
          "那一刻，不会太早，也不会太晚",
          "它会成为跨越死亡的镇魂曲",
          "它会成为奇迹降临的赞美诗",
          "世界将在那一刻只为了一个人而转动",
          "让那被强加的罪孽烟消云散",
          "让那被终结的意志继续向前",
          "卑鄙，将由我带进坟墓",
          "光明，会因你伸向未来",
          "我愚弄了友人",
          "愚弄了至亲",
          "愚弄了世界和它之上的规则",
          "只为了给予那唯一真实的你以第二次生命",
          "我回来了",
          "卡莲"
        },
        sy = sy,
        delay = 10,
        pause_time = 3000
      })
    end
    
    u:uivar_add({
      keyname = "奥托初始",
      keytype = "传奇栏",
      text = "|cFFFEDB1F“一个人，要犯下多少恶行\n才能在地狱的尽头，将她带回黎明\n一个人，要走多远的距离\n才能在时光的尽头，追回最初的自己”|r",
      cd = 1200,
      icon = "Start_Aotuo_2",
      clickfunc = function(u, button)
        PlayBGM({
          bgm = BGM_Aotuo_01,
          time = 240,
          ID = 180,
          unit = u.handle
        })
        qiehuan()
        if not u:hasdata("奥托初始id改变") then
          u:setdata("奥托初始id改变")
          u:uivar_change({
            keyname = "奥托初始",
            keytype = "传奇栏",
            text = "|cFF99CCFF卑鄙，将由|r|cFFFFD700我|r|cFF99CCFF带进坟墓；光明，会因|r|cFF9933FF你|r|cFF99CCFF伸向未来。|r\t\n|cFF99CCFF世界的|r|cFFFF66FF恶意|r|cFF99CCFF……就由|r|cFFFFD700恶人|r|cFF99CCFF来|r|cFFFF0000斩断|r|cFF99CCFF吧。|r\n|cFFFFD700卡莲…活下去……|r",
            icon = "Start_Aotuo_22"
          })
        end
      end
    })
  end
end
