-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local function mwxjiesuan(u, boolean, medicine)
  local b1 = boolean
  
  medicinegetend(u, b1, medicine)
  if b1 then
    u:changedata("冥王星变异数量", 1)
    MwxJibingpanding(u)
  end
end

local function wrap_medicine_choice_end(option, medicine, on_success, on_finish)
  local old_func = option.func
  
  function option.func(u2)
    local result = old_func(u2)
    local ok = result and result ~= "失败"
    if ok and on_success then
      on_success(u2)
    end
    medicinegetend(u2, ok, medicine)
    if on_finish then
      on_finish()
    end
    return result
  end
end

local function get_mwx_non_start_pools(u)
  u:setdata("药水判定-冥王星")
  local pools = MWXPools(u)
  u:deldata("药水判定-冥王星")
  local non_start_pools = {}
  for _, pool in ipairs(pools) do
    if pool ~= Vars_Mwx then
      table.insert(non_start_pools, pool)
    end
  end
  return non_start_pools
end

local function give_medicine_to_owner(u, medicine)
  if CountedMedicine.by_type[medicine] then
    CountedMedicine.change(u, medicine, 1)
  else
    u:additem(medicine)
  end
end

function MedicineActBiexibo(u, medicine)
  local sy = u.ownerid
  if u:hasdata("花瓣-别西卜") and Ewaishu[sy] < 1 and medicine ~= MEDICINE_MWX_Wenda then
    if TableContains(ystype, medicine) then
      if not u:hasdata("别西卜-已生效") or ModeSelect_Infinite then
        u:setdata("别西卜-已生效")
        u:sendmessage("|cFF00FF99别|r|cFF00E4A8西|r|cFF00C9B6卜|r|cFF00AEC5-|r|cFF0092D3愚|r|cFF0077E2钝|r")
        give_medicine_to_owner(u, medicine)
      end
    else
      u:sendmessage("|cFF00FF99别|r|cFF00E4A8西|r|cFF00C9B6卜|r|cFF00AEC5-|r|cFF0092D3愚|r|cFF0077E2钝|r")
      give_medicine_to_owner(u, medicine)
    end
  end
  if u:hasdata("神器判定-药水腰带") and u:getluckrandom(10) then
    u:sendmessage("|cFFCC9900药水腰带-不消耗|r")
    give_medicine_to_owner(u, medicine)
  end
end

function MedicineActBlood(u, medicine, item)
  local sy = u.ownerid
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
  if u:hasdata("变异判定-祢豆子") then
    u:addstr(GetRandomInt(2, 6))
  end
  if not u:hasdata("往世乐土-变异获取中") and u:hasdata("变异判定-黑龙") and u:getdata("黑龙血统阶级") < 5 then
    b1 = false
    u:addrandomstats(GetRandomInt(1, 3))
    u:effectadd("Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl", "origin")
    local gl = 70 - 10 * u:getdata("黑龙血统阶级")
    if u:getdata("黑龙血统阶级") < 5 and GetRandom100(gl) then
      u:changedata("龙血浓度", 20)
      u:sendmessage("|cFF990000血统之力进阶|r")
      u:changedata("黑龙血统阶级", 1)
      if u:getdata("黑龙血统阶级") == 3 then
        u:addskill("S02G")
        u:addstexiao("黑龙", "被施加Buff时效果-眩晕", function(args)
          if not Keyan_Guomintizhi then
            args.time = 0
          end
        end)
      end
      if u:getdata("黑龙血统阶级") == 4 then
        u:deldata("诅咒-灵体化")
        u:uivar_remove("灵体化", "传奇栏")
      end
      if u:getdata("黑龙血统阶级") == 5 then
        ChangeValue(Correction_CureUp, sy, 0.75)
        ChangeValue(Correction_CureOther, sy, 0.75)
      end
    end
  end
  local str
  if b1 then
    local pools = {
      Vars_Blood
    }
    if medicine == MEDICINE_BLOOD_TC then
      u:setdata("提纯的血晶使用中")
      str = herogetvar(u, pools, "血晶", GetData(item, "血晶-定向"))
      u:deldata("提纯的血晶使用中")
    else
      str = herogetvar(u, pools, "血晶")
    end
    if str == "反噬" then
      b1 = false
      u:sendmessage("|cFF990000药水的作用反噬了|r")
      u:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl")
      u:losshp(u, 0, 90)
      if u:getdata("血统浓度") >= 100 and not u:hasdata("血统-完全抑制") then
        u:changedata("血统-完全抑制", 30)
        ac.loop(1000, function(timer)
          u:changedata("血统-完全抑制", -1)
          if u:getdata("血统-完全抑制") <= 0 then
            u:deldata("血统-完全抑制")
            timer:remove()
          end
        end)
      end
    elseif str == "失败" then
      b1 = false
    end
  end
  if not b1 and str ~= "反噬" then
    u:sendmessage("|cFF990000这瓶药水没有对你起作用|r")
  end
  medicinegetend(u, b1, medicine)
  if b1 then
    u:changedata("血统数", 1)
    if u:hasdata("判定-吉普利露") and str ~= "人类" and str ~= "天使" then
      u:setdata("吉普利露-非天使化")
    end
    if u:hasdata("变异判定-王家诅咒") then
      u:addrandomstats(15)
    end
  end
