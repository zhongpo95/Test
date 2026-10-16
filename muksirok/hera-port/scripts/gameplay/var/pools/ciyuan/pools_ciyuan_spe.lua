-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
Vars_Ciyuan_Spe = {
  {
    name = "见习死神",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() and Hero_Shenhua_Now[sy] == 0 and u:isinsecvar("外域") then
        AdvanceGet["小死神"](u)
      end
    end,
    lv = 2,
    weight = 5,
    key = {
      "唯一",
      "外域",
      "死神",
      "灵魂"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("变异判定-黑猫") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(Correction_Exp, sy, 0.05)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:isnormal() then
          u:changedata("小死神-灵魂计数", 1)
        elseif tg:iselite() then
          u:changedata("小死神-灵魂计数", 10)
        else
          u:changedata("小死神-灵魂计数", 100)
        end
        if u:hasdata("物品-罪之镰") then
          u:changedata("小死神-灵魂计数", 0.5)
        end
      end)
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        jc = 0
        if u:hasdata("变异判定-小死神") then
          jc = 0.001 * u:getdata("小死神-灵魂计数")
        end
        if u:hasdata("变异判定-特莉波卡") then
          jc = jc * 2
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:isnormal() then
          if u:hasdata("变异判定-特莉波卡") and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(5) then
            u:settimedata(var.name .. "-特效冷却", 5)
            tg:kill(u.handle)
          end
        elseif not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 0.2)
          local sh = 175 * u:getdata("小死神-灵魂计数")
          if u:hasdata("变异判定-小死神") then
            sh = sh * u:getstate("灵魂")
          end
          if u:hasdata("变异判定-特莉波卡") then
            sh = sh * u:getstate("外域")
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = sh,
            bj = "特莉波卡(灵魂收割损耗)"
          })
        end
      end)
    end,
    effectname = "|cFFCC0000见|r|cFFC21F1F习|r|cFFB83D3D死|r|cFFAD5C5C神|r",
    effecttext = "|cFFCC0000[奇迹] 外域 死神 灵魂 唯一|r\n|cFFAD5C5C提升10%经验加成\n提升2.5%伤害加成|r\n|cFFCC0000【灵魂收割】|r\n|cFFAD5C5C杀敌时提升1点灵魂计数(精英10点,BOSS100点)\n直接伤害非普通单位时损耗目标[200*灵魂计数]生命值,冷却0.2秒|r\n|cFFCC0000【死神契约】|r\n|cFFAD5C5C - 没有神化力量\n - 次变异为外域\n满足条件时,点击签订契约并进阶[见习死神]|r",
    effectart = "Mwx_Waiyu_2_06_7"
  },
  {
    name = "黑皇帝",
    lv = 2,
    weight = 100,
    key = {
      "唯一",
      "外域",
      "根源",
      "影"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if WAIYU_Count >= 45 or u:hasdata("系统-特殊获取中") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      if u:hasdata("变异判定-愚者初始") then
        PlayGlobalSound(Sound_Yuzhe_Cq_Hhd_01)
        local data = {
          {
            time = 0.9,
            text = "|cFFCCCCCC来|r|cFFBFBFC6到|r|cFFB2B2BF这|r|cFFA6A6B9个|r|cFF9999B2时|r|cFF8C8CAC代|r|cFF8080A6后|r"
          },
          {
            time = 2.4,
            text = "|cFFCCCCCC我|r|cFFC6C6C9最|r|cFFC0C0C6开|r|cFFBABAC3始|r"
          },
          {
            time = 3.6,
            text = "|cFFA8A8BA—|r|cFFA2A2B7—|r|cFF9C9CB4将|r|cFF9696B1这|r|cFF9090AE一|r|cFF8A8AAB切|r|cFF8484A8当|r|cFF7E7EA5成|r|cFF7878A2游|r|cFF72729F戏|r"
          },
          {
            time = 5.5,
            text = "|cFFCCCCCC玩|r|cFFBFBFC6得|r|cFFB2B2BF很|r|cFFA6A6B9爽|r|cFF9999B2很|r|cFF8C8CAC开|r|cFF8080A6心|r"
          },
          {
            time = 8.5,
            text = "|cFF999999但|r|cFF9E9994偶|r|cFFA3998F尔|r|cFFA8998A也|r|cFFAD9985会|r|cFFB29980回|r|cFFB8997A想|r|cFFBD9975「故|r|cFFC29970乡」|r"
          },
          {
            time = 10.8,
            text = "|cFF999999回|r|cFF9B9997想|r|cFF9E9994那|r|cFFA09992些|r|cFFA3998F养|r|cFFA5998D成|r|cFFA8998A了|r|cFFAA9988我|r|cFFAC9986绝|r|cFFAF9983大|r|cFFB19981部|r|cFFB4997E分|r|cFFB6997C性|r|cFFB99979格|r|cFFBB9977和|r|cFFBD9975爱|r|cFFC09972好|r|cFFC29970的|r|cFFC5996D过|r|cFFC7996B去|r"
          },
          {
            time = 16.2,
            text = "|cFF999999活|r|cFF9F9993得|r|cFFA4998E越|r|cFFAA9988久|r|cFFB09982.|r|cFFB5997D.|r|cFFBB9977.|r|cFFC19971.|r"
          },
          {
            time = 17.7,
            text = "|cFF999999这|r|cFF9D9995种|r|cFFA19991感|r|cFFA5998D觉|r|cFFA99989出|r|cFFAD9985现|r|cFFB19981的|r|cFFB4997E频|r|cFFB8997A率|r|cFFBC9976就|r|cFFC09972越|r|cFFC4996E高|r"
          },
          {
            time = 20.6,
            text = "|cFF999999就|r|cFF9D9995像|r|cFFA09992落|r|cFFA4998E叶|r|cFFA8998A总|r|cFFAB9987是|r|cFFAF9983要|r|cFFB29980回|r|cFFB6997C归|r|cFFBA9978树|r|cFFBD9975的|r|cFFC19971根|r|cFFC5996D部....|r"
          },
          {
            time = 24.4,
            text = "|cFF999999不|r|cFF9B9997过|r|cFF9D9995呢|r|cFFA09992，|r|cFFA29990我|r|cFFA4998E还|r|cFFA6998C至|r|cFFA99989少|r|cFFAB9987有|r|cFFAD9985女|r|cFFAF9983儿|r|cFFB19981，|r|cFFB4997E有|r|cFFB6997C妻|r|cFFB8997A子|r|cFFBA9978，|r|cFFBC9976有|r|cFFBF9973两|r|cFFC19971个|r|cFFC3996F儿|r|cFFC5996D子|r|cFFC8996A…|r"
          },
          {
            time = 30.9,
            text = "|cFF999999在|r|cFF9C9996这|r|cFFA09992个|r|cFFA3998F世|r|cFFA7998B界|r|cFFAA9988上|r|cFFAD9985还|r|cFFB19981是|r|cFFB4997E有|r|cFFB8997A许|r|cFFBB9977多|r|cFFBE9974牵|r|cFFC29970挂|r|cFFC5996D的|r"
          },
          {
            time = 34.8,
            text = "|cFF999999有|r|cFF9E9994一|r|cFFA29990定|r|cFFA7998B程|r|cFFAC9986度|r|cFFB09982上|r|cFFB5997D的|r|cFFB99979归|r|cFFBE9974属|r|cFFC3996F感|r"
          },
          {
            time = 40.1,
            text = "|cFF666666而|r|cFF80806E你|r|cFF999977呢|r|cFFB2B280…|r|cFFCCCC88…|r"
          },
          {
            time = 41.7,
            text = "|cFF666699我|r|cFF626291能|r|cFF5E5E89感|r|cFF5A5A81觉|r|cFF56567A得|r|cFF525272出|r|cFF4E4E6A你|r|cFF4B4B62的|r|cFF47475A「|r|cFF434352孤|r|cFF3F3F4B独|r|cFF3B3B43」|r"
          },
          {
            time = 44.1,
            text = "|cFF666699从|r|cFF626291骨|r|cFF5E5E89子|r|cFF5A5A81里|r|cFF56567A透|r|cFF525272出|r|cFF4E4E6A来|r|cFF4B4B62的|r|cFF47475A「|r|cFF434352孤|r|cFF3F3F4B独|r|cFF3B3B43」|r"
          },
          {
            time = 52.3,
            text = "|cFFCC9966再见吧.......|r"
          },
          {
            time = 53.4,
            text = "|cFFCC9966\"朋友\"|r"
          },
          {
            time = 56.1,
            text = "|cFFCC9966希望真的能有再见的一天|r"
          }
        }
        for index, value in ipairs(data) do
          SendDtimeMsgAll(value.time, value.text)
        end
      end
      u:changedata("外神变异数量", 1)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      local hp = 0
      ac.loop(3000, function()
        if hp < u:getallattri() then
          local change = u:getallattri() - hp
          u:changemaxhp(change)
          hp = u:getallattri()
        end
      end)
      u:addstexiao(var.name, "伤害格挡效果", function(args)
        local tg = args.tg
        if not tg:hasdata("黑皇帝-格挡生效") and not args.b and not tg:hasdata("黑皇帝-格挡生效") then
          args.b = true
          tg:setdata("黑皇帝-格挡生效")
          u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
          u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
        end
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        if tg ~= 0 and tg:isalive() and not tg:getdata(var.name .. "-已触发") then
          tg:setdata(var.name .. "-已触发", true)
          tg:changedata("怪物-伤害修正", 0.85, 1)
          tg:changedata("怪物-额外受伤", 0.08)
        end
      end)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.7, 1)
      ChangeValue(DamageSystem_EndSh, sy, 0.003)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getshenxing() >= tg:getdata("神性") then
          info.endup = info.endup + 0.1
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        if not tg:hasdata(var.name .. "-减甲") then
          local change = 10 + 0.05 * tg:getarmor()
          tg:changearmor(-change)
        end
      end)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "黑皇帝",
          keytype = "传奇栏",
          icon = "Yuzhe_Cq_02_B.tga",
          ishasphoto = true,
          size_h = 2,
          smallicon = "Yuzhe_Cq_02.tga"
        })
      end)
    end,
    effectname = "|cFFCC9966「|r|cFFC4996E黑|r|cFFBB9977皇|r|cFFB29980帝|r|cFFAA9988」|r|cFF666699罗|r|cFF6C6C99塞|r|cFF717199尔|r|cFF777799.|r|cFF7D7D99古|r|cFF828299斯|r|cFF888899塔|r|cFF8E8E99夫|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFCC9966外域 根源 影 唯一|r\n|cFFCC9966「黑皇帝」的复活\n提高[全属性*1]生命值上限\n死亡时复活,冷却888秒\n【不可名状的阴影】\n受到单位首次伤害时,免疫该次伤害并使其提升8%额外受伤,降低15%伤害\n【秩序的阴影】\n提高30%受伤减少\n提高0.3%终结伤害\n近战伤害段数+1(暗魔力)\n直接伤害时降低对方[10+5%]护甲,无法叠加\n对神性低于自身的目标提升10%伤害|r\n|cFF9999CC「故乡」\n「数据删除」|r",
    effectart = "Yuzhe_Cq_02"
  },
  {
    name = "黑夜女神",
    clickfunc = function(u, button)
      if not u:hasdata("黑夜女神-恐惧关闭") then
        u:sendmessage("|cFF999999[黑夜女神]恐惧关闭|r")
        u:setdata("黑夜女神-恐惧关闭")
      else
        u:sendmessage("|cFF999999[黑夜女神]恐惧开启|r")
        u:deldata("黑夜女神-恐惧关闭")
      end
    end,
    lv = 2,
    weight = 100,
    key = {
      "唯一",
      "外域",
      "根源",
      "光明",
      "黑暗"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if WAIYU_Count >= 45 or u:hasdata("系统-特殊获取中") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      if u:hasdata("变异判定-愚者初始") then
        PlayGlobalSound(Sound_Yuzhe_Cq_Hynv_01)
        local data = {
          {
            time = 1,
            text = "|cFF999999埋|r|cFF9D9995葬|r|cFFA19991在|r|cFFA5998D旧|r|cFFA99989日|r|cFFAD9985的|r|cFFB19981那|r|cFFB4997E个|r|cFFB8997A时|r|cFFBC9976代|r|cFFC09972…|r|cFFC4996E…|r"
          },
          {
            time = 4.1,
            text = "|cFF9999CC是|r|cFF9999C6我|r|cFF9999C1们|r|cFF9999BB共|r|cFF9999B5同|r|cFF9999B0的|r|cFF9999AA回|r|cFF9999A4忆|r"
          },
          {
            time = 7.5,
            text = "|cFFFFFFCC也|r|cFFFCF7C2是|r|cFFFAF0B8我|r|cFFF7E8AD们|r|cFFF5E0A3人|r|cFFF2D999性|r|cFFF0D18F初|r|cFFEDC985生|r|cFFEBC27A、|r|cFFE8BA70萌|r|cFFE5B266芽|r|cFFE3AB5C、|r|cFFE0A352滋|r|cFFDE9C47长|r|cFFDB943D的|r|cFFD98C33关|r|cFFD68529键|r|cFFD47D1F时|r|cFFD17514期|r"
          },
          {
            time = 14.4,
            text = "|cFF9999CC哪|r|cFF9595C8怕|r|cFF9191C4我|r|cFF8D8DC0已|r|cFF8989BC经|r|cFF8585B8拥|r|cFF8181B4有|r|cFF7E7EB1漫|r|cFF7A7AAD长|r|cFF7676A9的|r|cFF7272A5生|r|cFF6E6EA1命|r"
          },
          {
            time = 17.7,
            text = "|cFFCCCCCC它|r|cFFB2BFD9依|r|cFF99B2E6旧|r"
          },
          {
            time = 19.2,
            text = "|cFF999999是|r|cFF9F9993我|r|cFFA4998E最|r|cFFAA9988美|r|cFFB09982好|r|cFFB5997D的|r|cFFBB9977回|r|cFFC19971忆|r"
          },
          {
            time = 24.7,
            text = "|cFF9999CC你|r|cFFA099BD有|r|cFFA899AF它|r|cFFAF99A0的|r|cFFB69992烙|r|cFFBD9983印|r"
          },
          {
            time = 27.1,
            text = "|cFF9999CC所以|r"
          },
          {
            time = 28.6,
            text = "|cFF9999CC我更愿意帮助你|r"
          }
        }
        for index, value in ipairs(data) do
          SendDtimeMsgAll(value.time, value.text)
        end
        ac.wait(3000, function()
          coopjudge("故乡", u)
        end)
      end
      u:changedata("外神变异数量", 1)
      ac.loop(1000, function()
        if not u:hasdata("黑夜女神-恐惧关闭") and u:isalive() then
          local x, y = u:getxy()
          local damage = 111 * u:getallattri() + u:getlevel() * 750
          for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not xq:hasdata("黑夜女神-伤害冷却") then
              xq:settimedata("黑夜女神-伤害冷却", 15)
              xq:changetimedata("怪物-额外受伤", 0.1, 10)
              xq:buffset(u.handle, 1, "僵直")
              DamageUnit({
                bj = "黑夜女神恐惧",
                unit = xq.handle,
                source = u.handle,
                damage = damage,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "心灵",
                extradata = {""}
              })
            end
          end
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        if u:hasdata("黑夜女神-强化") then
          local add = 5.0E-4 * u:getstate("外域变异")
          ChangeValue(Correction_Jzsh, sy, 0.1 * add)
          ChangeValue(Correction_Gun, sy, 0.1 * add)
        end
      end)
      local add = 0
      local xlsh = 0
      local med = 0
      ac.loop(3000, function()
        ChangeValue(DamageSplit_CountJzMax, sy, -add)
        ChangeValue(Damage_Element_Heart, sy, -xlsh)
        ChangeValue(Correction_MEDCgl, sy, -med)
        add = 0.02 * u:getstate("外域变异")
        xlsh = 0.01 * u:getstate("外域变异")
        if IsTimeNight() then
          u:setdata("黑夜女神-强化")
          med = 0.0025 * u:getdata("幸运")
        else
          u:deldata("黑夜女神-强化")
          med = 0
        end
        ChangeValue(Correction_MEDCgl, sy, med)
        ChangeValue(DamageSplit_CountJzMax, sy, add)
        ChangeValue(Damage_Element_Heart, sy, xlsh)
      end)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 1)
      ChangeValue(Damage_ElementRes_Heart, sy, 30)
      u:addstexiao(var.name, "伤害格挡效果", function(args)
        local tg = args.tg
        if not u:hasdata("黑夜女神-格挡生效冷却") and not args.b then
          args.b = true
          u:settimedata("黑夜女神-格挡生效冷却", 60)
          u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
          u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 3)
          local txsh = 11111 * u:getstate("外域变异") * math.max(u:getdata("外神变异数量"), 1)
          DamageUnit({
            bj = "黑夜女神附伤",
            unit = tg.handle,
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
        if tg:isnormal() then
          local jl = 1
          if u:hasdata("隐藏职业-天谴之子") then
            jl = jl * 2
          end
          if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
            jl = jl * 2
          end
          if u:getluckrandom(jl) then
            tg:effectadd("war3mapImported\\texiao_xukongtongyizhi.mdl")
            tg:kill(u.handle, true)
          end
        end
      end)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "黑夜女神",
          keytype = "传奇栏",
          icon = "Yuzhe_Cq_01_B.tga",
          ishasphoto = true,
          size_h = 2,
          smallicon = "Yuzhe_Cq_01.tga"
        })
      end)
    end,
    effectname = "|cFF666666「|r|cFF755757黑|r|cFF834949夜|r|cFF923A3A女|r|cFFA02C2C神|r|cFFAF1D1D」|r|cFFAB162D阿曼妮西斯|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF990000外域 黑暗 光明 根源 唯一|r\n|cFF666666【黑夜】|r\n|cFF666666处于夜间时:\n药水成功率提高[幸运*0.25%]\n杀敌提高[外域变异*0.05%]枪械与近战修正|r\n|cFF666666【隐秘】\n提高15%受伤减少\n受到伤害时格挡,冷却60秒|r\n|cFF999999【安眠】\n提高30%心灵伤害抗性\n提高[外域变异*1%]心灵伤害\n直接伤害10%附带[外域变异*11111]心灵伤害,冷却3秒|r\n|cFF999999【恐惧】\n靠近自身1000范围内的单位将被僵直1秒(独立冷却15秒)\n同时附带[全属性*111+英雄等级*750]心灵伤害\n提升目标10%额外受伤10秒|r\n|cFF990000【厄难】\n提升[外域变异*2%]近战多段伤害上限\n直接伤害1%即死普通单位|r\n|cFF9999CC「故乡」\n「数据删除」|r",
    effectart = "Yuzhe_Cq_01"
  }
}
local huopudata = {
  {
    name = "闪光皇",
    effect = function(u, var)
      local sy = u.ownerid
      u:changedata("光明变异数量", 1)
      u:setdata("霍普-当前形态", var.name)
      local add = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.1 * u:getstate("光明变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          u:changedata("光明变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66闪光皇.霍普|r\n|cFFFFAA00[传奇]|r\n|cFFFFFF66战士 同奏 光明\n提升[0.5%*战士变异]伤害加成\n提升[0.2%*全队同奏变异]伤害加成\n【闪光皇】\n提升[光明变异*1%]伤害加成\n提升[希望计数*1%]近战伤害\n提升[希望计数*2%]伤害加成\n【升阶魔法】\n[左键]拥有任意4个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Sgh.tga"
  },
  {
    name = "翻倍皇",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:addstexiao(var.name, "伤害判定前变更", function(args)
        local u = args.u
        if u:getdata("霍普-当前形态") == var.name and u:getluckrandom(50) then
          args.shadd = args.shadd + 1
        end
      end)
    end,
    effecttext = "|cFFFFFF66翻倍皇.霍普|r\n|cFFFFAA00[传奇]|r\n|cFFFFFF66战士 同奏\n提升[0.5%*战士变异]伤害加成\n提升[0.2%*全队同奏变异]伤害加成\n【翻倍皇】\n50%造成伤害翻倍(独立)\n提升[希望计数*1%]近战伤害\n提升[希望计数*2%]伤害加成\n【升阶魔法】\n[左键]拥有任意4个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Fbh.tga"
  },
  {
    name = "混沌皇",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("根源变异数量", 1)
      local add = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -add)
        add = 0.01 * u:getstate("根源变异")
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * add)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_EndSh, sy, 0.1 * -add)
          u:changedata("根源变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66混沌皇.霍普|r\n|cFFFFAA00[传奇]|r\n|cFFFFFF66战士 同奏 根源\n提升[0.5%*战士变异]伤害加成\n提升[0.2%*全队同奏变异]伤害加成\n【混沌皇】\n提升[根源变异*0.1%]终结伤害\n提升[希望计数*1%]近战伤害\n提升[希望计数*2%]伤害加成\n【升阶魔法】\n[左键]拥有任意4个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Hdh.tga"
  },
  {
    name = "绝望皇",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("黑暗变异数量", 1)
      local health_refresh = u:addhealthrefresh(function(set_value, bs)
        set_value(DamageSystem_Shjc, sy, 0.1 * (0.2 * u:getstate("黑暗变异") * bs))
      end)
      ac.loop(3000, function(timer)
        if var.name ~= u:getdata("霍普-当前形态") then
          health_refresh:remove()
          u:changedata("黑暗变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66绝望皇.霍普勒斯|r\n|cFFFFAA00[传奇]|r\n|cFFFFFF66战士 同奏 黑暗\n提升[0.5%*战士变异]伤害加成\n提升[0.2%*全队同奏变异]伤害加成\n【绝望皇】\n提升[黑暗变异*2%*背水]伤害加成\n提升[希望计数*1%]近战伤害\n提升[希望计数*2%]伤害加成\n【升阶魔法】\n[左键]拥有任意4个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Jwh.tga"
  },
  {
    name = "电光皇",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("雷变异数量", 1)
      ChangeValue(DamageSystem_Baoji, sy, 15)
      local add = 0
      local add2 = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Baoshang, sy, -add2)
        add = 0.15 * u:getstate("雷变异")
        add2 = 0.05 * u:getstate("雷变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Baoshang, sy, add2)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_Baoji, sy, -15)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          ChangeValue(DamageSystem_Baoshang, sy, -add2)
          u:changedata("雷变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66电光皇.霍普|r\n|cFFCC66FF[超凡]|r\n|cFFFFFF66战士 同奏 雷\n提升[0.7%*战士变异]伤害加成\n提升[0.3%*全队同奏变异]伤害加成\n【电光皇】\n提升15%暴击率\n提升[雷变异*1.5%]伤害加成\n提升[雷变异*5%]暴击伤害\n提升[希望计数*1.5%]近战伤害\n提升[希望计数*3%]伤害加成\n【升阶魔法】\n[左键]拥有任意6个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Dgh.tga"
  },
  {
    name = "狮子霍普雷",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("兽变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if var.name == u:getdata("霍普-当前形态") and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 5000 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "狮子霍普雷附伤",
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
      local add = 0
      local add2 = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        u:changedata("固定伤害", 0.1 * -add2)
        add = 0.15 * u:getstate("兽变异")
        add2 = 4000 * u:getstate("兽变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        u:changedata("固定伤害", 0.1 * add2)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          u:changedata("固定伤害", 0.1 * -add2)
          u:changedata("兽变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66狮子霍普雷|r\n|cFFCC66FF[超凡]|r\n|cFFFFFF66战士 同奏 兽\n提升[0.7%*战士变异]伤害加成\n提升[0.3%*全队同奏变异]伤害加成\n【狮子霍普雷】\n提升[兽变异*1.5%]伤害加成\n提升[兽变异*400]固定伤害\n直接伤害时10%附带[希望计数*5000]物理伤害,冷却1秒\n提升[希望计数*1.5%]近战伤害\n提升[希望计数*3%]伤害加成\n【升阶魔法】\n[左键]拥有任意6个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Szhpl.tga"
  },
  {
    name = "龙王霍普雷",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("龙变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if var.name == u:getdata("霍普-当前形态") and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 2500 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "龙王霍普雷附伤",
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
      local add = 0
      local add2 = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Damage_Element_Dragon, sy, -add2)
        add = 0.15 * u:getstate("龙变异")
        add2 = 0.005 * u:getstate("龙变异")
        ChangeValue(Damage_Element_Dragon, sy, add2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          ChangeValue(Damage_Element_Dragon, sy, -add2)
          u:changedata("龙变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66龙王霍普雷|r\n|cFFCC66FF[超凡]|r\n|cFFFFFF66战士 同奏 龙\n提升[0.7%*战士变异]伤害加成\n提升[0.3%*全队同奏变异]伤害加成\n【龙王霍普雷】\n提升[龙变异*1.5%]伤害加成\n提升[龙变异*0.5%]龙属性伤害\n直接伤害时10%附带[希望计数*2500]物理(龙属性)伤害,冷却1秒\n提升[希望计数*1.5%]近战伤害\n提升[希望计数*3%]伤害加成\n【升阶魔法】\n[左键]拥有任意6个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Lwhpl.tga"
  },
  {
    name = "霍普雷胜光",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("光明变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if var.name == u:getdata("霍普-当前形态") and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 5000 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "霍普雷胜光附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光明"
          })
        end
      end)
      local add = 0
      local add2 = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Correction_MHp, sy, 0.1 * -add2)
        add = 0.15 * u:getstate("光明变异")
        add2 = 0.03 * u:getstate("光明变异")
        ChangeValue(Correction_MHp, sy, 0.1 * add2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          ChangeValue(Correction_MHp, sy, 0.1 * -add2)
          u:changedata("光明变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66霍普雷胜光|r\n|cFFCC66FF[超凡]|r\n|cFFFFFF66战士 同奏 光明\n提升[0.7%*战士变异]伤害加成\n提升[0.3%*全队同奏变异]伤害加成\n【霍普雷胜光】\n提升[光明变异*1.5%]伤害加成\n提升[光明变异*0.3%]生命上限\n直接伤害时10%附带[希望计数*5000]光明物理伤害,冷却1秒\n提升[希望计数*1.5%]近战伤害\n提升[希望计数*3%]伤害加成\n【升阶魔法】\n[左键]拥有任意6个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Hplsg.tga"
  },
  {
    name = "霍普雷V",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("炎变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if var.name == u:getdata("霍普-当前形态") and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 7500 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "霍普雷V附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "火"
          })
        end
      end)
      local add = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.2 * u:getstate("光明变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          u:changedata("炎变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66霍普雷V|r\n|cFFCC66FF[超凡]|r\n|cFFFFFF66战士 同奏 炎\n【组合:火炎V铠甲+雷神猛虎剑+天风精灵翼+任一】\n提升[0.7%*战士变异]伤害加成\n提升[0.3%*全队同奏变异]伤害加成\n【霍普雷V】\n提升[炎变异*2%]伤害加成\n提升[炎变异*10%]灼烧伤害\n直接伤害时10%附带[希望计数*7500]炎物理伤害,冷却1秒\n提升[希望计数*1.5%]近战伤害\n提升[希望计数*3%]伤害加成\n【升阶魔法】\n[左键]拥有任意6个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Hplv.tga"
  },
  {
    name = "彼端超霍普",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("光明变异数量", 1)
      u:changedata("根源变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if var.name == u:getdata("霍普-当前形态") and u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 7500 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "彼端超霍普附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光明"
          })
        end
      end)
      local add = 0
      local add2 = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Correction_MHp, sy, 0.1 * -add2)
        add = 0.2 * u:getstate("光明变异")
        add2 = 0.05 * u:getstate("光明变异")
        ChangeValue(Correction_MHp, sy, 0.1 * add2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        if var.name ~= u:getdata("霍普-当前形态") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          ChangeValue(Correction_MHp, sy, 0.1 * -add2)
          u:changedata("光明变异数量", -1)
          u:changedata("根源变异数量", -1)
          timer:remove()
        end
      end)
    end,
    effecttext = "|cFFFFFF66彼端超霍普|r\n|cFFCC66FF[超凡]|r\n|cFFFFFF66战士 同奏 根源 光明\n【组合:天风精灵翼+极星神马圣铠+星光铠甲+任一】\n提升[0.7%*战士变异]伤害加成\n提升[0.3%*全队同奏变异]伤害加成\n【彼端超霍普】\n提升[光明变异*2%]伤害加成\n提升[光明变异*0.5%]生命上限\n直接伤害时10%附带[希望计数*7500]光明物理伤害,冷却1秒\n提升[希望计数*1.5%]近战伤害\n提升[希望计数*3%]伤害加成\n【升阶魔法】\n[左键]拥有任意6个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    icon = "Mwx_Myzf_Hp_Bdchp.tga"
  },
  {
    name = "无限达克霍普",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("黑暗变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 20000 * u:getdata("霍普-希望计数") * u:getstate("背水")
          DamageUnit({
            bj = "无限达克霍普附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "黑暗"
          })
        end
      end)
      u:changedata("效果增强-背水", 0.25)
      u:addhealthrefresh(function(set_value, bs)
        set_value(DamageSystem_Shjc, sy, 0.1 * (0.6 * u:getstate("光明变异") * bs))
      end)
    end,
    effecttext = "|cFFFFFF66无限达克霍普|r\n|cFFFF3366[神话]|r\n|cFFFFFF66战士 同奏 黑暗\n【组合:天风精灵翼+幻影铠甲+无限铠甲+天圣辉狼剑+任二】\n提升[0.9%*战士变异]伤害加成\n提升[0.4%*全队同奏变异]伤害加成\n【无限达克霍普】\n提升25%背水效果\n提升[黑暗变异*6%*背水]伤害加成\n直接伤害时10%附带[希望计数*20000*背水]黑暗物理伤害,冷却1秒\n提升[希望计数*2%]近战伤害\n提升[希望计数*4.5%]伤害加成|r",
    icon = "Mwx_Myzf_Hp_Wxdkhp.tga"
  },
  {
    name = "霍普真皇",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("光明变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 10000 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "霍普真皇附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光明"
          })
        end
      end)
      u:changedata("全属性增幅", 0.125)
      local add = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.3 * u:getstate("战士变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
    end,
    effecttext = "|cFFFFFF66霍普真皇|r\n|cFFFF3366[神话]|r\n|cFFFFFF66战士 同奏 光明\n【组合:天风精灵翼+升华铠甲+星光铠甲+荒鹫激神爪+任二】\n提升[0.9%*战士变异]伤害加成\n提升[0.4%*全队同奏变异]伤害加成\n【霍普真皇】\n提升12.5%全属性\n提升[战士变异*3%]伤害加成\n直接伤害时10%附带[希望计数*10000]光明物理伤害,冷却1秒\n提升[希望计数*2%]近战伤害\n提升[希望计数*4.5%]伤害加成|r",
    icon = "Mwx_Myzf_Hp_Hpzh.tga"
  },
  {
    name = "霍普德拉戈纳",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("战士变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 10000 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "霍普德拉戈纳附伤",
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
      local add = 0
      local add2 = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add2)
        add = 0.3 * u:getstate("战士变异")
        add2 = 0.2 * u:getstate("战士变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * add2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
    end,
    effecttext = "|cFFFFFF66霍普德拉戈纳|r\n|cFFFF3366[神话]|r\n|cFFFFFF66战士 同奏 战士\n【组合:天风精灵翼+升华铠甲+武装铠甲+雷神猛虎剑+任二】\n提升[0.9%*战士变异]伤害加成\n提升[0.4%*全队同奏变异]伤害加成\n【霍普德拉戈纳】\n提升[战士变异*2%]近战伤害\n提升[战士变异*3%]伤害加成\n直接伤害时10%附带[希望计数*10000]物理伤害,冷却1秒\n提升[希望计数*2%]近战伤害\n提升[希望计数*4.5%]伤害加成|r",
    icon = "Mwx_Myzf_Hp_Hpdlgn.tga"
  },
  {
    name = "未来龙皇霍普",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("龙变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 5000 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "未来龙皇霍普附伤",
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
      local add = 0
      local add2 = 0
      local add3 = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add2)
        ChangeValue(Damage_Element_Dragon, sy, -add3)
        add = 0.25 * u:getstate("龙变异")
        add2 = 0.15 * u:getstate("龙变异")
        add3 = 0.01 * u:getstate("龙变异")
        ChangeValue(Damage_Element_Dragon, sy, add3)
        ChangeValue(Correction_Jzsh, sy, 0.1 * add2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
    end,
    effecttext = "|cFFFFFF66未来龙皇霍普|r\n|cFFFF3366[神话]|r\n|cFFFFFF66战士 同奏 龙\n【组合:天风精灵翼+升华铠甲+极星神马圣铠+风神云龙剑+任二】\n提升[0.9%*战士变异]伤害加成\n提升[0.4%*全队同奏变异]伤害加成\n【未来龙皇霍普】\n提升[龙变异*2.5%]伤害加成\n提升[龙变异*1.5%]近战伤害\n提升[龙变异*1%]龙属性伤害\n直接伤害时10%附带[希望计数*5000]物理(龙属性)伤害,冷却1秒\n提升[希望计数*2%]近战伤害\n提升[希望计数*4.5%]伤害加成|r",
    icon = "Mwx_Myzf_Hp_Wllhhp.tga"
  },
  {
    name = "未来皇霍普",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("战士变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 10000 * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "未来皇霍普附伤",
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
      local add = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.4 * u:getstate("战士变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
    end,
    effecttext = "|cFFFFFF66未来皇霍普|r\n|cFFFF3366[神话]|r\n|cFFFFFF66战士 同奏 战士\n【组合:任意6个】\n提升[0.9%*战士变异]伤害加成\n提升[0.4%*全队同奏变异]伤害加成\n【未来斩皇霍普】\n提升[战士变异*4%]伤害加成\n直接伤害时10%附带[希望计数*10000]物理伤害,冷却1秒\n提升[希望计数*2%]近战伤害\n提升[希望计数*4.5%]伤害加成|r",
    icon = "Mwx_Myzf_Hp_Wlhhp.tga"
  },
  {
    name = "未来斩皇霍普",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:setdata("变异判定-未来斩皇霍普")
      u:changedata("战士变异数量", 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 2500 * u:getstate("战士变异") * u:getdata("霍普-希望计数")
          DamageUnit({
            bj = "未来斩皇霍普附伤",
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
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.5)
      local add = 0
      ac.loop(3000, function(timer)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add)
        add = 0.6 * u:getstate("战士变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * add)
      end)
    end,
    effecttext = "|cFFFFFF66未来斩皇霍普|r\n|cFFFF3366[神话]|r\n|cFFFFFF66战士 同奏 战士\n【组合:天马双翼剑+天圣辉狼剑+风神云龙剑+雷神猛虎剑+任二】\n提升[0.9%*战士变异]伤害加成\n提升[0.4%*全队同奏变异]伤害加成\n【未来斩皇霍普】\n近战多段段数+1(物理)\n近战多段上限+50%\n提升[战士变异*6%]近战伤害\n直接伤害时10%附带[希望计数*2500*战士变异]物理伤害,冷却1秒\n提升[希望计数*2%]近战伤害\n提升[希望计数*4.5%]伤害加成|r",
    icon = "Mwx_Myzf_Hp_Wlzhhp.tga"
  },
  {
    name = "希望之异热同心",
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("霍普-当前形态", var.name)
      u:changedata("根源变异数量", 1)
      u:addallstats(333)
      u:changeoriginmaxhp(900.0)
      local add = 0
      local add2 = 0
      ac.loop(3000, function(timer)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add)
        ChangeValue(Correction_Gun, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        u:changedata("全属性增幅", -add2)
        local count = u:getdata("霍普-异热同心数量")
        add = 0.33 * count
        add2 = 0.015 * count
        u:changedata("全属性增幅", add2)
        ChangeValue(Correction_Jzsh, sy, 0.1 * add)
        ChangeValue(Correction_Gun, sy, 0.1 * add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
    end,
    effecttext = "|cFFFFFF66希望之异热同心|r\n|cFFFF3366[神话]|r\n|cFFFFFF66战士 同奏 根源\n【组合:异热同心数量达到9以上】\n提升[0.9%*战士变异]伤害加成\n提升[0.4%*全队同奏变异]伤害加成\n【希望之异热同心】\n提升333全属性\n提升900基础生命上限\n提升[异热同心数量*33%]近战加成\n提升[异热同心数量*33%]枪械加成\n提升[异热同心数量*3.3%]伤害加成\n提升[根源变异*1.5%]全属性\n提升[希望计数*2%]近战伤害\n提升[希望计数*4.5%]伤害加成|r",
    icon = "Mwx_Myzf_Hp_Xwzyrtx.tga"
  }
}
Vars_Ciyuan_EventOnly = {
  {
    name = "希望皇霍普",
    clickfunc = function(u, var)
      local sy = u.ownerid
      local lv = u:getdata("霍普-当前阶级")
      if 4 <= lv then
        return
      end
      if u:getdata("霍普-异热同心数量") >= 2 * lv then
        local b = false
        local jg
        if lv == 1 then
          local sjdata = {
            "闪光皇",
            "翻倍皇",
            "混沌皇",
            "绝望皇"
          }
          jg = sjdata[GetRandomInt(1, #sjdata)]
        end
        if lv == 2 then
          local sjdata = {
            "电光皇",
            "狮子霍普雷",
            "龙王霍普雷",
            "霍普雷胜光"
          }
          jg = sjdata[GetRandomInt(1, #sjdata)]
          if u:hasdata("变异判定-火炎V铠甲") and u:hasdata("变异判定-雷神猛虎剑") and u:hasdata("变异判定-天风精灵翼") then
            jg = "霍普雷V"
          end
          if u:hasdata("变异判定-天风精灵翼") and u:hasdata("变异判定-极星神马圣铠") and u:hasdata("变异判定-星光铠甲") then
            jg = "彼端超霍普"
          end
        end
        if lv == 3 then
          local sjdata = {
            "未来皇霍普"
          }
          jg = sjdata[GetRandomInt(1, #sjdata)]
          if u:hasdata("变异判定-天风精灵翼") then
            if u:hasdata("变异判定-幻影铠甲") and u:hasdata("变异判定-无限铠甲") and u:hasdata("变异判定-天圣辉狼剑") then
              jg = "无限达克霍普"
            end
            if u:hasdata("变异判定-升华铠甲") and u:hasdata("变异判定-星光铠甲") and u:hasdata("变异判定-荒鹫激神爪") then
              jg = "霍普真皇"
            end
            if u:hasdata("变异判定-升华铠甲") and u:hasdata("变异判定-武装铠甲") and u:hasdata("变异判定-雷神猛虎剑") then
              jg = "霍普德拉戈纳"
            end
            if u:hasdata("变异判定-升华铠甲") and u:hasdata("变异判定-极星神马圣铠") and u:hasdata("变异判定-风神云龙剑") then
              jg = "未来龙皇霍普"
            end
          end
          if u:hasdata("变异判定-天马双翼剑") and u:hasdata("变异判定-天圣辉狼剑") and u:hasdata("变异判定-风神云龙剑") and u:hasdata("变异判定-雷神猛虎剑") then
            jg = "未来斩皇霍普"
          end
          if u:getdata("霍普-异热同心数量") >= 9 then
            jg = "希望之异热同心"
          end
        end
        for index, value in ipairs(huopudata) do
          if value.name == jg then
            value.effect(u, value)
            if lv == 3 then
              u:uivar_change({
                keyname = "希望皇霍普",
                keytype = "传奇栏",
                text = value.effecttext,
                icon = value.icon,
                isclearclick = true
              })
            else
              u:uivar_change({
                keyname = "希望皇霍普",
                keytype = "传奇栏",
                text = value.effecttext,
                icon = value.icon
              })
            end
            b = true
            u:sendmessage("|cFFFFFF66进阶成功[" .. jg .. "]")
            break
          end
        end
        if b then
          if lv == 1 then
            u:setdata("霍普-当前阶级", 2)
            local add = 1
            u:changedata("系统-神力承载", add)
            u:changedata("系统-神力承载上限", add)
          end
          if lv == 2 then
            u:setdata("霍普-当前阶级", 3)
            local add = 2
            u:changedata("系统-神力承载", add)
            u:changedata("系统-神力承载上限", add)
          end
          if lv == 3 then
            u:setdata("霍普-当前阶级", 4)
            local add = 2
            u:changedata("系统-神力承载", add)
            u:changedata("系统-神力承载上限", add)
          end
        else
          u:sendmessage("|cFFFFFF66进阶条件未满足")
        end
      else
        u:sendmessage("|cFFFFFF66异热同心装备不足")
      end
    end,
    weight = 100,
    lv = 2,
    key = {"战士", "同奏"},
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
      ciyuanget(u, var)
      u:changedata("霍普-希望计数", 1)
      u:setdata("霍普-当前阶级", 1)
      u:setdata("霍普-当前形态", var.name)
      local add = 0
      local add2 = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        local lv = u:getdata("霍普-当前阶级")
        add = (0.01 + 0.02 * lv) * u:getstate("战士变异")
        add = add + 0.01 * lv * TONGZOU_Count
        local count = u:getdata("霍普-希望计数")
        if lv == 4 then
          add = add + count * 0.45
        else
          add = add + count * 0.1 * lv
        end
        add2 = 0.05 * lv * count
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(Correction_Jzsh, sy, 0.1 * add2)
      end)
    end,
    effectname = "|cFFFFFF66希望皇.霍普|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFFFFF66战士 同奏\n提升[0.3%*战士变异]伤害加成\n提升[0.1%*全队同奏变异]伤害加成\n【希望皇】\n获取时提升1希望计数\n提升[希望计数*0.5%]近战伤害\n提升[希望计数*1%]伤害加成\n【升阶魔法】\n[左键]拥有任意2个[异热同心]武器时进阶\n部分升阶结果只有在特定[异热同心]组合时出现|r",
    effectart = "Mwx_Myzf_Hp_Xwh",
    test = "    "
  },
  {
    name = "伊卡洛斯",
    weight = 300,
    lv = 0,
    key = {
      "唯一",
      "光明",
      "机械"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:become("机械生命")
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 0.5)
      u:changedata("固定格挡", 250)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 1)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      u:changeoriginmaxhp(500.0)
      local hp = 0
      local zs = 0
      local bs = 0
      ac.loop(3000, function()
        ChangeValue(Correction_MHp, sy, 0.1 * -hp)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -zs)
        ChangeValue(DamageSystem_Baoshang, sy, -bs)
        hp = 0.025 * u:getstate("光明变异")
        zs = 0.1 * u:getstate("机械变异")
        bs = 0.1 * u:getstate("机械变异")
        ChangeValue(DamageSystem_Baoshang, sy, bs)
        ChangeValue(Correction_MHp, sy, 0.1 * hp)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * zs)
      end)
      u:changearmor(50)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      ChangeValue(DamageSystem_Baoshang, sy, 0.5)
      u:addstexiao(var.name, "伤害格挡效果", function(args)
        if not args.b and GetRandom100(25) then
          args.b = true
          u:effectadd("Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl", "chest")
        end
      end)
      ac.wait(500, function()
        u:uivar_change({
          keyname = "伊卡洛斯",
          keytype = "传奇栏",
          dx = 3.5,
          ishasphoto = true
        })
      end)
    end,
    effectname = "|cFFE3B3A6伊|r|cFFE9AEB8卡|r|cFFEEA9CA洛|r|cFFF4A3DB斯|r",
    effecttext = "|cFFFFBFBF[特殊]|r\n|cFFF4A3DB唯一 机械 光明|r\n|cFFF4A3DB【自我修复】|r\n|cFFE3B3A6提升0.5%永恒恢复\n提升500基础生命上限\n提升[光明变异*0.25%]生命上限|r\n|cFFF4A3DB【绝对防御圈】|r\n|cFFE3B3A6提升50护甲\n提升250固定减伤\n提升25%受伤减少\n25%格挡伤害|r\n|cFFF4A3DB【最终兵器阿波罗】|r\n|cFFE3B3A6提升50%暴击伤害\n提升10%伤害加成\n提升[1%*机械变异]伤害加成\n提升[10%*机械变异]暴击伤害|r",
    effectart = "NewIcon_Ykls",
    test = "    "
  }
}
