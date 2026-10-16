-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
function gunchangetrg(unit, wp)
  local u = getunit(unit)
  
  if GetItemType(wp) == ITEM_TYPE_PERMANENT then
    if GetItemTypeId(wp) == S2ID("I01G") or GetItemTypeId(wp) == S2ID("I0DH") then
      return
    end
    if GetItemCharges(wp) ~= 0 then
      SetItemCharges(wp, GetItemCharges(wp) + 1)
      SetItemCharges(wp, GetItemCharges(wp))
    end
    if u:ishasskill(SKILL_TESHUYINGXIONG) or u.type == HeroType["C呆"] or u.type == HeroType["铃仙"] then
      if GetItemTypeId(wp) ~= S2ID("I01F") then
        u:sendmessage("无法使用枪支")
      end
      return
    end
    gunchange(unit, wp)
  end
end

function gunchange(unit, wp)
  local u = getunit(unit)
  local p = getplayer(u.owner)
  local sy = u.ownerid
  local bb = getunit(System_ZbBeibao[sy])
  local gun = GetItemTypeId(wp)
  local zgun = u:getdata("装备枪支")
  local fgun = u:getdata("辅助枪支")
  local zguntype = GetItemTypeId(zgun)
  local lx = GetData(gun, "枪械类型")
  local b = false
  if u:hasdata("狙击模式-开启") then
    u:deldata("狙击模式-开启")
  end
  u:setdata("霰弹装弹", false)
  if zguntype == Guns["加斯尔.豺狼(腐化)"] and u:getdata("加斯尔豺狼-生命上限提升") >= u:getmaxhp() then
    u:sendmessage("无法卸下当前枪支-生命值不足")
    return
  end
  if (u:hasdata("变异判定-漆黑的子弹") or u:hasdata("缇娜天赋-狙击精通")) and lx ~= 3 and lx ~= 8 and lx ~= 9 then
    u:sendmessage("无法装备狙击枪或手枪以外枪械")
    return
  end
  if gun == Guns["丧钟"] then
    local zb = false
    if u.type == HeroType["琪露诺"] then
      if u:getallattri() >= 500 then
        zb = true
      end
    elseif u:getstr() >= 188 and 188 <= u:getagi() and 188 <= u:getint() then
      zb = true
    end
    if u:getdata("外域变异数量") < 10 then
      zb = false
    end
    if u:getdata("变异判定-愚者初始") then
      zb = true
    end
    if not zb then
      u:sendmessage("|cff5974a8[丧钟]条件未满足|r")
      return
    end
  end
  if gun == Guns["光之剑超新星"] then
    weaponchange(u.handle, wp)
    if not u:hasdata("武器判定-光之剑超新星") then
      u:sendmessage("|cFFCCFFFF无法装载光之剑|r")
      return
    end
  end
  if gun == Guns["新月玫瑰"] then
    weaponchange(u.handle, wp)
    if not u:hasdata("武器判定-新月玫瑰") then
      u:sendmessage("|cFF990000无法装备新月玫瑰|r")
      return
    end
  end
  if zgun ~= wp and fgun ~= wp and u:hasdata("缇娜天赋-枪斗术阿尔法") then
    local sx = 5 + u:getlevel() / 5
    local c = u:getdata("枪斗术层数")
    u:setdata("枪斗术时间", 9)
    if sx > c then
      u:setdata("枪斗术层数", c + 1)
      local add = 0.005 * u:getlevel()
      u:changedata("缇娜-枪斗术提升修正", add)
      ChangeValue(Correction_Gun, sy, 0.1 * add)
    end
  end
  if lx == 1 then
    b = true
    if fgun ~= ITEM_KONG then
      bb:dropitem(fgun)
      u:addspeitem(fgun)
      u:setdata("辅助枪支", wp)
      u:setdata("辅助换弹", false)
      fgun = u:getdata("辅助枪支")
      u:dropitem(fgun)
      bb:addspeitem(fgun)
    elseif zgun ~= ITEM_KONG and GetItemLevel(zgun) == 3 then
      u:sendmessage("|cFF7DBEF1双持状态|r")
      u:setdata("辅助枪支", wp)
      u:setdata("辅助换弹", false)
      fgun = u:getdata("辅助枪支")
      u:dropitem(fgun)
      bb:addspeitem(fgun)
    else
      gunchangedel(unit)
      u:setdata("辅助枪支", ITEM_KONG)
      u:setdata("辅助换弹", false)
      u:setdata("装备枪支", wp)
      u:setdata("枪支换弹", false)
      gunchangadd(unit)
      zgun = u:getdata("装备枪支")
      u:dropitem(zgun)
      bb:addspeitem(zgun)
    end
  else
    if fgun ~= ITEM_KONG then
      bb:dropitem(fgun)
      u:addspeitem(fgun)
    end
    u:setdata("辅助枪支", ITEM_KONG)
    u:setdata("辅助换弹", false)
  end
  if 2 <= lx and lx <= 9 then
    b = true
    gunchangedel(unit)
    u:setdata("辅助枪支", ITEM_KONG)
    u:setdata("辅助换弹", false)
    u:setdata("装备枪支", wp)
    u:setdata("枪支换弹", false)
    zgun = u:getdata("装备枪支")
    gunchangadd(unit)
    u:dropitem(zgun)
    bb:addspeitem(zgun)
  end
  if u:hasdata("贝洛妮卡-蔷薇荆棘") then
    if lx == 4 then
      if not u:hasdata("贝洛妮卡-蔷薇荆棘") then
        u:setdata("贝洛妮卡-蔷薇荆棘")
        ChangeValue(Correction_Gun, sy, 0.033)
      end
    elseif u:hasdata("贝洛妮卡-蔷薇荆棘") then
      u:deldata("贝洛妮卡-蔷薇荆棘")
      ChangeValue(Correction_Gun, sy, -0.033)
    end
  end
  if 1 <= lx and lx <= 9 and lx ~= 6 then
    local strz = {}
    local sz = {
      "枪口",
      "下挂",
      "弹匣"
    }
    for index, value in ipairs(sz) do
      if GetData(wp, "枪械模块-" .. value) ~= 0 then
        strz[index] = GetData(wp, "枪械模块-" .. value) .. "Lv" .. GetData(wp, "枪械模块等级-" .. value)
      else
        strz[index] = "无"
      end
    end
    local dlv = GetData(wp, "枪械-枪械等级")
    local strzadd = ""
    if dlv ~= 0 then
      strzadd = "+" .. dlv
    end
    u:sendmessage("|cFF7DBEF1枪械:" .. GetItemName(wp) .. strzadd, 30)
    u:sendmessage("|cFF7DBEF1枪口模块:" .. strz[1], 30)
    u:sendmessage("|cFF7DBEF1下挂模块:" .. strz[2], 30)
    u:sendmessage("|cFF7DBEF1弹匣模块:" .. strz[3], 30)
  end
  if gun == Guns["竞争者"] then
  end
  if lx == 3 then
    local sc = GetData(gun, "开镜射程")
    if u:hasdata("缇娜天赋-狙击精通") then
      sc = sc * 1.5
    end
    u:setdata("狙击模式-射程", sc)
  else
    u:deldata("狙击模式-射程")
  end
  if b then
    gunchangeend(unit)
  end
  if b and u:hasdata("变异判定-但丁") then
    u:setskillcd("A00A", 0.4)
    u:buffset(u.handle, 0.25, "绝对闪避")
    ChangeTimeValue(Correction_Gun, sy, 0.010000000000000002, 15)
  end
  if lx ~= 6 and lx ~= 7 then
    ac.wait(30, function()
      if GetItemCharges(zgun) == 0 or GetItemCharges(zgun) <= GetData(zguntype, "弹匣容量") then
        IssueNeutralImmediateOrderById(u.owner, unit, String2OrderIdBJ("berserk"))
      end
    end)
  end
  gunshowrefreesh(unit)
  if lx == 8 then
    if gun == Guns["星光魔术师"] then
      u:sendmessage("|cFF6650D6①星之技术\n[星光弹]与[幻想虚弹]造成光属性伤害|r\n|cFFCCFFFF②月|r|cFFA3D9FF之|r|cFF7AB3FF魔|r|cFF528DFF法|r\n|cFFCCFFFF子弹改为造成10次10%伤害(伤害间隔0.05秒)|r")
    end
    if gun == Guns["加斯尔.豺狼"] then
      u:sendmessage("|cFF990000①吸血鬼猎人\n杀敌时提升[0.5+吸血鬼变异数量*0.25]点生命上限\n提升[吸血鬼变异数量*1.3%]枪械伤害|r\n|cFF999999②双枪\n射击起始点会略微偏移;以下述顺序发射不同子弹:\n①洗礼银弹(500%):命中吸血鬼时,即死(10%最大/1%当前 魔力抹除伤害);移除目标一个精英特性(独立冷却3秒)\n②水银合弹(2000%):命中时1秒内附带[1+吸血鬼变异数量*0.1]次(上限5次)11%等额伤害,抑制生命恢复10秒|r")
    end
    if gun == Guns["竞争者"] then
      u:sendmessage("|cFF666666①断|r|cFF63556A罪|r|cFF60446F者|r|cFF5C3373魔|r|cFF592277弹|r\n|cFF666666子弹提升2.5%伤害加成与200%暴击伤害,|r|cFF63556A附带5秒断罪状态(40%易伤);|r|cFF592277如果目标已处于断罪状态,则造成抹除伤害|r\n|cFF666666②曾|r|cFF6B5C5C想|r|cFF705252成|r|cFF754747为|r|cFF7A3D3D正|r|cFF7F3333义|r|cFF852929的|r|cFF8A1F1F伙|r|cFF8F1414伴|r\n|cFF666666[起源弹]基础伤害提升100%,持续伤害提升100%,|r|cFF705252禁用重生并破坏所有精英特性,对精英附带削除25%生命上限,对BOSS附带削除3%生命上限|r")
    end
    if gun == Guns["加斯尔.豺狼(腐化)"] then
      p:clearMsg()
      u:sendmessage("|cFF990000①嗜血狂化：\n杀敌时在16秒内提升0.5%枪械伤害,可叠加,分立计时,夜晚加成效果提升50%\n杀敌时提升[0.5+吸血鬼变异数量*0.25]点生命上限\n提升[吸血鬼变异数量*5]额外移速,夜晚加成翻倍\n提升[吸血鬼变异数量*1.3%]枪械伤害|r")
      ac.wait(5000, function()
        u:sendmessage("|cFF990000②血舞双枪：\n射击起始点会略微偏移\n射击后0.5秒内右击地面向目标点冲刺,持续0.1秒,期间绝对闪避,有效距离400码\n以下述顺序发射不同子弹:\n①血咒银弹(1750%):命中的第一个单位附带225范围[(10%+吸血鬼变异数量*1%)*伤害值]命运魔力伤害;移除目标一个精英特性(独立冷却3秒)\n②水银合弹(2000%):命中时1秒内附带[1+吸血鬼变异数量*0.1]次(上限5次)11%等额伤害,抑制生命恢复10秒|r")
        u:sendmessage("|cFFFF0000③附骨燃殇：\n每秒降低1点生命上限\n每次射击消耗自身1点生命上限\n子弹命中敌人时附带降低[1%(0.5%/0.05%)]生命上限\n射杀敌人时提升2点生命上限与0.01%枪械伤害(绑定枪械与玩家)|r")
      end)
    end
  end