end

function MedicineActXingyou(u, medicine, item)
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
  u:setdata("药水判定-禁止跳过")
  local ysb = guobodvarget({
    u = u,
    pools = pools,
    poolsstr = poolstr,
    skip_medicinegetend = true,
    option_func_wrapper = function(option)
      wrap_medicine_choice_end(option, medicine, function(u2)
        if sjz == 2 then
          u2:changedata("冥王星变异数量", 1)
          MwxJibingpanding(u2)
        elseif sjz == 3 then
          u2:changedata("传奇数量", 1)
        end
      end)
    end
  })
  u:deldata("药水判定-禁止跳过")
  if not ysb then
    medicinegetend(u, false, medicine)
  end
end

function MedicineActJinjizhixue(u, medicine, item)
  local sy = u.ownerid
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
  local b = false
  if b1 then
    local jl2 = 0
    if u:getdata("血统数") == 0 then
      jl2 = 15
    end
    if u:getbloodcd("龙") >= 0.5 then
      jl2 = 30
    end
    if u:ishasitem("I012") then
      jl2 = jl2 * 2
    end
    if u:hasdata("判定-黑龙") then
      jl2 = jl2 * 2
    end
    if u:hasdata("判定-黑龙高概率") then
      jl2 = 100
    end
    if Race_Dragon_Cd[sy] ~= 0 then
      jl2 = jl2 * Race_Dragon_Cd[sy]
    end
    if u:hasdata("血坏血统") then
      jl2 = 0
    end
    if GetRandom100(jl2) then
      b = true
    end
    if b then
      local str
      local pools = {
        Vars_Xuehuai
      }
      u:setdata("黑龙-获取中判定")
      str = herogetvar(u, pools, "血坏", "黑龙")
      u:deldata("黑龙-获取中判定")
      if str == "失败" then
        b = false
        b1 = false
      end
    end
  end
  if not b or not b1 then
    u:sendmessage("|cFF990000给驾驭不住的力量解开约束，可是代表了自我毁灭|r")
    u:playsound(Sound_Heilong_Fail)
    local cs = 0
    ac.loop(1000, function(timer)
      if not Boolean_Jinselingyu then
        cs = cs + 1
        if u:isalive() then
          u:losshp(u, cs, cs * 0.1)
          u:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
        end
        if 360 <= cs then
          timer:remove()
        end
      end
    end)
  end
  medicinegetend(u, b1, medicine)
end

