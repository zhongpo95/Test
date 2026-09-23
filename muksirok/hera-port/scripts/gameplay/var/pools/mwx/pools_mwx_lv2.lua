-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local keystring = "冥王公共池"
Vars_Mwx_Lv2 = {
  {
    name = "黑魔法师",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() then
        if u:hasdata("黑魔法师-冰魔法") then
          u:deldata("黑魔法师-冰魔法")
          u:changedata("冰变异数量", -1)
          u:setdata("黑魔法师-火魔法")
          u:changedata("炎变异数量", 1)
          u:sendmessage("|cFF996600切换成功|r")
          u:uivar_change({
            keyname = "黑魔法师",
            keytype = "冥王栏",
            text = "|cFF996600黑魔法师|r\n|cFF996600【阶级】2\n魔导 炎 雷 唯一\n职业量谱\n提升[元素变异*0.5%]法术修正\n提升[1%*炎变异]伤害加成\n每3秒恢复[0.5%*冰变异]魔法值|r\n|cFFFF3300强化 - 火魔法[点击切换]\n魔法值无法常规恢复\n直接伤害13%概率对目标附近600范围附带[3333+等级*333]（火,魔导,法术）伤害,触发冷却1秒\n每1%魔法值提升0.1%终结伤害\n每造成10次伤害减少1%魔法值|r"
          })
          return
        end
        if u:hasdata("黑魔法师-火魔法") then
          u:deldata("黑魔法师-火魔法")
          u:changedata("炎变异数量", -1)
          u:setdata("黑魔法师-冰魔法")
          u:changedata("冰变异数量", 1)
          u:sendmessage("|cFF996600切换成功|r")
          u:uivar_change({
            keyname = "黑魔法师",
            keytype = "冥王栏",
            text = "|cFF996600黑魔法师|r\n|cFF996600【阶级】2\n魔导 冰 雷 唯一\n职业量谱\n提升[元素变异*0.5%]法术修正\n提升[1%*炎变异]伤害加成\n每3秒恢复[0.5%*冰变异]魔法值|r\n|cFF3399FF强化 - 冰魔法[点击切换]\n直接伤害时10%概率冰冻目标1秒,独立冷却1秒\n直接伤害时10%为目标附加持续伤害(每3秒附带全属性*25*叠加层数(基础1层 上限[5+冰变异数量]层))\n(冰,魔导,法术),持续30秒,可叠加,重复触发时刷新持续时间,触发冷却1秒|r"
          })
          return
        end
      end
    end,
    weight = 10,
    lv = 2,
    key = {
      "冰",
      "魔导",
      "炎",
      "雷",
      "唯一"
    },
    unique = true,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      u:changedata(var.lv .. "阶精神变异数量", 1)
      MwxApplySpiritLoadByLv(u, var)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("炎变异数量", -1)
      u:changedata("冰变异数量", -1)
      u:sendmessage("|cFF996600你走上了一条毁灭之路，凭你的意志，能否成为毁灭的使者...|r")
      local add = 0
      local add2 = 0
      local add3 = 0
      local cs = 0
      local yssh = 0
      local g = CreateGroupLua()
      ac.loop(3000, function()
        ChangeValue(Correction_Magic, sy, -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add2)
        add = 0.005 * u:getdata("元素变异数量")
        add2 = 0.05 * u:getstate("炎变异")
        add3 = 0.005 * u:getstate("冰变异")
        ChangeValue(Correction_Magic, sy, add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add2)
        u:curemp(0, add3)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -yssh)
        if u:hasdata("黑魔法师-火魔法") then
          yssh = 0.05 * u:getmp() / u:getmaxmp()
        else
          yssh = 0
        end
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * yssh)
        ForGroupLuaNew(g, function(xq)
          xq:changedata("黑魔法师-冰持续时间", -3)
          if xq:getdata("黑魔法师-冰持续时间") <= 0 then
            xq:groupremove(g)
            xq:deldata("黑魔法师-冰持续时间")
            xq:deldata("黑魔法师-冰魔法叠加层数")
          else
            local txsh = 25 * u:getallattri() * xq:getdata("黑魔法师-冰魔法叠加层数")
            DamageUnit({
              bj = "黑魔法师(附伤)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "冰",
              extradata = {"法术", "魔导"}
            })
          end
        end)
      end)
      u:setdata("黑魔法师-火魔法")
      u:changedata("炎变异数量", 1)
      u:addstexiao(var.name, "伤害判定后效果", function(args)
        if u:hasdata("变异判定-" .. var.name) then
          if u:getdata("黑魔法师-火魔法计数") >= 10 then
            u:setdata("黑魔法师-火魔法计数", 0)
            u:curemp(0, -1)
          else
            u:changedata("黑魔法师-火魔法计数", 1)
          end
        end
      end)
      local txsh = 0
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("黑魔法师-冰魔法") then
          if not tg:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
            tg:settimedata(var.name .. "-特效冷却", 1)
            tg:buffset(u.handle, 1, "冰冻")
          end
          if u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却2") then
            u:settimedata(var.name .. "-特效冷却2", 1)
            local max = 5 + u:getdata("冰变异数量")
            if 1 <= tg:getdata("黑魔法师-冰魔法叠加层数") then
              tg:changedata("黑魔法师-冰魔法叠加层数", 1)
              if max <= tg:getdata("黑魔法师-冰魔法叠加层数") then
                tg:setdata("黑魔法师-冰魔法叠加层数", max)
              end
            else
              tg:setdata("黑魔法师-冰魔法叠加层数", 1)
            end
            tg:setdata("黑魔法师-冰持续时间", 30)
            tg:groupadd(g)
          end
        end
        if u:hasdata("黑魔法师-火魔法") and u:getluckrandom(13 * info.txgl) and not u:hasdata(var.name .. "-特效冷却3") then
          u:settimedata(var.name .. "-特效冷却3", 1)
          txsh = 3333 + 333 * u:getlevel()
          DamageUnit({
            bj = "黑魔法师(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "火",
            extradata = {"法术", "魔导"}
          })
        end
      end)
    end,
    effectname = "|cFF996600黑魔法师|r",
    effecttext = "|cFF996600【阶级】2\n魔导 炎 雷 唯一\n职业量谱\n提升[元素变异*0.5%]法术修正\n提升[1%*炎变异]伤害加成\n每3秒恢复[0.5%*冰变异]魔法值|r\n|cFFFF3300强化 - 火魔法[点击切换]\n魔法值无法常规恢复\n直接伤害13%概率对目标附近600范围附带[3333+等级*333]（火,魔导,法术）伤害,触发冷却1秒\n每1%魔法值提升0.05%终结伤害\n每造成10次伤害减少1%魔法值|r",
    effectart = "Ewl_Mwx_Lv2_Heimo"
  },
  {
    name = "花园百合铃",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "黑暗",
      "魔导"
    },
    unique = true,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      if not u:hasdata("变异判定-邪神酱") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      u:changedata(var.lv .. "阶精神变异数量", 1)
      MwxApplySpiritLoadByLv(u, var)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:sendmessage("|cFFFF3366获得" .. var.name)
      coopjudge("CQC超人", u)
      u:changedata("幸运", 1)
      u:adddxdstats("幻想", 1)
      local cs = 0
      ac.loop(3000, function()
        cs = cs + 1
        if cs == 10 then
          cs = 0
          if u:getluckrandom(5) then
            u:addgold(GetRandomInt(10, 100))
            u:sendmessage("|cFFFF3366百合铃分解了邪神酱回收了一部分积分|r")
          end
        end
        local damages = {
          Damage_Element_Dark,
          Damage_Element_Thunder,
          Damage_Element_Water,
          Damage_Element_Ice,
          Damage_Element_Fire,
          Damage_Element_Blank,
          Damage_Element_Light,
          Damage_Element_Wind,
          Damage_Element_Earth,
          Damage_Element_Heart
        }
        local values = {}
        for _, damage in ipairs(damages) do
          table.insert(values, damage[sy])
        end
        local max_value = math.max(table.unpack(values))
        local max_index = 1
        for i, v in ipairs(values) do
          if v == max_value then
            max_index = i
            break
          end
        end
        local add = 0.01 * u:getstate("魔导变异")
        ChangeTimeValue(damages[max_index], sy, add, 2.99)
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage > 1 and u:getdata("花园百合铃-减伤叠加层数") < 10 then
          u:changetimedata("花园百合铃-减伤叠加层数", 1, 10)
          ChangeTimeValue(DamageSystem_Ssjianshao, sy, 0.95, 3, 1)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(9 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.9)
          local txsh = 200 * (u:getstr() + u:getint())
          DamageUnit({
            bj = "花园百合铃(附伤)",
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
    end,
    effectname = "|cFFFF3366花|r|cFFFF4477园|r|cFFFF5588百|r|cFFFF6699合|r|cFFFF77AA铃|r",
    effecttext = "|cFFFF3366【阶级】2\n唯一 黑暗 魔导|r\n|cFFFF77AA幻想+1\n提升1点幸运|r\n|cFFFF3366地表最强黑魔法师|r\n|cFFFF77AA最高的属性伤害提升[魔导变异*1%]\n受伤后提升5%伤害减免,持续3秒,至多10次,分立计时\n直接伤害9%附带[(力量+智力)*200]暗属性魔力伤害,触发冷却0.9秒|r\n|cFFFF3366邪神召唤主|r\n|cFFFF77AA每30秒5%触发一次邪神酱的致死计数叠加并获得10~100积分\n使邪神酱的[柏青哥！]被动抽奖效果失效\n主动触发[柏青哥！]时,如果获取0积分则立刻触发一次邪神酱的致死计数并获得10~100积分|r",
    effectart = "Ewl_Mwx_Erjie_02"
  },
  {
    name = "燕",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() then
        if not u:hasdata("燕-进阶标记") and u:ishasitem("I098") then
          u:setdata("燕-进阶标记")
          u:sendmessage("|cFF3366FF成功解锁|r")
          local wp = u:getitem("I098")
          ChangeItemCount(wp, -1)
          u:changedata("召唤变异数量", 1)
          u:changedata("水变异数量", 1)
          u:setdata("燕-拉普拉斯数量", 1)
          u:changedata("召唤物数量", 1)
          u:setdata("燕-拉普拉斯")
          ChangeValue(Damage_Element_Water, sy, 0.1)
          ac.loop(10000, function()
            u:setdata("燕-拉普拉斯附伤")
          end)
          u:addstexiao("燕-拉普拉斯", "直接伤害特效", function(args)
            local tg = args.tg
            local u = args.u
            local x, y = tg:getxy()
            if u:hasdata("燕-拉普拉斯附伤") then
              u:deldata("燕-拉普拉斯附伤")
              local txsh = 10000 + 1000 * u:getlevel()
              for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "燕(附伤)",
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
                xq:buffset(u.handle, 2, "眩晕")
              end
            end
          end)
          local x, y = u:getxy()
          local mj = u:createunit("n00L", x, y)
          mj:setguard(u.handle)
          mj:groupadd(u:getdata("召唤物组"))
          mj:groupadd(Group_ZhaohuanwuAll)
          mj:setdata("常规召唤物", "拉普拉斯")
          SendMsgAll("|cFFF56490BGM：「それを世界と言うんだね」|r")
          PlayBGM({
            bgm = BGM_Huapu,
            time = 150,
            ID = 157,
            unit = u.handle
          })
          u:uivar_change({
            keyname = "燕",
            keytype = "冥王栏",
            text = "|cFFF56490燕|r\n|cFFF56490水 召唤 歌姬\n拉普拉斯[点击消耗(拉普拉斯数量+1)个水之星强化]|r\n|cFF404184召唤拉普拉斯(可多次召唤)\n提升10%水属性伤害(可多次强化)\n每隔10秒下一次直接伤害附带500范围[10000+等级*1000]水魔力伤害与2秒眩晕|r\n|cFFF56490被厌恶的此身|r\n|cFF404184脱战时,提升12%药水成功率与5生命恢复\n战斗时,降低50%药水成功率|r\n|cFFF56490不可解|r\n|cFF404184每次BGM切换时,提升3点属性与0.1%伤害加成,触发冷却60秒|r\n|cFFF56490摇曳空间|r\n|cFF404184受到大于100伤害时,接下来0.75秒内自身伤害免疫,BOSS战中拥有15秒触发冷却|r"
          })
        else
          local wp = u:getitem("I098")
          local xhsl = u:getdata("燕-拉普拉斯数量") + 1
          if xhsl <= GetItemCharges(wp) then
            ChangeItemCount(wp, -1 * xhsl)
            u:sendmessage("|cFF3366FF成功强化|r")
            u:changedata("燕-拉普拉斯数量", 1)
            u:changedata("召唤物数量", 1)
            ChangeValue(Damage_Element_Water, sy, 0.025)
            local x, y = u:getxy()
            local mj = u:createunit("n00L", x, y)
            mj:setguard(u.handle)
            mj:groupadd(u:getdata("召唤物组"))
            mj:groupadd(Group_ZhaohuanwuAll)
            mj:setdata("常规召唤物", "拉普拉斯")
          else
            u:sendmessage("|cFF3366FF水之星不足，需求数量：" .. math.floor(xhsl) .. "个|r")
          end
        end
      end
    end,
    weight = 25,
    lv = 2,
    key = {"歌姬", "唯一"},
    unique = true,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      u:changedata(var.lv .. "阶精神变异数量", 1)
      MwxApplySpiritLoadByLv(u, var)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:sendmessage("|cFFF56490世界……厌恶……|r")
      local hp = 0
      ac.loop(250, function()
        ChangeValue(HeroMenu_HpChange_Inr, sy, -1 * hp)
        if u:getdata("战斗时间") > 0 then
          hp = 0
          u:setdata("燕-被厌恶的此身-战斗")
          u:deldata("燕-被厌恶的此身-脱战")
        else
          hp = 5
          u:deldata("燕-被厌恶的此身-战斗")
          u:setdata("燕-被厌恶的此身-脱战")
        end
        ChangeValue(HeroMenu_HpChange_Inr, sy, 1 * hp)
      end)
    end,
    effectname = "|cFFF56490燕|r",
    effecttext = "|cFFF56490【阶级】2\n歌姬\n拉普拉斯[点击消耗1枚水之星解锁]|r\n|cFF404184[待解锁]|r\n|cFFF56490被厌恶的此身|r\n|cFF404184脱战时,提升12%药水成功率与5生命恢复\n战斗时,降低50%药水成功率|r\n|cFFF56490不可解|r\n|cFF404184每次BGM切换时,提升3点属性与0.1%伤害加成,触发冷却60秒|r\n|cFFF56490摇曳空间|r\n|cFF404184受到大于100伤害时,接下来0.75秒内自身伤害免疫,BOSS战中拥有15秒触发冷却|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_600.tga"
  },
  {
    name = "恶灵附身",
    weight = 25,
    lv = 2,
    key = {"唯一", "黑暗"},
    unique = true,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      u:changedata(var.lv .. "阶精神变异数量", 1)
      MwxApplySpiritLoadByLv(u, var)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:sendmessage("|cFF1BE6B8获得恶灵附身|r", 3)
      u:setdata("恶灵强度", 0)
      u:changedata("光明变异补正", -50)
      local b1 = false
      ac.loop(1000, function(t)
        if u:isalive() then
          if GetTimeOfDay() >= 20 or GetTimeOfDay() <= 4 then
            if b1 == false then
              b1 = true
              local x, y = u:getxy()
              local mj = u:createunit("u06W", x, y)
              mj:setcolor(25, 25, 25, 125)
              u:setdata("恶灵附身-附身状态")
              u:setdata("恶灵吸收伤害", 0)
              local cs = 0
              ac.loop(33, function(t2)
                cs = cs + 1
                x, y = u:getxy()
                mj:setxy(x, y)
                mj:setface(u:getface())
                if GetTimeOfDay() >= 4 and GetTimeOfDay() <= 20 then
                  u:deldata("恶灵附身-附身状态")
                  u:deldata("恶灵吸收伤害")
                  mj:remove()
                  t2:remove()
                end
              end)
            end
          elseif b1 == true then
            b1 = false
            u:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl")
            if u:getdata("恶灵吸收伤害") > u:gethp() then
              local gg = getunit(BOSS_DEATH)
              gg:setdata("混沌吞噬")
              u:kill(BOSS_DEATH)
              gg:deldata("混沌吞噬")
              ac.wait(30, function()
                if not u:isalive() then
                  u:changedata("恶灵强度", 1)
                  u:sendmessage("自身恶灵强度增强了", 5)
                  ChangeValue(DamageSystem_Sszengjia, sy, 1.16)
                  ChangeValue(DamageSystem_Shjc, sy, 0.008)
                end
              end)
            else
              u:losshp(u, u:getdata("恶灵吸收伤害"))
            end
          end
        end
        if not u:hasdata("变异判定-恶灵附身") then
          t:remove()
        end
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        if u:getluckrandom(25) then
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not u:hasdata(var.name .. "-特效冷却") then
            u:settimedata(var.name .. "-特效冷却", 3)
            local x, y = u:getxy()
            local tx = EffectcreateArgs({
              effect = "units\\creeps\\VoidWalker\\VoidWalker.mdl",
              x = x,
              y = y,
              time = 2,
              size = 4,
              zxz = u:getface()
            })
            SetEffectAnimation(tx, "spell")
            Effectcreate("Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl", x, y, 0, 4)
            for _, xq in ac.selector():in_rangexy(x, y, 750):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:effectadd("Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl", "origin", 1)
              xq:buffset(u.handle, 1, "僵直")
            end
          end
        end
      end)
    end,
    effectname = "|cFF6633FF恶灵附身|r",
    effecttext = "|cFF6633FF【阶级】2\n唯一 黑暗\n于20点至4点时恶灵会缠绕自身的灵魂,期间获得以下效果：\n①枪械射击25%将子弹变化为恶灵弹 伤害变为[250*(等级+20*当前恶灵强度)]灵力纯粹伤害\n②近战伤害25%产生一个鬼影惊吓周围750码所有敌方单位1秒恐惧(触发冷却3秒)\n③自身受到的50%终结伤害由恶灵承受\n4点时恶灵离去同时对自身造成本夜累积伤害(生命损耗 混沌致死)\n每次恶灵杀死自己会永久提高自身一层恶灵强度\n每层恶灵强度提升自身0.8%伤害加成与16%追加受伤\n降低50%光明变异补正|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_Elingfushen.blp"
  }
}
