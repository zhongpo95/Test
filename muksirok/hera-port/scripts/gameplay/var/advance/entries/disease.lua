-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local AdvanceHelpers = require("gameplay.var.advance.helpers")

local function refresh_divinity_load(u)
  local ccz = {
    0.05,
    0.25,
    0.5,
    0.75
  }
  if Nandu_Shenzhao then
    ccz = {
      0.01,
      0.1,
      0.25,
      0.75
    }
  end
  local cc = u:getdata("系统-神力承载") - u:getdata("系统-神力承载上限")
  if 15 < cc then
    local z = ccz[1]
    if u:getdata("无序之力-影响深度") ~= z then
      u:sendmessage("|cFF990000[力量无序化]:当前惩罚" .. math.floor((1 - z) * 100) .. "%|r")
    end
    u:setdata("无序之力-影响深度", z)
  elseif 10 < cc then
    local z = ccz[2]
    if u:getdata("无序之力-影响深度") ~= z then
      u:sendmessage("|cFF990000[力量无序化]:当前惩罚" .. math.floor((1 - z) * 100) .. "%|r")
    end
    u:setdata("无序之力-影响深度", z)
  elseif 5 < cc then
    local z = ccz[3]
    if u:getdata("无序之力-影响深度") ~= z then
      u:sendmessage("|cFF990000[力量无序化]:当前惩罚" .. math.floor((1 - z) * 100) .. "%|r")
    end
    u:setdata("无序之力-影响深度", z)
  elseif 0 < cc then
    local z = ccz[4]
    if u:getdata("无序之力-影响深度") ~= z then
      u:sendmessage("|cFF990000[力量无序化]:当前惩罚" .. math.floor((1 - z) * 100) .. "%|r")
    end
    u:setdata("无序之力-影响深度", z)
  else
    u:deldata("无序之力-影响深度")
  end
end