function MedicineActXuehuai(u, medicine, item)
  local sy = u.ownerid
  if u:hasdata("东风谷早苗-神乐祈舞") and u:ishasitem("I02B") and not u:hasdata("变异判定-神代の御神子") and u:hasdata("变异判定-奇迹の祝福") and u:hasdata("血统判定-风神") then
    MovieAct["神乐祈舞"](u)
    return
  end
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
  u:buffset(u.handle, 12, "暂停")
  u:buffset(u.handle, 12, "无敌")
  ac.wait(3000, function()
    u:sendmessage("|cFF530080是|r|cFF4E0488谁|r|cFF490890给|r|cFF430C98你|r|cFF3E10A0的|r|cFF3914A8勇|r|cFF3418B0气|r|cFF2F1CB8喝|r|cFF2A20C0下|r|cFF2425C7这|r|cFF1F29CF瓶|r|cFF1A2DD7药|r|cFF1531DF剂|r|cFF1035E7的|r|cFF0A39EF？|r")
  end)
  ac.wait(6000, function()
    u:sendmessage("|cFF530080人|r|cFF4B068D类|r|cFF420D99真|r|cFF3A14A6是|r|cFF321AB3贪|r|cFF2A20BF婪|r|cFF2127CC无|r|cFF192ED9比|r|cFF1134E6呢|r")
  end)
  ac.wait(9000, function()
    u:sendmessage("|cFF530080那|r|cFF4D0589么|r|cFF470992就|r|cFF410E9B来|r|cFF3B13A4看|r|cFF3517AD看|r|cFF2F1CB6你|r|cFF2920C0的|r|cFF2425C9命|r|cFF1E2AD2运|r|cFF182EDB如|r|cFF1233E4何|r|cFF0C38ED吧|r")
  end)
  ac.wait(12000, function()
    local b = false
    if b1 then
      local jl2 = 1
      if u:hasdata("变异判定-王家诅咒") then
        jl2 = jl2 * 1.1
      end
      if u:hasdata("隐藏职业-律者") then
        jl2 = jl2 * 1.5
      elseif not u:isgirl() then
        jl2 = jl2 * 0.5
      end
      local zs, name
      if not b then
        zs = 3
        name = "雷之律者"
        local jl
        if u:hasdata("判定-雷律概率2") then
          jl = 12 + 6 * u:getdata("血坏使用次数")
        elseif ModeSelect_Infinite then
          jl = 5 - 0.5 * u:getdata("血坏使用次数")
          if jl <= 2.5 then
            jl = 2.5
          end
        else
          jl = 5 - 1 * u:getdata("血坏使用次数")
        end
        if u:hasdata("隐藏职业-律者") then
          jl = jl + 10
        end
        jl = jl * jl2
        if u:getdata("雷变异数量") > 0 or u:hasdata("判定-雷之律者") then
          jl = jl * (1 + 0.2 * u:getdata("雷变异数量"))
        else
          jl = 0
        end
        if u:hasdata("判定-雷之律者") then
          jl = jl * 1.7
        end
        if u:ishasitem("I08V") then
          jl = jl * 1.5
        end
        if u:hasdata("血统判定-人类") then
          jl = jl * 1.25
        end
        if GetRandom100(jl) then
          b = true
        end
      end
      if not b then
        zs = 2
        name = "塞壬公主"
        local jl
        if u:hasdata("权限-塞壬公主") then
          if ModeSelect_Infinite then
            jl = 20 - 2 * u:getdata("血坏使用次数")
            if jl <= 10 then
              jl = 10
            end
          else
            jl = 20 - 4 * u:getdata("血坏使用次数")
          end
        else
          jl = 0
        end
        local z1 = 1
        local z2 = 1.25
        local bz = u:getbloodcd("渊海")
        if 0.75 <= bz then
          jl = jl * (0.5 + z1 * (bz - 0.75) / 0.25)
        else
          jl = 0
        end
        jl = jl * jl2
        if u:hasdata("血统判定-人鱼") then
          jl = jl * z2
        end
        if u:hasdata("血统判定-人类") then
          jl = jl * 1.25
        end
        if GetRandom100(jl) then
          b = true
        end
      end
      if not b then
        zs = 1
        name = "空之律者"
        local jl
        if ModeSelect_Infinite then
          jl = 10 - 1 * u:getdata("血坏使用次数")
          if jl <= 5 then
            jl = 5
          end
        else
          jl = 10 - 2 * u:getdata("血坏使用次数")
        end
        if u:hasdata("隐藏职业-律者") then
          jl = jl + 10
        end
        jl = jl * jl2
        if u:hasdata("血统判定-人类") then
          jl = jl * 1.25
        end
        jl = jl * (100 - u:getdata("血统浓度")) / 100
        if u:hasdata("变异判定-黑龙") then
          jl = 0
        end
        if u:hasdata("权限-空之律者") then
          jl = jl * 2
        end
        if GetRandom100(jl) then
          b = true
        end
      end
      if u:hasdata("血坏血统") then
        b = false
      end
      u:changedata("血坏使用次数", 1)
      if b then
        local str
        local pools = {
          Vars_Xuehuai
        }
        str = herogetvar(u, pools, "血坏", name)
        if str == "失败" then
          b = false
          b1 = false
        end
      end
    end
    if not b or not b1 then
      u:sendmessage("|cFF530080享|r|cFF4D0589受|r|cFF470992你|r|cFF410E9B的|r|cFF3B13A4惩|r|cFF3517AD罚|r|cFF2F1CB6吧|r|cFF2920C0 |r|cFF2425C9贪|r|cFF1E2AD2婪|r|cFF182EDB的|r|cFF1233E4人|r|cFF0C38ED类|r")
      u:playsound(LvzheFail)
      local cs = 1050
      u:setdata("血坏生效中")
      local boss = getunit(BOSS_DEATH)
      ac.loop(200, function(timer)
        if u:isalive() and not Boolean_Jinselingyu then
          cs = cs - 1
          u:setdata("血坏生效中")
          local hp = 0.004 * u:getmaxhp()
          boss:setdata("时限伤害", hp)
          DamageUnit({
            unit = u.handle,
            source = boss.handle,
            damage = hp,
            level = 1,
            type = "魔力"
          })
          boss:deldata("时限伤害")
          u:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          if cs <= 0 or u:hasdata("血坏清除") then
            u:deldata("血坏生效中")
            timer:remove()
          end
        end
      end)
    end
    medicinegetend(u, b1, medicine)
  end)
end