end

function gundataclear(u)
  u:deldata("枪械判定-光之剑超新星")
  u:deldata("枪械判定-魔弹")
  u:deldata("枪械-星光魔术师")
  u:deldata("枪械-竞争者")
  u:deldata("枪械-加斯尔豺狼")
  u:deldata("枪械-加斯尔豺狼-蕾米强化")
  u:deldata("枪械-白洲梓-虚无步枪")
  u:deldata("枪械-丧钟")
end

function gunchangadd(unit)
  local u = getunit(unit)
  local sy = u.ownerid
  local zgun = u:getdata("装备枪支")
  local gun = GetItemTypeId(zgun)
  local lx = GetData(gun, "枪械类型")
  if zgun == ITEM_KONG then
    RefreshCritWeaponBonus(u.handle)
    return
  end
  RefreshCritWeaponBonus(u.handle)
  gundataclear(u)
  if lx == 8 then
    u:addskill("A1HO")
    u:addskill("A001")
    if gun == Guns["丧钟"] then
      u:setdata("枪械-丧钟")
      u:setdata("丧钟-剩余子弹数", GetItemCharges(zgun))
    end
    if gun == Guns["星光魔术师"] then
      u:setdata("枪械-星光魔术师")
    end
    if gun == Guns["竞争者"] then
      u:setdata("枪械-竞争者")
      u:addstexiao("竞争者", "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("竞争者-断罪者魔弹强化") then
          info.bjsh = info.bjsh + 2
          if not tg:hasdata("断罪者魔弹-断罪状态") then
            tg:settimedata("断罪者魔弹-断罪状态", 5)
          end
        end
      end)
    end
    if gun == Guns["加斯尔.豺狼"] then
      u:setdata("枪械-加斯尔豺狼")
      u:setdata("加斯尔豺狼-顺序", GetRandomInt(1, 2))
      if not u:hasdata("加斯尔豺狼-装备") then
        u:setdata("加斯尔豺狼-装备")
        local qx = 0
        ac.loop(3000, function(t)
          ChangeValue(Correction_Gun, sy, 0.1 * (-1 * qx))
          qx = 0.13 * u:getdata("吸血鬼变异数量")
          ChangeValue(Correction_Gun, sy, 0.1 * (1 * qx))
          if GetItemTypeId(u:getdata("装备枪支")) ~= Guns["加斯尔.豺狼"] then
            u:deldata("加斯尔豺狼-装备")
            u:deldata("加斯尔豺狼-顺序")
            ChangeValue(Correction_Gun, sy, 0.1 * (-1 * qx))
            t:remove()
          end
        end)
      end
    end
    if gun == Guns["加斯尔.豺狼(腐化)"] then
      u:setdata("枪械-加斯尔豺狼-蕾米强化")
      u:setdata("加斯尔豺狼-顺序", GetRandomInt(1, 2))
      if not u:hasdata("加斯尔豺狼-位移添加") then
        u:setdata("加斯尔豺狼-位移添加")
        u:addtrgevent("单位-指定点目标指令", function(args)
          if args.orderid == String2OrderIdBJ("smart") and u:hasdata("加斯尔豺狼-位移") then
            u:deldata("加斯尔豺狼-位移")
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            local angle = AngleXY(x, y, x2, y2)
            local dis = DistanceXY(x, y, x2, y2)
            if 400 <= dis then
              dis = 400
            end
            u:buffset(u.handle, 0.1, "绝对闪避")
            unitmove({
              unit = u.handle,
              time = 0.1,
              distance = dis,
              angle = angle,
              loops = {
                {
                  looptime = 0.02,
                  func = function()
                    local x, y = u:getxy()
                    Effectcreate("war3mapImported\\blackblink.mdx", x, y)
                  end
                }
              }
            })
          end
        end)
      end
      if not u:hasdata("加斯尔豺狼-蕾米强化-装备") then
        u:setdata("加斯尔豺狼-蕾米强化-装备")
        u:changemaxhp(u:getdata("加斯尔豺狼-生命上限提升"))
        local qx = 0
        local ys = 0
        ac.loop(3000, function(t)
          if u:isalive() then
            u:changemaxhp(-3)
          end
          ChangeValue(Correction_Gun, sy, 0.1 * (-1 * qx))
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ys)
          qx = 0.13 * u:getdata("吸血鬼变异数量") + u:getdata("加斯尔豺狼-枪械提升")
          if IsTimeNight() then
            ys = 10 * u:getdata("吸血鬼变异数量")
          else
            ys = 5 * u:getdata("吸血鬼变异数量")
          end
          ChangeValue(Correction_Gun, sy, 0.1 * (1 * qx))
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ys)
          if GetItemTypeId(u:getdata("装备枪支")) ~= Guns["加斯尔.豺狼(腐化)"] then
            u:deldata("加斯尔豺狼-蕾米强化-装备")
            u:deldata("加斯尔豺狼-顺序")
            u:changemaxhp(-1 * u:getdata("加斯尔豺狼-生命上限提升"))
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ys)
            ChangeValue(Correction_Gun, sy, 0.1 * (-1 * qx))
            t:remove()
          end
        end)
      end
    end
  end
  if lx == 2 or lx == 5 then
    u:addskill("A001")
    u:addskill("A1N2")
    u:addskill("A008")
    if gun == Guns["Et OmniaVanitas"] and not u:hasdata("枪械-白洲梓-虚无步枪") then
      u:setdata("枪械-白洲梓-虚无步枪")
      Hero_Tili_Huifu[sy] = Hero_Tili_Huifu[sy] + 0.1
      local bu = 0
      ac.loop(1000, function(t)
        ChangeValue(Correction_Gun_Bullet, sy, -1 * bu)
        bu = 0.05 + 0.02 * GetData(zgun, "枪械-枪械等级")
        ChangeValue(Correction_Gun_Bullet, sy, 1 * bu)
        if not u:hasdata("枪械-白洲梓-虚无步枪") then
          Hero_Tili_Huifu[sy] = Hero_Tili_Huifu[sy] - 0.1
          ChangeValue(Correction_Gun_Bullet, sy, -1 * bu)
          t:remove()
        end
      end)
    end
  end
  u:deldata("系统-狙击技能")
  u:deldata("系统-狙击换弹")
  if lx == 3 then
    u:addskill("A0CM")
  end
  if gun == Guns.AWP then
    u:addskill("A02J")
    u:addskill("A1N4")
    u:addskill("A1NL")
    u:addskill("A001")
    u:setdata("系统-狙击技能", "A02J")
    u:setdata("系统-狙击换弹", "A001")
  end
  if gun == Guns["AX338狙击枪"] then
    u:addskill("A0DO")
    u:addskill("A1NF")
    u:addskill("A1NL")
    u:addskill("A001")
    u:setdata("系统-狙击技能", "A0DO")
    u:setdata("系统-狙击换弹", "A001")
  end
  if gun == Guns.G3SG1 or gun == Guns["SIG550-N"] then
    u:addskill("A08G")
    u:addskill("A1N5")
    u:addskill("A1NL")
    u:addskill("A001")
    u:setdata("系统-狙击技能", "A08G")
    u:setdata("系统-狙击换弹", "A001")
  end
  if lx == 1 then
    u:addskill("A00P")
    u:addskill("A02B")
    u:addskill("A1N3")
  end
  if gun == Guns.M1014 then
    u:addskill("A034")
    u:addskill("A1N6")
    u:addskill("A03Y")
  end
  if gun == Guns.M3C then
    u:addskill("A06V")
    u:addskill("A1N7")
    u:addskill("A03X")
  end
  u:deldata("物品-梓山之弓")
  if lx == 6 then
    u:setdata("弓箭系统-装备中")
    u:addskill("A0DJ")
    u:addskill("A0DL")
    u:addskill("A0DY")
    u:addskill("A0E3")
    u:setdata("弓箭系统-X", 0)
    u:setdata("弓箭系统-Y", 0)
    if not u:hasdata("弓箭系统-注册") then
      u:setdata("弓箭系统-注册")
      
      local function skill(args)
        if args.skill == S2ID("A0DJ") then
          local x2 = args.x
          local y2 = args.y
          u:setdata("弓箭系统-X", x2)
          u:setdata("弓箭系统-Y", y2)
        end
        if args.skill == S2ID("A0DL") and not u:hasdata("弓箭系统-蓄力中") then
          local hasjs = false
          local jslx, jswp
          for i = 1, 6 do
            local wp = u:getcountitem(i)
            if wp ~= 0 then
              local wptype = GetItemTypeId(wp)
              if HasData(wptype, "弹药-箭矢") then
                jslx = wptype
                jswp = wp
                hasjs = true
                break
              end
            end
          end
          if not hasjs then
            local bb = getunit(Beibao[sy])
            for i = 1, 6 do
              local wp = bb:getcountitem(i)
              if wp ~= 0 then
                local wptype = GetItemTypeId(wp)
                if HasData(wptype, "弹药-箭矢") then
                  jslx = wptype
                  jswp = wp
                  hasjs = true
                  break
                end
              end
            end
          end
          if u:hasdata("变异判定-圣大人") and not hasjs then
            local wp = Shengdaren_Jianshi
            jslx = GetItemTypeId(wp)
            jswp = wp
            hasjs = true
          end
          if not hasjs then
            u:sendmessage("|cFF7DBEF1箭矢不足|r")
            return
          end
          ChangeItemCount(jswp, -1)
          if u:islocal() then
            u:setskilldatastring("A0E3", "图标", "war3mapImported\\BTNSystem_Bow01.tga")
          end
          u:setdata("弓箭系统-蓄力中")
          u:effectadd("war3mapImported\\0Tx_Bow (6).mdx", "hand left")
          local dx, dy = u:getxy()
          local x2 = u:getdata("弓箭系统-X")
          local y2 = u:getdata("弓箭系统-Y")
          local angle = AngleXY(dx, dy, x2, y2)
          local tx = Effectcreate("war3mapImported\\0Tx_Bow (5).mdl", dx, dy, 1, 0.4, 50, angle)
          ac.timer(100, 10, function()
            local dx, dy = u:getxy()
            SetEffectXY(tx, dx, dy)
          end)
          local tt = flytext({
            unit = u.handle,
            text = "",
            size = 8,
            time = -1,
            height = 0,
            xspeed = 0,
            yspeed = 0
          })
          local jcsh = GetData(jslx, "伤害")
          if jslx == S2ID("I05J") then
            jcsh = jcsh + 1000 * u:getlevel()
          end
          if jslx == S2ID("I0BR") then
            jcsh = jcsh + 800 * u:getlevel()
          end
          if jslx == S2ID("I0BQ") then
            jcsh = jcsh + 1600 * u:getlevel()
          end
          if jslx == S2ID("I0F5") then
            jcsh = jcsh + 444 * u:getlevel()
          end
          local ctsj = GetData(jslx, "穿透衰减")
          local ctcs = GetData(jslx, "穿透次数")
          local zgun = u:getdata("装备枪支")
          local bowtype = GetItemTypeId(zgun)
          local shxz = GetData(bowtype, "伤害修正")
          local xltime = 0
          local maxtime = GetData(bowtype, "蓄力时间")
          local csbfb = 0.1
          local sc = GetData(bowtype, "最大射程")
          if u:hasdata("变异判定-圣大人") then
            maxtime = maxtime * 0.5
            jcsh = jcsh * 1.5
            sc = sc * 1.25
          end
          if u:hasdata("物品-梓山之弓") then
            maxtime = maxtime * 10
            jcsh = jcsh * 10
          end
          SetTextTagText(tt, "|cFF7DBEF1" .. math.floor(xltime / maxtime * 100) .. "/100%", TextTagSize2Height(8))
          SetTextTagPosUnit(tt, u.handle, 0)
          u:playsound(Sound_Bow_01)
          ac.loop(30, function(timer)
            xltime = xltime + 0.03
            if xltime >= maxtime then
              xltime = maxtime
            end
            SetTextTagText(tt, "|cFF7DBEF1" .. math.floor(xltime / maxtime * 100) .. "/100%", TextTagSize2Height(8))
            SetTextTagPosUnit(tt, u.handle, 0)
            if u:hasdata("弓箭系统-蓄力取消") then
              if u:islocal() then
                u:setskilldatastring("A0E3", "图标", "war3mapImported\\BTNSystem_Bow02.tga")
              end
              local xlbfb = csbfb + (1 - csbfb) * (xltime / maxtime)
              u:playsound(Sound_Bow_02)
              local maxxl = false
              if xltime == maxtime then
                maxxl = true
                if u:hasdata("物品-梓山之弓") then
                  u:setdata("梓山之弓-必暴")
                  local yxz = {
                    {
                      yx = Sound_Jg_N01,
                      str = "我不会逃避，也不会躲藏。"
                    },
                    {
                      yx = Sound_Jg_N02,
                      str = "接下来，是你的头！"
                    },
                    {
                      yx = Sound_Jg_N03,
                      str = "你只有死路一条！"
                    }
                  }
                  local zs = GetRandomInt(1, #yxz)
                  PlayGlobalSound(yxz[zs].yx)
                  SendDtimeMsgAll(0, "|cFF826DCA桔|r|cFF7A62C7梗|r|cFFC5B6E4：『" .. yxz[zs].str .. "』|r", 10)
                end
              end
              local x, y = u:getxy()
              local x2 = u:getdata("弓箭系统-X") or 0
              local y2 = u:getdata("弓箭系统-Y") or 0
              local angle = AngleXY(x, y, x2, y2)
              local damage = jcsh * xlbfb * shxz
              unifycreate({
                owner = u.handle,
                model = "war3mapImported\\0Tx_Bow (3).mdl",
                modelname = "箭矢",
                modelsize = 1,
                height = 90,
                damage = damage,
                damagetype = 1,
                x = x,
                y = y,
                range = sc * xlbfb,
                speed = sc * 2 * xlbfb,
                volume = 90,
                angle = angle + 5 * (1 - xlbfb),
                angleoffset = 0,
                attenua = ctsj,
                attenuacount = ctcs,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                startfunc = function(mj)
                  mj:setdata("循环计数", 0)
                  mj:setdata("箭矢-判定")
                end,
                loopfunc = function(mj)
                  mj:changedata("循环计数", UnifyDT)
                  if mj:getdata("循环计数") >= 0.03 then
                    mj:setdata("循环计数", 0)
                  end
                end,
                hitfunc = function(mj, damage)
                  if u:hasdata("变异判定-桔梗") and not mj:hasdata("桔梗-爆炸触发") and (GetRandom100(30) or u:hasdata("梓山之弓-必暴")) then
                    mj:setdata("桔梗-爆炸触发")
                    local dx, dy = mj:getxy()
                    local fw = 350
                    local bl = 1
                    if u:hasdata("梓山之弓-必暴") then
                      fw = 700
                      bl = 2
                    end
                    mj:playsound(bac40)
                    Effectcreate("war3mapImported\\2.21.731.mdl", dx, dy, 0, 3.25 * bl)
                    for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      if xq:isboss() and u:hasdata("梓山之弓-必暴") then
                        u:setdata("梓山之弓-固伤")
                      end
                      DamageUnit({
                        bj = "梓山之弓(灵力爆发)",
                        unit = xq.handle,
                        source = u.handle,
                        damage = damage * bl,
                        level = 1,
                        type = "灵力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "无",
                        extradata = {""}
                      })
                      u:deldata("梓山之弓-固伤")
                    end
                    u:deldata("梓山之弓-必暴")
                  end
                  return damage
                end,
                hitbeforefunc = function(mj, xq, damage2)
                end,
                hitafterfunc = function(mj, xq, damage2)
                  if u:hasdata("变异判定-桔梗") and xq:getdata("桔梗-流血层数") < 20 then
                    xq:changetimedata("桔梗-流血层数", 1, 10)
                    xq:changetimedata("桔梗-流血伤害", 0.5 * damage, 10)
                  end
                end,
                endfunc = function(mj)
                end
              })
              u:deldata("弓箭系统-蓄力中")
              TimerDestroyTextTag(0, tt)
              timer:remove()
            end
          end)
        end
        if args.skill == S2ID("A0DY") then
          local x2 = args.x
          local y2 = args.y
          u:setdata("弓箭系统-X", x2)
          u:setdata("弓箭系统-Y", y2)
          if not u:hasdata("弓箭系统-蓄力取消") then
            u:settimedata("弓箭系统-蓄力取消", 0.15)
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
    end
    if gun == Guns["脉冲电荷弓"] then
      u:addskill("A1EW")
      u:banskill("A1EW", false)
      if not u:hasdata("弹射系统-判定") then
        u:setdata("弹射系统-判定")
        u:setdata("弹射系统-充能次数", 0)
        local cs = 0
        ac.loop(100, function(t)
          if u:isalive() then
            if u:getdata("弹射系统-充能次数") < 3 then
              cs = cs + 1
              if cs == 50 then
                cs = 0
                u:changedata("弹射系统-充能次数", 1)
                u:setskilldatastring("A1EW", "提示", "|cFF7DBEF1脉冲弹射(R) - 充能[" .. math.floor(u:getdata("弹射系统-充能次数")) .. "]|r")
              end
            else
              cs = 0
            end
          end
          if zgun ~= u:getdata("装备枪支") then
            u:deldata("弹射系统-判定")
            u:deldata("弹射系统-充能次数")
            t:remove()
          end
        end)
      end
      if not u:hasdata("弓箭系统-脉冲弹射注册") then
        u:setdata("弓箭系统-脉冲弹射注册")
        
        local function skill(args)
          if args.skill == S2ID("A1EW") then
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            if u:getdata("弹射系统-充能次数") > 0 then
              u:changedata("弹射系统-充能次数", -1)
              u:setskilldatastring("A1EW", "提示", "|cFF7DBEF1脉冲弹射(R) - 充能[" .. math.floor(u:getdata("弹射系统-充能次数")) .. "]|r")
              local angle = AngleXY(x, y, x2, y2)
              unitmove({
                unit = u.handle,
                time = 0.25,
                distance = 600,
                angle = angle,
                loops = {
                  {
                    looptime = 0.03,
                    func = function(dx, dy)
                      Effectcreate("Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl", dx, dy)
                    end
                  }
                }
              })
            else
              u:sendmessage("|cFF7DBEF1充能次数不足|r")
            end
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
    end
    if gun == Guns["梓山之弓"] then
      u:setdata("物品-梓山之弓")
      u:addskill("A1GC")
      u:banskill("A1GC", false)
      if not u:hasdata("弹射系统-判定") then
        u:setdata("弹射系统-判定")
        u:setdata("弹射系统-充能次数", 0)
        local cs = 0
        ac.loop(100, function(t)
          if u:isalive() then
            if u:getdata("弹射系统-充能次数") < 3 then
              cs = cs + 1
              if cs == 30 then
                cs = 0
                u:changedata("弹射系统-充能次数", 1)
                u:setskilldatastring("A1GC", "提示", "|cFF826DCA魂之追击(R) - 充能[" .. math.floor(u:getdata("弹射系统-充能次数")) .. "]|r")
              end
            else
              cs = 0
            end
          end
          if zgun ~= u:getdata("装备枪支") then
            u:deldata("弹射系统-判定")
            u:deldata("弹射系统-充能次数")
            t:remove()
          end
        end)
      end
      if not u:hasdata("弓箭系统-死魂追击注册") then
        u:setdata("弓箭系统-死魂追击注册")
        
        local function skill(args)
          if args.skill == S2ID("A1GC") then
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            if u:getdata("弹射系统-充能次数") > 0 then
              u:changedata("弹射系统-充能次数", -1)
              u:setskilldatastring("A1GC", "提示", "|cFF826DCA魂之追击(R) - 充能[" .. math.floor(u:getdata("弹射系统-充能次数")) .. "]|r")
              local angle = AngleXY(x, y, x2, y2)
              unitmove({
                unit = u.handle,
                time = 0.25,
                distance = 600,
                angle = angle,
                loops = {
                  {
                    looptime = 0.03,
                    func = function(dx, dy)
                      unifycreate({
                        owner = u.handle,
                        model = "war3mapImported\\Texiao_baiyu.mdl",
                        modelname = "死魂蝶",
                        modelsize = 0.35,
                        height = 90,
                        damage = 10000 + 1000 * u:getlevel(),
                        damagetype = 6,
                        x = dx,
                        y = dy,
                        range = 3000,
                        speed = 500,
                        volume = 90,
                        angle = GetRandomAngle(),
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
                            local dx, dy = mj:getxy()
                            if mj:hasdata("弹幕-追踪单位") then
                              local dangle = AngleBetweenUnits(mj.handle, mj:getdata("弹幕-追踪单位"))
                              local angleDelta = dangle - mj:getface()
                              if 180.0 <= angleDelta then
                                angleDelta = angleDelta - 360.0
                              elseif angleDelta <= -180.0 then
                                angleDelta = angleDelta + 360.0
                              end
                              if 60.0 < angleDelta then
                                angleDelta = 60.0
                              elseif angleDelta < -60.0 then
                                angleDelta = -60.0
                              end
                              mj:setface(mj:getface() + angleDelta)
                            else
                              mj:setdata("弹幕-穿透次数", 1)
                              for _, xq in ac.selector():in_rangexy(dx, dy, 500):is_enemy(u.handle):ipairs() do
                                xq = getunit(xq)
                                mj:setdata("弹幕-追踪单位", xq.handle)
                                break
                              end
                            end
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
                  }
                }
              })
            else
              u:sendmessage("|cFF7DBEF1充能次数不足|r")
            end
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
    end
  end
  if gun == Guns["维拉之判决"] then
    u:addskill("A1FE")
    u:addskill("A1FF")
  end
  if gun == Guns["演算宝珠"] then
    u:addskill("A1EY")
    u:addskill("A0MU")
  end
  if gun == Guns["魔力压缩器"] then
    u:addskill("A1EY")
    u:addskill("A0MU")
  end
  if gun == Guns["光之剑超新星"] then
    u:addskill("A03L")
    u:addskill("A03P")
    u:setdata("枪械判定-光之剑超新星")
  end
  if gun == Guns["魔弹"] then
    u:addskill("A09E")
    u:addskill("A09F")
    u:setdata("枪械判定-魔弹")
    u:playsound(Sound_Angela_Wa_01)
  end
  if gun == Guns["新月玫瑰"] then
    u:setdata("枪械判定-新月玫瑰")
  end
end

function gunchangedel(unit)
  local u = getunit(unit)
  local p = getplayer(u.owner)
  local sy = u.ownerid
  local bb = getunit(System_ZbBeibao[sy])
  local zgun
  if u.type == HeroType["铃仙"] then
    zgun = u:getdata("专属枪支")
    bb:dropitem(zgun)
    u:addspeitem(zgun)
    return
  else
    zgun = u:getdata("装备枪支")
  end
  local fgun = u:getdata("辅助枪支")
  if zgun ~= ITEM_KONG then
    Juji_Zb[sy] = false
    if GetData(zgun, "枪械模块-雷电") > 0 then
      ChangeValue(Damage_Element_Thunder_NotJz, sy, -0.1 * GetData(zgun, "枪械模块-雷电"))
    end
    if u.type == HeroType["C呆"] then
      bb:dropitem(zgun)
      u:addspeitem(zgun)
      u:setdata("装备枪支", ITEM_KONG)
      u:deldata("Caber-枪支类型")
      RefreshCritWeaponBonus(u.handle)
      return
    end
    bb:dropitem(zgun)
    u:addspeitem(zgun)
    u:setdata("装备枪支", ITEM_KONG)
    u:deldata("是否射击")
    u:setdata("枪支换弹", false)
    u:setdata("霰弹换弹", false)
    u:deldata("弓箭系统-装备中")
    u:delskill("A0DJ")
    u:delskill("A0DL")
    u:delskill("A0DY")
    u:delskill("A0E3")
    gundataclear(u)
  end
  if fgun ~= ITEM_KONG then
    bb:dropitem(fgun)
    u:addspeitem(fgun)
    u:setdata("辅助枪支", ITEM_KONG)
    u:setdata("辅助换弹", false)
    u:deldata("是否射击")
    u:setdata("霰弹换弹", false)
  end
  gundel(unit)
  RefreshCritWeaponBonus(u.handle)
  u:delskill("A0CM")
  if u:hasdata("武器判定-特殊近战武器") then
    weapondown(u.handle, false, true)
  end
end

function gunchangeend(unit)
  local u = getunit(unit)
  local zgun = u:getdata("装备枪支")
  local gun = GetItemTypeId(zgun)
  local lx = GetData(gun, "枪械类型")
  local x, y = u:getxy()
  local sy = u.ownerid
  if u:hasdata("缇娜天赋-枪斗术阿尔法") then
    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
    local sh = 750 * u:getstr()
    for _, xq in ac.selector():in_rangexy(x, y, 275):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
      DamageUnit({
        bj = "缇娜(枪斗术阿尔法)",
        unit = xq.handle,
        source = u.handle,
        damage = sh,
        isattack = true,
        extradata = {"近战"}
      })
    end
  end
  ac.wait(30, function()
    if lx == 8 and (GetItemCharges(zgun) == 0 or GetItemCharges(zgun) <= GetData(gun, "弹匣容量")) then
      IssueNeutralImmediateOrderById(u.owner, unit, String2OrderIdBJ("berserk"))
    end
  end)
end

function ReturnGunMokuaiData(gun, loc)
  local mokuai = GetData(gun, "枪械模块-" .. loc) or "无"
  local lv = GetData(gun, "枪械模块等级-" .. loc) or 1
  return mokuai, lv
end

function gunshowrefreesh(unit)
  local u = getunit(unit)
  local sy = u.ownerid
  local p = getplayer(u.owner)
  local zb = false
  local str = "|cFFFF9900弹匣："
  local str2 = "|cFFFF9900弹匣："
  local gun = u:getdata("装备枪支")
  local fgun = u:getdata("辅助枪支")
  local qz1 = GetItemTypeId(gun)
  local lim = GetData(qz1, "弹匣容量")
  local lx = GetData(qz1, "枪械类型")
  local now = 0
  local max = 0
  local now2 = 0
  local max2 = 0
  if u.type == HeroType["铃仙"] then
    zb = true
    gun = u:getdata("专属枪支")
    qz1 = u:getdata("吞噬枪支")
    lim = GetData(qz1, "弹匣容量")
    lx = GetData(qz1, "枪械类型")
    if 0 < GetData(gun, "铃仙剪影模块-弹匣") then
      if lx == 3 or lx == 8 then
        if lim <= 100 then
          lim = lim + 5 * GetData(gun, "铃仙剪影模块-弹匣")
        else
          lim = lim * (1 + 0.05 * GetData(gun, "铃仙剪影模块-弹匣"))
        end
      elseif lim <= 20 then
        lim = lim + 1 * GetData(gun, "铃仙剪影模块-弹匣")
      else
        lim = lim * (1 + 0.05 * GetData(gun, "铃仙剪影模块-弹匣"))
      end
    end
    now = math.floor(GetItemCharges(gun))
    local mk_dx, lv_dx = ReturnGunMokuaiData(gun, "弹匣")
    if mk_dx == "扩容弹匣" then
      lim = lim * (1 + 0.5 * lv_dx)
    end
    max = math.floor(lim)
    str2 = str2 .. math.floor(GetItemCharges(gun)) .. "/" .. math.floor(lim)
    if lx == 3 then
      local xh = 0
      if qz1 == Guns["AX338狙击枪"] then
        xh = 10
      else
        xh = 5
      end
      Juji_Zidan[sy] = GetItemCharges(gun) / xh
      Juji_ZidanMax[sy] = lim / xh
    end
  else
    if gun ~= ITEM_KONG then
      zb = true
      str2 = str2 .. math.floor(GetItemCharges(gun)) .. "/" .. math.floor(lim)
      now = math.floor(GetItemCharges(gun))
      local mk_dx, lv_dx = ReturnGunMokuaiData(gun, "弹匣")
      if mk_dx == "扩容弹匣" then
        lim = lim * (1 + 0.5 * lv_dx)
      end
      max = math.floor(lim)
    end
    if fgun ~= ITEM_KONG then
      u:setdata("UI-双持")
      local qz2 = GetItemTypeId(fgun)
      lim = GetData(qz2, "弹匣容量")
      str2 = str2 .. math.floor(GetItemCharges(fgun)) .. "/" .. math.floor(lim)
      now2 = math.floor(GetItemCharges(fgun))
      local mk_dx, lv_dx = ReturnGunMokuaiData(fgun, "弹匣")
      if mk_dx == "扩容弹匣" then
        lim = lim * (1 + 0.5 * lv_dx)
      end
      max2 = math.floor(lim)
    else
      u:deldata("UI-双持")
    end
  end
  str2 = str2 .. "|r"
  if EnableCustomUI then
    if u.type == HeroType["C呆"] then
      zb = false
    end
    if zb then
      u:setdata("UI-弹药显示")
      if u:hasdata("UI-双持") then
        u:setdata("UI-弹药数量2", now2)
        u:setdata("UI-弹药数量上限2", max2)
      end
    else
      u:deldata("UI-弹药显示")
    end
  else
    if u.type == HeroType["C呆"] and gun ~= ITEM_KONG then
      zb = true
      str2 = "|cFFFF9900武装魔导术形态："
      if u:getdata("Caber-枪支类型") == 1 then
        str2 = str2 .. "魔力弹"
      end
      if u:getdata("Caber-枪支类型") == 2 then
        str2 = str2 .. "魔炮"
      end
      if u:getdata("Caber-枪支类型") == 3 then
        str2 = str2 .. "魔力爆破"
      end
      str2 = str2 .. "|r"
    end
    if zb then
      UI_Text_Reload[sy]:set_text(str2)
      if p:islocal() then
        UI_Text_Reload[sy]:show()
      end
    else
      UI_Text_Reload[sy]:hide()
    end
  end
  u:setdata("系统-当前弹药数量", now)
  u:setdata("系统-当前弹药数量2", now2)
  u:setdata("UI-弹药数量", now)
  u:setdata("UI-弹药数量上限", max)
  if now == 0 then
    u:setdata("系统-空弹")
  else
    u:deldata("系统-空弹")
  end
end

function gundel(unit)
  local u = getunit(unit)
  for i = 1, #Gunskill do
    u:delskill(Gunskill[i])
  end
end

local spshotskill = {
  "A1N7",
  "A1N6",
  "A1N3",
  "A1N2",
  "A1N4",
  "A1N5",
  "A1N8",
  "A1N9",
  "A1NA",
  "A1NB",
  "A1NC",
  "A1NC",
  "A1ND",
  "A1NE",
  "A1NF"
}
local notspshotskill = {
  "A0DO",
  "A06V",
  "A034",
  "A00P",
  "A008",
  "A02J",
  "A08G",
  "A0DP",
  "A03A",
  "A03B",
  "A03D",
  "A0N4",
  "A0N5",
  "A0N6"
}

function gunban(unit, boolean)
  if boolean ~= nil then
  else
    boolean = true
  end
  local u = getunit(unit)
  for i = 1, #Gunskill do
    u:banskill(Gunskill[i], boolean)
  end
  if boolean == false then
    if u:hasdata("枪械射击-快捷施法") then
      for i = 1, #spshotskill do
        u:banskill(spshotskill[i], boolean)
      end
      for i = 1, #notspshotskill do
        u:banskill(notspshotskill[i])
      end
    else
      for i = 1, #spshotskill do
        u:banskill(spshotskill[i])
      end
      for i = 1, #notspshotskill do
        u:banskill(notspshotskill[i], boolean)
      end
    end
  end
end

function gunbankj(u)
  for i = 1, #spshotskill do
    u:banskill(spshotskill[i])
  end
end