RegisterAdvanceEntries({
  ["无序之力"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-无序之力"
    if not u:hasdata(str) then
      u:setdata(str)
      u:sendmessage("|cFF990000力量无序化(神力承载超过上限)|r")
      AdvanceHelpers.ylyzuzhou(u)
      if Nandu_Shenzhao then
        u:uivar_add({
          keyname = "无序之力",
          keytype = "疾病栏",
          text = "|cFFFFCC33无|r|cFFF5A329序|r|cFFEB7A1F之|r|cFFE05214力|r\n|cFFF5A329获取回忆力量概率降低95%\n降低伤害能力与造成的生命损耗|r\n|cFFFFCC33[0~5点]25%|r\n|cFFF5A329[5~10点]75%|r\n|cFFEB7A1F[10~15点]90%|r\n|cFFE05214[15点以上]99%|r",
          icon = "Disease_Wuxu_2"
        })
      else
        u:uivar_add({
          keyname = "无序之力",
          keytype = "疾病栏",
          text = "|cFFFFCC33无|r|cFFF5A329序|r|cFFEB7A1F之|r|cFFE05214力|r\n|cFFF5A329获取回忆力量概率降低95%\n降低伤害能力与造成的生命损耗|r\n|cFFFFCC33[0~5点]25%|r\n|cFFF5A329[5~10点]50%|r\n|cFFEB7A1F[10~15点]75%|r\n|cFFE05214[15点以上]95%|r",
          icon = "Disease_Wuxu_2"
        })
      end
    end
    refresh_divinity_load(u)
  end,
  ["精神暴走"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-精神暴走"
    if not u:hasdata(str) then
      u:setdata(str)
      u:sendmessage("|cFF990000患上了新的疾病……(精神变异超过上限)|r")
      AdvanceHelpers.ylyzuzhou(u)
      u:uivar_add({
        keyname = "精神暴走",
        keytype = "疾病栏",
        text = "|cFF336699精神暴走|r\n|cFF336699根据超出的精神承载力获得惩罚\n提升[超出数量*2.5%]变异成功率惩罚(乘算)\n提升[超出数量*10%]冥王星变异成功率惩罚(乘算)\n受到伤害时被暴击概率提升[超出数量*5%],被暴击伤害提升[超出数量*10%]\n每秒有概率精神崩坏,概率受超出精神力影响\n崩坏时无法造成暴击与特效伤害,同时被暴击率提升至100%,持续10秒|r",
        icon = "Disease_Jingshenbaozou_2"
      })
    end
  end,
  ["心智混乱"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-心智混乱"
    if not u:hasdata(str) then
      u:setdata(str)
      u:sendmessage("|cFF990000患上了新的疾病……|r")
      AdvanceHelpers.ylyzuzhou(u)
      u:uivar_add({
        keyname = "心智混乱",
        keytype = "疾病栏",
        text = "|cFF336699心智混乱|r\n|cFF336699变异补正会变成随机词条的补正\n每秒有概率心智混乱,概率与时长受精神承载超出数量影响\n心智混乱时混乱且所有伤害只造成1点伤害|r",
        icon = "Disease_Xinzhihunluan_2"
      })
    end
  end,
  ["崩坏躯壳"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-崩坏躯壳"
    if not u:hasdata(str) then
      u:setdata(str)
      u:sendmessage("|cFF990000患上了新的疾病……(以太身体变异超过上限)|r")
      AdvanceHelpers.ylyzuzhou(u)
      local ss = 0
      ac.loop(1000, function()
        local count = u:getdata("局部身体变异数量") - u:getdata("局部身体承载上限")
        if count <= 0 then
          count = 0
        end
        local count2 = u:getdata("全身变异数量") - u:getdata("全身身体承载上限")
        if count2 <= 0 then
          count2 = 0
        end
        count = count + count2 * 4
        if u:hasdata("邪王真眼-圣人之躯") then
          count = count * 0.5
        end
        if 0 < count then
          local gl = 0.1 * count
          if GetRandom100(gl) and not Boolean_Jinselingyu and not u:hasdata("崩坏躯壳发作冷却") then
            u:settimedata("崩坏躯壳发作冷却", 30)
            u:settimedata("崩坏躯壳-抑制恢复", 15)
            u:sendmessage("|cFF990000你的疾病发作了-崩坏躯壳|r")
            if not u:hasdata("神器判定-医疗箱") then
              local dehp = GetRandomReal(1, 100)
              u:changekyx(10)
              if dehp >= u:getperhp() then
                u:kill()
                SendMsgAll(u:getplayername() .. "|cFF990000死于身体崩坏|r")
              else
                u:losshp(u, 0, dehp)
              end
            end
          end
        end
        u:setdata("崩坏躯壳-超出数量", count)
      end)
      u:uivar_add({
        keyname = "崩坏躯壳",
        keytype = "疾病栏",
        text = "|cFF990000崩坏躯壳|r\n|cFF990000根据超出的局部身体变异和全身变异获得惩罚(全身变异视为4个局部)\n提升[超出数量*10%]抗药性惩罚\n提升[超出数量*10%]抗药性获取\n抗药性降低效率降低[超出数量*5%](乘算)\n每秒有概率身体崩坏,概率受超出的局部身体变异与全身变异影响\n崩坏时提升10%抗药性并损耗1~100%最大生命值(不足时即死)\n并在接下来15秒内无法恢复生命值\n疾病最小触发冷却30秒|r",
        icon = "Disease_Benghuaiquqiao"
      })
    end
  end,
  ["复瞳症"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-复瞳症"
    if not u:hasdata(str) then
      u:setdata(str)
      u:sendmessage("|cFF990000患上了新的疾病……(瞳变异超出上限)|r")
      AdvanceHelpers.ylyzuzhou(u)
      u:setdata("复瞳症-伤害减少", 0)
      u:addstexiao("复瞳症", "BOSS减伤计算", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        local down = 1 - u:getdata("复瞳症-伤害减少")
        if down <= 0.01 then
          down = 0.01
        end
        info.damage = info.damage * down
      end)
      u:addstexiao("复瞳症", "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("复瞳症-失明暴击减少") then
          info.bjl = info.bjl - 1000
        end
      end)
      local ss = 0
      ac.loop(1000, function()
        u:changedata("复瞳症-伤害减少", -ss)
        local count = u:getdata("瞳变异数量")
        if count > u:getdata("瞳承载上限") then
          ss = 0.05 * count
          if not u:hasdata("复瞳症-失明") then
            local gl = 0.2 * count
            if GetRandom100(gl) then
              u:sendmessage("|cFF990000你的疾病发作了-复瞳症|r")
              u:settimedata("复瞳症-失明", 3)
              if not u:hasdata("复瞳症-失明暴击减少") then
                u:settimedata("复瞳症-失明暴击减少", 60)
                u:changetimedata("复瞳症-伤害减少", 0.5, 60)
              end
              if not u:hasdata("神器判定-医疗箱") then
                local cs = 0
                local x, y = u:getxy()
                local fog = CreateFogModifierRadius(u.owner, FOG_OF_WAR_MASKED, x, y, 800, false, true)
                FogModifierStart(fog)
                ac.wait(299, function()
                  FogModifierStop(fog)
                  DestroyFogModifier(fog)
                end)
                ac.loop(300, function(timer)
                  cs = cs + 1
                  local x, y = u:getxy()
                  local fog = CreateFogModifierRadius(u.owner, FOG_OF_WAR_MASKED, x, y, 800, false, true)
                  FogModifierStart(fog)
                  ac.wait(299, function()
                    FogModifierStop(fog)
                    DestroyFogModifier(fog)
                  end)
                  if cs == 9 then
                    timer:remove()
                  end
                end)
              end
            end
          end
        else
          ss = 0
        end
        u:changedata("复瞳症-伤害减少", ss)
      end)
      u:uivar_add({
        keyname = "复瞳症",
        keytype = "疾病栏",
        text = "|cFF990000复瞳症候群|r\n|cFF990000每秒低概率双目致盲,概率受瞳变异数量影响\n致盲时失去视野3秒,并在60秒内降低50%伤害同时无法触发暴击\n降低[5%*瞳变异数量]伤害|r",
        icon = "Disease_Futongzheng"
      })
    end
  end,
  ["心室衰竭"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-心室衰竭"
    if not u:hasdata(str) then
      u:setdata(str)
      u:sendmessage("|cFF990000患上了新的疾病……(心脏变异超出上限)|r")
      AdvanceHelpers.ylyzuzhou(u)
      u:setdata("心室衰竭-机制受伤", 0)
      local ss = 0
      ac.loop(1000, function()
        u:changedata("心室衰竭-机制受伤", -ss)
        local count = u:getdata("心脏变异数量")
        if count > u:getdata("心脏承载上限") then
          local cz = count - u:getdata("心脏承载上限")
          ss = 0.1 * count
          if not u:hasdata("心室衰竭-心肺停止") then
            local gl = 0.2 * cz
            if u:hasdata("神器判定-索林原虫虫后") then
              gl = 0
            end
            if GetRandom100(gl) then
              u:sendmessage("|cFF990000你的疾病发作了-心室衰竭|r")
              u:settimedata("心室衰竭-心肺停止", 3)
              u:changetimedata("心室衰竭-机制受伤", 0.5, 60)
              if not u:hasdata("神器判定-医疗箱") then
                u:buffset(u.handle, 3, "暂停")
                local cs = 0
                ac.loop(1000, function(timer)
                  cs = cs + 1
                  local dehp = 0.02 * u:getmaxhp()
                  if dehp >= u:gethp() then
                    u:losshp(u, dehp)
                    u:kill()
                  else
                    u:losshp(u, dehp)
                  end
                  if cs == 60 then
                    timer:remove()
                  end
                end)
              end
            end
          end
        else
          ss = 0
        end
        u:changedata("心室衰竭-机制受伤", ss)
      end)
      u:uivar_add({
        keyname = "心室衰竭",
        keytype = "疾病栏",
        text = "|cFF990000过载衰竭的心室|r\n|cFF990000每秒低概率心肺停止,概率受心脏数量影响\n提升[10%*心脏数量]机制受伤\n心脏停止跳动时无法行动3秒,同时在接下来的60秒提升50%机制受伤,每秒损耗2%最大生命值(致死)|r",
        icon = "Disease_Xinshishuaijie"
      })
    end
  end
})