function MedicineActYitai(u, medicine, item)
  local pools
  local enhanced = u:hasdata("强化药剂-本次药剂强化")
  local enhanced_heart = enhanced and u:getdata("心脏变异数量") <= 0
  local itemtype = item and GetItemTypeId(item) or medicine
  local directed_tag = item and HasData(item, "以太-定向补正") and GetData(item, "以太-定向补正") or nil
  u:setdata("服用以太", itemtype)
  local _, success = medicineprobability(u, S2ID("A04W"), MEDICINE_YITAI)
  u:deldata("服用以太")
  ac.wait(1, function()
    local function fail()
      medicinegetend(u, false, medicine)
    end
    
    if not success then
      fail()
      return
    end
    u:setdata("药水判定-禁止跳过")
    if enhanced then
      u:setdata("强化药剂-以太体质概率翻倍")
    end
    if enhanced_heart then
      pools = {
        Vars_Yitai_Jubu_Xinzang
      }
      u:sendmessage("|cFF99CCFF强化药剂-以太心脏诱导|r")
    elseif directed_tag then
      u:setdata("以太药水-临时池判定中")
      local directed_pools = GetYitaiVar(u, "全部", 1, directed_tag)
      u:deldata("以太药水-临时池判定中")
      u:setdata("以太药水-临时池", directed_pools)
      pools = GetYitaiVar(u, "全部", 3)
    else
      pools = GetYitaiVar(u, "全部", 3)
    end
    local result = guobodvarget({
      u = u,
      pools = pools,
      poolsstr = "以太",
      skip_medicinegetend = true,
      option_func_wrapper = function(option)
        wrap_medicine_choice_end(option, medicine)
      end
    })
    if enhanced_heart and (not result or result == "失败") then
      pools = GetYitaiVar(u, "全部", 3)
      result = guobodvarget({
        u = u,
        pools = pools,
        poolsstr = "以太",
        skip_medicinegetend = true,
        option_func_wrapper = function(option)
          wrap_medicine_choice_end(option, medicine)
        end
      })
    end
    if enhanced then
      u:deldata("强化药剂-以太体质概率翻倍")
    end
    u:deldata("以太药水-临时池")
    u:deldata("药水判定-禁止跳过")
    if not result or result == "失败" then
      fail()
    end
  end)
end

function MedicineActMwx(u, medicine, item)
  local lock_key = "冥王星药剂-判定处理中"
  local pending_key = "冥王星药剂-待判定次数"
  local pending_enhanced_key = "冥王星药剂-待强化次数"
  local first_enhanced = u:hasdata("强化药剂-本次药剂强化")
  if u:hasdata(lock_key) then
    u:changedata(pending_key, 1)
    if first_enhanced then
      u:changedata(pending_enhanced_key, 1)
    end
    return
  end
  u:setdata(lock_key)
  local finish_once
  
  local function wait_until_mwx_choice_finished(callback)
    ac.wait(100, function()
      if not u:hasdata("系统-正在选择选项") then
        callback()
        return
      end
      ac.loop(100, function(timer)
        if not u:hasdata("系统-正在选择选项") then
          timer:remove()
          callback()
        end
      end)
    end)
  end
  
  local function wrap_mwx_option(option, finished)
    local old_func = option.func
    
    function option.func(u2)
      local result = old_func(u2)
      mwxjiesuan(u2, result and result ~= "失败", medicine)
      if finished then
        finished()
      end
      return result
    end
  end
  
  local function process_once()
    local enhanced = first_enhanced
    first_enhanced = false
    if not enhanced and u:getdata(pending_enhanced_key) > 0 then
      enhanced = true
      u:changedata(pending_enhanced_key, -1)
    end
    local start_pools = {
      Vars_Mwx
    }
    local non_start_pools = get_mwx_non_start_pools(u)
    local has_start_option = 0 < #generateThreeRandomVars(u, start_pools, "冥王星", 1)
    
    local function try_start_limit_break()
      Count_MwxStartLimitBreak = Count_MwxStartLimitBreak or 0
      local chance = math.max(0.1, 0.25 * 0.5 ^ Count_MwxStartLimitBreak)
      if GetRandom100(chance) then
        Count_MwxStartLimitBreak = Count_MwxStartLimitBreak + 1
        u:changedata("系统-启动承载上限", 3)
        SendMsgAll(u:getplayername() .. "|cFF99CCFF精神觉醒过程中突破了自身极限(精神承载上限+3)|r")
        return true
      end
      return false
    end
    
    local function choose_mwx_start(finished)
      u:setdata("药水判定-禁止跳过")
      local ysb = guobodvarget({
        u = u,
        pools = start_pools,
        poolsstr = "冥王星",
        skip_medicinegetend = true,
        option_func_wrapper = function(option)
          wrap_mwx_option(option, finished)
        end
      })
      u:deldata("药水判定-禁止跳过")
      return ysb
    end
    
    local function choose_mwx_normal(finished)
      local pools = non_start_pools
      local start_chance = math.max(10, 100 * 0.5 ^ u:getdata("启动变异数量"))
      if has_start_option and GetRandom100(start_chance) then
        pools = {
          Vars_Mwx
        }
        for _, pool in ipairs(non_start_pools) do
          table.insert(pools, pool)
        end
      end
      u:setdata("药水判定-禁止跳过")
      local ysb = guobodvarget({
        u = u,
        pools = pools,
        poolsstr = "冥王星",
        skip_medicinegetend = true,
        option_func_wrapper = function(option)
          wrap_mwx_option(option, finished)
        end
      })
      u:deldata("药水判定-禁止跳过")
      return ysb
    end
    
    local ysb = false
    local non_start_pending = false
    if has_start_option and enhanced and u:getdata("系统-启动负载力") < u:getdata("系统-启动承载上限") then
      u:sendmessage("|cFF99CCFF强化药剂-启动变异获取|r")
      ysb = choose_mwx_start(finish_once)
    elseif has_start_option and u:getdata("系统-启动负载力") >= u:getdata("系统-启动承载上限") and try_start_limit_break() then
      ysb = choose_mwx_start(finish_once)
    end
    if not ysb then
      local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
      if b1 then
        non_start_pending = true
      end
    end
    if ysb then
      wait_until_mwx_choice_finished(function()
      end)
    elseif non_start_pending then
      ac.wait(100, function()
        if choose_mwx_normal(finish_once) then
          wait_until_mwx_choice_finished(function()
          end)
        else
          medicinegetend(u, false, medicine)
          finish_once()
        end
      end)
    else
      ac.wait(100, function()
        medicinegetend(u, false, medicine)
        finish_once()
      end)
    end
  end
  
  function finish_once()
    if u:getdata(pending_key) > 0 then
      u:changedata(pending_key, -1)
      process_once()
    else
      u:deldata(lock_key)
    end
  end
  
  process_once()
