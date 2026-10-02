-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
BloodType = {
  {
    name = "人",
    color = "|cFF7DBEF1人"
  },
  {
    name = "兽",
    color = "|cFFCC9933兽"
  },
  {
    name = "妖",
    color = "|cFFFF9966妖"
  },
  {
    name = "魔",
    color = "|cFF6633CC魔"
  },
  {
    name = "灵",
    color = "|cFF6699FF灵"
  },
  {
    name = "神",
    color = "|cFFFFCC33神"
  },
  {
    name = "龙",
    color = "|cFFFFCC33龙"
  },
  {
    name = "月",
    color = "|cFF0099FF月"
  },
  {
    name = "妖精",
    color = "|cFF66FF99妖精"
  },
  {
    name = "元素",
    color = "|cFF99CCFF元素"
  },
  {
    name = "吸血鬼",
    color = "|cFF990000吸血鬼"
  },
  {
    name = "渊海",
    color = "|cFF006699渊海"
  },
  {
    name = "不死",
    color = "|cFF666666不死"
  },
  {
    name = "构造",
    color = "|cFF99CCCC构造"
  }
}

local function apply_blood_base_effect(u, var, set_variation_flag)
  u:setdata("血统判定-" .. var.name)
  if set_variation_flag then
    u:setdata("变异判定-" .. var.name)
  end
  for _, key in ipairs(var.key or {}) do
    u:changedata(key .. "变异数量", 1)
  end
  if var.bloodkey and #var.bloodkey ~= 0 then
    for _, bloodkey in ipairs(var.bloodkey) do
      u:changedata(bloodkey .. "血统补正浓度", var.bloodcoc)
    end
    u:changedata("总血统补正浓度", var.bloodcoc)
  end
  if var.dragoncoc and var.dragoncoc ~= 0 then
    u:adddragonpower(var.dragoncoc)
  end
  if var.bloodcoc then
    u:changedata("血统浓度", var.bloodcoc)
  end
end

