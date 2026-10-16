-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
Vars_Ciyuan_Yuanshi_Spe = {
  {
    name = "史尔特尔",
    weight = 10,
    key = {
      "唯一",
      "炎",
      "战士",
      "恶魔",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("史尔特尔天赋-萨米的不灭心脏碎片") then
        add = add + 2000
      end
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("자기 몫의 일조차 제대로 못 하는 거야? 내가 도와줘야 해?")
      PlayGlobalSound(Sound_Shierter_01)
      u:changeysnd(1)
      ChangeValue(Damage_Element_Fire, sy, 0.05)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("史尔特尔-熔火破抗") then
          tg:setdata("史尔特尔-熔火破抗")
        end
      end)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.75)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("史尔特尔-决死冷却") then
          args.dt = false
          u:sendmessage("|cFFCF4256史|r|cFFD14B58尔|r|cFFD3545B特|r|cFFD55D5D尔|r|cFFD66660-|r|cFFD86F62余|r|cFFDA7864烬|r")
          u:settimedata("史尔特尔-决死冷却", 180)
          u:settimedata("史尔特尔-死亡抗拒", 8)
          u:effectadd("42_baofa.mdx")
          u:effectadd("42_chixu.mdx", "origin", 8)
        end
      end)
      u:addstexiao(var.name, "决死效果触发后", function(args)
        ChangeTimeValue(DamageSystem_Shjc, sy, 0.025, 15)
        ChangeTimeValue(DamageSystem_EndSh, sy, 0.005000000000000001, 15)
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("史尔特尔-烈焰魔剑") and not info.isvestdamage then
          u:deldata("史尔特尔-烈焰魔剑")
          tg:effectadd("42_jian.mdx")
          info.damage = info.damage * 1.25
          ac.wait(10, function()
            if not tg:isalive() then
              u:curetili(5)
            end
          end)
        end
      end)
      u:addtrgevent("单位-发动技能", function(args)
        u:setdata("史尔特尔-烈焰魔剑")
      end)
    end,
    effectname = "|cFFCF4256史|r|cFFD2505A尔|r|cFFD55F5E特|r|cFFD86D61尔|r",
    effecttext = "|cFFCF4256唯一 炎 恶魔 战士 源石\n熔火|r\n|cFFD86D61提升5%炎属性伤害\n直接伤害降低目标10%炎属性抗性|r\n|cFFCF4256烈焰魔剑|r\n|cFFD86D61发动技能命令后首次近战伤害提升25%(独立),如果该次伤害杀敌恢复5点体力|r\n|cFFCF4256余烬|r\n|cFFD86D61受到致死伤害时死亡抗拒6秒,触发冷却180秒\n触发决死效果时在15秒内提升2.5%伤害加成与5%终结伤害|r\n|cFFCF4256熔核巨影|r\n|cFFD86D61近战伤害多击段数+1(火属性魔力)\n近战伤害多击上限+75%|r",
    effectart = "Ewl_Shierteer",
    test = [[

        ]]
  }
}
Vars_Ciyuan_Yuanshi = {
  {
    name = "麦哲伦",
    clickfunc = function(u, button)
      if u:isalive() and u:getdata("麦哲伦-考察记录") >= 10 then
        u:changedata("麦哲伦-考察记录", -10)
        PlayGlobalSound(Sound_Maizhelun_02)
        local npc = getunit(NPC_TIANZI)
        npc:setdata("环境变更")
      end
    end,
    cd = 10,
    weight = 25,
    key = {
      "唯一",
      "土",
      "源石",
      "兽"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:ishasitem("I0HH") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("诶多……要不要加入我的探险队呢？很有趣的！")
      PlayGlobalSound(Sound_Maizhelun_01)
      u:changeysnd(1)
      u:setdata("麦哲伦-考察记录", 0)
      u:setdata("麦哲伦-考察记录生命上限", 0)
      u:setdata("麦哲伦-考察记录伤害加成", 0)
      local cs = 0
      ac.loop(3000, function()
        if u:isalive() then
          cs = cs + 1
          if cs == 20 then
            cs = 0
            local addhp = 10 * u:getstate("土") * u:getdata("麦哲伦-考察记录")
            local addlw = 0.003 * u:getstate("土") * u:getdata("麦哲伦-考察记录")
            u:sendmessage("|cFFA0896C麦哲伦-考察成果获取" .. u:getdata("麦哲伦-考察记录") .. "点|r")
            u:changedata("麦哲伦-考察记录生命上限", addhp)
            u:changedata("麦哲伦-考察记录伤害加成", addlw)
            u:changemaxhp(addhp)
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * addlw)
          end
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.1)
          tg:changedata("麦哲伦-叠加次数", 1)
          local txsh = 100 + u:getdata("麦哲伦-考察记录") * 10
          txsh = txsh * u:getstate("源石")
          txsh = txsh * tg:getdata("麦哲伦-叠加次数")
          DamageUnit({
            bj = "麦哲伦(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "能量",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {"法术"}
          })
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:isboss() then
          u:changedata("麦哲伦-考察记录", 10)
        elseif tg:iselite() then
          u:changedata("麦哲伦-考察记录", 1)
        end
      end)
    end,
    effectname = "|cFFA0896C麦哲伦|r",
    effecttext = "|cFFA0896C唯一 源石 土 兽\n极地考察|r\n|cFFFFC550环境免疫失效\n每次环境切换时获得3点考察记录|r\n|cFFA0896C考察成果|r\n|cFFFFC550存活时每60秒提升[考察记录*10*土]生命上限与[考察记录*0.03%*土]伤害加成\n彻底死亡时,该效果的累积加成将减少一半|r\n|cFFA0896C激光开采模块|r\n|cFFFFC550减少25%物质枪冷却\n直接伤害时附带[100+考察记录*10]叠加伤害(能量,源石,法术),触发冷却0.1秒|r\n|cFFA0896C萨米的意志|r\n|cFFFFC550击杀精英单位时提升1点考察记录\n击杀BOSS单位时提升10点考察记录\n点击时消耗10点考察记录切换当前环境|r",
    effectart = "Ewl_Cq_Maizhelun",
    test = [[

        ]]
  },
  {
    name = "霜星",
    clickfunc = function(u)
      if u:isalive() then
        local sy = u.ownerid
        if u:hasdata("霜星-彩蛋触发") then
          return
        end
        if u:hasdata("霜星-准备完毕") then
          u:deldata("霜星-准备完毕")
          MovieAct["霜星"](u)
          return
        end
        if u:getdata("冰变异数量") >= 3 and 3 <= u:getdata("源石变异数量") and BossBattle and Group_Counts(Group_Xingcunzu) <= 1 then
          u:sendmessage("|cFF6699FF你已经准备好了么，如果继续的话你的生命将进入倒计时，准备好了的话 就再次点击|r")
          u:settimedata("霜星-准备完毕", 3)
        else
          u:sendmessage("|cFF6699FF还没有到合适的时刻……|r")
        end
      end
    end,
    weight = 25,
    key = {
      "唯一",
      "冰",
      "源石",
      "兽"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:getdata("冰变异数量") > 0 and u:getdata("矿石病爆发次数") >= 10 and u:getdata("系统-血液源石结晶密度") >= 200 and not u:hasdata("变异判定-爱国者") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("冷终归……只是冷——不会诞生新生命的，冬天的寒冷。")
      u:changeysnd(1)
      local add = 0
      local sx = 0
      ac.loop(3000, function()
        ChangeValue(Damage_Element_Ice, sy, -1 * sx)
        ChangeValue(Correction_Magic, sy, -1 * add)
        add = u:getdata("系统-血液源石结晶密度") / 100 * 0.3
        sx = u:getdata("系统-血液源石结晶密度") / 100 * 0.03
        if u:hasdata("霜星-彩蛋触发") then
          add = 2.5
          sx = 1
        end
        ChangeValue(Damage_Element_Ice, sy, 1 * sx)
        ChangeValue(Correction_Magic, sy, 1 * add)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:hasdata("霜星-雪中至亲加速") then
            local sy2 = xq.ownerid
            xq:deldata("霜星-雪中至亲加速")
            xq:delskill("S0AR")
            ChangeValue(DamageSystem_EndSh, sy2, -0.010000000000000002)
          end
        end)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:hasdata("变异判定-矿石病") and not xq:hasdata("霜星-雪中至亲加速") then
            local sy2 = xq.ownerid
            xq:setdata("霜星-雪中至亲加速")
            xq:addskill("S0AR")
            ChangeValue(DamageSystem_EndSh, sy2, 0.010000000000000002)
          end
        end)
      end)
      local g = {}
      u:setdata("霜星-冰晶特效组", g)
      local cs = 0
      for i = 1, 3 do
        u:changedata("霜星-冰晶数量", 1)
        local x, y = u:getxy()
        local tx = Effectcreate("Shuang_02.mdx", x, y, -1)
        g[#g + 1] = tx
      end
      local jd = 0
      ac.loop(30, function()
        if u:getdata("霜星-冰晶数量") > 0 then
          jd = jd + 3
          local x, y = u:getxy()
          local jg = 360 / #g
          local djd = jd
          for i = 1, #g do
            djd = djd + jg
            local dx, dy = PolarXY(x, y, 150, djd)
            SetEffectXY(g[i], dx, dy)
          end
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata("霜星-冰晶射击间隔") and u:isalive() then
          if u:hasdata("霜星-彩蛋触发") then
            u:settimedata("霜星-冰晶射击间隔", 0.5)
          else
            u:settimedata("霜星-冰晶射击间隔", 2)
          end
          local x2, y2 = tg:getxy()
          local txsh = 1000 * u:getlevel() * u:getstate("源石")
          for i = 1, #g do
            local dx, dy = GetEffectXY(g[i])
            local angle = AngleXY(dx, dy, x2, y2)
            unifycreate({
              owner = u.handle,
              model = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl",
              modelname = "霜星弹幕",
              modelsize = 1,
              height = 90,
              damage = txsh,
              damagetype = 1,
              x = dx,
              y = dy,
              range = 2500,
              speed = 1500,
              volume = 90,
              angle = angle,
              angleoffset = 0,
              attenua = 1,
              attenuacount = 3,
              life = 10,
              isbullet = false,
              isvest = false,
              isignorearmor = false,
              startfunc = function(mj)
              end,
              loopfunc = function(mj)
              end,
              hitfunc = function(mj, damage)
                return damage
              end,
              hitbeforefunc = function(mj, xq, damage2)
              end,
              hitafterfunc = function(mj, xq, damage2)
                xq:buffset(u.handle, 1, "冰冻")
              end,
              endfunc = function(mj)
              end
            })
          end
        end
        if not tg:hasdata("霜星-已伤害") or not tg:hasdata("霜星-彩蛋特效冷却") and u:hasdata("霜星-彩蛋触发") then
          tg:setdata("霜星-已伤害")
          if u:hasdata("霜星-彩蛋触发") then
            tg:settimedata("霜星-彩蛋特效冷却", 3)
          end
          local txsh = 1000 * u:getlevel() * u:getstate("源石")
          tg:buffset(u.handle, 1, "冻结")
          DamageUnit({
            bj = "霜星(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "冰"
          })
        end
        if (u:getluckrandom(5) or u:hasdata("霜星-彩蛋触发")) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.25)
          local txsh = 1000 * u:getlevel() * u:getstate("源石")
          tg:buffset(u.handle, 1, "冰冻")
          DamageUnit({
            bj = "霜星(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "冰"
          })
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(Damage_Element_Ice, sy, 5.0E-4)
      end)
      u:addskill("S0AQ")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:setdata("霜星-雪中至亲")
      end)
    end,
    effectname = "|cFFDDDDDD霜|r|cFFA6A6A6星|r",
    effecttext = "|cFFDDDDDD唯一 兽 冰 源石\n冻原的公主|r\n|cFFA6A6A6提升[源石结晶密度每100u/ml*3%]冰属性伤害与[每100u/ml*30%]法术修正\n直接伤害时5%附带[1000*等级*源石]冰魔力伤害与1秒冰冻，触发冷却0.25秒\n杀敌时提升0.05%冰属性伤害|r\n|cFFDDDDDD霜环领域|r\n|cFFA6A6A6减速1000范围30%速度并降低10%冰属性抗性\n对每个单位第一次直接伤害时冻结1秒并附带[1000*等级*源石]冰魔力伤害\n生成三枚冰晶环绕自身,攻击间隔2秒|r\n|cFFDDDDDD雪中至亲|r\n|cFFA6A6A6所有[矿石病]感染者提升1%终结伤害与20%移速\n降低除自身外所有[矿石病]感染者25%自然增长速度|r\n|cFFDDDDDD维生晶体|r\n|cFFA6A6A6战斗状态下源石结晶密度增长翻倍\n矿石病非致死阶段的爆发不会致死,至多损耗80%生命|r\n|cFFDDDDDDFrostNova|r\n|cFFA6A6A6[数据删除]|r",
    effectart = "BTNEwl_Shuangxing_01",
    test = [[

        ]]
  },
  {
    name = "爱国者",
    clickfunc = function(u)
      if u:isalive() then
        local sy = u.ownerid
        if u:hasdata("爱国者-行军形态") then
          u:sendmessage("|cFF990000当前形态-毁灭|r")
          u:deldata("爱国者-行军形态")
          u:setdata("爱国者-毁灭形态")
          ChangeValue(DamageSplit_CountJzMax, sy, -0.25)
          ChangeValue(DamageSplit_CountJzHit, sy, -3)
          ChangeValue(DamageSplit_CountJzMax, sy, 0.5)
          ChangeValue(DamageSplit_CountJzHit, sy, 1)
          u:uivar_change({
            keyname = "爱国者",
            keytype = "传奇栏",
            text = "|cFF990000博|r|cFF991A1A卓|r|cFF993333卡|r|cFF994C4C斯|r|cFF996666替|r\n|cFF990000唯一 恶魔 战士 源石 兽\n爱国者|r\n|cFF996666[矿石病]对自身效果翻倍\n[矿石病]爆发致死时永久死亡|r\n|cFF990000感染者之盾|r\n|cFF996666提升[100*源石]护甲\n提升[25%*源石]受伤减少\n提升所有[矿石病]感染者25%源石效果\n存活时所有[矿石病]感染者自然增长速率下降|r\n|cFF990000行军/毁灭(点击切换形态)|r\n|cFF996666每秒对周围600范围单位附带[10000*源石]魔力伤害\n提升[10%*源石]伤害加成\n近战伤害上限+50%\n近战伤害段数+1(物理)\n直接伤害时附带[1000*源石]魔力伤害,冷却0.25秒\n受到致死伤害时抵挡该次伤害并无敌1秒,使血液源石结晶密度上升,触发冷却90秒|r\n|cFF990000恶魔之血|r\n|cFF996666提升[1%*恶魔]终结伤害\n提升[3%*恶魔]原始伤害|r",
            icon = "BTNEwl_Aiguozhe_02"
          })
        else
          u:sendmessage("|cFF990000当前形态-行军|r")
          u:deldata("爱国者-毁灭形态")
          u:setdata("爱国者-行军形态")
          ChangeValue(DamageSplit_CountJzMax, sy, -0.5)
          ChangeValue(DamageSplit_CountJzHit, sy, -1)
          ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
          ChangeValue(DamageSplit_CountJzHit, sy, 3)
          u:uivar_change({
            keyname = "爱国者",
            keytype = "传奇栏",
            text = "|cFF990000博|r|cFF991A1A卓|r|cFF993333卡|r|cFF994C4C斯|r|cFF996666替|r\n|cFF990000唯一 恶魔 战士 源石 兽\n爱国者|r\n|cFF996666[矿石病]对自身效果翻倍\n[矿石病]爆发致死时永久死亡|r\n|cFF990000感染者之盾|r\n|cFF996666提升[100*源石]护甲\n提升[25%*源石]受伤减少\n提升所有[矿石病]感染者25%源石效果\n存活时所有[矿石病]感染者自然增长速率下降|r\n|cFF990000行军/毁灭(点击切换形态)|r\n|cFF996666仇恨权重极大提升\n提升20%终结减伤\n提升[1%*源石]永恒恢复\n近战伤害上限+25%\n近战伤害段数+3(物理)\n受到致死伤害时抵挡该次伤害并无敌1秒,使血液源石结晶密度上升,触发冷却90秒|r\n|cFF990000恶魔之血|r\n|cFF996666提升[1%*恶魔]终结伤害\n提升[3%*恶魔]原始伤害|r",
            icon = "BTNEwl_Aiguozhe_01"
          })
        end
        return
      end
    end,
    weight = 25,
    key = {
      "唯一",
      "恶魔",
      "战士",
      "兽",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:getdata("系统-血液源石结晶密度") >= 400 and not u:hasdata("变异判定-霜星") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("这就是命运。我尝到，太多滋味。")
      u:changeysnd(1)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:changedata("效果增强-源石", 0.25)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("爱国者-毁灭形态") and not u:hasdata("爱国者-特效冷却") then
          u:settimedata("爱国者-特效冷却", 0.25)
          local txsh = 1000 * u:getstate("源石")
          DamageUnit({
            bj = "爱国者(附伤)",
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
      local hp = 0
      local yssh = 0
      local endsh = 0
      local hj = 0
      local ssjs = 1
      local lwsh = 0
      ac.loop(1000, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:deldata("爱国者-感染者之盾")
        end)
        if u:isalive() then
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:setdata("爱国者-感染者之盾")
          end)
        end
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1 * hp)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lwsh))
        if u:hasdata("爱国者-行军形态") then
          hp = 1 * u:getstate("源石")
          lwsh = 0
        else
          hp = 0
          lwsh = 1 * u:getstate("源石")
          if u:isalive() then
            local x, y = u:getxy()
            local txsh = 10000 * u:getstate("源石")
            for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "霜星(附伤)",
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
        end
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1 * hp)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lwsh))
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * endsh))
        endsh = 0.09 * u:getstate("恶魔")
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (1 * endsh))
        ChangeValue(DamageSystem_Ssjianshao, sy, ssjs, 2)
        u:changearmor(-1 * hj)
        hj = 100 * u:getstate("源石")
        ssjs = 1 - 0.25 * u:getstate("源石")
        if ssjs <= 0.1 then
          ssjs = 0.1
        end
        u:changearmor(1 * hj)
        ChangeValue(DamageSystem_Ssjianshao, sy, ssjs, 1)
      end)
      u:setdata("爱国者-行军形态")
      ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
      ChangeValue(DamageSplit_CountJzHit, sy, 3)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("爱国者-决死冷却") then
          args.dt = false
          local t = 90
          if u:hasdata("爱国者-彩蛋触发") then
            t = 1
          end
          u:settimedata("爱国者-决死冷却", t)
          u:buffset(u.handle, 1, "无敌")
          u:changeysnd(GetRandomReal(1, 10))
        end
      end)
    end,
    effectname = "|cFF990000博|r|cFF991A1A卓|r|cFF993333卡|r|cFF994C4C斯|r|cFF996666替|r",
    effecttext = "|cFF990000唯一 恶魔 战士 源石 兽\n爱国者|r\n|cFF996666[矿石病]对自身效果翻倍\n[矿石病]爆发致死时永久死亡|r\n|cFF990000感染者之盾|r\n|cFF996666提升[100*源石]护甲\n提升[25%*源石]受伤减少\n提升所有[矿石病]感染者25%源石效果\n存活时所有[矿石病]感染者自然增长速率下降|r\n|cFF990000行军/毁灭(点击切换形态)|r\n|cFF996666仇恨权重极大提升\n提升20%终结减伤\n提升[1%*源石]永恒恢复\n近战伤害上限+25%\n近战伤害段数+3(物理)\n受到致死伤害时抵挡该次伤害并无敌1秒,使血液源石结晶密度上升,触发冷却90秒|r\n|cFF990000恶魔之血|r\n|cFF996666提升[0.9%*恶魔]终结伤害|r",
    effectart = "BTNEwl_Aiguozhe_01",
    test = [[

        ]]
  },
  {
    name = "妮芙",
    weight = 25,
    key = {
      "唯一",
      "恶魔",
      "外域",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("真得用武力解决问题吗......？")
      PlayGlobalSound(Sound_Nifu_01)
      u:changeysnd(1)
      local xl = 0
      ac.loop(3000, function()
        ChangeValue(Damage_Element_Heart, sy, -1 * xl)
        xl = 0.05 * u:getstate("外域")
        ChangeValue(Damage_Element_Heart, sy, 1 * xl)
        if u:getdata("外域变异数量") >= 7 and u:isinmaxvar("外域") then
          u:setdata("妮芙-心灵伤害转换")
        end
      end)
      local cs = 0
      ac.loop(1000, function()
        local count = 0
        ForGroupLuaNew(Group_ZhaohuanwuAll, function(xq)
          local dis = DistanceBetweenUnits(u.handle, xq.handle)
          if dis <= 1800 then
            count = count + 1
          end
        end)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() and xq.handle ~= u.handle then
            local dis = DistanceBetweenUnits(u.handle, xq.handle)
            if dis <= 1800 then
              count = count + 1
            end
          end
        end)
        local cgl = 0.05 * count
        if 0.3 <= cgl then
          cgl = 0.3
        end
        u:setdata("妮芙-药水成功率", cgl)
        if u:getdata("妮芙-震爆充能层数") < 2 then
          cs = cs + 1
          if 12 <= cs then
            u:changedata("妮芙-震爆充能层数", 1)
            cs = 0
          end
        end
      end)
      local g = CreateGroupLua()
      ForGroupLuaNew(g, function(xq)
        if xq:getdata("妮芙-凋亡损伤时间") > 0 then
          xq:changedata("妮芙-凋亡损伤时间", -1)
          local hp
          if xq:isboss() then
            hp = 0.5
          else
            hp = 5
          end
          LossHpUnit({
            u = u,
            tg = xq,
            damage = 0,
            perhp = hp,
            maxhp = 0,
            bj = "[生命损耗]妮芙凋亡损伤"
          })
        else
          xq:deldata("妮芙-凋亡损伤时间")
          xq:groupremove(g)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getdata("妮芙-震爆充能层数") > 0 then
          u:setdata(var.name .. "-特效冷却", 3)
          u:changedata("妮芙-震爆充能层数", -1)
          tg:setdata("妮芙-凋亡损伤时间", 2.5)
          tg:groupadd(g)
          tg:buffset(u.handle, 4, "混乱")
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:hasbuff("混乱") then
          ChangeValue(Damage_Element_Heart, sy, 4.0E-4)
        end
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if info.element == "心灵" and tg:hasbuff("混乱") then
          info.endup = info.endup + 0.15
        end
      end)
      u:addstexiao(var.name, "伤害判定后特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.element == "心灵" and info.damage >= tg:getmaxhp() * 0.5 then
          tg:setdata("妮芙-凋亡损伤时间", 5)
          tg:groupadd(g)
        end
      end)
    end,
    effectname = "|cFFE65A8B妮|r|cFFEE91B2芙|r",
    effecttext = "|cFFE65A8B唯一 恶魔 外域 源石\n笞心魔|r\n|cFFEE91B2提升[5%*外域]心灵伤害\n外域变异数量≥7且主变异为外域时\n无属性伤害变为心灵伤害|r\n|cFFE65A8B巡心|r\n|cFFEE91B2自身周围1800范围每存在一名存活队友或召唤物,药水成功率增加5%(上限30%)|r\n|cFFE65A8B怵然震爆|r\n|cFFEE91B2每隔12秒获得一层充能,上限2层\n直接伤害时消耗一层充能对敌人施加4秒混乱与2.5秒[凋亡损伤],触发冷却3秒|r\n|cFFE65A8B失魂|r\n|cFFEE91B2击杀混乱单位时提升0.04%心灵伤害\n对混乱中单位提升15%心灵伤害|r\n|cFFE65A8B心防溃决|r\n|cFFEE91B2心灵伤害超过[目标最大生命值*50%]时,施加5秒[凋亡损伤]|r",
    effectart = "BTNEwl_Nifu",
    test = [[

        ]]
  },
  {
    name = "阿斯卡纶",
    weight = 25,
    key = {
      "唯一",
      "恶魔",
      "影",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("随我步入阴影。")
      PlayGlobalSound(Sound_Asikalun_01)
      u:changeysnd(1)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      u:addstexiao(var.name, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("阿斯卡纶-无形无情") then
          tg:setdata("阿斯卡纶-无形无情")
        end
      end)
      AddAllSTexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("阿斯卡纶-无形无情") then
          info.ewss = info.ewss + 0.1
        end
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata("阿斯卡纶-追袭冷却") and not info.isvestdamage then
          ChangeTimeValue(Correction_Jzsh, sy, 0.1, 1)
          u:settimedata("阿斯卡纶-追袭冷却", 3)
          local txsh = info.yssh
          DamageUnit({
            bj = "阿斯卡纶(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗"
          })
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not tg:hasdata("阿斯卡纶-死亡拘审减速") then
          tg:setdata("阿斯卡纶-死亡拘审减速")
          tg:addskill("S0AK")
        end
        if not tg:hasdata("阿斯卡纶-死亡拘审伤害") then
          tg:settimedata("阿斯卡纶-死亡拘审伤害", 30)
          local cs = 0
          ac.loop(1000, function(timer)
            cs = cs + 1
            local txsh = 110 * u:getlevel() * u:getstate("源石")
            DamageUnit({
              bj = "阿斯卡纶(附伤)",
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
            if cs == 30 or not tg:isalive() then
              timer:remove()
            end
          end)
        end
      end)
      ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        if not u:hasdata("阿斯卡纶-残影冷却") then
          u:settimedata("阿斯卡纶-残影冷却", 30)
          local add = 0.6 * u:getstate("源石")
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.1 * add, 10)
        end
      end)
      ac.loop(250, function()
        if u:getdata("战斗时间") > 0 then
          if u:hasdata("阿斯卡纶-脱战移速") then
            u:deldata("阿斯卡纶-脱战移速")
            u:delskill("S0AL")
            u:clearbuff("B0EN")
          end
        elseif not u:hasdata("阿斯卡纶-脱战移速") then
          u:setdata("阿斯卡纶-脱战移速")
          u:addskill("S0AL")
        end
      end)
    end,
    effectname = "|cFFAC4C7B阿|r|cFFB2668B斯|r|cFFB97F9B卡|r|cFFBF99AC纶|r",
    effecttext = "|cFFAC4C7B唯一 恶魔 影 源石\n无形无情|r\n|cFFBF99AC提升10%暴击率\n暴击时使目标提升10%额外受伤,无法叠加|r\n|cFFAC4C7B追袭|r\n|cFFBF99AC近战直接伤害时提升100%近战修正1秒并附带[100%*原始伤害]暗物理近战伤害,触发冷却3秒|r\n|cFFAC4C7B死亡拘审|r\n|cFFBF99AC直接伤害时降低目标50%速度,同时每秒附带[110*等级*源石]暗属性魔力,持续30秒,无法叠加|r\n|cFFAC4C7B噬光残影|r\n|cFFBF99AC入战时在10秒内提升[6%*源石]伤害加成,触发冷却30秒\n脱战时提升100%移速|r\n|cFFAC4C7B恶魔之血|r\n|cFFBF99AC提高0.5%终结伤害|r",
    effectart = "BTNEwl_Asikalun",
    test = [[

        ]]
  },
  {
    name = "逻各斯",
    weight = 25,
    key = {
      "唯一",
      "恶魔",
      "魔导",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("凡有疑问，必有解答。凡有规则，必能解析。")
      PlayGlobalSound(Sound_Logos_01)
      u:changeysnd(1)
      ac.loop(1000, function()
        if u:isalive() then
          local x, y = u:getxy()
          local txsh = 5000 + u:getallattri() * 150
          for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if xq:isnormal() and xq:getperhp() <= 5 then
              xq:kill(u.handle)
              local dx, dy = xq:getxy()
              for _, xq2 in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):ipairs() do
                xq2 = getunit(xq2)
                DamageUnit({
                  bj = "逻各斯(附伤)",
                  unit = xq2.handle,
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
            end
          end
        end
      end)
      ChangeValue(Damage_ElementRes_All, sy, 15)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(Correction_Magic, sy, 1.0E-5)
      end)
      ac.loop(100, function(timer)
        local x, y = u:getxy()
        for _, xq in ac.selector():in_rangexy(x, y, 1800):of_unify():ipairs() do
          xq = getunit(xq)
          if xq.owner ~= u.owner then
            xq:setdata("弹幕-飞行速度", 0.6)
          end
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(4 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 0.25)
          local txsh = 125 * u:getallattri()
          DamageUnit({
            bj = "逻各斯(附伤)",
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
      u:addstexiao(var.name, "伤害判定后特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 1)
          tg:changetimedata("全属性抗性", -3, 5)
        end
      end)
    end,
    effectname = "|cFF3366FF逻|r|cFF4066D9各|r|cFF4C66B2斯|r",
    effecttext = "|cFF3366FF唯一 恶魔 魔导 源石\n殁亡|r\n|cFF4C66B2自身周围1200范围普通单位血量低于5%时即死并对周围300范围造成[5000+全属性*150]暗属性魔力伤害|r\n|cFF3366FF报丧女妖|r\n|cFF4C66B2提升15%全属性抗性\n杀敌时提升0.1%法术修正|r\n|cFF3366FF延异视阈|r\n|cFF4C66B2视野范围扩大\n自身周围1800范围非自身弹幕降低40%速度|r\n|cFF3366FF语汇演化|r\n|cFF4C66B2直接伤害时4%附带[全属性*125]暗属性魔力伤害,触发冷却0.25秒|r\n|cFF3366FF剜魂具辞|r\n|cFF4C66B2造成伤害时降低目标全属性抗性3%持续5秒,触发冷却1秒,可叠加分立计时|r",
    effectart = "BTNEwl_Logos",
    test = [[

        ]]
  },
  {
    name = "特蕾西娅",
    weight = 300,
    key = {
      "唯一",
      "恶魔",
      "同奏",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:getdata("源石变异数量") >= 3 and u:hasdata("卡兹戴尔纹章-持有") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("......我在。")
      PlayGlobalSound(Sound_Teleixiya_01)
      u:changeysnd(1)
      if not u:hasdata("特蕾西娅-微尘特效组") then
        local g = {}
        u:setdata("特蕾西娅-微尘特效组", g)
        u:setdata("特蕾西娅-微尘上限", 6)
        u:setdata("特蕾西娅-微尘恢复速率", 1)
        local cs = 0
        ac.loop(1000, function()
          if u:isalive() and u:getdata("特蕾西娅-微尘数量") < u:getdata("特蕾西娅-微尘上限") then
            cs = cs + u:getdata("特蕾西娅-微尘恢复速率")
            if 6 <= cs then
              cs = 0
              u:changedata("特蕾西娅-微尘数量", 1)
              local x, y = u:getxy()
              local tx = Effectcreate("Tlxy_Fuwen.mdx", x, y, -1)
              g[#g + 1] = tx
            end
          end
        end)
        local jd = 0
        ac.loop(30, function()
          if u:getdata("特蕾西娅-微尘数量") > 0 then
            jd = jd + 3
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
      else
        u:changedata("特蕾西娅-微尘上限", 6)
        u:changedata("特蕾西娅-微尘恢复速率", 1)
      end
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getdata("特蕾西娅-微尘数量") > 0 then
          local g = u:getdata("特蕾西娅-微尘特效组")
          if type(g) ~= "table" or #g <= 0 then
            return
          end
          u:setdata(var.name .. "-特效冷却", 1)
          u:changedata("特蕾西娅-微尘数量", -1)
          DestroyEffectLua(g[#g])
          g[#g] = nil
          u:settimedata(var.name .. "-特效冷却", 1)
          local yssh = info.yssh
          if tg:isboss() then
            local max = 0.005 * tg:getmaxhp()
            if yssh >= max then
              yssh = max + (yssh - max) * 0.1
            end
          end
          local txsh = 5 * yssh * u:getstate("源石") * u:getstate("恶魔")
          local x, y = tg:getxy()
          Effectcreate("Tlxy_Baofa.mdx", x, y)
          LossHpUnit({
            u = u,
            tg = tg,
            damage = txsh,
            perhp = 0,
            maxhp = 0,
            bj = "[生命损耗]特蕾西娅微尘"
          })
          tg:buffset(u.handle, 3.5, "僵直")
          tg:buffset(u.handle, 3.5, "缠绕")
        end
      end)
      local yssh = 0
      local endsh = 0
      ac.loop(3000, function()
        local add = 0.1 * Count_Emobianyi * u:getstate("恶魔")
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:hasdata("特蕾西娅-魔王残响增伤") then
            local sy2 = xq.ownerid
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * (-1 * xq:getdata("特蕾西娅-魔王残响增伤")))
            xq:deldata("特蕾西娅-魔王残响增伤")
            ChangeValue(DamageSystem_Ssjianshao, sy2, 0.85, 2)
            ChangeValue(HeroMenu_HpForever_MaxHp, sy2, -0.25)
          end
        end)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy2 = xq.ownerid
          if xq:getdata("恶魔变异数量") > 0 then
            if not u:isalive() then
              add = 0
            end
            xq:setdata("特蕾西娅-魔王残响增伤", add)
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * add)
            ChangeValue(DamageSystem_Ssjianshao, sy2, 0.85, 1)
            ChangeValue(HeroMenu_HpForever_MaxHp, sy2, 0.25)
          end
        end)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * endsh))
        endsh = 0.09 * u:getstate("恶魔")
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (1 * endsh))
      end)
      ac.loop(1000, function(timer)
        if u:getdata("恶魔变异数量") >= 8 then
          u:sendmessage("|cFFC6BABC特蕾西娅-编织重构现世效果解锁|r")
          u:chat("每个人都有平静入梦的权利，你也一样。")
          PlayGlobalSound(Sound_Teleixiya_02)
          u:changedata("效果增强-源石", 1)
          u:changedata("效果增强-恶魔", 0.25)
          timer:remove()
        end
      end)
    end,
    effectname = "|cFFC6BABC特|r|cFFB8ADB2蕾|r|cFFA9A0A8西|r|cFF9B939E娅|r",
    effecttext = "|cFFE3D4CF唯一 恶魔 同奏\n永|r|cFFCFC2C1恒|r|cFFBBB0B4尘|r|cFFA69DA6埃\n每隔6秒获得一层[微尘],至多六层\n直接伤害时消耗一层[微尘]造成[500%*原始伤害(超过0.5%部分衰减90%)*源石*恶魔]生命损耗与3.5秒缠绕与僵直,触发冷却1秒|r\n|cFFE3D4CF魔|r|cFFD4AAA6王|r|cFFC57F7C残|r|cFFB75553响|r\n|cFFE3D4CF自身存活时,提升所有拥有[恶魔]英雄[恶魔(自身)*全队恶魔变异总和*1%]伤害加成,15%论外减伤|r\n|cFFE3D4CF期|r|cFFE9C8D9冀|r|cFFEEBCE2之|r|cFFF4B1EC汇|r\n|cFFE3D4CF自身存活时,提升所有拥有[恶魔]英雄15%药水成功率与0.25%永恒恢复|r\n|cFF990000恶魔之血|r\n|cFFCC0000提升[0.9%*恶魔]终结伤害|r\n|cFFFFFFFF编织|r|cFFE9E0DD重构|r|cFFEAD8D2现世[恶魔变异数量≥8时生效]|r\n|cFFE9E0DD提升100%源石效果\n提升25%恶魔效果|r\n|cFF666666黑冠\n[数据删除]|r",
    effectart = "BTNEwl_Tlxy_01",
    test = "        "
  },
  {
    name = "德克萨斯",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:hasdata("血统判定-狼人") or u:hasdata("变异判定-白狼王") or u:hasdata("赫萝-狼血") or u:hasdata("变异判定-千矢") then
        PlayGlobalSound(Sound_Dkss_03)
        SendColorfulMsgAll("为了平静的生活，我还有很多事情需要处理，如果摆脱过去的方法只有粉碎它，那我就会粉碎它。", "|cFF3D63F1", "|cFFF1F5FE", "|cFF3B4350", "|cFF0123CB")
        u:setdata("德克萨斯-缄默之狼")
        ChangeValue(Correction_Jzsh, sy, 0.025)
        ChangeValue(Correction_Jzsh, sy, 0.025)
        ChangeValue(DamageSplit_CountJzMax, sy, 0.2)
        u:addstexiao("德克萨斯-缄默之狼", "终结伤害计算效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not tg:isingroup(Group_Wolf) then
            info.end1 = info.end1 + 0.12
          end
        end)
        u:uivar_change({
          keyname = "德克萨斯",
          keytype = "传奇栏",
          text = "|cFF3D63F1德克|r|cFFF1F5FE萨斯|r\n|cFF3D63F1兽 战士\n德克萨斯剑术|r\n|cFFF1F5FE切换剑类武器后立刻眩晕周围600范围单位3秒,在15秒内触发以下效果,触发冷却60秒\n杀敌时延长1秒,触发冷却2秒\n剑类武器享受30%法术修正\n挥动剑类武器时,如果身上还有剑类武器则立刻自动切换并挥动,无视切换冷却,触发冷却0.5秒|r\n|cFF3D63F1细雨无声|r\n|cFFF1F5FE提升50%近战修正\n近战伤害移除目标精英特性3秒,独立冷却5秒|r\n|cFF3D63F1德克萨斯传统|r\n|cFFF1F5FE切换剑类武器时,在10秒内提升25%法术修正与25%近战修正|r\n|cFF3D63F1缄默之狼|r\n|cFFF1F5FE提升5%近战伤害\n近战多击上限+40%\n近战多击段数+1(魔力,不处于德克萨斯剑术效果时享受30%法术修正)\n对狼群以外的敌人提升12%伤害\n对狼群造成的伤害降低75%|r",
          icon = "war3mapImported\\BTNEwl_Cq_Dekesasi",
          isclearclick = true
        })
      else
        u:sendmessage("|cFF3D63F1条件不满足|r")
      end
    end,
    weight = 25,
    key = {
      "唯一",
      "战士",
      "兽",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendColorfulMsgAll("代号德克萨斯，职能包括载具驾驶、货物搬运以及人员安全保障。关于任务的说明，请尽量简单些", "|cFF3D63F1", "|cFFF1F5FE", "|cFF3B4350", "|cFF0123CB")
      PlayGlobalSound(Sound_Dkss_01)
      u:changeysnd(1)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.2)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        if not tg:hasdata(var.name .. "-移除特性冷却") then
          tg:removecharacteristics(3)
          tg:settimedata(var.name .. "-移除特性冷却", 5)
        end
      end)
      ac.loop(1000, function()
        if u:hasdata("德克萨斯-德克萨斯剑术时间") then
          u:changedata("德克萨斯-德克萨斯剑术时间", -1)
          if u:getdata("德克萨斯-德克萨斯剑术时间") <= 0 then
            u:deldata("德克萨斯-德克萨斯剑术")
            u:deldata("德克萨斯-德克萨斯剑术时间")
          end
        end
      end)
    end,
    effectname = "|cFF3D63F1德克|r|cFFF1F5FE萨斯|r",
    effecttext = "|cFF3D63F1兽 战士 源石\n德克萨斯剑术|r\n|cFFF1F5FE切换剑类武器后立刻眩晕周围600范围单位3秒,在15秒内触发以下效果,触发冷却60秒\n杀敌时延长1秒,触发冷却2秒\n剑类武器享受30%法术修正\n挥动剑类武器时,如果身上还有剑类武器则立刻自动切换并挥动,无视切换冷却|r\n|cFF3D63F1德克萨斯传统|r\n|cFFF1F5FE切换剑类武器时,在10秒内提升25%法术修正与25%近战修正|r\n|cFF3D63F1细雨无声|r\n|cFFF1F5FE提升25%近战修正\n近战伤害移除目标精英特性3秒,独立冷却5秒|r\n|cFF3D63F1缄默之狼[拥有狼人血统时点击进阶]|r\n|cFFF1F5FE提升2.5%近战伤害\n近战多击上限+20%\n近战多击段数+1(魔力)|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Dekesasi_2"
  },
  {
    name = "赫德雷",
    weight = 25,
    key = {
      "唯一",
      "恶魔",
      "战士",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("......战争从未改变。")
      PlayGlobalSound(Sound_Hedelei_01)
      Weiyi_New[2] = true
      coopjudge("佣兵三人组")
      u:changeysnd(1)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
      u:changearmor(30)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        if not tg:hasdata(var.name .. "-特效冷却") then
          tg:settimedata(var.name .. "-特效冷却", 10)
          tg:buffset(u.handle, 3, "眩晕")
        end
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local tg = args.tg
        if tg:hasbuff("僵直") or tg:hasbuff("眩晕") then
          args.damage = args.damage * 1.08 * u:getstate("源石")
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if info.ismeleedamage then
          info.pk_jianying = true
        end
      end)
      ac.wait(1, function()
        if u:hasdata("变异判定-植物学硕士") and not u:hasdata("赫德雷-遇强则强") then
          u:setdata("赫德雷-遇强则强")
          u:addstexiao(var.name, "终结伤害计算效果", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if tg:isboss() then
              info.end3 = info.end3 + 0.01 * u:getdata("怪物强度") * u:getstate("源石")
            elseif tg:iselite() then
              info.end3 = info.end3 + 0.25 * u:getstate("源石")
            else
              info.end3 = info.end3 - 0.85
              if info.end3 < 0 then
                info.end3 = 0.01
              end
            end
          end)
          u:uivar_change({
            keyname = "赫德雷",
            keytype = "传奇栏",
            text = "|cFF990000赫德雷|r\n|cFF990000[源石]\n恶魔 唯一 战士\n砺尘巨剑|r\n|cFF993333提升5%近战伤害\n近战伤害无视精英特性铁壁与坚硬|r\n|cFF990000及锋而试|r\n|cFF993333近战伤害对处于僵直或眩晕的单位提升[8%*源石]伤害|r\n|cFF990000余火之壁|r\n|cFF993333提升30点护甲\n受伤时使目标眩晕3秒,独立冷却10秒|r\n|cFF990000恶魔之血|r\n|cFF993333提升0.5%终结伤害|r\n|cFF990000遇强则强实力不详|r\n|cFF993333对普通单位降低85%伤害\n对精英单位提升[25%]伤害\n对BOSS提升[目标怪物强度*1%]伤害|r"
          })
        end
      end)
    end,
    effectname = "|cFF990000赫德雷|r",
    effecttext = "|cFF990000[源石]\n恶魔 唯一 战士\n砺尘巨剑|r\n|cFF993333提升5%近战伤害\n近战伤害无视精英特性铁壁与坚硬|r\n|cFF990000及锋而试|r\n|cFF993333近战伤害对处于僵直或眩晕的单位提升[8%*源石]伤害|r\n|cFF990000余火之壁|r\n|cFF993333提升30点护甲\n受伤时使目标眩晕3秒,独立冷却10秒|r\n|cFF990000恶魔之血|r\n|cFF993333提升1%终结伤害\n提升3%原始伤害|r",
    effectart = "BTNEwl_Hedelei_Cq",
    test = [[

        ]]
  },
  {
    name = "玛恩纳",
    weight = 25,
    key = {
      "唯一",
      "光明",
      "战士",
      "兽",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("......您考虑妥当的话，我无意反对。")
      PlayGlobalSound(Sound_Maenna_01)
      if u:getdata("传奇数量") <= 3 then
        u:chat("玛↑恩↓纳↑~")
        PlayGlobalSound(Sound_Maenna_SPe)
      end
      u:changedata("仇恨权重", 100)
      u:changeysnd(1)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      local sj = 0
      local jz = 0
      ac.loop(1000, function()
        if u:getdata("战斗时间") > 0 then
          local change = sj
          sj = 0
          ac.wait(10000, function()
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * change))
          end)
        else
          local add = u:getstate("源石") * 0.05
          local max = 2 * u:getstate("源石")
          if max > sj then
            sj = sj + u:getstate("源石") * 0.05
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
          end
        end
        ChangeValue(Correction_Jzsh, sy, 0.1 * (-1 * jz))
        jz = 0.1 * u:getstate("光明变异") * u:getstate("源石")
        ChangeValue(Correction_Jzsh, sy, 0.1 * (1 * jz))
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:isboss() then
          info.end3 = info.end3 + 0.09
        elseif tg:iselite() then
          info.end3 = info.end3 + 0.12
        else
          info.end3 = info.end3 + 0.18
        end
      end)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 1)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage > 10 then
          local txsh = 10000 * u:getstate("光明变异") * u:getstate("源石")
          DamageUnit({
            bj = "玛恩纳(反伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光"
          })
        end
      end)
      u:changearmor(30)
      u:changedata("效果增强-光明", 0.05)
      u:addstexiao(var.name, "直接伤害变更", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(15) then
          info.element = "光"
          if info.level <= 5 then
            info.level = 5
          end
        end
      end)
    end,
    effectname = "|cFFFDDFB5玛恩纳|r",
    effecttext = "|cFF957B72唯一 光明 战士 兽 源石\n沉默的解放者|r\n|cFFFDDFB5提升5%伤害加成\n脱战时每秒提升[0.5%*源石]伤害加成,上限[200%*源石],进入战斗后持续10秒|r\n|cFF957B72游侠|r\n|cFFFDDFB5对普通敌人提升18%伤害\n对精英提升12%伤害\n对BOSS提升9%伤害|r\n|cFF957B72无动于衷|r\n|cFFFDDFB5提升15%论外减伤\n受伤时对伤害来源造成[10000*光明变异*源石]光属性魔力伤害|r\n|cFF957B72未声张的怒火|r\n|cFFFDDFB5提升30护甲\n提升[1%*光明变异*源石]近战伤害|r\n|cFF957B72未照耀的荣光|r\n|cFFFDDFB5提升100仇恨权重\n提升5%光明变异效果\n直接伤害15%变为光属性抹除伤害|r",
    effectart = "BTNEwl_Maenna_01",
    test = [[

        ]]
  },
  {
    name = "W",
    weight = 25,
    key = {
      "唯一",
      "恶魔",
      "源石"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("阿拉，又是美好的一天。")
      PlayGlobalSound(Sound_W_01)
      Weiyi_New[3] = true
      coopjudge("佣兵三人组")
      u:changeysnd(1)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local b = false
        if tg:hasbuff("睡眠") then
          b = true
        end
        if tg:hasbuff("石化") then
          b = true
        end
        if tg:hasbuff("缠绕") then
          b = true
        end
        if tg:hasbuff("僵直") then
          b = true
        end
        if tg:hasbuff("混乱") then
          b = true
        end
        if tg:hasbuff("麻痹") then
          b = true
        end
        if tg:hasbuff("暂停") then
          b = true
        end
        if tg:hasbuff("冰冻") then
          b = true
        end
        if tg:hasbuff("燃烧") then
          b = true
        end
        if b then
          info.end2 = info.end2 + 0.1 * u:getstate("源石")
        end
      end)
      ChangeValue(Correction_Gun, sy, 0.025)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
      ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 30)
          u:buffset(u.handle, 3, "隐身")
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, -50, 30)
        end
      end)
      u:addstexiao(var.name, "枪械装弹时效果", function(args)
        if not u:hasdata("W-改装榴弹") then
          u:setdata("W-改装榴弹")
        end
      end)
    end,
    effectname = "|cFFAF1821W|r",
    effecttext = "|cFFAF1821[源石]\n恶魔 唯一\n铳械精通|r\n|cFFAF1821提升2.5%枪械伤害\n装弹时将首发子弹改装为榴弹,造成500码[范围伤害]并眩晕2秒|r\n|cFFAF1821设伏|r\n|cFFAF1821提升50额外移速,受到伤害时隐身3秒并进入冷却,冷却30秒,冷却期间无提升|r\n|cFFAF1821落井下石|r\n|cFFAF1821对处于异常状态单位提升[10%]伤害|r\n|cFFAF1821恶魔之血|r\n|cFFAF1821提升0.5%终结伤害|r",
    effectart = "Ewl_W_Cq",
    test = [[

        ]]
  },
  {
    name = "伊内丝",
    weight = 25,
    key = {
      "唯一",
      "影",
      "战士",
      "源石",
      "兽"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-至宝指环") then
        add = add + 25
      end
      if u:hasdata("特典-神秘兜帽男") then
        add = add + 75
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFBA4E4B『你只需要知道，我暂时不会威胁你的性命，“博士”。』|r")
      u:playselfsound(Sound_Yineisi_01)
      if GetRandom100(10) then
        ac.wait(100, function()
          u:uivar_change({
            keyname = "伊内丝",
            keytype = "传奇栏",
            text = "|cFFBA4E4B土豆地雷|r\n|cFFBA4E4B影 战士 源石 唯一 兽\n淬影突袭|r\n|cFFB4ABAA近战伤害使目标在3秒内每秒受到[25%*原始伤害]暗魔力生命移除特效伤害,无法叠加|r\n|cFFBA4E4B暗夜无明|r\n|cFFB4ABAA近战伤害恢复0.1体力值,独立冷却1秒\n处于隐身状态提升20%暴击率,[2.5%+0.05%*等级]伤害加成与10%终结伤害,脱离隐身时,加成效果粘滞至多1秒|r\n|cFFBA4E4B独影归途|r\n|cFFB4ABAA入战时,在15秒提升[5%+0.1%*等级]伤害加成,同时下一次伤害将会传导至随机6名单位,触发冷却60秒|r"
          })
        end)
      end
      Weiyi_New[4] = true
      coopjudge("佣兵三人组")
      u:changeysnd(1)
      local bj = 0
      local lw = 0
      local zj = 0
      ac.loop(1000, function()
        ChangeValue(DamageSystem_Baoji, sy, -1 * bj)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * zj))
        if u:isalive() and not u:isbeseen(BOSS_DEATH) then
          bj = 20
          lw = (0.25 + 0.005 * u:getlevel()) * u:getstate("源石")
          zj = 0.1
        else
          bj = 0
          lw = 0
          zj = 0
        end
        ChangeValue(DamageSystem_Baoji, sy, 1 * bj)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (1 * zj))
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if not tg:hasdata("暗夜无明-回体冷却") then
          tg:settimedata("暗夜无明-回体冷却", 1)
          u:curetili(0.1)
        end
        if not tg:hasdata("淬影突袭-生效中") then
          tg:settimedata("淬影突袭-生效中", 3)
          local txsh = 0.25 * info.yssh * u:getstate("源石")
          ac.timer(1000, 3, function()
            DamageUnit({
              bj = "伊内丝(淬影突袭)",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 4,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗"
            })
          end)
        end
      end)
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        if not u:hasdata("独影归途冷却") then
          u:sendmessage("|cFFBA4E4B独影归途|r")
          u:settimedata("独影归途冷却", 60)
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.1 * ((0.5 + 0.01 * u:getlevel()) * u:getstate("源石")), 15)
          u:setdata("独影归途-传导伤害")
          u:setdata("独影归途-特效", u:effectadd("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl", "hand left", -1))
        end
      end)
      u:addstexiao(var.name, "直接伤害变更", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("独影归途-传导伤害") then
          u:deldata("独影归途-传导伤害")
          DestroyEffectLua(u:getdata("独影归途-特效"))
          u:deldata("独影归途-特效")
          local txsh = info.damage
          local g = Group_Randomunits(Group_Monster, 6)
          for index, value in ipairs(g) do
            DamageUnit({
              bj = "伊内丝(独影归途)",
              unit = value,
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
        end
      end)
    end,
    effectname = "|cFFBA4E4B伊内丝|r",
    effecttext = "|cFFBA4E4B影 战士 源石\n淬影突袭|r\n|cFFB4ABAA近战伤害使目标在3秒内每秒受到[25%*原始伤害]暗魔力生命移除特效伤害,无法叠加|r\n|cFFBA4E4B暗夜无明|r\n|cFFB4ABAA近战伤害恢复0.1体力值,独立冷却1秒\n处于隐身状态提升20%暴击率,[2.5%+0.05%*等级]伤害加成与10%终结伤害,脱离隐身时,加成效果粘滞至多1秒|r\n|cFFBA4E4B独影归途|r\n|cFFB4ABAA入战时,在15秒提升[5%+0.1%*等级]伤害加成,同时下一次伤害将会传导至随机6名单位,触发冷却60秒|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Yineisi"
  }
}