end

function MedicineActMwxWenda(u, medicine, item)
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
  if b1 then
    if not u:hasdata("系统-启示药水已使用") then
      u:setdata("系统-启示药水已使用")
      local ysb = guobodvarget({
        u = u,
        pools = {
          Vars_Mwx
        },
        poolsstr = "冥王星",
        skip_medicinegetend = true,
        option_func_wrapper = function(option)
          wrap_medicine_choice_end(option, medicine)
        end
      })
      if not ysb then
        medicinegetend(u, false, medicine)
      end
      return
    else
      b1 = false
      u:sendmessage("|cFF9999FF[系统]已使用过启示药水|r")
    end
  end
  medicinegetend(u, b1, medicine)
end

function MedicineActHuiyi(u, medicine, item)
  local lock_key = "回忆药剂-判定处理中"
  local pending_key = "回忆药剂-待判定次数"
  local pending_enhanced_key = "回忆药剂-待强化次数"
  local first_enhanced = u:hasdata("强化药剂-本次药剂强化")
  if u:hasdata(lock_key) then
    u:changedata(pending_key, 1)
    if first_enhanced then
      u:changedata(pending_enhanced_key, 1)
    end
    return
  end
  u:setdata(lock_key)
  local finish_once
  
  local function process_once()
    local enhanced = first_enhanced
    first_enhanced = false
    if not enhanced and u:getdata(pending_enhanced_key) > 0 then
      enhanced = true
      u:changedata(pending_enhanced_key, -1)
    end
    if u:hasdata("变异判定-窥星者") and u:hasdata("窥星-夜晚判定") and u:getdata("星座数") < 12 then
      local gl = 100 - 6 * u:getdata("星座数")
      if GetRandom100(gl) then
        u:sendmessage("|cFF6699FF星|r|cFF578CFF座|r|cFF4980FF被|r|cFF3A73FF激|r|cFF2C67FF活|r|cFF1D5AFF了|r")
        u:getdata("窥星-获取星座")()
      end
    end
    if u:hasdata("变异判定-星虹之眸") and u:hasdata("判定-星神之嗣") and not u:hasdata("变异判定-星神之嗣") and u:ishasshw() and u:ishasitem("I0CB") then
      AdvanceGet["星神之嗣"](u)
      local wp = u:getitem("I0CB")
      u:removeitem(wp)
      finish_once()
      return
    end
    local woodadd = 0
    local pity_key = "回忆药剂-觉醒保底概率"
    local pity_count_key = "回忆药剂-觉醒次数"
    local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
    if b1 then
      u:setdata(pity_key, 0)
      u:changedata(pity_count_key, 1)
      ac.wait(3000, function()
        local pools = VarsCiyuanPools(Vars_Lingjiejing, Vars_Ciyuan_Spe, Vars_Ciyuan_Shenhua, Vars_Huiyi_Dz)
        if u:hasdata("史尔特尔天赋-萨米的不灭心脏碎片") then
          table.insert(pools, Vars_Ciyuan_Yuanshi_Spe)
        end
        if u:hasdata("神器判定-至宝指环") or u:hasdata("特典-神秘兜帽男") then
          table.insert(pools, Vars_Ciyuan_Yuanshi)
          table.insert(pools, Vars_Ciyuan_Yuanshi_Spe)
        end
        local ysb
        local finish_after_choice = false
        if enhanced then
          u:setdata("药水判定-禁止跳过")
          ysb = guobodvarget({
            u = u,
            pools = pools,
            poolsstr = "次元",
            option_count = 3,
            skip_medicinegetend = true,
            option_func_wrapper = function(option)
              wrap_medicine_choice_end(option, medicine, function(u2)
                u2:changedata("传奇数量", 1)
              end, finish_once)
            end
          })
          u:deldata("药水判定-禁止跳过")
          finish_after_choice = ysb and ysb ~= "失败"
        else
          u:setdata("药水判定-禁止跳过")
          ysb = guobodvarget({
            u = u,
            pools = pools,
            poolsstr = "次元",
            option_count = 2,
            skip_medicinegetend = true,
            option_func_wrapper = function(option)
              wrap_medicine_choice_end(option, medicine, function(u2)
                u2:changedata("传奇数量", 1)
              end, finish_once)
            end
          })
          u:deldata("药水判定-禁止跳过")
          finish_after_choice = ysb and ysb ~= "失败"
        end
        if not ysb then
          u:changedata(pity_count_key, -1)
          medicinegetend(u, false, medicine)
        end
        if not finish_after_choice then
          finish_once()
        end
      end)
    else
      local add = 0.5
      u:changedata(pity_key, add)
      finish_once()
      ac.wait(3000, function()
        medicinegetend(u, false, medicine)
      end)
    end
  end
  
  function finish_once()
    if u:getdata(pending_key) > 0 then
      u:changedata(pending_key, -1)
      process_once()
    else
      u:deldata(lock_key)
    end
  end
  
  process_once()