Vars_Blood = {
  {
    name = "风神",
    bloodlevel = 1,
    bloodcoc = 5,
    dragoncoc = 0,
    weight = 5,
    key = {"唯一", "风"},
    bloodkey = {"神", "人"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-早苗") and u:hasdata("变异判定-奇迹の祝福") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      apply_blood_base_effect(u, var, true)
      u:sendmessage("|cFFFFFF00你感觉四周升起了风|r")
      u:adddivinity(1)
      u:changedata("幸运", 1)
      u:addskill("S02N")
      u:addskill("S02O")
      u:changedata("闪避值", 20)
      ChangeValue(HeroMenu_Sbxs, sy, 0.05)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      ChangeValue(Correction_RPM, sy, 0.15)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.9, 1)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      ChangeValue(DamageSystem_Shjc, sy, 0.03)
      Zaomiao_xinyangzengjia(u, 5)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 1)
          local sl = tg:eliteschange()
          local txsh = 25 * u:getlevel() + 250 * sl
          DamageUnit({
            bj = "风神血统",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "风",
            extradata = {""}
          })
          if u:getluckrandom(1) and not tg:hasdata("奇迹的洗礼无效") then
            if not tg:isnormal() then
              tg:setdata("奇迹的洗礼无效")
            end
            tg:effectadd("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl")
            tg:eliteschange(-1)
          end
        end
        if u:hasdata("东风谷早苗-风祝的巫女") and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(5) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local x, y = u:getxy()
          local txsh = 300 * u:getlevel() + 5000
          local angle = AngleBetweenUnits(u.handle, tg.handle)
          unifycreate({
            owner = u.handle,
            model = "Abilities\\Spells\\NightElf\\Cyclone\\CycloneTarget.mdl",
            modelname = "早苗风",
            modelsize = 1,
            height = 0,
            damage = txsh,
            damagetype = 1,
            x = x,
            y = y,
            range = 1500,
            speed = 1100,
            volume = 250,
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
              xq:buffset(u.handle, 1, "眩晕")
              unitmove({
                unit = xq.handle,
                time = 0.5,
                distance = 500,
                angle = angle
              })
            end,
            endfunc = function(mj)
            end
          })
        end
      end)
      u:addtrgevent("单位-被攻击", function(args)
        local soc = args.soc
        local u = args.u
        if not u:hasdata("烈风障壁冷却") then
          local dis = DistanceBetweenUnits(u.handle, soc.handle)
          if dis <= 300 and u:getluckrandom(50) then
            u:settimedata("烈风障壁冷却", 15)
            soc:buffset(u.handle, 1, "眩晕")
            local txsh = 15 * u:getdata("魔力值")
            DamageUnit({
              bj = "烈风障壁",
              unit = soc.handle,
              source = u.handle,
              damage = txsh,
              level = 4,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "风",
              extradata = {""}
            })
          end
        end
      end)
    end,
    effectname = "|cFFFFFF33风神|r",
    effecttext = "|cFFFFFF33风 唯一\n神性 1\n风の声|r\n|cFF66FF99提升15%RPM\n提升0.1体力恢复\n提升1幸运\n提升25额外移速与20%移速\n降低900范围敌军20%移速|r\n|cFFFFFF33风の守护|r\n|cFF66FF99增加10%论外减伤\n每60秒免疫一次大于100的伤害\n提高0.05闪避系数与20闪避值|r\n|cFFFFFF33风の祈愿|r\n|cFF66FF99受到致命伤害时抵挡该次伤害并回复40%生命值,无敌3秒,期间提升400额外移速,触发冷却500秒|r\n|cFFFFFF33烈风障壁|r\n|cFF66FF99300码内单位试图攻击自身时将会被击退400码并眩晕1秒附带[魔力值*15]灵力生命移除伤害(独立冷却15秒)|r\n|cFFFFFF33秘术「グレイソーマタージ」|r\n|cFF66FF99[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Fengshen.blp"
  },
  {
    name = "银冰的庇护",
    bloodlevel = 1,
    bloodcoc = 25,
    dragoncoc = 25,
    weight = 50,
    key = {
      "龙",
      "唯一",
      "白毛",
      "冰"
    },
    bloodkey = {"龙", "人"},
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFF3366FF瓶中的血液被饮下后变得极度寒冷，你感觉死亡在临近……|r")
      u:changedata("龙变异补正", 50)
      u:sethp(1, true)
      u:setdata("银冰杀敌", 0)
      u:playsound(Sound_Filene_01)
      local ice = 0
      local zs = 0
      ac.loop(3000, function(t)
        local dr = u:getdragonbloodpower()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zs))
        ChangeValue(Damage_Element_Ice, sy, -1 * ice)
        if u:hasdata("血统判定-银冰的加护") then
          zs = 0.1 * dr * u:getstate("冰变异")
          ice = 0.1 * dr
        else
          zs = 0.08 * dr * u:getstate("冰变异")
          ice = 0
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zs))
        ChangeValue(Damage_Element_Ice, sy, 1 * ice)
        if u:hasdata("变异判定-菲琳") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zs))
          ChangeValue(Damage_Element_Ice, sy, -1 * ice)
          t:remove()
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          if GetRandom100(50) then
            if u:hasdata("变异判定-菲琳") then
              u:playsound(Sound_Filene_05)
            else
              u:playsound(Sound_Filene_02)
            end
          end
          tg:effectadd("AATX\\[AATxNew]Ice05.mdl", "chest", 0.5)
          local dr = u:getdragonbloodpower()
          if u:hasdata("血统判定-银冰的加护") then
            local txsh
            if u:hasdata("变异判定-菲琳") then
              txsh = 10 * (u:getdata("龙变异数量") * u:getdata("冰变异数量")) * u:getallattri()
            else
              txsh = 10 * u:getdata("龙变异数量") * u:getallattri()
            end
            txsh = txsh * (175 - u:getperhp()) / 100 * dr
            local x, y = tg:getxy()
            Effectcreate("ATX\\[ATxNew]Ice_02_C.mdl", x, y, 0, 2)
            for _, xq in ac.selector():in_rangexy(x, y, 255):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "银冰的加护",
                unit = tg.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "冰",
                extradata = {"龙属性"}
              })
              if u:hasdata("变异判定-菲琳") then
                xq:buffset(u.handle, 1, "冰冻")
              end
            end
          else
            local txsh = 10 * u:getallattri() * (150 - u:getperhp()) / 100 * dr
            DamageUnit({
              bj = "银冰的加护",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "冰",
              extradata = {"龙属性"}
            })
          end
          local t = 2
          if u:hasdata("变异判定-菲琳") then
            t = 1.5
          end
          u:settimedata(var.name .. "-特效冷却", t)
        end
      end)
      ac.loop(3000, function(timer)
        if u:getdata("银冰杀敌") >= 100 and u:getdata("冰变异数量") >= 3 then
          u:chat("这将是你最后的吐息")
          u:setdata("变异判定-银冰的加护")
          PlayGlobalSound(Sound_Filene_03)
          ChangeValue(Hero_Tili_Huifu, sy, 0.1)
          u:changedata("龙变异补正", 50)
          u:uivar_remove("银冰的庇护", "血统栏")
          u:uivar_add({
            keyname = "银冰的加护",
            keytype = "传奇栏",
            text = "|cFF3366FF银|r|cFF5C85FF冰の|r|cFF85A3FF加|r|cFFADC2FF护|r\n|cFF5C85FF冰 龙\n冰息|r\n|cFFADC2FF提升[10%*纯度浓度相关]冰属性伤害\n直接伤害时10%附带255范围[(50%+目标缺失生命百分比)*全属性*50*龙变异数量*纯度浓度相关]冰系龙属性魔力伤害,触发冷却2秒|r\n|cFF5C85FF冰龙血楔|r\n|cFFADC2FF受到大于100伤害时降低25%所受伤害并冰冻目标1秒,独立冷却3(6/15)秒\n提升50%龙变异补正|r\n|cFF5C85FF冰冷之心|r\n|cFFADC2FF提升0.1体力恢复\n提升自身[1%*冰变异数量*纯度浓度相关]伤害加成|r\n|cFF949596反正到头来，终究会变得冰冷。\n——既然如此我不要，也不需要。\n——所以就都冻结吧，直至身体的每一处。|r",
            icon = "war3mapImported\\BTNEwl_Filene_02",
            clickfunc = function(u, button)
              if u:isalive() and u:ishasshw() and u:getdata("冰变异数量") > u:getdata("炎变异数量") and u:getdata("冰变异数量") >= 3 and Race_Dragon_Cd[sy] >= 0.7 then
                AdvanceGet["菲琳"](u)
              end
            end
          })
          timer:remove()
        end
      end)
    end,
    effectname = "|cFF3366FF银|r|cFF5C85FF冰の|r|cFF85A3FF庇|r|cFFADC2FF护|r",
    effecttext = "|cFF5C85FF冰 龙\n冰息|r\n|cFFADC2FF直接伤害时10%附带[(50%+目标缺失生命百分比)*全属性*10*纯度浓度相关]冰系龙属性魔力伤害,触发冷却2秒|r\n|cFF5C85FF冰龙血楔|r\n|cFFADC2FF受到大于100伤害时冰冻目标1秒,独立冷却3(6/15)秒\n提升50%龙变异补正|r\n|cFF5C85FF冰冷之心|r\n|cFFADC2FF提升自身[0.8%*(冰变异数量-炎变异数量)*纯度浓度相关]伤害加成|r\n|cFF3366FF进阶：获取后累积杀敌100，冰变异数量大于等于3|r\n|cFF949596凡是温暖的东西，总有背叛的一天。|r",
    effectart = "war3mapImported\\BTNEwl_Filene_01"
  },
  {
    name = "海豹",
    bloodlevel = 1,
    bloodcoc = 5,
    dragoncoc = 0,
    weight = 5,
    key = {"唯一"},
    bloodkey = {"兽"},
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
      apply_blood_base_effect(u, var)
      u:chat("在下" .. u:getplayername() .. ",八十万海豹教头，请多指教")
      u:setdata("血统判定-海豹")
      local z = u:getdata("传奇数量")
      u:changedata("幸运", 1 * z)
      u:changedata("幸运系数", 0.05)
      local cs = 0
      local z2 = z
      ac.loop(3000, function()
        z = u:getdata("传奇数量")
        if z2 ~= z then
          u:changedata("幸运", -1 * z2)
          u:changedata("幸运", 1 * z)
          z2 = z
        end
        if u:isalive() then
          cs = cs + 3
          if 180 <= cs then
            local g = CreateGroupLua()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:groupadd(g)
            end)
            u:groupremove(g)
            if Group_Counts(g) > 0 then
              local mb = Group_Randomunit(g)
              u:chat(mb:getplayername() .. "，我豹子头零充与你自幼相交，今日倒来害我，怎不干你事！且吃我一晒。")
            end
            cs = 0
            u:changedata("幸运", 1)
            u:sendmessage("|cFF999999幸运提升|r")
          end
        end
      end)
      local yx = {}
      yx[1] = SealWhat1
      yx[2] = SealWhat2
      PlayGlobalSound(yx[GetRandomInt(1, 2)])
    end,
    effectname = "|cFF999999海豹血统|r",
    effecttext = "|cFF999999氪命三郎|r\n|cFFCCCCCC药水失败时,提升下一次药水10%成功率,成功时清空(可叠加)|r\n|cFF999999豹子头零充|r\n|cFFCCCCCC每存活180秒提升1点幸运\n提升0.05幸运系数\n提升[传奇数量*1]幸运\n提升[唯一变异数量*0.1%]药水成功率|r\n|cFF999999欧吃矛|r\n|cFFCCCCCC会被友军的近战武器伤害(0.1%),被友军杀死时该友军永久提升1点幸运与3点全属性(独立冷却300秒)|r",
    effectart = "ReplaceableTextures\\CommandButtons\\BTNSeal.blp"
  },
  {
    name = "妖魔之子",
    bloodlevel = 1,
    bloodcoc = 100,
    dragoncoc = 0,
    weight = 25,
    key = {"唯一"},
    bloodkey = {"妖"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("血统浓度") > 0 then
        b = false
      end
      if u:hasdata("变异判定-雪怨") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFCC0000此|r|cFFCF1111生|r|cFFD32222何|r|cFFD63333用|r|cFFDA4444声|r|cFFDD5555声|r|cFFE06666叹|r|cFFE47777，|r|cFFE78888道|r|cFFEB9999不|r|cFFEEAAAA尽|r|cFFF1BBBB流|r|cFFF5CCCC年|r|cFFF8DDDD。|r")
      u:addrandomstats(GetRandomInt(10, 30))
    end,
    effectname = "|cFF3366FF妖|r|cFF477AFF魔|r|cFF5C8FFF之|r|cFF70A3FF子|r",
    effecttext = "|cFF3366FF怪谭传|r\n|cFF70A3FF获取时随机分配10点属性\n每次队友死亡时提升自身10生命上限与1点属性\n每次BOSS死亡时提升自身2.5%伤害加成修正\n每次升级时随机获得额外1点属性|r\n|cFF3366FF诅咒之血|r\n|cFF70A3FF使用魔封或者妖壶时提升0.6%随机伤害修正或1点属性\n回忆药水成功率减半\n降低15%抗药性惩罚\n免疫大部分魔封与妖咒的负面效果\n每次获得魔封与妖咒使你提升1%伤害加成修正与10点属性|r\n|cFF3366FF魔妖物语|r\n|cFF70A3FF为妖族所眷顾\n可能获得妖族传承|r",
    effectart = "war3mapImported\\BTNEwl_Dayao_N"
  },
  {
    name = "狂战士之血",
    bloodlevel = 1,
    bloodcoc = 50,
    dragoncoc = 0,
    weight = 100,
    key = {"战士", "兽"},
    bloodkey = {"兽"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      ChangeValue(HeroMenu_HpChange_Inr, sy, 10)
      u:addhealthrefresh(function(set_value, bs)
        set_value(u, "系统-生命恢复增强", 0.7 * bs)
        set_value(DamageSystem_Shjc, sy, 0.1 * ((1 + 0.1 * u:getlevel()) * bs))
      end)
    end,
    effectname = "|cffff9c1b狂战士之血|r",
    effecttext = "|cffff9c1b狂战士之血\n兽 战士\n血统浓度[兽] 50%\n提升[10]生命恢复\n提升[70%*背水]生命恢复效果\n提升[(10%+1%*等级)*背水]伤害加成|r",
    effectart = "Blood_Kuangzhanshizhixue.tga"
  },
  {
    name = "人鱼",
    bloodlevel = 1,
    bloodcoc = 20,
    dragoncoc = 0,
    weight = 100,
    key = {"水"},
    bloodkey = {"渊海"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得人鱼血统|r")
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("睡眠") then
          info.end2 = info.end2 + 0.125
        end
      end)
      ac.loop(250, function()
        if u:isalive() then
          if u:hasdata("系统-水域中") then
            u:addskill("S02I")
          else
            u:delskill("S02I")
            u:clearbuff("B023")
          end
        end
      end)
    end,
    effectname = "|cFFFF0000人鱼|r",
    effecttext = "|cFFFF0000水\n①受到大于100伤害时免疫该次伤害并睡眠伤害来源10秒 睡眠加成效果提升12.5% 冷却20秒\n②在水中时极限移速并无视碰撞且每秒恢复0.3%生命值与0.2体力|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Renyu.blp"
  },
  {
    name = "人类",
    bloodlevel = 1,
    bloodcoc = 5,
    dragoncoc = 0,
    weight = 50,
    key = {},
    bloodkey = {"人"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("血统数") > 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得人类血统|r")
      ChangeValue(Correction_Exp, sy, 0.2)
    end,
    effectname = "|cFFFF0000人类|r",
    effecttext = "|cFFFF0000①提升20%经验获取\n②降低12%抗药性增加\n③提升10%药水成功率|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Renlei.blp"
  },
  {
    name = "狼人",
    allowrepeat = true,
    bloodlevel = 1,
    bloodcoc = 25,
    dragoncoc = 0,
    weight = 100,
    key = {"兽"},
    bloodkey = {"兽"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:hasdata("血统判定-狼人") then
        if Weiyi_Feishen[4] == true then
          b = false
        end
        if u:getdata("总血统补正浓度") ~= 0 then
          local nd = u:getbloodcd("兽")
          if nd < 1 then
            b = false
          end
        end
        if GetRandom100(90) then
          b = false
        end
      end
      if u:hasdata("变异判定-白狼王") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      if u:hasdata("赫萝-狼血") then
        u:changedata("赫萝-狼血浓度", 1)
        u:changedata("兽血统补正浓度", 10)
        u:changedata("总血统补正浓度", 10)
        u:changedata("血统浓度", 10)
        u:sendmessage("|cFFFF6633狼血的力量被激发了|r")
        return
      end
      if u:hasdata("血统判定-狼人") and Weiyi_Feishen[4] == false then
        Weiyi_Feishen[4] = true
        SendMsgAll("|cFF949596月落之时 苍白为之殇|r")
        u:changedata("兽血统补正浓度", 100)
        u:changedata("总血统补正浓度", 100)
        u:changedata("血统浓度", 100)
        u:deldata("血统判定-狼人")
        u:setdata("变异判定-白狼王")
        ac.wait(1, function()
          u:uivar_remove("狼人", "血统栏")
        end)
        
        local function trg(args)
          if args.chat == "狼化" and u:isalive() then
            u:heshin("白狼王")
          end
        end
        
        u:addtrgevent("玩家-聊天", function(args)
          trg(args)
        end)
        if not u:hasdata("狼人-技能触发判定") then
          u:setdata("狼人-技能触发判定")
          
          local function skill(args)
            if args.skill == S2ID("A0QE") then
              local angle = u:getface()
              u:buffset(u.handle, 0.3, "暂停")
              u:buffset(u.handle, 0.15, "绝对闪避")
              ac.wait(1, function()
                u:animeact("attack slam")
                u:animespeed(2)
              end)
              unitjump({
                unit = u.handle,
                time = 0.4,
                distance = 1000,
                height = 300,
                angle = angle,
                isfly = true,
                loops = {
                  {
                    looptime = 0.02,
                    func = function(dx, dy)
                      for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
                        xq = getunit(xq)
                        unitmove({
                          unit = xq.handle,
                          time = 0.2,
                          distance = 100,
                          angle = AngleBetweenUnits(u.handle, xq.handle)
                        })
                        DamageUnit({
                          bj = "狼人附伤",
                          unit = xq.handle,
                          source = u.handle,
                          damage = 4000,
                          level = 1,
                          type = "物理",
                          isvest = false,
                          isattack = true,
                          isnoarmor = false,
                          element = "无"
                        })
                        xq:buffset(u.handle, 1.5, "眩晕")
                        xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                      end
                    end
                  }
                },
                endfunc = function()
                  u:animespeed(1)
                end
              })
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
        u:addstexiao("白狼王", "直接伤害特效", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not u:hasdata("白狼王" .. "-特效冷却") then
            u:settimedata("白狼王" .. "-特效冷却", 0.5)
            local txsh = 0.3 * info.yssh
            DamageUnit({
              bj = "白狼王附伤",
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
            if u:getluckrandom(25) then
              tg:buffset(u.handle, 0.1, "眩晕")
            end
          end
        end)
        u:uivar_add({
          keyname = "白狼王",
          keytype = "血统栏",
          text = "|cFF949596白狼王|r\n|cFF88006D兽\n撕裂|r\n|cFF949596直接伤害时附带[30%原始伤害]伤害同时25%眩晕目标0.1秒,触发冷却0.5秒|r\n|cFF88006D群体狩猎|r\n|cFF949596狼群杀敌时,提升狼群内所有玩家0.01%伤害加成\n提升狼群与自身[狼群数量*1.5%]伤害加成与[狼群数量*5%]论外减伤|r\n|cFF88006D狼王|r\n|cFF949596输入“狼化”变身白狼王同时使时间固定至午夜并刷新狼群的狼化冷却 持续45秒 冷却600秒|r\n|cFF88006D月夜|r\n|cFF949596夜晚提升13%移速与1.3%伤害加成\n狼群与自身受到致死伤害时抵挡该次伤害并无敌3秒(独立冷却)\n自身狼化时刷新冷却|r",
          icon = "war3mapImported\\BTNEwl_Bailangwang.blp"
        })
        ac.wait(1000, function()
          u:delskill("S02H")
          ac.loop(500, function()
            if u:isalive() then
              if IsTimeNight() then
                if not u:ishasskill("S02H") then
                  u:addskill("S02H")
                  if u:hasdata("遗物-百兽王化") then
                    ChangeValue(DamageSystem_Shjc, sy, 0.0195)
                  else
                    ChangeValue(DamageSystem_Shjc, sy, 0.013)
                  end
                end
              elseif u:ishasskill("S02H") then
                u:delskill("S02H")
                u:clearbuff("B021")
                if u:hasdata("遗物-百兽王化") then
                  ChangeValue(DamageSystem_Shjc, sy, -0.0195)
                else
                  ChangeValue(DamageSystem_Shjc, sy, -0.013)
                end
              end
            end
          end)
        end)
        local lq = 0
        ac.loop(3000, function()
          ForGroupLuaNew(Group_Wolf, function(xq)
            local sy2 = xq.ownerid
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * (-0.15 * lq))
            ChangeValue(DamageSystem_Ssjianshao, sy2, 1 - 0.05 * lq, 2)
          end)
          lq = Group_Counts(Group_Wolf)
          ForGroupLuaNew(Group_Wolf, function(xq)
            local sy2 = xq.ownerid
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * (0.15 * lq))
            ChangeValue(DamageSystem_Ssjianshao, sy2, 1 - 0.05 * lq, 1)
          end)
        end)
        return
      end
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得狼人血统|r")
      u:groupadd(Group_Wolf)
      u:setdata("血统判定-狼人")
      u:changedata("兽变异数量", 1)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("血统判定-狼人") and not u:hasdata(var.name .. "-特效冷却") then
          local jl = 20
          if u:ishasskill(SKILL_TESHUYINGXIONG) then
            jl = 40
          end
          if u:getluckrandom(jl) then
            DamageUnit({
              bj = "狼人附伤",
              unit = tg.handle,
              source = u.handle,
              damage = info.yssh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
            u:settimedata(var.name .. "-特效冷却", 0.5)
          end
        end
      end)
      if not u:hasdata("狼人-技能触发判定") then
        u:setdata("狼人-技能触发判定")
        
        local function skill(args)
          if args.skill == S2ID("A0QE") then
            local angle = u:getface()
            u:buffset(u.handle, 0.3, "暂停")
            u:buffset(u.handle, 0.15, "绝对闪避")
            ac.wait(1, function()
              u:animeact("attack slam")
              u:animespeed(2)
            end)
            unitjump({
              unit = u.handle,
              time = 0.4,
              distance = 1000,
              height = 300,
              angle = angle,
              isfly = true,
              loops = {
                {
                  looptime = 0.02,
                  func = function(dx, dy)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      unitmove({
                        unit = xq.handle,
                        time = 0.2,
                        distance = 100,
                        angle = AngleBetweenUnits(u.handle, xq.handle)
                      })
                      DamageUnit({
                        bj = "狼人附伤",
                        unit = xq.handle,
                        source = u.handle,
                        damage = 4000,
                        level = 1,
                        type = "物理",
                        isvest = false,
                        isattack = true,
                        isnoarmor = false,
                        element = "无"
                      })
                      xq:buffset(u.handle, 1.5, "眩晕")
                      xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                    end
                  end
                }
              },
              endfunc = function()
                u:animespeed(1)
              end
            })
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
      local dskill = "S02H"
      ac.loop(500, function(t)
        if not u:hasdata("血统判定-狼人") then
          t:remove()
        end
        if u:isalive() then
          if IsTimeNight() then
            if GetTimeOfDay() >= 23 or GetTimeOfDay() <= 1 then
              u:heshin("狼人")
            end
            if not u:ishasskill(dskill) then
              u:addskill(dskill)
            end
          elseif u:ishasskill(dskill) then
            u:delskill(dskill)
            u:clearbuff("B021")
          end
        end
      end)
    end,
    effectname = "|cFFFF0000狼人|r",
    effecttext = "|cFFFF0000兽\n①午夜变身持续40秒 冷却480秒\n②近战伤害40(20%)%附带[伤害值*100%]物理纯粹伤害,冷却0.5秒\n③夜晚提升13%移速|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Langren.blp"
  },
  {
    name = "僵尸",
    bloodlevel = 1,
    bloodcoc = 25,
    dragoncoc = 0,
    weight = 100,
    key = {"黑暗", "不死"},
    bloodkey = {"不死"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:hasdata("变异判定-散华礼弥") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得僵尸血统|r")
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.3)
      ac.loop(500, function(t)
        if u:isalive() then
          if IsTimeNight() then
            if u:ishasskill("S02F") then
              ChangeValue(DamageSystem_Sszengjia, sy, -0.3)
              ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.3)
              u:delskill("S02F")
              u:clearbuff("B01Y")
            end
          elseif not u:ishasskill("S02F") then
            ChangeValue(DamageSystem_Sszengjia, sy, 0.3)
            ChangeValue(HeroMenu_HpChange_MaxHp, sy, -0.3)
            u:addskill("S02F")
          end
        end
        if not u:hasdata("血统判定-僵尸") then
          if u:ishasskill("S02F") then
            ChangeValue(DamageSystem_Sszengjia, sy, -0.3)
            u:delskill("S02F")
            u:clearbuff("B01Y")
          end
          t:remove()
        end
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local sh = args.damage
        if u:hasdata("血统判定-僵尸") and 100 <= sh then
          local txsh = sh * 0.1
          args.damage = args.damage * 0.7
          local cs = 0
          ac.loop(1000, function(timer)
            cs = cs + 1
            u:losshp(u, txsh)
            u:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
            if cs == 3 then
              timer:remove()
            end
          end)
        end
      end)
    end,
    effectname = "|cFFFF0000僵尸|r",
    effecttext = "|cFFFF0000黑暗 不死\n①对大于100的伤害\n只受到70%的有效伤害 剩余30%有效伤害变为生命损耗迟滞到接下来的3秒内(不致死)\n②白天降低15%移速同时提升30%额外受伤修正\n③夜晚提升0.3%生命恢复\n④采摘紫阳花时25%额外获得一朵 食用紫阳花固定属性概率提升一倍,不会降低属性,损耗生命值降低一半|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Jiangshi2.blp"
  },
  {
    name = "精灵",
    bloodlevel = 1,
    bloodcoc = 20,
    dragoncoc = 0,
    weight = 100,
    key = {"自然"},
    bloodkey = {"妖精"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000你长出了长耳朵|r")
      u:changedata("闪避值", 40)
      u:addskill("A084")
      
      local function trg(args)
        if (args.chat == "飞行切换" or args.chat == "Hikou Kirikae") and u:isalive() then
          if u:hasdata("精灵血统-飞行") then
            u:deldata("精灵血统-飞行")
            u:delskill("A0BM")
          else
            u:setdata("精灵血统-飞行")
            u:addskill("A0BM")
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
    end,
    effectname = "|cFFFF0000精灵|r",
    effecttext = "|cFFFF0000自然\n①魔抗增加25%\n②闪避值增加40\n③输入“飞行切换”来切换飞行状态\n切换间隔5秒\n基础移速增加70|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Elf.blp"
  },
  {
    name = "龙女",
    bloodlevel = 1,
    bloodcoc = 25,
    dragoncoc = 25,
    weight = 50,
    key = {"龙"},
    bloodkey = {"龙"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFF6699CC你的身上开始长出龙鳞|r")
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.1)
      ChangeValue(HeroMenu_HpChange_Inr, sy, 5)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:getluckrandom(5 * info.txgl) then
          tg:effectadd("Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl", "origin")
          tg:buffset(u.handle, 1, "僵直")
        end
      end)
      local gd = 0
      ac.loop(3000, function()
        u:changedata("固定格挡", -1 * gd)
        gd = 25 * u:getdragonbloodpower()
        u:changedata("固定格挡", 1 * gd)
      end)
    end,
    effectname = "|cFF99FFFF龙女|r",
    effecttext = "|cFF99FFFF龙\n提升[5+0.1%]生命恢复\n提升[25*纯度浓度相关]固定格挡\n提升25%龙变异补正\n直接伤害时5%使目标僵直1秒|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Long.blp"
  },
  {
    name = "堕天使",
    bloodlevel = 1,
    bloodcoc = 25,
    dragoncoc = 0,
    weight = 50,
    key = {"光明", "黑暗"},
    bloodkey = {"神", "魔"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFF6699CC获得堕天使血统|r")
      u:changedata("黑暗变异补正", 25)
      u:adddivinity(1)
      local z = u:getstate("光明变异")
      local zz = u:getdata("黑暗变异数量")
      if 10 <= z then
        z = 10
      end
      ChangeValue(DamageSystem_Ssjianshao, sy, 1 - 0.03 * z, 1)
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.04 * zz))
      ac.loop(3000, function()
        local z2 = u:getstate("光明变异")
        local zz2 = u:getdata("黑暗变异数量")
        if 10 <= z2 then
          z2 = 10
        end
        if z ~= z2 then
          ChangeValue(DamageSystem_Ssjianshao, sy, 1 - 0.03 * z, 2)
          z = z2
          ChangeValue(DamageSystem_Ssjianshao, sy, 1 - 0.03 * z, 1)
        end
        if zz ~= zz2 then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-0.04 * zz))
          zz = zz2
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.04 * zz))
        end
      end)
    end,
    effectname = "|cFF3366CC堕天使|r",
    effecttext = "|cFF3366CC神性 1\n光明 黑暗\n提升[光明变异数量*3%]受伤减少(上限30%)\n提升[黑暗变异数量*0.4%]伤害加成\n提升25%黑暗变异补正|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Demon.blp"
  },
  {
    name = "魔族",
    bloodlevel = 2,
    bloodcoc = 35,
    dragoncoc = 0,
    weight = 50,
    key = {"黑暗"},
    bloodkey = {"魔"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:hasdata("变异判定-斯巴达之子") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      if u:hasdata("隐藏职业-斯巴达之子") then
        AdvanceGet["斯巴达之子"](u)
        return
      end
      u:become("魔族")
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得魔族血统|r")
      u:adddivinity(1)
      ChangeValue(DamageSystem_EndSh, sy, 0.011000000000000001)
    end,
    effectname = "|cFFFF0000魔族|r",
    effecttext = "|cFFFF0000神性 1\n黑暗\n提升1.1%终结伤害|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Mozu.blp"
  },
  {
    name = "深海",
    bloodlevel = 2,
    bloodcoc = 35,
    dragoncoc = 0,
    weight = 50,
    key = {"水"},
    bloodkey = {"渊海"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得深海血统|r")
      local lwsh = 0
      local lwss = 1
      ac.loop(250, function(t)
        if u:isalive() then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lwsh))
          ChangeValue(DamageSystem_Ssjianshao, sy, lwss, 2)
          if u:hasdata("系统-水域中") then
            u:addskill("S02I")
            lwsh = 0.3
            lwss = 0.7
          else
            u:delskill("S02I")
            u:clearbuff("B023")
            lwsh = 0.15
            lwsh = 0.85
          end
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lwsh))
          ChangeValue(DamageSystem_Ssjianshao, sy, lwss, 1)
        end
        if not u:hasdata("血统判定-深海") then
          u:delskill("S02I")
          u:clearbuff("B023")
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lwsh))
          ChangeValue(DamageSystem_Ssjianshao, sy, lwss, 2)
          t:remove()
        end
      end)
      ac.loop(5000, function(t)
        if u:isalive() then
          local x, y = u:getxy()
          Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x, y)
          local sc = u:createunit("h01E", x, y)
          sc:setxy(x, y)
          sc:timetoremove(20)
        end
        if not u:hasdata("血统判定-深海") then
          t:remove()
        end
      end)
    end,
    effectname = "|cFFFF0000深海|r",
    effecttext = "|cFFFF0000水\n①在水中时极限移速并无视单位碰撞\n②提升1.5%伤害加成与15%论外减伤 在水中翻倍\n③每5秒在所处位置产生水流持续20秒 视为在水中|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Shenhai.blp"
  },
  {
    name = "天使",
    bloodlevel = 2,
    bloodcoc = 35,
    dragoncoc = 0,
    weight = 50,
    key = {"光明"},
    bloodkey = {"神"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得天使族血统|r")
      ChangeValue(Correction_CureUp, sy, 0.25)
      u:getgoddessforce(1)
      u:adddivinity(1)
      u:addskill("A0PW")
      for i = 1, 6 do
        ChangeValue(DamageSystem_Ssjianshao, i, 0.9, 1)
      end
      ac.loop(1000, function()
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 1800):is_ally(u.handle):ipairs() do
            xq = getunit(xq)
            if xq:isingroup(Group_PlayHero) then
              xq:curehp(u.handle, 0, 0.25, 1)
            end
          end
        end
      end)
    end,
    effectname = "|cFFFF0000天使族|r",
    effecttext = "|cFFFF0000神性 1\n光明\n①提升25%医疗效果\n②每秒医疗1800范围内英雄0.25%最大生命值 享受自身医疗效果增强\n③全图所有英雄增加10%追加减伤同时提升2点固有恢复|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Tianshi.blp"
  },
  {
    name = "亡灵",
    bloodlevel = 2,
    bloodcoc = 35,
    dragoncoc = 0,
    weight = 50,
    key = {"黑暗"},
    bloodkey = {"灵"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:hasdata("变异判定-深海空母") or u:hasdata("变异判定-深海驱逐") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得亡灵血统|r")
      ac.loop(3000, function(t)
        if u:getdata("怨念值") >= 250 then
          if u:hasdata("血统判定-深海") and not Weiyi_New[17] then
            AdvanceGet["深海空母"](u)
          else
            AdvanceGet["深海驱逐"](u)
          end
        end
        if not u:hasdata("血统判定-亡灵") then
          t:remove()
        end
      end)
    end,
    effectname = "|cFF6699CC亡灵|r",
    effecttext = "|cFF6699CC黑暗\n固定伤害提升[怨念值*10]\n杀死单位时恢复自身1%最大生命值且20%提升1点怨念值\n杀死单位时2.5%提升1点属性\n死亡时提升10点怨念值与1点属性|r",
    effectart = "war3mapImported\\BTNXuetong_Wangling2.blp"
  },
  {
    name = "默示录病毒",
    bloodlevel = 1,
    bloodcoc = 25,
    dragoncoc = 0,
    weight = 100,
    key = {"吸血鬼"},
    bloodkey = {"吸血鬼"},
    unique = false,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      return u:isinsecvar("吸血鬼")
    end,
    effect = function(u, var)
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFF990000默示录病毒已融入你的血液|r")
      local vampire_bonus = 0
      local all_penalty = 0
      
      local function refresh_effect_enhance()
        u:changedata("效果增强-吸血鬼", -vampire_bonus)
        u:changedata("效果增强-全词条", -all_penalty)
        local vampire_count = u:getdata("吸血鬼变异数量")
        vampire_bonus = 0.02 * vampire_count
        all_penalty = -0.01 * vampire_count
        u:changedata("效果增强-吸血鬼", vampire_bonus)
        u:changedata("效果增强-全词条", all_penalty)
      end
      
      refresh_effect_enhance()
      ac.loop(3000, refresh_effect_enhance)
    end,
    effectname = "|cFF990000默示录病毒|r",
    effecttext = "|cFF990000吸血鬼\n血统浓度[吸血鬼] 25%\n提升[吸血鬼变异*2%]吸血鬼效果增强\n降低[吸血鬼变异*1%]全效果增强\n每次喝下血统药剂成功时提升0.5%吸血鬼效果增强与2%吸血鬼获取补正\n解锁对应传奇变异池|r",
    effectart = "Blood_Moshilubingdu.tga"
  },
  {
    name = "吸血鬼",
    bloodlevel = 2,
    bloodcoc = 35,
    dragoncoc = 0,
    weight = 50,
    key = {"吸血鬼"},
    bloodkey = {"吸血鬼"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I06H") and not HasData(u:getitem("I06H"), "生效过") then
        add = add + 10000
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000你十分地渴望鲜血…|r")
      if u:ishasitem("I06H") and HasData(u:getitem("I06H"), "石鬼面彩蛋") then
        DelData(u:getitem("I06H"), "石鬼面彩蛋")
        u:chat("おれは人间をやめるぞ！ジョジョ──ッ！！")
        PlayGlobalSound(Yinxiao_Shiguimian)
      end
      u:addstexiao(var.name, "伤害吸血效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if IsTimeNight() then
          info.xxz = info.xxz + 4
          info.lvxxz = info.lvxxz + 0.8
        else
          info.xxz = info.xxz + 2
          info.lvxxz = info.lvxxz + 0.4
        end
      end)
      if IsTimeNight() then
        ChangeValue(DamageSystem_Shjc, sy, 0.03)
      else
        ChangeValue(DamageSystem_Shjc, sy, 0.015)
      end
      ac.loop(500, function()
        if u:isalive() then
          if IsTimeNight() then
            if not u:ishasskill("A0PX") then
              u:addskill("A0PX")
              ChangeValue(DamageSystem_Shjc, sy, 0.015)
            end
          elseif u:ishasskill("A0PX") then
            u:delskill("A0PX")
            u:clearbuff("B02C")
            ChangeValue(DamageSystem_Shjc, sy, -0.015)
          end
        end
      end)
    end,
    effectname = "|cFFFF0000吸血鬼|r",
    effecttext = "|cFFFF0000吸血鬼\n①提升[2+等级*0.4]点伤害吸血\n②提升1.5%伤害加成\n③夜晚提升15%移速\n④夜晚①②效果翻倍|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Xixuegui.blp"
  },
  {
    name = "英雄",
    bloodlevel = 2,
    bloodcoc = 35,
    dragoncoc = 0,
    weight = 50,
    key = {"战士"},
    bloodkey = {"人"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("隐藏职业-正义伙伴") then
        add = add + 250
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000拯救世界吧 少女|r")
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.tg:isboss() then
          info.lw = info.lw + 0.4
        end
      end)
      if u:hasdata("隐藏职业-正义伙伴") then
        hideproshow(u.handle)
      end
    end,
    effectname = "|cFFFF0000英雄|r",
    effecttext = "|cFFFF0000战士\n①对BOSS提升4%伤害加成\n②对BOSS提升40%论外减免\n③提升100点固定减伤 但该固减数值不会超过伤害值的50%|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Hero.blp"
  },
  {
    name = "幽灵",
    bloodlevel = 2,
    bloodcoc = 45,
    dragoncoc = 0,
    weight = 50,
    key = {"影"},
    bloodkey = {"灵"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000获得幽灵血统|r")
      u:changedata("闪避值", 40)
      ChangeValue(HeroMenu_Sbxs, sy, 0.15)
    end,
    effectname = "|cFFFF0000幽灵|r",
    effecttext = "|cFFFF0000影\n提升50闪避值\n提升0.15闪避系数\n无视碰撞体积\n每次闪避成功时在30秒降低自身10闪避值并提升1%伤害加成(触发冷却1秒)|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Youling.blp"
  },
  {
    name = "元素",
    allowrepeat = true,
    bloodlevel = 2,
    bloodcoc = 40,
    dragoncoc = 0,
    weight = 50,
    key = {"元素", "唯一"},
    bloodkey = {"元素"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-老男人") then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = true
      if Weiyi_New[1] and not u:hasdata("血统判定-元素") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      if var.bloodkey and #var.bloodkey ~= 0 then
        for index, value in ipairs(var.bloodkey) do
          u:changedata(value .. "血统补正浓度", var.bloodcoc)
        end
        u:changedata("总血统补正浓度", var.bloodcoc)
      end
      if var.dragoncoc and var.dragoncoc ~= 0 then
        u:adddragonpower(var.dragoncoc)
      end
      if var.bloodcoc then
        u:changedata("血统浓度", var.bloodcoc)
      end
      u:changedata("魔力值", 250)
      u:changedata("元素变异数量", 1)
      if not u:hasdata("血统判定-元素") then
        Weiyi_New[1] = true
        u:addskill("A0PV")
        u:sendmessage("|cFFFF0000获得元素血统|r")
        u:setdata("血统判定-元素")
        u:setdata("元素阶级", 1)
        u:changedata("魔导变异数量", 1)
        u:changedata("唯一变异数量", 1)
        ChangeValue(Damage_ElementRes_All, sy, 10)
        local sx = 0
        local fs = 0
        ac.loop(3000, function()
          ChangeValue(Damage_Element_All, sy, -1 * sx)
          ChangeValue(Correction_Magic, sy, -1 * fs)
          sx = 0.01 * u:getdata("元素变异数量")
          fs = 0.1 * u:getdata("元素变异数量")
          ChangeValue(Damage_Element_All, sy, 1 * sx)
          ChangeValue(Correction_Magic, sy, 1 * fs)
        end)
        u:addstexiao(var.name, "直接伤害特效", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
            u:settimedata(var.name .. "-特效冷却", 1)
            local x, y = u:getxy()
            local txsh = (10000 + u:getdata("魔力值")) * u:getdata("元素阶级")
            local lx = {
              "风",
              "雷",
              "冰",
              "水",
              "火"
            }
            local sxlx = lx[GetRandomInt(1, #lx)]
            for _, xq in ac.selector():in_rangexy(x, y, 250):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "元素血统",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = sxlx
              })
            end
          end
        end)
      else
        u:sendmessage("|cFFFF0000元素阶级提升|r")
        u:changedata("元素阶级", 1)
        u:uivar_change({
          keyname = "元素",
          keytype = "血统栏",
          text = "|cFFFF0000元素 - 阶级[" .. math.floor(u:getdata("元素阶级")) .. "]|r\n|cFFFF0000元素(数量1*阶级) 魔导\n提升[250*阶级]魔力值\n提升10%全属性抗性\n提升[1%*元素变异数量]全属性伤害\n提升[10%*元素变异数量]法术修正\n直接伤害时10%附带250范围[(10000+魔力值)*阶级]随机元素属性魔力伤害,触发冷却1秒\n可以重复获取 重复获取时提升阶级|r"
        })
      end
    end,
    effectname = "|cFFFF0000元素 - 阶级[1]|r",
    effecttext = "|cFFFF0000元素(数量1*阶级) 魔导\n提升[250*阶级]魔力值\n提升10%全属性抗性\n提升[1%*元素变异数量]全属性伤害\n提升[10%*元素变异数量]法术修正\n直接伤害时10%附带250范围[(10000+魔力值)*阶级]随机元素属性魔力伤害,触发冷却1秒\n可以重复获取 重复获取时提升阶级|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_Yuansu.blp"
  },
  {
    name = "冥神",
    clickfunc = function(u, ewl)
      if u:ishasitem("I09C") then
        local wp = u:getitem("I09C")
        if GetItemCharges(wp) >= 2 then
          u:setdata("冥神-闭锁进阶标记")
          ChangeItemCount(wp, -2)
          u:uivar_change({
            keyname = "冥神",
            keytype = "血统栏",
            isclearclick = true
          })
        else
          u:sendmessage("|cFF1BE6B8所需物品数量不足|r")
        end
      else
        u:sendmessage("|cFF1BE6B8没有所需物品|r")
      end
    end,
    bloodlevel = 3,
    bloodcoc = 75,
    dragoncoc = 0,
    weight = 10,
    key = {
      "唯一",
      "龙",
      "外域",
      "影",
      "恶魔"
    },
    bloodkey = {
      "龙",
      "魔",
      "神",
      "月"
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFF3366FF就|r|cFF3361FA算|r|cFF335CF5得|r|cFF3357F0到|r|cFF3352EB了|r|cFF334DE6神|r|cFF3347E0的|r|cFF3342DB意|r|cFF333DD6志|r|cFF3338D1，|r|cFF3333CC你|r|cFF332EC7还|r|cFF3329C2是|r|cFF3324BD畏|r|cFF331FB8惧|r|cFF331AB3死|r|cFF3314AD亡|r|cFF330FA8吗|r|cFF330AA3？|r")
      u:adddivinity(1)
      local cs = 0
      local g = CreateGroupLua()
      local g2 = CreateGroupLua()
      ac.loop(1000, function()
        if u:isalive() then
          cs = cs + 1
          if cs == 59 then
            u:effectadd("ATX\\[ATxNew]Cthulhu_17.mdl", "overhead")
            u:playsound(AbominationAlternateDeath101)
          end
          if cs == 60 then
            cs = 0
            u:playsound(Sound_Mugen_10000_14)
            local x, y = u:getxy()
            Effectcreate("ATX\\[ATxNew]Cthulhu_10.mdl", x, y, 0, 10)
            for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:setdata("精英特性-失效")
              if xq:isnormal() then
                xq:groupadd(g)
              end
              if xq:iselite() then
                xq:groupadd(g2)
              end
            end
            local mb
            if 0 < Group_Counts(g2) then
              mb = Group_Randomunit(g2)
            elseif 0 < Group_Counts(g) then
              mb = Group_Randomunit(g)
            end
            if mb then
              mb:effectadd("ATX\\[ATxNew]Purple_48.mdl", "overhead")
              mb:kill(u.handle, true)
            end
            GroupClearLua(g)
            GroupClearLua(g2)
          end
        end
      end)
      ac.loop(3000, function(timer)
        if u:isalive() then
          local b = false
          if u:getdata("龙变异数量") > 3 and not u:hasdata("冥神-龙承") then
            b = true
            u:setdata("冥神-龙承")
            u:getgoddessforce(1)
            u:adddragonpower(25)
            u:sendmessage("|cFF3366FF冥|r|cFF335EF7神|r|cFF3356EF血|r|cFF334EE7统|r|cFF3347E0-|r|cFF333FD8[|r|cFF3337D0龙|r|cFF332FC8承|r|cFF3327C0]|r|cFF331FB8已|r|cFF3318B1解|r|cFF3310A9锁|r")
            u:changedata("固定伤害", 300.0)
            u:adddivinity(1)
            local lw = 0
            ac.loop(3000, function()
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
              lw = 0.15 * u:getdata("龙变异数量")
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
            end)
          end
          if u:hasdata("冥神-闭锁进阶标记") and not u:hasdata("冥神-闭锁") then
            b = true
            u:setdata("冥神-闭锁")
            u:deldata("冥神-闭锁进阶标记")
            u:getgoddessforce(1)
            u:adddivinity(1)
            u:adddragonpower(25)
            u:sendmessage("|cFF3366FF冥|r|cFF335EF7神|r|cFF3356EF血|r|cFF334EE7统|r|cFF3347E0-|r|cFF333FD8[|r|cFF3337D0闭|r|cFF332FC8锁|r|cFF3327C0]|r|cFF331FB8已|r|cFF3318B1解|r|cFF3310A9锁|r")
            ac.loop(10000, function()
              if u:isalive() then
                u:effectadd("ATX\\[ATxNew]Cthulhu_03.mdl", "origin", 3)
                u:buffset(u.handle, 3, "无实体")
              end
            end)
          end
          if u:hasdata("冥神-现冥进阶标记") and not u:hasdata("冥神-现冥") then
            b = true
            u:setdata("冥神-现冥")
            u:deldata("冥神-现冥进阶标记")
            u:getgoddessforce(1)
            u:adddivinity(1)
            u:adddragonpower(25)
            u:sendmessage("|cFF3366FF冥|r|cFF335EF7神|r|cFF3356EF血|r|cFF334EE7统|r|cFF3347E0-|r|cFF333FD8[|r|cFF3337D0现|r|cFF332FC8冥|r|cFF3327C0]|r|cFF331FB8已|r|cFF3318B1解|r|cFF3310A9锁|r")
            u:addstexiao(var.name, "直接伤害变更", function(args)
              local tg = args.tg
              tg:banrelive()
            end)
          end
          if b then
            local sxz = 1
            if u:hasdata("冥神-龙承") then
              sxz = sxz + 1
            end
            if u:hasdata("冥神-现冥") then
              sxz = sxz + 1
            end
            if u:hasdata("冥神-闭锁") then
              sxz = sxz + 1
            end
            local str = {}
            str[1] = "|cFF3366FF神性 " .. math.floor(sxz) .. "|n龙 外域 影|n神之化身|r|n"
            str[2] = "|cFF3329C2每隔60秒使自身周围1800范围内单位精英特性永久失效并随机超即死一个非BOSS单位,优先精英"
            str[3] = "死亡240秒后复活|r|n"
            local zs = 3
            if u:hasdata("冥神-龙承") then
              zs = zs + 1
              str[zs] = "|cFF3366FF龙承|r|n"
              zs = zs + 1
              str[zs] = "|cFF3329C2提升[300*纯度浓度相关]固定伤害|n"
              zs = zs + 1
              str[zs] = "提升[1.5%*龙变异数量*纯度浓度相关]伤害加成|r|n"
            else
              zs = zs + 1
              str[zs] = "|cFF3366FF龙承 - [龙变异数量＞3时解锁]|r|n"
              zs = zs + 1
              str[zs] = "|cFF3329C2[待解锁]|r|n"
            end
            if u:hasdata("冥神-闭锁") then
              zs = zs + 1
              str[zs] = "|cFF3366FF闭锁|r|n"
              zs = zs + 1
              str[zs] = "|cFF3329C2每隔10秒自身获得3秒无实体|n"
              zs = zs + 1
              str[zs] = "受到致死伤害时抵挡该次伤害并在15秒内处于无实体，触发冷却500秒|r|n"
            else
              zs = zs + 1
              str[zs] = "|cFF3366FF闭锁 - [点击来消耗2个暗影之核解锁]|r|n"
              zs = zs + 1
              str[zs] = "|cFF3329C2[待解锁]|r|n"
            end
            if u:hasdata("冥神-现冥") then
              zs = zs + 1
              str[zs] = "|cFF3366FF现冥|r|n"
              zs = zs + 1
              str[zs] = "|cFF3329C2直接伤害时使目标所有重生效果失效|n"
              zs = zs + 1
              str[zs] = "游戏失败时，如果自身血量上限大于1000则降低[10%+1000]生命上限使自身复活，触发冷却1200秒|r|n"
            else
              zs = zs + 1
              str[zs] = "|cFF3366FF现冥 - [获取后累计杀敌150时解锁]|r|n"
              zs = zs + 1
              str[zs] = "|cFF3329C2[待解锁]|r|n"
            end
            local s = ""
            for i = 1, zs do
              s = s .. str[i]
            end
            u:uivar_change({
              keyname = "冥神",
              keytype = "血统栏",
              text = "|cFF3366FF冥|r|cFF330099神|r" .. "\n" .. s
            })
          end
          if u:hasdata("冥神-现冥") and u:hasdata("冥神-龙承") and u:hasdata("冥神-闭锁") then
            u:getgoddessforce(0, true)
            timer:remove()
          end
        end
      end)
      if u:hasdata("变异判定-西行寺幽幽子") then
        u:setdata("冥神-现冥进阶标记")
      end
    end,
    effectname = "|cFF3366FF冥|r|cFF330099神|r",
    effecttext = "|cFF3366FF神性 0\n龙 外域 影\n神之化身|r\n|cFF3329C2每隔60秒使自身周围1200范围内单位精英特性永久失效并随机超即死一个非BOSS单位,优先精英\n死亡240秒后复活|r\n|cFF3366FF龙承 - [龙变异数量＞3时解锁]|r\n|cFF3329C2[待解锁]|r\n|cFF3366FF闭锁 - [点击来消耗2个暗影之核解锁]|r\n|cFF3329C2[待解锁]|r\n|cFF3366FF现冥 - [获取后累计杀敌150时解锁]|r\n|cFF3329C2[待解锁]|r",
    effectart = "war3mapImported\\PASBTNEwl_Xuetong_3_Mingshen.blp"
  },
  {
    name = "黎明之堕天使",
    bloodlevel = 3,
    bloodcoc = 50,
    dragoncoc = 0,
    weight = 25,
    key = {
      "光明",
      "战士",
      "黑暗"
    },
    bloodkey = {"神", "魔"},
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFFFF99无|r|cFFF0ED99论|r|cFFE2DB99我|r|cFFD3C899们|r|cFFC5B699去|r|cFFB6A499哪|r|cFFA89299，|r|cFF997F99都|r|cFF8A6D99在|r|cFF7C5B99地|r|cFF6D4999狱|r|cFF5F3799中|r|cFF502499。|r")
      u:adddivinity(2)
      ac.loop(720000, function()
        u:adddivinity(1)
      end)
      u:addskill("A03Q")
      u:banskill("A03Q")
      u:setskillforever("A02P")
      local g = CreateGroupLua()
      
      local function skill(args)
        if args.skill == S2ID("A02P") then
          local unit = args.unit
          local u = getunit(unit)
          if not u:hasdata("神之惩戒冷却") then
            u:settimedata("神之惩戒冷却", 480)
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            Effectcreate("war3mapImported\\[TX] (514).mdl", x, y, 3)
            Effectcreate("war3mapImported\\[ake]war3ake.com - 8938363897730084317466280.mdl", x2, y2, 3)
            for i = 1, 5 do
              Effectcreate("Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl", x2, y2, 0, 4)
            end
            u:buffset(u.handle, 3, "暂停")
            u:buffset(u.handle, 4, "无敌")
            local cs = 0
            ac.loop(100, function(timer)
              cs = cs + 1
              if cs <= 10 then
                for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:buffset(u.handle, 0.5, "暂停")
                end
              else
                for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:buffset(u.handle, 0.5, "暂停")
                  if not xq:isingroup(g) then
                    xq:groupadd(g)
                    if xq:isnormal() then
                      xq:kill(u.handle, true)
                    elseif xq:iselite() then
                      local txsh = xq:getmaxhp() * 0.1
                      DamageUnit({
                        bj = "神之惩戒",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 5,
                        type = "魔力",
                        isvest = false,
                        isattack = false,
                        isnoarmor = false,
                        element = "光"
                      })
                    else
                      LossHpUnit({
                        u = u,
                        tg = xq,
                        damage = 0,
                        perhp = 10,
                        maxhp = 0,
                        bj = "[生命损耗]神之惩戒"
                      })
                    end
                  end
                end
              end
              if cs == 30 then
                GroupClearLua(g)
                timer:remove()
              end
            end)
          else
            u:sendmessage("冷却中")
            u:setskillcd("A02P", 0)
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
      AddAllSTexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("天空坠落加成") then
          info.wsmy = true
        end
      end)
      
      local function chat(args)
        if args.chat == "天空坠落" or args.chat == "Tenku Tsuiraku" then
          local u = getunit(args.unit)
          if u:isalive() and not u:hasdata("天空坠落冷却") then
            u:settimedata("天空坠落冷却", 720)
            ac.wait(720000, function()
              u:sendmessage("天空坠落冷却完毕")
            end)
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:settimedata("天空坠落加成", 60)
              xq:effectadd("war3mapImported\\[ake]war3ake.com - 7144121232703075945564515.mdl", "origin", 60)
            end)
            UseTimeOfDayBJ(false)
            SetTimeOfDay(12.0)
            PlayGlobalSound(StarfallCaster1)
            do
              local cs = 0
              local tt = 0.04
              local dt = 12
              ac.loop(100, function(timer)
                cs = cs + 1
                dt = dt + tt
                SetTimeOfDay(dt)
                if cs == 600 then
                  UseTimeOfDayBJ(true)
                  timer:remove()
                end
              end)
            end
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chat(args)
      end)
    end,
    effectname = "|cFFFFFF99黎明|r|cFFCCBF99之堕|r|cFF998099天使|r",
    effecttext = "|cFF998099神性 2\n光明 黑暗 战士\n神之子|r\n|cFFFFFF99自身神性不足神迹时视为神迹\n每720秒提升1点神性|r\n|cFF998099混沌|r\n|cFFFFFF99自身血统判定时光明补正与黑暗补正变为互相补正\n血统补正享受黑暗补正与光明补正|r\n|cFF998099天空坠落|r\n|cFFFFFF99输入“天空坠落”发动\n使时间变为12点同时快速逝去直至夜晚12点,持续60秒\n期间破坏全图所有敌军伤害抗性与伤害减伤\n绝对冷却720秒|r\n|cFF998099神判|r\n|cFFFFFF99允许使用[神之惩戒]|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_3_Duotianshi.blp"
  },
  {
    name = "恶魔",
    bloodlevel = 3,
    bloodcoc = 50,
    dragoncoc = 0,
    weight = 25,
    key = {
      "恶魔",
      "黑暗",
      "魔导"
    },
    bloodkey = {"魔"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:hasdata("变异判定-斯巴达之子") then
        b = false
      end
      if u:hasdata("变异判定-帝国的公主") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      if u:hasdata("隐藏职业-斯巴达之子") then
        AdvanceGet["斯巴达之子"](u)
        return
      end
      u:become("魔族")
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000恶魔之血在你体内流淌…|r")
      u:setdata("血统判定-恶魔")
      u:adddivinity(2)
      if not u:hasdata("恶魔变身-触发相关") then
        u:setdata("恶魔变身-触发相关")
        u:addtrgevent("单位-指定点目标指令", function(args)
          if args.orderid == String2OrderIdBJ("smart") and u:hasdata("恶魔变身-传送移动") and not u:hasdata("恶魔变身-传送移动冷却") then
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            local angle = AngleXY(x, y, x2, y2)
            local dis = DistanceXY(x, y, x2, y2)
            if not IsXYinAnyPlayRect(x2, y2) then
              return
            end
            u:settimedata("恶魔变身-传送移动冷却", 0.7)
            u:setcamera(x2, y2, 0.3)
            Effectcreate("war3mapImported\\Demon (1).mdl", x, y)
            Effectcreate("war3mapImported\\Demon (3).mdl", x, y)
            u:playsound(Sound_Demon_01)
            u:buffset(u.handle, 0.6, "暂停")
            u:buffset(u.handle, 0.6, "绝对闪避")
            u:buffset(u.handle, 0.6, "无敌")
            ac.wait(1, function()
              u:animeact("morph alternate")
            end)
            ac.wait(600, function()
              Effectcreate("war3mapImported\\Demon (1).mdl", x2, y2)
              Effectcreate("war3mapImported\\Demon (3).mdl", x2, y2)
              u:setxy(x2, y2)
            end)
            ac.wait(650, function()
              u:setface(angle)
              u:playsound(Sound_Demon_01)
            end)
          end
        end)
        
        local function skill(args)
          if args.skill == S2ID("A1RK") then
            local u = getunit(args.unit)
            if not u:hasdata("恶魔变身-传送移动") then
              u:setdata("恶魔变身-传送移动")
              u:sendmessage("|cFF990000传送移动开启|r")
            else
              u:deldata("恶魔变身-传送移动")
              u:sendmessage("|cFF990000传送移动关闭|r")
            end
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
      
      local function trg(args)
        if (args.chat == "深渊召唤" or args.chat == "Shinen Shoukan") and not u:hasdata("变异判定-帝国的公主") and u:isalive() then
          u:heshin("恶魔")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
      local gwslz = 0
      local emx = 0
      ac.loop(3000, function()
        u:changedata("魔力值", -4 * gwslz)
        u:changedata("固定伤害", 0.1 * (-4 * gwslz))
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * emx))
        gwslz = Group_Counts(Group_Monster)
        emx = 0.001 * Huanjing_Moli
        u:changedata("魔力值", 4 * gwslz)
        u:changedata("固定伤害", 0.1 * (4 * gwslz))
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * emx))
      end)
    end,
    effectname = "|cFFCC0000恶|r|cFFCC5555魔|r",
    effecttext = "|cFFCC0000神性 2\n黑暗 魔导 恶魔\n恶魔之血|r\n|cFFCC5555提升[魔力浓度*1%]伤害加成修正|r\n|cFFCC0000弱肉强食|r\n|cFFCC5555杀死单位时提升1.5点生命上限与1点魔力值同时5%提升1点属性|r\n|cFFCC0000地狱之门|r\n|cFFCC5555提升[存活怪物数量*4]魔力值\n提升[存活怪物数量*0.4]固定伤害|r\n|cFFCC0000恶魔形态|r\n|cFFCC5555输入\"深渊召唤\"来变身为大恶魔,法术修正与魔力值翻倍,持续45秒,冷却360秒|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_3_Emo.blp"
  },
  {
    name = "帝国的公主",
    bloodlevel = 1,
    bloodcoc = 100,
    dragoncoc = 0,
    weight = 5,
    key = {
      "恶魔",
      "唯一",
      "兽",
      "吸血鬼",
      "魔导"
    },
    bloodkey = {
      "魔",
      "吸血鬼",
      "兽"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local gl = 0
      if u:getdata("血统数") <= 3 and 0 < u:getdata("吸血鬼变异数量") and 0 < u:getdata("恶魔变异数量") and 0 < u:getdata("兽变异数量") and 0 < u:getdata("魔导变异数量") then
        gl = 1
      end
      if u:getdata("血统数") <= 1 and u:hasdata("血统判定-恶魔") then
        gl = 50
      end
      if u:hasdata("判定-克萝蒂亚") then
        gl = gl + 50
      end
      if GetRandom100(gl) then
        b = true
      end
      if u:hasdata("变异判定-斯巴达之子") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:become("魔族")
      apply_blood_base_effect(u, var, true)
      u:sendmessage("|cFFFF6699『|r|cFFFB5E8C你|r|cFFF65580真|r|cFFF24C73是|r|cFFEE4466个|r|cFFEA3C59奇|r|cFFE6334C怪|r|cFFE12A40的|r|cFFDD2233人|r|cFFD91A26啊|r|cFFD4111A』|r")
      u:addskill("A1OK")
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      u:addskill("S09J")
      u:setdata("帝国的公主-消除仇恨概率", 10)
      local hp = 0
      local cs = 0
      local xxzq = 0
      ac.loop(2000, function()
        if u:isalive() then
          cs = cs + 1
        end
        ChangeValue(DamageSystem_Xxzq, sy, -xxzq)
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -hp)
        if IsTimeDay() then
          xxzq = 0.15
          hp = 0.4
        else
          xxzq = 0.3
          hp = 0.8
        end
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, hp)
        ChangeValue(DamageSystem_Xxzq, sy, xxzq)
        if cs == 5 then
          if GetRandom100(u:getdata("帝国的公主-消除仇恨概率")) then
            u:setdata("帝国的公主-消除仇恨概率", 10)
            local x, y = u:getxy()
            for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:buffset(u.handle, 5, "混乱")
            end
          else
            u:changedata("帝国的公主-消除仇恨概率", 10)
          end
        end
      end)
      if not u:hasdata("血统判定-恶魔") then
        u:setdata("血统判定-恶魔")
        u:adddivinity(2)
        local gwslz = 0
        local emx = 0
        ac.loop(1000, function()
          u:changedata("魔力值", -4 * gwslz)
          u:changedata("固定伤害", 0.1 * (-4 * gwslz))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -emx)
          gwslz = Group_Counts(Group_Monster)
          emx = 0.001 * Huanjing_Moli
          u:changedata("魔力值", 4 * gwslz)
          u:changedata("固定伤害", 0.1 * (4 * gwslz))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * emx)
        end)
      else
        u:uivar_remove("恶魔", "血统栏")
      end
      local dskill = S2ID("A1NV")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local tg = getunit(args.target)
          local ewl = getunit(args.unit)
          local dis = DistanceBetweenUnits(u.handle, tg.handle)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if 1000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1超过1000码|r")
          end
          if tg.handle == u.handle then
            b = false
            u:sendmessage("|cFF7DBEF1不能以自己为目标|r")
          end
          if b then
            local x1, y1 = tg:getxy()
            tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", "origin")
            Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x1, y1, 0, 3)
            if tg:isingroup(Group_PlayHero) then
              SendMsgAll(tg:getplayername() .. "|cFFFF6699被砸矮了3厘米|r")
              tg:changemaxhp(-0.1 * tg:getmaxhp())
              tg:setsize(0.7)
              local sy2 = tg.ownerid
              ChangeValue(DamageSystem_Shjc, sy2, -0.01)
              tg:addstr(-0.1 * tg:getoriginstr())
            else
              SendMsgAll(tg:getname() .. "|cFFFF6699被砸矮了3厘米|r")
              if tg:isnormal() then
                tg:kill(u.handle)
              else
                tg:changemaxhp(-0.1 * tg:getmaxhp())
                local typeid = GetUnitTypeId(tg.handle)
                u:setsize(0.85 * tonumber(slk.unit[ID2S(typeid)].modelScale))
              end
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      
      local function chattrg(args)
        if args.chat == "契约开始" then
          u:setdata("帝国的公主-恶魔契约")
          u:sendmessage("|cFFFF6699契约开始|r")
        end
        if args.chat == "契约终止" then
          u:deldata("帝国的公主-恶魔契约")
          u:sendmessage("|cFFFF6699契约终止|r")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
    end,
    effectname = "|cFFCCCCCC帝国的|r|cFFFF3333公主|r",
    effecttext = "|cFFCCCCCC吸血鬼 恶魔 兽 魔导\n因为是兔子，所以萌即是正义|r\n|cFFFF3333无视地形\n提升10%移速与25额外移速\n杀敌时在20(10)秒内提升10额外移速,分立计时\n每隔10秒,10%混乱自身周围600范围单位5秒,如果为未触发则概率增加|r\n|cFFCCCCCC吸血鬼萝莉|r\n|cFFFF3333夜晚时(白昼减半)\n提升30%伤害吸血\n提升0.8%生命恢复\n受到致死伤害时抵挡,冷却240(360)秒|r\n|cFFCCCCCC恶魔|r\n|cFFFF3333继承恶魔血统大部分效果\n杀敌时提升1~3点魔力值\n输入“契约开始”开启,“契约终止”关闭:\n杀敌时5%消耗200生命上限与100魔力值提升属性|r",
    effectart = "war3mapImported\\BTNEwl_Kldy_01"
  },
  {
    name = "白龙",
    bloodlevel = 3,
    bloodcoc = 75,
    dragoncoc = 75,
    weight = 25,
    key = {"龙"},
    bloodkey = {"龙"},
    unique = false,
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
      apply_blood_base_effect(u, var)
      u:sendmessage("|cFFFF0000龙血在你体内流淌…|r")
      u:changedata("龙族补正数量", 1)
      
      local function trg(args)
        if (args.chat == "龙化" or args.chat == "Ryuka") and u:isalive() then
          u:heshin("龙化")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and info.distance >= 600 then
          u:settimedata(var.name .. "-特效冷却", 3)
          local txsh = 30 * u:getdata("龙变异数量") * u:getstr() * u:getdragonbloodpower()
          local x, y = tg:getxy()
          Effectcreate("war3mapImported\\[TX] (327).mdl", x, y)
          for _, xq in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "龙族血统",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "火",
              extradata = {"龙属性"}
            })
          end
        end
      end)
      u:addstexiao(var.name, "伤害判定后特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效2冷却") and info.distance <= 350 then
          u:settimedata(var.name .. "-特效2冷却", 1)
          local txsh = 50 * u:getdata("龙变异数量") * u:getstr() * u:getdragonbloodpower()
          tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", "origin")
          DamageUnit({
            bj = "龙族血统",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {"龙属性"}
          })
        end
      end)
      u:addstexiao(var.name, "被施加Buff时效果-眩晕", function(args)
        if not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:addskill("A06D")
      u:addskill("S01B")
      ac.wait(100, function()
        local str = 100 + 12 * u:getdata("龙变异数量") * u:getdragonbloodpower()
        u:addstr(str)
      end)
      local cs = 0
      local hf = 0
      local hj = 0
      local ewys = 0
      ac.loop(1000, function()
        local lxxg = u:getdragonbloodpower()
        local x, y = u:getxy()
        local jl = 0
        for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          if xq:isnormal() then
            jl = 25
          else
            jl = 5
          end
          if u:getluckrandom(jl) then
            xq:buffset(u.handle, 1, "僵直")
          end
        end
        u:changearmor(-1 * hj)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ewys)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1 * hf)
        hj = u:getlevel() * u:getdata("龙变异数量") * 0.5 * lxxg
        hf = Race_Dragon_Nd[sy]
        ewys = 25 + 10 * u:getdata("龙变异数量")
        u:changearmor(1 * hj)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ewys)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1 * hf)
        cs = cs + 1
        if cs == 180 then
          cs = 0
          u:addstr(u:getdata("龙变异数量") * lxxg)
        end
      end)
    end,
    effectname = "|cFF3399CC白|r|cFF77BBDD龙|r",
    effecttext = "|cFF3399CC龙\n龙血|r\n|cFF77BBDD提升[1%*浓度相关]永恒恢复\n提升[等级*0.5*龙变异数量*纯度浓度相关]点护甲\n获取时提升[100+12*龙变异数量*纯度浓度相关]点力量\n每180秒提升[龙变异数量*纯度浓度相关]点力量|r\n|cFF3399CC龙威|r\n|cFF77BBDD降低1200范围敌军25%移速与攻速\n每秒25%(5%)僵直其1秒|r\n|cFF3399CC龙力|r\n|cFF77BBDD提升20%移动速度\n提升[25+10*龙变异数量]额外移速\n对350范围内敌人造成伤害时附带一次[力量*50*龙变异数量*纯度浓度相关]龙属性物理纯粹伤害,触发冷却1秒\n直接伤害600范围外敌人时造成一次300范围[力量*30*龙变异数量*纯度浓度相关]龙属性魔力伤害,触发冷却3秒|r\n|cFF3399CC真龙形态|r\n|cFF77BBDD输入“龙化”化身龙,持续30秒,冷却480秒|r",
    effectart = "war3mapImported\\BTNEwl_Xuetong_3_Long.blp"
  }
}
