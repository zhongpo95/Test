-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
Vars_Ciyuan_Niuqu = {
  {
    name = "威蕾丝",
    weight = 25,
    lv = 3,
    key = {
      "唯一",
      "白毛",
      "战士",
      "黑暗",
      "恶魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("扭曲力量", 1)
      SendMsgAll("|cFF6633FF『|r|cFF6B3BFF来|r|cFF7143FF吧|r|cFF764BFF！|r|cFF7B53FF我|r|cFF815BFF准|r|cFF8663FF备|r|cFF8C6BFF好|r|cFF9173FF了|r|cFF967BFF！|r|cFF9C84FF好|r|cFFA18CFF跃|r|cFFA694FF跃|r|cFFAC9CFF欲|r|cFFB1A4FF试|r|cFFB7ACFF啊|r|cFFBCB4FF！|r|cFFC1BCFF』|r")
      PlayGlobalSound(Sound_Nq_Wls_01)
      u:changedata("力量增幅", 0.05)
      u:changedata("敏捷增幅", 0.05)
      u:addstr(100)
      u:addagi(100)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.5)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata("威蕾丝-怪力冷却") then
          u:setdata("威蕾丝-怪力冷却", 5)
          local x2, y2 = tg:getxy()
          Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x2, y2)
          Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x2, y2, 0, 3)
          Effectcreate("BTX\\[BTxNew]LionKing_01.mdx", x2, y2, 0, 2, 0, tg:getface())
          local txsh = 250 * (u:getstr() + u:getagi())
          ac.timer(50, 3, function()
            DamageUnit({
              bj = "威蕾丝怪力",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗",
              extradata = {"法术", "魔导"}
            })
            tg:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", "origin")
          end)
        end
        ac.wait(10, function()
          if not tg:isalive() then
            ChangeValue(Correction_Jzsh, sy, 5.9999999999999995E-5)
            u:changemaxhp(1)
          end
        end)
      end)
      local ewss = 0
      local mlz = 0
      local jzjc = 0
      ac.loop(1000, function()
        u:changedata("魔力值", 1)
        u:changemaxhp(-1)
        ChangeValue(Correction_Jzsh, sy, -2.9999999999999997E-5)
        ChangeValue(DamageSystem_Sszengjia, sy, -ewss)
        ewss = 0.02 * u:getdata("光明变异数量")
        ChangeValue(DamageSystem_Sszengjia, sy, ewss)
        u:changedata("魔力值", -mlz)
        mlz = 5 * u:getstr()
        u:changedata("魔力值", mlz)
        u:changedata("近战机体-基础伤害提升", -jzjc)
        jzjc = 1 * u:getdata("魔力值")
        u:changedata("近战机体-基础伤害提升", jzjc)
        if u:getdata("威蕾丝-怪力冷却") > 0 then
          u:changedata("威蕾丝-怪力冷却", -1)
          if u:getdata("威蕾丝-怪力冷却") <= 0 then
            u:deldata("威蕾丝-怪力冷却")
          end
        end
      end)
      local dskill = S2ID("A1GY")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local yxz = {
              Sound_Nq_Wls_02,
              Sound_Nq_Wls_03,
              Sound_Nq_Wls_04
            }
            u:playsound(yxz[GetRandomInt(1, #yxz)])
            u:clearbuff()
            u:clearbuff("眩晕")
            u:clearbuff("僵直")
            u:clearbuff("缠绕")
            ChangeTimeValue(HeroMenu_HpChange_MaxHp, sy, 10, 40)
            u:changetimedata("力量增幅", 0.2, 40)
            u:changetimedata("敏捷增幅", 0.2, 40)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFF9966FF威|r|cFFA680FF蕾|r|cFFB299FF丝|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF9966FF唯一 白毛 黑暗 恶魔 战士|r\n|cFF9966FF恶魔之力量|r\n|cFFB299FF获取时提升100点力量与敏捷\n提升5%力量\n提升5%敏捷\n提升0.5%生命恢复\n解锁[肉体强化]|r\n|cFF9966FF强化怪力|r\n|cFFB299FF近战伤害杀敌时提升0.006%近战伤害与1点生命上限\n每秒提升1点魔力值\n提升[力量*5]魔力值\n提升[魔力值*1]近战基础伤害\n近战伤害附带三段[250*(力量+敏捷)]暗属性物理伤害(法术,魔导),触发冷却5秒,使用位移技能后立刻刷新冷却|r\n|cFF9966FF侵蚀|r\n|cFFB299FF提升[2%*光明变异数量]额外受伤\n每秒降低1点生命上限\n每秒降低0.003%近战伤害|r",
    effectart = "war3mapImported\\BTNNql_03.tga",
    test = ""
  },
  {
    name = "缇欧",
    weight = 25,
    lv = 3,
    key = {
      "唯一",
      "白毛",
      "影",
      "黑暗",
      "恶魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("扭曲力量", 1)
      SendMsgAll("|cFF6633FF『|r|cFF6A39FF啊|r|cFF6E3FFF啦|r|cFF7245FF~|r|cFF764BFF是|r|cFF7A52FF您|r|cFF7E58FF召|r|cFF835EFF唤|r|cFF8764FF了|r|cFF8B6AFF我|r|cFF8F70FF吗|r|cFF9376FF？|r|cFF977CFF失|r|cFF9B83FF礼|r|cFF9F89FF了|r|cFFA38FFF-|r|cFFA795FF-|r|cFFAB9BFF我|r|cFFAFA1FF名|r|cFFB4A7FF叫|r|cFFB8ADFF缇|r|cFFBCB4FF欧|r|cFFC0BAFF。|r|cFFC4C0FF』|r")
      PlayGlobalSound(Sound_Nq_To_01)
      local ewss = 0
      local gd = 0
      ac.loop(1000, function()
        if u:hasdata("变身状态") then
          u:changedata("魔力值", 3)
        end
        u:changemaxhp(-1)
        ChangeValue(DamageSystem_Shjc, sy, -3.0E-5)
        ChangeValue(DamageSystem_Sszengjia, sy, -ewss)
        ewss = 0.02 * u:getdata("光明变异数量")
        ChangeValue(DamageSystem_Sszengjia, sy, ewss)
        u:changedata("固定格挡", -gd)
        if u:hasdata("缇欧-龙化暗") then
          gd = 1 * u:getdata("魔力值")
        else
          gd = 0
        end
        u:changedata("固定格挡", gd)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        if u:hasdata("变身状态") then
          ChangeValue(DamageSystem_Shjc, sy, 3.0E-4)
          u:changemaxhp(3)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u.type == S2ID("E00C") and not u:hasdata("缇欧" .. "-特效冷却") then
          u:settimedata("缇欧" .. "-特效冷却", 0.1)
          local txsh = 100 * u:getallattri()
          DamageUnit({
            bj = "缇欧变身",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗",
            extradata = {"法术", "魔导"}
          })
          tg:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
        end
        if u.type == S2ID("E00D") and not u:hasdata("缇欧" .. "-特效冷却") then
          u:settimedata("缇欧" .. "-特效冷却", 0.1)
          local txsh = 100 * u:getallattri()
          local x2, y2 = tg:getxy()
          for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "缇欧变身",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗",
              extradata = {"法术", "魔导"}
            })
            xq:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
          end
        end
      end)
      local dskill = S2ID("A1GZ")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
        end
      end)
      
      local function trg(args)
        if args.chat == "龙化暗" and u:isalive() then
          u:heshin("龙化暗")
        end
        if args.chat == "兽化暗" and u:isalive() then
          u:heshin("兽化暗")
        end
        if args.chat == "恶魔显现" and u:isalive() then
          u:heshin("恶魔显现")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
    end,
    effectname = "|cFF9966FF缇|r|cFFAA88FF欧|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF9966FF唯一 白毛 黑暗 恶魔 影|r\n|cFF9966FF恶魔之变化|r\n|cFFB299FF解锁[恶魔之变化]|r\n|cFF9966FF形态恶魔|r\n|cFFB299FF变身状态下每秒提升3魔力值\n变身状态下杀敌时提升3点生命上限与0.03%伤害加成\n提升25%变身持续时间\n发动变身效果时提升自身15点全属性\n变身状态下提升75%受伤减少|r\n|cFF9966FF侵蚀|r\n|cFFB299FF提升[2%*光明变异数量]额外受伤\n每秒降低1点生命上限\n每秒降低0.003%伤害加成|r",
    effectart = "war3mapImported\\BTNNql_04",
    test = ""
  },
  {
    name = "索妮亚姆",
    weight = 25,
    lv = 3,
    key = {
      "唯一",
      "白毛",
      "灵魂",
      "同奏",
      "黑暗",
      "恶魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("扭曲力量", 1)
      SendMsgAll("|cFF9966FF『|r|cFF9A69FF欸|r|cFF9C6BFF多|r|cFF9D6EFF~|r|cFF9E70FF你|r|cFFA073FF就|r|cFFA176FF是|r|cFFA278FF召|r|cFFA37BFF唤|r|cFFA57EFF者|r|cFFA680FF么|r|cFFA783FF.|r|cFFA985FF.|r|cFFAA88FF.|r|cFFAB8BFF啊|r|cFFAD8DFF,|r|cFFAE90FF不|r|cFFAF92FF需|r|cFFB195FF要|r|cFFB298FF问|r|cFFB39AFF呢|r|cFFB49DFF。|r|cFFB6A0FF我|r|cFFB7A2FF的|r|cFFB8A5FF名|r|cFFBAA7FF字|r|cFFBBAAFF是|r|cFFBCADFF索|r|cFFBEAFFF妮|r|cFFBFB2FF亚|r|cFFC0B4FF姆|r|cFFC2B7FF,|r|cFFC3BAFF请|r|cFFC4BCFF多|r|cFFC5BFFF指|r|cFFC7C2FF教|r|cFFC8C4FF~|r|cFFC9C7FF』|r")
      PlayGlobalSound(Sound_Nq_Snym_01)
      local ewss = 0
      local gd = 0
      ac.loop(1000, function()
        u:changedata("魔力值", 1)
        u:changemaxhp(-1)
        ChangeValue(DamageSystem_Shjc, sy, -3.0E-5)
        ChangeValue(DamageSystem_Sszengjia, sy, -ewss)
        ewss = 0.02 * u:getdata("光明变异数量")
        ChangeValue(DamageSystem_Sszengjia, sy, ewss)
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          info.endup = info.endup + 0.12
        end
      end)
      u:setdata("索妮亚姆-混乱概率", 10)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local dis = DistanceBetweenUnits(tg.handle, u.handle)
          if dis <= 250 and u:getluckrandom(info.txgl * u:getdata("索妮亚姆-混乱概率")) then
            u:settimedata(var.name .. "-特效冷却", 0.1)
            local time = 3
            if tg:isboss() then
              time = 1
            end
            tg:buffset(u.handle, time, "混乱")
            tg:changetimedata("索妮亚姆-混乱概率", -3, time)
          end
        end
      end)
      local dskill = S2ID("A1H0")
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
          if tg:isboss() then
            b = false
            u:sendmessage("|cFF7DBEF1不能以BOSS为目标|r")
          end
          if tg.handle == u.handle then
            b = false
            u:sendmessage("|cFF7DBEF1不能以自己为目标|r")
          end
          if dis > 250 * Correction_Distance[sy] then
            b = false
            u:sendmessage("|cFF7DBEF1超出施法距离|r")
          end
          if b then
            local yxz = {
              Sound_Nq_Snym_02,
              Sound_Nq_Snym_03,
              Sound_Nq_Snym_04,
              Sound_Nq_Snym_05
            }
            u:playsound(yxz[GetRandomInt(1, #yxz)])
            tg:buffset(u.handle, 15, "混乱")
            if tg:isingroup(Group_PlayHero) then
              local wj = u.owner
              local wj2 = tg.owner
              local sy2 = tg.ownerid
              ChangeValue(DamageSystem_Sszengjia, sy2, 1)
              ChangeValue(DamageSystem_EndSh, sy2, 0.1)
              tg:changedata("全属性增幅", 0.125)
              ac.loop(250, function(timer)
                SetPlayerAlliance(wj2, wj, ALLIANCE_SHARED_VISION, true)
                SetPlayerAlliance(wj2, wj, ALLIANCE_SHARED_CONTROL, true)
                if not tg:hasbuff("混乱") then
                  ChangeValue(DamageSystem_Sszengjia, sy2, -1)
                  ChangeValue(DamageSystem_EndSh, sy2, -0.1)
                  tg:changedata("全属性增幅", -0.125)
                  SetPlayerAlliance(wj2, wj, ALLIANCE_SHARED_VISION, false)
                  SetPlayerAlliance(wj2, wj, ALLIANCE_SHARED_CONTROL, false)
                  timer:remove()
                end
              end)
            else
              tg:addskill("A1H4")
              tg:changearmor(100)
              ac.wait(15000, function()
                tg:delskill("A1H4")
                tg:changearmor(-100)
              end)
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFF9966FF索|r|cFFA37AFF妮|r|cFFAD8FFF亚|r|cFFB8A3FF姆|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF9966FF唯一 白毛 黑暗 恶魔 同奏 灵魂|r\n|cFF9966FF恶魔之精神|r\n|cFFB299FF免疫混乱失控\n直接伤害250范围内敌军时,[10%-3%*已影响目标]混乱目标3(1)秒\n被自身混乱的单位提升100%攻击,攻速与移速\n解锁[精神操纵]|r\n|cFF9966FF神智烙印|r\n|cFFB299FF杀死处于混乱状态的单位时提升2点生命上限与0.02%伤害加成\n对混乱中单位提升12%伤害\n受到来自混乱中单位的伤害降低50%\n施加混乱时25%提升1点属性,冷却1秒|r\n|cFF9966FF侵蚀|r\n|cFFB299FF提升[2%*光明变异数量]额外受伤\n每秒降低1点生命上限\n每秒降低0.003%伤害加成|r",
    effectart = "war3mapImported\\BTNNql_05",
    test = ""
  },
  {
    name = "嘉缇娜",
    weight = 25,
    lv = 3,
    key = {
      "唯一",
      "白毛",
      "魔导",
      "黑暗",
      "恶魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("扭曲力量", 1)
      SendMsgAll("|cFF9966FF『|r|cFF9C6BFF契|r|cFF9E70FF约|r|cFFA175FF成|r|cFFA37AFF立|r|cFFA67FFF,|r|cFFA885FF那|r|cFFAB8AFF么|r|cFFAD8FFF接|r|cFFB094FF下|r|cFFB399FF来|r|cFFB59EFF就|r|cFFB8A3FF叫|r|cFFBAA8FF我|r|cFFBDADFF嘉|r|cFFBFB2FF缇|r|cFFC2B8FF娜|r|cFFC4BDFF吧|r|cFFC7C2FF』|r")
      PlayGlobalSound(Sound_Nq_Jtn_01)
      local ewss = 0
      local gd = 0
      local mlz = 0
      ac.loop(1000, function()
        u:changedata("魔力值", 1)
        u:changemaxhp(-1)
        ChangeValue(DamageSystem_Shjc, sy, -3.0E-5)
        ChangeValue(DamageSystem_Sszengjia, sy, -ewss)
        ewss = 0.02 * u:getdata("光明变异数量")
        ChangeValue(DamageSystem_Sszengjia, sy, ewss)
        u:changedata("魔力值", -mlz)
        mlz = 5 * u:getagi()
        u:changedata("魔力值", mlz)
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasbuff("缠绕") then
          info.endup = info.endup + 0.12
        end
        if tg:hasbuff("僵直") then
          info.endup = info.endup + 0.12
        end
      end)
      u:setdata("索妮亚姆-混乱概率", 10)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local dis = DistanceBetweenUnits(tg.handle, u.handle)
        if dis <= 900 then
          if not tg:hasdata(var.name .. "-特效冷却") and u:getluckrandom(info.txgl * (10 - dis / 90)) then
            tg:settimedata(var.name .. "-特效冷却", 0.1)
            tg:buffset(u.handle, 1, "僵直")
          end
          if not tg:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(info.txgl * (10 - dis / 90)) then
            tg:settimedata(var.name .. "-特效2冷却", 0.1)
            tg:buffset(u.handle, 1, "缠绕")
          end
        end
      end)
      u:addstexiao(var.name, "施加Buff时效果-缠绕", function(args)
        local u = args.u
        local tg = args.tg
        local time = args.time
        if not tg:hasdata("精英特性-免疫失效") then
          tg:settimedata("精英特性-免疫失效", time)
        end
        if not tg:hasdata(var.name .. "-伤害特效冷却") then
          tg:settimedata(var.name .. "-伤害特效冷却", 0.1)
          local txsh = 125 * u:getdata("魔力值") + 10 * u:getagi() * u:getstate("黑暗变异")
          DamageUnit({
            bj = "嘉缇娜-黑暗之力",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗",
            extradata = {"法术", "魔导"}
          })
        end
      end)
      u:addstexiao(var.name, "施加Buff时效果-僵直", function(args)
        local u = args.u
        local tg = args.tg
        local time = args.time
        if not tg:hasdata("精英特性-免疫失效") then
          tg:settimedata("精英特性-免疫失效", time)
        end
        if not tg:hasdata(var.name .. "-伤害特效冷却") then
          tg:settimedata(var.name .. "-伤害特效冷却", 0.1)
          local txsh = 125 * u:getdata("魔力值") + 10 * u:getagi() * u:getstate("黑暗变异")
          DamageUnit({
            bj = "嘉缇娜-黑暗之力",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗",
            extradata = {"法术", "魔导"}
          })
        end
      end)
      local dskill = S2ID("A1GX")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
            return
          end
          if b then
            local yxz = {
              Sound_Nq_Jtn_03,
              Sound_Nq_Jtn_04,
              Sound_Nq_Jtn_05,
              Sound_Nq_Jtn_06,
              Sound_Nq_Jtn_07
            }
            u:playsound(yxz[GetRandomInt(1, #yxz)])
            ac.timer(3000, 10, function()
              u:playsound(Sound_Nq_Jtn_12)
              local x1, y1 = u:getxy()
              Effectcreate("war3mapImported\\Texiao_Jtn_01.mdl", x1, y1, 2, 4.5, 0, GetRandomAngle())
              local g = CreateGroupLua()
              ForGroupLuaNew(Group_Randomunits(Group_Monster, 3), function(xq)
                xq:groupadd(g)
              end)
              for _, xq in ac.selector():in_rangexy(x1, y1, 600):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
              end
              ForGroupLuaNew(g, function(xq)
                local x2, y2 = xq:getxy()
                Effectcreate("war3mapImported\\Texiao_Jtn_02.mdl", x2, y2)
                if xq:hasbuff("僵直") then
                  xq:buffset(u.handle, 2, "眩晕")
                end
                xq:buffset(u.handle, 2, "僵直")
              end)
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFF9966FF嘉|r|cFFA680FF缇|r|cFFB299FF娜|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF9966FF唯一 白毛 黑暗 恶魔 魔导|r\n|cFF9966FF恶魔之束缚|r\n|cFFB299FF自身施加僵直或缠绕时使精英特性免疫失效对应时间\n对[僵直]中单位提升12%伤害\n对[缠绕]中单位提升12%伤害\n解锁技能[痛苦召唤]|r\n|cFF9966FF黑暗之力|r\n|cFFB299FF杀敌时提升0.006%伤害加成与1点生命上限\n每秒提升1点魔力值\n提升[敏捷*5]魔力值\n直接伤害900距离内单位时,10%~0%缠绕目标1秒或僵直目标1秒,随着距离增加概率衰减,独立冷却1秒\n施加[僵直]或[缠绕]时附带[125*魔力值+黑暗变异*10*敏捷]暗属性魔力伤害(法术,魔导),独立冷却0.1秒(僵直与缠绕冷却独立)|r\n|cFF9966FF侵蚀|r\n|cFFB299FF提升[2%*光明变异数量]额外受伤\n每秒降低1点生命上限\n每秒降低0.003%伤害加成|r",
    effectart = "war3mapImported\\BTNNql_02",
    test = ""
  },
  {
    name = "法琦尔",
    weight = 25,
    lv = 3,
    key = {
      "唯一",
      "白毛",
      "机械",
      "黑暗",
      "恶魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("扭曲力量", 1)
      SendMsgAll("|cFF6633FF『|r|cFF6B3AFF我|r|cFF6F41FF叫|r|cFF7448FF法|r|cFF794FFF琦|r|cFF7D56FF尔|r|cFF825DFF.|r|cFF8664FF.|r|cFF8B6BFF.|r|cFF9072FF是|r|cFF9479FF你|r|cFF997FFF召|r|cFF9E86FF唤|r|cFFA28DFF的|r|cFFA794FF我|r|cFFAC9BFF吗|r|cFFB0A2FF.|r|cFFB5A9FF.|r|cFFB9B0FF.|r|cFFBEB7FF？|r|cFFC3BEFF』|r")
      PlayGlobalSound(Sound_Nq_Fqe_01)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      ChangeValue(Correction_Gun, sy, 0.025)
      local ewss = 0
      local gd = 0
      local mlz = 0
      local zs = 0
      ac.loop(1000, function()
        u:changedata("魔力值", 1)
        u:changemaxhp(-1)
        ChangeValue(Correction_Magic, sy, -3.0E-6)
        ChangeValue(DamageSystem_Sszengjia, sy, -ewss)
        ewss = 0.02 * u:getdata("光明变异数量")
        ChangeValue(DamageSystem_Sszengjia, sy, ewss)
        u:changedata("魔力值", -mlz)
        mlz = 5 * u:getint()
        u:changedata("魔力值", mlz)
        if zs ~= u:getdata("黑暗变异数量") then
          local add = 0.1 * (u:getdata("黑暗变异数量") - zs)
          ChangeValue(Correction_Jzsh, sy, 0.1 * add)
          ChangeValue(Correction_Gun, sy, 0.1 * add)
          zs = u:getdata("黑暗变异数量")
        end
      end)
      u:addskill("A1H2")
      local dskill = S2ID("A1GW")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          local target = args.target
          local itemtype = GetItemTypeId(target)
          local itemtpyeid = ID2S(itemtype)
          local prio = tonumber(slk.item[itemtpyeid].prio)
          if 1 <= prio and prio <= 12 then
          elseif GetItemType(target) == ITEM_TYPE_PERMANENT and itemtpyeid ~= "I0C1" and itemtpyeid ~= "I0BE" then
          else
            b = false
            u:sendmessage("|cFF7DBEF1不合法目标|r")
          end
          if b then
            local yxz = {
              Sound_Nq_Fqe_02
            }
            u:playsound(yxz[GetRandomInt(1, #yxz)])
            u:chat("来自期待的绝望最有效率")
            if u:hasdata("法琦尔-恶魔制造目标") then
              DelData(u:getdata("法琦尔-恶魔制造目标"), "法琦尔-恶魔制造")
            end
            SetData(target, "法琦尔-恶魔制造")
            u:setdata("法琦尔-恶魔制造目标", target)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFF9966FF法|r|cFFA680FF琦|r|cFFB299FF尔|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF9966FF唯一 白毛 黑暗 恶魔 机械|r\n|cFF9966FF恶魔之技艺|r\n|cFFB299FF提升25%枪械修正\n提升25%近战修正\n提升25%物理武器伤害\n获取黑暗变异时,提升10%枪械修正与近战修正\n解锁技能[恶魔制造]|r\n|cFF9966FF黑暗之力|r\n|cFFB299FF杀敌时提升0.06%法术修正与1点生命上限\n每秒提升1点魔力值\n提升[智力*5]魔力值\n枪械子弹、箭矢或近战武器命中时附带一次[125*魔力值+黑暗变异数量*25*智力]暗属性魔力伤害|r\n|cFF9966FF侵蚀|r\n|cFFB299FF提升[2%*光明变异数量]额外受伤\n每秒降低1点生命上限\n每秒降低0.03%法术修正|r",
    effectart = "war3mapImported\\BTNNql_01",
    test = ""
  },
  {
    name = "亚波伦",
    weight = 250,
    lv = 5,
    key = {
      "唯一",
      "白毛",
      "根源",
      "黑暗",
      "恶魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("物品判定-晋升之环") and u:hasdata("变异判定-万众归一") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("扭曲力量", 1)
      u:chat("|cFF6F2F9F如果这就是一切的尽头")
      u:chat("|cFF6F2F9F那么这一宿命------", 3)
      u:chat("|cFF6F2F9F就由我画上休止符", 6)
      u:removeitem("I0PK")
      u:additem("I0PL")
      local cs = 0
      local sds = 0
      ac.loop(3000, function()
        if u:isalive() then
          cs = cs + 1
          if 2 <= cs then
            cs = 0
            local hdz = 200 * u:getdata("系统-累积等级")
            hdzlinshiadd(u, hdz)
          end
        end
        if 666 <= u:getdata("累积杀敌") - sds * 666 then
          local add = math.floor(u:getdata("累积杀敌") - sds * 666)
          u:setdata("亚波伦-复活次数", add)
          sds = sds + add
          u:sendmessage("|cFF79687D[亚波伦]复活次数:" .. u:getdata("亚波伦-复活次数"))
        end
      end)
      ChangeValue(DamageSystem_EndSh, sy, 0.009)
      u:addstr(100)
      u:addagi(200)
      u:addint(150)
      u:changedata("近战机体-基础伤害提升", GetRandomInt(5970, 8960))
      u:addstexiao(var.name, "杀敌效果", function(args)
        u:addrandomstats(1)
      end)
      ac.wait(100, function()
        u:uivar_change({
          keyname = "亚波伦",
          keytype = "传奇栏",
          icon = "Niuqu_Yabolun_02.tga",
          ishasphoto = true
        })
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("亚波伦-抑制恢复") then
          tg:settimedata("亚波伦-抑制恢复", 5)
          tg:groupadd(HpGroup)
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("回光返照冷却") then
          args.dt = false
          u:settimedata("回光返照冷却", 65)
          u:settimedata("亚波伦-回光返照", 6)
          u:playseensound(Sound_Yabadun_01)
          u:effectadd("Abilities\\Spells\\Undead\\Unsummon\\UnsummonTarget.mdl", "origin", 6)
          u:clearbuff()
          u:clearbuff("僵直")
          u:clearbuff("眩晕")
          u:clearbuff("混乱")
          u:clearbuff("缠绕")
          u:clearbuff("麻痹")
        end
      end)
      AddUISkill({
        text = "回光返照",
        u = u,
        cd = 66,
        icon = "Niuqu_Yabolun_Skill.tga",
        showtext = "|cFF22A8AA回光返照\n启动后驱散自身大部分负面状态\n所有受到的伤害与生命损耗效果均变为治疗\n持续6秒\n冷却65秒|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          if not u:hasdata("回光返照冷却") then
            u:settimedata("回光返照冷却", 65)
            u:settimedata("亚波伦-回光返照", 6)
            u:playseensound(Sound_Yabadun_01)
            u:effectadd("Abilities\\Spells\\Undead\\Unsummon\\UnsummonTarget.mdl", "origin", 6)
            u:clearbuff()
            u:clearbuff("僵直")
            u:clearbuff("眩晕")
            u:clearbuff("混乱")
            u:clearbuff("缠绕")
            u:clearbuff("麻痹")
          else
            u:sendmessage("|cFF22A8AA冷却中|r")
          end
        end
      })
    end,
    effectname = "|cFFE6E7EC亚|r|cFFB0A8B4波|r|cFF79687D伦|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFFE6E7EC恶魔 黑暗 白毛 根源 唯一|r\n|cFFE6E7EC【无光之盾】|r\n|cFF79687D每6秒获得[200*累积等级]临时护盾值|r\n|cFFE6E7EC【霜之哀伤】|r\n|cFF79687D提升0.9%终结伤害\n提升100力量\n提升200敏捷\n提升150智力\n提升5970~8960近战基础伤害\n直接伤害时弱抑制目标生命恢复,持续5秒|r\n|cFFE6E7EC【回光返照】|r\n|cFF79687D拓展技能[回光返照]\n受到致死伤害时也会被动触发进入冷却|r\n|cFFE6E7EC【末日终结】|r\n|cFF79687D杀敌时提升1点属性\n每累积杀死666个单位获得1次复活机会\n进阶[晋升之环]|r",
    effectart = "Niuqu_Yabolun_02",
    test = ""
  }
}