end

function MedicineActLingjiejing(u, medicine, item)
  local sy = u.ownerid
  local cgl, b1 = medicineprobability(u, S2ID("I0GT"), medicine)
  u:addallstats(5)
  local xg = 1
  if 1 < u:getdata("精灵变异数量") then
    local all = 0
    local dxg = 1
    local count = u:getdata("精灵变异数量")
    for i = 1, count do
      all = all + dxg
      dxg = dxg / 2
    end
    xg = all / count
    if u:hasdata("隐藏职业-始源精灵") then
      xg = 1
    end
  end
  if u:hasdata("变异判定-伊芙利特") then
    local lv = u:getdata("伊芙利特-精灵阶级")
    if lv == 1 then
      u:addstr(4 * xg)
      ChangeValue(Damage_Element_Fire, sy, 0.01)
    end
    if lv == 2 then
      u:addstr(4 * xg)
      ChangeValue(Damage_Element_Fire, sy, 0.015)
    end
    if lv == 3 then
      u:addstr(6 * xg)
      ChangeValue(Damage_Element_Fire, sy, 0.02)
    end
    if lv == 4 then
      u:addstr(6 * xg)
      u:addallstats(2 * xg)
      ChangeValue(Damage_Element_Fire, sy, 0.03)
    end
    if lv == 5 then
      u:addstr(10 * xg)
      u:addallstats(5 * xg)
      ChangeValue(Damage_Element_Fire, sy, 0.05)
    end
  end
  if u:hasdata("变异判定-隐居者") then
    local lv = u:getdata("隐居者-精灵阶级")
    if lv == 1 then
      u:addint(4 * xg)
      ChangeValue(Damage_Element_Ice, sy, 0.01)
    end
    if lv == 2 then
      u:addint(4 * xg)
      ChangeValue(Damage_Element_Ice, sy, 0.015)
    end
    if lv == 3 then
      u:addint(6 * xg)
      ChangeValue(Damage_Element_Ice, sy, 0.02)
    end
    if lv == 4 then
      u:addint(6 * xg)
      u:addallstats(2 * xg)
      ChangeValue(Damage_Element_Ice, sy, 0.03)
    end
    if lv == 5 then
      u:addint(10 * xg)
      u:addallstats(5 * xg)
      ChangeValue(Damage_Element_Ice, sy, 0.05)
    end
  end
  if u:hasdata("变异判定-公主") then
    local lv = u:getdata("公主-精灵阶级")
    if lv == 1 then
      u:addallstats(2 * xg)
      ChangeValue(Damage_Element_Blank, sy, 0.005)
    end
    if lv == 2 then
      u:addallstats(3 * xg)
      ChangeValue(Damage_Element_Blank, sy, 0.01)
    end
    if lv == 3 then
      u:addallstats(4 * xg)
      ChangeValue(Damage_Element_Blank, sy, 0.02)
    end
    if lv == 4 then
      u:addallstats(6 * xg)
      ChangeValue(Damage_Element_Blank, sy, 0.03)
    end
    if lv == 5 then
      u:addallstats(12 * xg)
      ChangeValue(Damage_Element_Blank, sy, 0.05)
    end
  end
  if u:hasdata("变异判定-折纸天使") then
    local lv = u:getdata("天使-精灵阶级")
    if lv == 1 then
      u:addallstats(2 * xg)
      ChangeValue(Damage_Element_Light, sy, 0.01)
    end
    if lv == 2 then
      u:addallstats(3 * xg)
      ChangeValue(Damage_Element_Light, sy, 0.015)
    end
    if lv == 3 then
      u:addallstats(4 * xg)
      ChangeValue(Damage_Element_Light, sy, 0.02)
    end
    if lv == 4 then
      u:addallstats(6 * xg)
      ChangeValue(Damage_Element_Light, sy, 0.03)
    end
    if lv == 5 then
      u:addallstats(12 * xg)
      ChangeValue(Damage_Element_Light, sy, 0.05)
    end
  end
  if b1 then
    u:setdata("系统-灵结晶获取中")
    local pools = {
      Vars_Lingjiejing
    }
    local str = herogetvar(u, pools, "灵结晶")
    u:deldata("系统-灵结晶获取中")
    if str == "失败" then
      b1 = false
    end
  end
  medicinegetend(u, b1, medicine)
  if b1 then
    u:changedata("传奇数量", 1)
  end
end

function MedicineActShalujiejing(u, medicine, item)
  local sy = u.ownerid
  u:changemaxhp(250)
  if u:hasdata("八重樱-杀意形态") then
    u:changedata("狂化值", 1)
  end
  if u:hasdata("变异判定-古明地恋") then
    u:changedata("古明地恋-杀戮结晶使用次数", 1)
    if not u:hasdata("神化判定-古明地恋2") and u:getdata("古明地恋-杀戮结晶使用次数") >= 5 and (u:ishasshw() or u:hasdata("恋恋-神化位使用")) then
      AdvanceGet["古明地恋神化2"](u)
    end
  end
  local cgl, b1 = medicineprobability(u, S2ID("I09P"), medicine)
  if b1 then
    local pools = {
      Vars_Shalujiejing
    }
    local str = herogetvar(u, pools, "杀戮结晶")
    if str == "失败" then
      b1 = false
    end
  end
  medicinegetend(u, b1, medicine)
  if b1 then
    u:changedata("传奇数量", 1)
  end
end

function MedicineActHuanhaijiejing(u, medicine, item)
  local sy = u.ownerid
  if u:hasdata("属性-深海猎人") then
    u:changexueroutonghua(GetRandomReal(0.5, 1.5))
  end
  local b2 = false
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), MEDICINE_HUIYI)
  if b1 then
    b2 = true
    local pools = {
      Vars_Ciyuan_Shenhai
    }
    local str = herogetvar(u, pools, "次元")
    if str == "失败" then
      b1 = false
    end
  end
  medicinegetend(u, b1, MEDICINE_HUIYI)
  if b1 then
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 10)
    u:changedata("传奇数量", 1)
  elseif b2 then
    u:sendmessage("|cFF66CCFF你|r|cFF5EC1FF吸|r|cFF56B7FF收|r|cFF4EACFF了|r|cFF47A1FF幻|r|cFF3F97FF海|r|cFF378CFF结|r|cFF2F81FF晶|r|cFF2776FF中|r|cFF1F6CFF的|r|cFF1861FF力|r|cFF1056FF量|r")
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 10)
  else
    u:sendmessage("|cFF66CCFF你|r|cFF5BBDFF陷|r|cFF4FADFF入|r|cFF449EFF了|r|cFF398EFF幻|r|cFF2D7FFF境|r|cFF226FFF之|r|cFF1760FF中|r")
    ac.timer(1000, 180, function()
      if GetRandom100(25) then
        u:effectadd("Abilities\\Spells\\Undead\\Sleep\\SleepSpecialArt.mdl", "head")
      end
      u:losshp(u, 0, 10)
      u:curetili(-1)
    end)
  end
end

function MedicineActYuanshishenjingji(u, medicine, item)
  local sy = u.ownerid
  ac.timer(10000, 10, function()
    local nd = u:getdata("系统-血液源石结晶密度")
    local add = 0.1 + 0.001 * nd
    u:changeysnd(add)
  end)
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), MEDICINE_HUIYI)
  if b1 then
    local pools = {
      Vars_Ciyuan_Yuanshi,
      Vars_Ciyuan_Yuanshi_Spe
    }
    local str = herogetvar(u, pools, "源石神经剂")
    if str == "失败" then
      b1 = false
    end
  end
  medicinegetend(u, b1, MEDICINE_HUIYI)
  if b1 then
    u:changedata("传奇数量", 1)
  end
end

function MedicineActNiuqu(u, medicine, item)
  local sy = u.ownerid
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), MEDICINE_HUIYI)
  if b1 then
    local pools = {
      Vars_Ciyuan_Niuqu
    }
    local str = herogetvar(u, pools, "扭曲药剂")
    if str == "失败" then
      b1 = false
    end
  end
  medicinegetend(u, b1, MEDICINE_HUIYI)
  if b1 then
    u:changedata("传奇数量", 1)
  end
end

function MedicineActLongmenshi(u, medicine, item)
  local sy = u.ownerid
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), MEDICINE_HUIYI)
  if b1 then
    local pools = {
      Vars_Ciyuan_Longmenshi
    }
    local str = herogetvar(u, pools, "龙门石")
    if str == "失败" then
      b1 = false
    end
  end
  medicinegetend(u, b1, MEDICINE_HUIYI)
  if b1 then
    u:changedata("传奇数量", 1)
  end
end

function MedicineActRengemianju(u, medicine, item)
  local sy = u.ownerid
  local b1 = true
  local pools = {
    Vars_Yugonglian_Jiamian
  }
  local str = herogetvar(u, pools, "次元")
  if str == "失败" then
    b1 = false
  end
  if not b1 then
    u:sendmessage("|cFF6699FF但是没有任何效果|r")
  end
end

function MedicineActZhenyao(u, medicine, item)
  local sy = u.ownerid
  ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.005 * u:getdata("妖咒数量")))
  if u:hasdata("血统判定-妖魔之子") then
    if GetRandom100(50) then
      u:addrandomstats(1)
    else
      u:addrandomdamage(0.6)
    end
  end
  if u:hasdata("变异判定-祢豆子") then
    u:addstr(1)
  end
  if u:hasdata("变异判定-少名针妙丸") then
    u:addrandomstats(1)
  end
  if u:hasdata("变异判定-雪女") then
    u:addint(1)
    if u:hasdata("神化判定-雪女") then
      u:addrandomstats(1)
    end
  end
  if u:hasdata("变异判定-滑头鬼之孙") then
    u:changedata("滑头鬼之孙-壶数量", 1)
  end
  local sj = GetRandomInt(1, 4)
  if sj == 1 then
    u:sendmessage("|cFFFF99CC壶中的妖气使你变得更强了(降低1点属性并提升0.2%伤害加成)|r")
    ChangeValue(DamageSystem_Shjc, sy, 0.002)
    u:addrandomstats(-1)
  end
  if sj == 2 then
    u:sendmessage("|cFFFF99CC壶中的妖气使你更强壮了(降低2点属性并提升100生命上限)|r")
    u:changemaxhp(100)
    u:addrandomstats(-2)
  end
  if sj == 3 then
    u:sendmessage("|cFFFF99CC壶中的妖气使你精力充沛(降低3点属性并提升1点魔力上限)|r")
    u:changemaxmp(1)
    u:addrandomstats(-3)
  end
  if sj == 4 then
    local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
    if b1 and b1 and u:getdata("御守-剩余次数") > 0 then
      b1 = false
      u:changedata("御守-剩余次数", -1)
      u:sendmessage("|cFFFF0066御守-抵挡诅咒|r")
    end
    if b1 then
      local pools = {
        Vars_Zhenyao
      }
      local str = herogetvar(u, pools, "镇妖壶")
      if str == "失败" then
        b1 = false
      end
    end
    medicinegetend(u, b1, medicine)
    if b1 then
      u:changedata("妖咒数量", 1)
    end
  end
end

function MedicineActFengmo(u, medicine, item)
  local sy = u.ownerid
  u:addrandomstats(math.floor(0.5 * u:getdata("魔封数量")))
  if u:hasdata("血统判定-妖魔之子") then
    if GetRandom100(50) then
      u:addrandomstats(1)
    else
      u:addrandomdamage(0.6)
    end
  end
  if u.type == HeroType["爱丽丝"] and u:ishasitem("I0GC") and u:getluckrandom(0.5) then
    u:sendmessage("|cFFCC0000魔导书活化了|r")
    u:removeitem("I0GC")
    u:additem("I0GE")
  end
  local sj = GetRandomInt(1, 4)
  if sj == 1 then
    u:sendmessage("|cFFCC3366壶中的魔气使你变得更强了(提升1点属性与0.1%伤害加成)|r")
    ChangeValue(DamageSystem_Shjc, sy, 0.001)
    u:addrandomstats(1)
  end
  if sj == 2 then
    u:sendmessage("|cFFCC3366壶中的魔气使你戾气更加浓重了(提升2点属性与2%额外受伤)|r")
    ChangeValue(DamageSystem_Sszengjia, sy, 0.02)
    u:addrandomstats(2)
  end
  if sj == 3 then
    u:sendmessage("|cFFCC3366壶中的魔气汲取了你的生命力(提升3点属性并降低100生命上限)|r")
    u:changemaxhp(-100)
    u:addrandomstats(3)
  end
  if sj == 4 then
    local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
    if b1 and b1 and u:getdata("御守-剩余次数") > 0 then
      b1 = false
      u:changedata("御守-剩余次数", -1)
      u:sendmessage("|cFFFF0066御守-抵挡诅咒|r")
    end
    if b1 then
      local pools = {
        Vars_Fengmo
      }
      local str = herogetvar(u, pools, "封魔壶")
      if str == "失败" then
        b1 = false
      end
    end
    medicinegetend(u, b1, medicine)
    if b1 then
      u:changedata("魔封数量", 1)
    end
  end
end

function MedicineActLns(u, medicine, item)
  local cgl, b1 = medicineprobability(u, S2ID("A04W"), medicine)
  if b1 then
    local pools = {
      Vars_Lns
    }
    local gd, str
    if (u:hasdata("灵梦-月下的荒御神一阶") or u:hasdata("两仪式天赋-视象干涉")) and not u:hasdata("变异判定-两仪式净眼") then
      gd = "两仪式净眼"
    end
    if u:hasdata("志贵天赋-退魔末裔") and not u:hasdata("变异判定-退魔眼") then
      gd = "退魔眼"
    end
    if u:hasdata("千咲天赋-命定之弦") and not u:hasdata("变异判定-解弦之眼") then
      gd = "解弦之眼"
    end
    if gd then
      str = herogetvar(u, pools, "鲁纳斯", gd)
    else
      str = herogetvar(u, pools, "鲁纳斯")
    end
    if str == "失败" then
      b1 = false
    end
  end
  medicinegetend(u, b1, medicine)
end
