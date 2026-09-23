-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local WaveState = require("gameplay.monster.wave_state")
local player = require("jh.ac.player")
local zhenhongbattle1 = false
local zhenhongbattle2 = false
local zhenhongbattle3 = false
local strz = {
  {
    name = "视为100杀敌",
    func = function(u)
      local sy = u.ownerid
      local count = 100
      if u:hasdata("变异判定-普利凯特") then
        count = 150
      end
      ac.timer(1, count, function()
        KillCount[sy] = KillCount[sy] + 1
        monsterrewardget1(u.handle, BOSS_DEATH)
        monsterrewardget2(u.handle, BOSS_DEATH)
      end)
      YisiSystem.chat({
        u = u,
        text = "选择成功"
      })
    end
  },
  {
    name = "3天赋点",
    func = function(u)
      local sy = u.ownerid
      local count = 3
      if u:hasdata("变异判定-普利凯特") then
        count = 4
      end
      TalentCode[sy] = TalentCode[sy] + count
      YisiSystem.chat({
        u = u,
        text = "选择成功"
      })
    end
  },
  {
    name = "降低10%抗药性",
    func = function(u)
      local sy = u.ownerid
      local count = -10
      if u:hasdata("变异判定-普利凯特") then
        count = -15
      end
      u:changekyx(count)
      YisiSystem.chat({
        u = u,
        text = "选择成功"
      })
    end
  },
  {
    name = "5个次元匣",
    func = function(u)
      local sy = u.ownerid
      local count = 5
      if u:hasdata("变异判定-普利凯特") then
        count = 7
      end
      for i = 1, count do
        u:additem("I00X")
      end
      YisiSystem.chat({
        u = u,
        text = "选择成功"
      })
    end
  },
  {
    name = "1000生命上限",
    func = function(u)
      local sy = u.ownerid
      local count = 1000
      if u:hasdata("变异判定-普利凯特") then
        count = 1500
      end
      u:changemaxhp(count)
      YisiSystem.chat({
        u = u,
        text = "选择成功"
      })
    end
  },
  {
    name = "5%伤害加成",
    func = function(u)
      local sy = u.ownerid
      local count = 0.5
      if u:hasdata("变异判定-普利凯特") then
        count = 0.75
      end
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * count)
      YisiSystem.chat({
        u = u,
        text = "选择成功"
      })
    end
  },
  {
    name = "20全属性",
    func = function(u)
      local sy = u.ownerid
      local count = 20
      if u:hasdata("变异判定-普利凯特") then
        count = 30
      end
      u:addallstats(count)
      YisiSystem.chat({
        u = u,
        text = "选择成功"
      })
    end
  }
}
local mrkq = false
local timerendbiaoji = false

local function shilipojianshen(u)
  u:setdata("隐藏职业-剑神出世")
  hideproshow(u.handle)
  u:changedata("传奇数量", 1)
  local pools = VarsCiyuanPools()
  u:setdata("系统-特殊获取中")
  local str = herogetvar(u.handle, pools, "次元", "李逍遥")
  u:deldata("系统-特殊获取中")
end

local slczcs = 0

local function init()
  attack_next = ac.loop(2000, function()
    local z = 5 + DebugNumofMonster
    if Nandu_Choose >= 3 then
      z = 10 + DebugNumofMonster
    end
    local run = true
    if z < LeftNumofMonster or z < AllNumofMonster or Group_Counts(Jianta_Jingying) > 0 or Movie_Boolean or BossBattle or ExtraBattle then
      run = false
    end
    if Boolean_Likeqifei then
      run = true
    end
    if not run then
      return
    end
    if not TestMode and not mrkq then
      local b = false
      if (Nandu_Choose >= 4 or Boolean_Morihuanjing) and (5 <= Nandu_Choose and Stage >= 1 or Stage >= 2) then
        b = true
      end
      if b then
        mrkq = true
        require("gameplay.monster.environmentnew")
      end
    end
    if Stage <= Stage_boss[4] or Boolean_TestMode and Stage <= 14 then
      StopWaveTimeLimitTimer()
      Boolean_GuoboInterval = true
      require("hera_gameplay_diagnostic").monster("WAVE_ADVANCE_BEGIN", {})
      Stage = Stage + 1
      require("hera_gameplay_diagnostic").monster("WAVE_ADVANCE_END", {})
      if Mode_Wangshiletu and WsltButton.p6 then
        WsltButton.p6.off:show()
      end
      local t = WaveState.get_interval_time()
      if Boolean_TestMode and Stage > 14 then
        t = t + 100000
        SendMsgAll("|cFF7DBEF1挑战BOSS已经全部击败,感谢游玩", 3600)
      else
        SendMsgAll("|cFF7DBEF1" .. math.floor(t) .. "秒后下一波")
        SendMsgAll("|cFF7DBEF1休息时间内交互建筑速度翻倍")
      end
      if Stage > 1 or Stage == 1 and Nandu_Choose == 1 then
        ZBButton:show()
      end
      attack_next:pause()
      timerendbiaoji = true
      local zhiliu = false
      local tipcount = 0
      WaveState.show("休息时间", t)
      ac.loop(1000, function(timer)
        if Movie_Boolean then
          WaveState.show("休息时间", t)
          return
        end
        t = t - 1
        WaveState.show("休息时间", t)
        local b = false
        for i = 1, 6 do
          if player[i]:isplayer() then
            if not Xuanze[i] or not PlayerReady[i] then
              b = false
              break
            end
            b = true
          end
        end
        if Boolean_TestMode and Stage > 14 then
          b = false
        end
        if b and 1 <= t then
          t = 1
          require("hera_gameplay_diagnostic").phase("ALL_READY", {})
          SendMsgAll("|cFF6699FF[系统]所有玩家准备完毕")
          ZBButton:hide()
        end
        if Group_Counts(Group_PlayHero) > 0 then
        elseif t <= 1 then
          t = 1
        end
        if not Mode_Dabamoshi and not ExBossBattle and t <= 0 then
          require("hera_gameplay_diagnostic").phase("ROUND_START_BEGIN", {})
          WaveState.hide()
          Boolean_GuoboInterval = false
          JiangLiShengyu = 75
          if Stage > 8 then
            JiangLiShengyu = JiangLiShengyu * 0.5
          end
          if Mode_Wangshiletu then
            JiangLiShengyu = JiangLiShengyu * 2
          end
          require("hera_gameplay_diagnostic").phase("BUILD_CLEANUP_BEGIN", {})
          ForGroupLuaNew(Group_PlanetBuild, function(xq)
            xq:groupremove(Group_PlanetBuild)
            xq:groupremove(PlanetBuild_Wajuedian)
            if xq:hasdata("贸易箱-标价") then
              local text = xq:getdata("贸易箱-标价")
              TimerDestroyTextTag(0, text)
              xq:deldata("贸易箱-标价")
            end
            xq:remove()
          end)
          require("hera_gameplay_diagnostic").phase("BUILD_CLEANUP_END", {})
          require("hera_gameplay_diagnostic").phase("ITEM_CLEANUP_BEGIN", {})
          EnumItemsInRectBJ(RECT_PlayArea, function()
            local wp = GetEnumItem()
            local type = GetItemTypeId(wp)
            if type == S2ID("I0NJ") or type == S2ID("I0NK") or type == S2ID("I0NL") then
              RemoveItemLua(wp)
            end
          end)
          require("hera_gameplay_diagnostic").phase("ITEM_CLEANUP_END", {})
          require("hera_gameplay_diagnostic").phase("HERO_RELOCATE_BEGIN", {})
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if not xq:isinrect(RECT_PlayArea) then
              xq:setmapxy(-4169, 15862)
            end
          end)
          require("hera_gameplay_diagnostic").phase("HERO_RELOCATE_END", {})
          require("hera_gameplay_diagnostic").phase("PLANET_REFRESH_BEGIN", {})
          planetflashset()
          require("hera_gameplay_diagnostic").phase("PLANET_REFRESH_END", {})
          Boolean_IsFlying = false
          Boolean_Zhiliu = false
          Boolean_Likeqifei = false
          zhiliu = false
          for i = 1, 6 do
            PlayerReady[i] = false
          end
          ZBButton:hide()
          attack_next:resume()
          require("hera_gameplay_diagnostic").monster("SPAWN_RESUME_BEGIN", {})
          attack_start:resume()
          require("hera_gameplay_diagnostic").monster("SPAWN_RESUME_END", {})
          require("hera_gameplay_diagnostic").monster("STAGESET_BEGIN", {})
          stageset()
          require("hera_gameplay_diagnostic").monster("STAGESET_END", {})
          require("hera_gameplay_diagnostic").phase("WAVE_TIMER_BEGIN", {})
          StartWaveTimeLimitTimer()
          require("hera_gameplay_diagnostic").phase("WAVE_TIMER_END", {})
          if Mode_Keyan then
            Keyan_JiesuoJishu = Keyan_JiesuoJishu + 1
            local max = 5
            if Nandu_Shenzhao then
              max = 3
            elseif 5 <= Nandu_Choose then
              max = 4
            end
            if max <= Keyan_JiesuoJishu then
              Keyan_JiesuoJishu = 0
              keyanjiesuo()
            end
          end
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy2 = xq.ownerid
            require("hera_gameplay_diagnostic").phase("HERO_ROUND_EFFECTS_BEGIN", {slot=sy2})
            StexiaoFunc({
              text = "波数开始时效果",
              u = xq,
              sy = sy2
            })
            require("hera_gameplay_diagnostic").phase("HERO_ROUND_EFFECTS_END", {slot=sy2})
            if Stage ~= 1 then
              xq:setdata("往世乐土-取消消耗积分", 10)
              if Mode_Wangshiletu then
                xq:sendmessage("|cFFFF99FF[往世乐土]取消次数与消耗重置|r")
              end
              local dcs = {
                5,
                5,
                5,
                3,
                2,
                1
              }
              xq:setdata("往世乐土-剩余刷新次数", dcs[Nandu_Choose])
              if Nandu_Shenzhao then
                xq:setdata("往世乐土-剩余刷新次数", 1)
              end
              if Mode_Wangshiletu then
                xq:setdata("PSHOP_REFRESH_COUNT", 0)
              end
            end
          end)
          require("hera_gameplay_diagnostic").phase("ROUND_START_END", {})
          timer:remove()
        end
      end)
      if Stage > 1 or Stage == 1 and Nandu_Choose == 1 then
        if Nandu_Choose >= 4 and Stage == 3 then
          local npc = getunit(NPC_ZHENHONG)
          npc:playseensound(BOSS_Zhenhong_Chuansong)
          local dx, dy = npc:getxy()
          EffectcreateArgs({
            effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
            x = dx,
            y = dy
          })
          ShowUnit(NPC_ZHENHONG, false)
        end
        SendMsgAll("|cFF7DBEF1选择过波奖励(3秒后获取)")
        Count_HuanxiangguaiMax = 5 + 5 * Count_Huanxiangxiangshuliang
        if GetRandom100(Quanju_Shenqidiaoluo) then
          Quanju_Shenqiboolean = true
          Quanju_Shenqidiaoluo = 22
        else
          Quanju_Shenqiboolean = false
          Quanju_Shenqidiaoluo = Quanju_Shenqidiaoluo + 22
        end
        slczcs = slczcs + 1
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy2 = xq.ownerid
          if Nandu_Choose <= 3 then
            xq:changekyx(-5)
          end
          if Stage == 2 then
            if xq:hasdata("花瓣-拿玛") then
              xq:sendmessage("|cFF666666拿玛|r|cFF858585 - 物质主义|r")
              xq:additem(Mainmedicine[GetRandomInt(1, #Mainmedicine)])
            end
            if xq:hasdata("原质-王国") then
              local x, y = xq:getxy()
              local wp = CreateItemLua("I0N0", x, y)
              SetData(wp, "所属玩家", xq.owner)
              xq:addspeitem(wp)
            end
          end
          if xq:hasdata("德丽莎新年选择") then
            xq:changedata(xq:getdata("德丽莎新年选择") .. "变异补正", 5)
          end
          if slczcs <= 20 then
            xq:changedata("系统-神力承载上限", 1)
          end
          do
            local lv = xq:getlevel()
            local needexp = (lv + 1) * 100
            xq:addexp(needexp)
          end
          StexiaoFunc({
            text = "过波时效果",
            u = xq,
            sy = sy2
          })
          RLChoose_Guobo(xq)
        end)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:changhuanqiankuan()
        end)
      end
      if Stage <= 1 then
        System_Ciyuanneng = System_Ciyuanneng + 240
      else
        System_Ciyuanneng = System_Ciyuanneng + 120
      end
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy = xq.ownerid
        xq:setdata("往世乐土-扒窃失败率波数增加", 0)
        xq:setdata("往世乐土-购买次数-特殊物品", 0)
        xq:setdata("往世乐土-购买次数-稀有武器", 0)
        xq:setdata("往世乐土-购买次数-稀有枪械", 0)
        xq:deldata("往世乐土-P6首次已购买")
        if xq:hasdata("隐藏职业-十里坡剑神") and not xq:hasdata("隐藏职业-剑神出世") then
          if Stage == 2 and Time_M >= 15 then
            shilipojianshen(xq)
          end
          if Stage == Stage_boss[1] + 1 and (Time_M >= 40 or KillCumCount[sy] >= 1500) then
            shilipojianshen(xq)
          end
        end
        if xq:hasdata("隐藏职业-路人女主") and Stage >= Stage_boss[4] and not xq:hasdata("隐藏职业-路人女主揭露") then
          xq:changedata("传奇数量", 1)
          local pools = VarsCiyuanPools()
          local str = herogetvar(xq.handle, pools, "次元", "加藤惠")
        end
        if xq:hasdata("变异判定-加藤惠") then
          local count = GetRandomInt(1, 8)
          if count == 1 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升2神力承载上限|r")
            xq:changedata("系统-神力承载上限", 2)
          end
          if count == 2 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升3启动承载上限|r")
            xq:changedata("系统-启动承载上限", 3)
          end
          if count == 3 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升1启动承载上限|r")
            xq:changedata("系统-启动承载上限", 1)
          end
          if count == 4 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升2启动承载上限|r")
            xq:changedata("系统-启动承载上限", 2)
          end
          if count == 5 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升1身体承载上限|r")
            xq:changedata("身体承载上限", 1)
          end
          if count == 6 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升2身体承载上限|r")
            xq:changedata("身体承载上限", 2)
          end
          if count == 7 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升天赋点|r")
            ChangeValue(TalentCode, sy, 1)
          end
          if count == 8 then
            xq:sendmessage("|cFFFFCCFF加藤惠-提升等级|r")
            xq:addlevel(5)
          end
        end
        if xq:hasdata("隐藏职业-转生者") and not xq:hasdata("隐藏职业-转生者已获取记忆") and Stage >= xq:getdata("隐藏职业-转生时间") then
          xq:setdata("隐藏职业-转生者已获取记忆")
          hideproshow(xq.handle)
          for i = 1, xq:getdata("隐藏职业-转生记忆数量") do
            local b1 = true
            local pools = VarsCiyuanPools(Vars_Lingjiejing, Vars_Ciyuan_Shenhua, Vars_Ciyuan_Yuanshi, Vars_Ciyuan_Spe, Vars_Ciyuan_Yuanshi_Spe, Vars_Huiyi_Dz)
            xq:setdata("转生者-获取变异中")
            local str = herogetvar(xq.handle, pools, "次元")
            xq:deldata("转生者-获取变异中")
            if str == "失败" then
              b1 = false
            end
            if b1 then
              xq:changedata("传奇数量", 1)
            end
          end
        end
        if xq:hasdata("变异判定-七夜志贵") and xq:hasdata("七夜志贵-歌月十夜准备就绪") then
          xq:deldata("七夜志贵-歌月十夜准备就绪")
        end
        if xq:hasdata("变异判定-Bloo") then
          xq:sendmessage("滑步值重置")
          if xq:hasdata("Bloo-假发加强") then
            xq:setdata("Bloo-滑步值", 500)
          else
            xq:setdata("Bloo-滑步值", 250)
          end
        end
        if xq:hasdata("变异判定-安克雷奇") then
          xq:sendmessage("|cFFB58C88安克雷奇-Riddle a riddle|r")
          xq:playsound(Sound_Aklq)
          xq:deldata("安克雷奇-Hide and seek冷却")
        end
        if xq:hasdata("变异判定-指引明路的苍蓝星") then
          xq:deldata("指引明路的苍蓝星-猫的报酬金冷却")
        end
        if xq:isgirl() and xq:hasdata("变异判定-卧龙") and not xq:hasdata("变异判定-诸葛亮") and not xq:hasdata("诸葛亮进阶标记") and xq:isalive() then
          local gl = 20
          if xq:hasdata("七罪-暴食") then
            gl = 30
          end
          if GetRandom100(gl) then
            xq:setdata("诸葛亮进阶标记")
            xq:sendmessage("|cFFFFFF00卧龙进阶解锁|r")
          end
        end
        if Stage == 8 or Stage == 15 or Stage == 22 then
          xq:setdata("杀戮祝福-购买次数", 0)
          xq:sendmessage("|cffdd6158杀戮祝福累积次数重置|r")
        end
      end)
      attackrelive()
      if Huanjing_Lingli >= 3000 then
        systemconcenchange(1000)
      else
        Huanjing_Lingli = 3000
        Huanjing_Moli = 0
      end
      if Stage == 1 and not Mode_Dabamoshi then
        SendMsgAll("|cFFFF99FF补给箱已刷新|r")
        local count = 6 + 3 * PlayerCount
        supplyborn(3, count, RECT_PlayArea)
      end
      if Danwei_Baoming ~= 0 then
        local u = getunit(Danwei_Baoming)
        if not Boolean_BaomingIng and not Boolean_BaomingTip[3] and PlayerCount == 1 then
          AdvanceGet["终末鸟-小鸟事件"](u)
        end
      end
      if Weiyi_Dz[27] and Weiyi_Dz[28] then
        do
          local kong = getunit(Danwei_Blank_Kong)
          local bai = getunit(Danwei_Blank_Bai)
          if kong:hasdata("诱导法存活标记") and bai:hasdata("诱导法存活标记") then
            kong:setdata("诱导法解锁标记")
            bai:setdata("诱导法解锁标记")
          end
          kong:deldata("诱导法存活标记")
          bai:deldata("诱导法存活标记")
        end
      end
    end
  end)
  attack_next:pause()
  ac.loop(10000, function()
    DebugNumofMonster = 0
    ForGroupLuaNew(Group_Monster, function(xq)
      local type = GetUnitTypeId(xq.handle)
      if type == S2ID("hhhh") or type == S2ID("u0E2") or type == S2ID("u03X") or type == S2ID("u066") then
        print("检测到马甲单位进入怪物组")
        xq:groupremove(Group_Monster)
        xq:setxy(PX_X, PX_Y)
        AllNumofMonster = AllNumofMonster - 1
        LeftNumofMonster = LeftNumofMonster + 1
      end
      if xq:hasdata("暗神-星渊核心单位") then
        print("检测到星渊核心进入怪物组")
        xq:groupremove(Group_Monster)
        AllNumofMonster = AllNumofMonster - 1
        LeftNumofMonster = LeftNumofMonster + 1
      end
      if xq:isinrect(RECT_DEBUG) then
        xq:changedata("怪物-原地不动次数", 1)
        if xq:getdata("怪物-原地不动次数") >= 3 then
          if not xq:isboss() then
            print("检测到连续30秒处于Debug区域怪物,清除")
            xq:groupremove(Group_Monster)
            xq:setxy(PX_X, PX_Y)
            AllNumofMonster = AllNumofMonster - 1
            LeftNumofMonster = LeftNumofMonster + 1
          end
        else
          xq:setdata("怪物-原地不动次数", 0)
        end
      end
    end)
    if Tipshow and not Movie_Boolean then
      local sl = 0
      if BossBattle or 0 < Group_Counts(Jianta_Jingying) then
        ForGroupLuaNew(Group_Monster, function(xq)
          local r, g, b = 255, 255, 255
          if not xq:hasdata("暗神-星渊核心单位") then
            sl = sl + 1
            if xq:isboss() then
              g = 0
              b = 0
              local x, y = xq:getxy()
              PingMinimapEx(x, y, 5, r, g, b, false)
            elseif xq:iselite() then
              r = 0
              g = 0
              local x, y = xq:getxy()
              PingMinimapEx(x, y, 5, r, g, b, false)
            end
          end
          if xq:getdata("生命上限") == 0 then
            xq:setmaxhp(1)
          end
          if xq:gethp() == 0 then
            xq:sethp(100, true)
          end
          if not xq:isinrect(RECT_PlayArea) and not xq:isboss() then
            print("检测到地图外怪物")
            print(xq.handle)
            print(GetUnitTypeId(xq.handle))
            print(ID2S(GetUnitTypeId(xq.handle)))
            print(xq:getname())
            Client_AllMap = true
            local npc = getunit(NPC_BAYUNZI)
            local x, y = npc:getxy()
            xq:setxy(x, y)
          end
        end)
      else
        ForGroupLuaNew(Group_Monster, function(xq)
          local r, g, b = 255, 255, 255
          if not xq:hasdata("暗神-星渊核心单位") then
            sl = sl + 1
            if xq:isboss() then
              g = 0
              b = 0
            elseif xq:iselite() then
              r = 0
              g = 0
            end
            local x = GetUnitX(xq.handle)
            local y = GetUnitY(xq.handle)
            if IsXYinRect(x, y, RECT_DEBUG) then
              print("检测到在Debug区域内怪物组单位")
              print(type(xq) .. "/" .. type(xq.handle))
              print(xq.handle)
              print(GetUnitTypeId(xq.handle))
              print(ID2S(GetUnitTypeId(xq.handle)))
              print(xq:getname())
              xq:groupremove(Group_Monster)
              AllNumofMonster = AllNumofMonster - 1
              LeftNumofMonster = LeftNumofMonster + 1
            else
              PingMinimapEx(x, y, 5, r, g, b, false)
            end
          end
          if xq:getdata("生命上限") == 0 then
            xq:setmaxhp(1)
          end
          if xq:gethp() == 0 then
            xq:sethp(100, true)
          end
          if not xq:isinrect(RECT_PlayArea) and not xq:isboss() then
            print("检测到地图外怪物")
            print(xq.handle)
            print(GetUnitTypeId(xq.handle))
            print(ID2S(GetUnitTypeId(xq.handle)))
            print(xq:getname())
            Client_AllMap = true
            local npc = getunit(NPC_BAYUNZI)
            local x, y = npc:getxy()
            xq:setxy(x, y)
          end
        end)
      end
      SendMsgAll("|cFF7DBEF1剩余怪物:" .. math.floor(sl + LeftNumofMonster - DebugNumofMonster))
    end
  end)
end

local g = CreateGroupLua()

function stageset()
  AllNumofMonster = 0
  LeftNumofMonster = 0
  MonsterAttack = true
  ForGroupLuaNew(Group_Monster, function(xq)
    xq:groupadd(g)
  end)
  GroupClearLua(Group_Monster)
  ForGroupLuaNew(g, function(xq)
    if xq:isalive() then
      xq:groupadd(Group_Monster)
      if not xq:isingroup(Group_PlanetMonster) then
        AllNumofMonster = AllNumofMonster + 1
      end
    end
  end)
  GroupClearLua(g)
  Monster = {}
  local pl = PlayerCount
  pl = pl + ComCount
  if Stage == Stage_boss[1] or Stage == Stage_boss[2] or Stage == Stage_boss[3] or Stage == Stage_boss[4] or Stage >= Stage_boss[4] then
    LeftNumofMonster = 0
  else
    LeftNumofMonster = 0
    LeftNumofMonster = LeftNumofMonster + 150
    if Stage == Stage_boss[4] - 1 and Boolean_ZhenhongBattle then
      LeftNumofMonster = LeftNumofMonster + 100
    end
  end
  if Stage == 2 then
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local sy = xq.ownerid
      if xq:hasdata("职业选择") then
        xq:deldata("职业选择")
        Proact(xq)
        xq:uivar_remove("职业选择", "传奇栏")
      end
    end)
  end
  if Boolean_Zhenhong and 4 <= Nandu_Choose then
    if Stage == Stage_boss[1] - 1 then
      local gl = 0
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy = xq.ownerid
        gl = gl + xq:getdata("传奇数量")
        gl = gl + xq:getdata("扭曲力量")
        gl = gl + HeroMenu_Shenxing[sy]
        if Hero_Shenhua_Now[sy] >= 1 then
          gl = gl + 5
        end
      end)
      local max = 25
      if Nandu_Choose >= 5 then
        max = 100
      end
      if gl >= max then
        gl = max
      end
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:hasdata("隐藏职业-Galgame女主") then
          gl = gl + 50
        end
      end)
      local gl3 = 0
      if Time_M >= 30 then
        gl3 = Time_M - 30
      end
      if Boolean_ZhenhongBiding then
        gl3 = 100
      end
      gl = gl + gl3
      if Nandu_Choose >= 5 then
        gl = gl * 2
      end
      if GetRandom100(gl) then
        Zhenhong_Start = true
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:hasdata("隐藏职业-Galgame女主") then
            if not xq:hasdata("隐藏职业-Galgame女主强化") then
              xq:setdata("隐藏职业-Galgame女主强化")
              xq:changedata("系统-神力承载上限", 10)
            end
            hideproshow(xq.handle)
          end
        end)
        SendDtimeMsgAll(0, "|cFFCC99FF八云紫：|r这是.....？", 5)
        SendDtimeMsgAll(5, "|cFFFFCCFF【八云紫捡起了地上的白色羽毛】|r", 5)
        SendDtimeMsgAll(10, "|cFFCC99FF八云紫：|r...羽毛？这种地方，为什么会有羽毛..呃.....", 5)
        SendDtimeMsgAll(15, "|cFFFFCCFF【八云紫像是感应到了什么，望向了天空那自己搭建中的结界】|r", 5)
        SendDtimeMsgAll(20, "|cFFCC99FF八云紫：|r呃...各位一切小心，我的结界感受到了一种奇怪的气息，我有种不祥的预感...", 5)
        SendDtimeMsgAll(25, "|cFFFFCCFF【八云紫低头望着手中的白色羽毛，皱起眉头，沉默不语】|r", 5)
      end
    end
    if Zhenhong_Start then
      if Stage == Stage_boss[1] then
        SendDtimeMsgAll(0, "|cFFCC99FF八云紫：|r有个不好的消息要告诉大家....", 5)
        SendDtimeMsgAll(5, "|cFFFFCCFF【八云紫眉头紧锁，手里拿着白色羽毛】|r", 5)
        SendDtimeMsgAll(10, "|cFFCC99FF八云紫：|r这个世界好像...发生了什么事情，通过我操控境界的能力，我能看到这个世界的一些本质", 5)
        SendDtimeMsgAll(15, "|cFFCC99FF八云紫：|r我感受到这个世界.的某种事物...或者说，|cFFCC0000法则|r，正在被改变", 5)
        SendDtimeMsgAll(20, "|cFFCC99FF八云紫：|r以我当前的能力不足以操作世界的法则，不管那是什么...我心中的|cFFCC0000不安感|r越来越强烈了", 5)
        SendDtimeMsgAll(25, "|cFFCC99FF八云紫：|r这个世界，可能会发生一种前所未有的|cFFCC0000异变|r", 5)
        SendDtimeMsgAll(30, "|cFFCC99FF八云紫：|r无论如何，请大家千万注意安全，小心应对", 5)
      end
      if Stage == Stage_boss[1] + 1 then
        SendDtimeMsgAll(0, "|cFFFFCCFF【你们来到了和八云紫约定好的地方】|r", 5)
        SendDtimeMsgAll(5, "|cFFCC99FF八云紫：|r各位，经过我的研究，这羽毛...恐怕是比我们更|cFFFFFF00高阶|r的存在带来的东西", 5)
        SendDtimeMsgAll(10, "|cFFFFCCFF【八云紫抬头望向天际，微风吹过脸颊，伴随着风，更多的羽毛从头顶轻轻飞过】|r", 5)
        SendDtimeMsgAll(15, "|cFFCC99FF八云紫：|r看这个情况，恐怕..有什么就要降临在这个世界了", 5)
        SendDtimeMsgAll(20, "|cFFCC99FF八云紫：|r请小心应对", 5)
      end
      if Stage >= Stage_boss[2] and not zhenhongbattle1 then
        zhenhongbattle1 = true
        BossBattle = true
        ExBossBattle = true
        Boolean_ZhenhongBattle = true
        musiccolortext({
          keep_original_text = true,
          strz = {
            {
              str = "天國顯現",
              time = 0,
              fadetime = 1,
              staytime = 44,
              sx = 50,
              sy = 160,
              dx = 70
            },
            {
              str = "白羽飛散於天際",
              time = 3,
              fadetime = 1,
              staytime = 41,
              sx = 60,
              sy = 210,
              dx = 70
            },
            {
              str = "世間萬物靜謐",
              time = 6,
              fadetime = 1,
              staytime = 38,
              sx = 70,
              sy = 260,
              dx = 70
            },
            {
              str = "恐懼滲透天地",
              time = 9,
              fadetime = 1,
              staytime = 35,
              sx = 80,
              sy = 310,
              dx = 70
            },
            {
              str = "一道身影於白羽之中顯現",
              time = 12,
              fadetime = 1,
              staytime = 32,
              sx = 90,
              sy = 360,
              dx = 70
            },
            {
              str = "世界法則皆環繞於其左右",
              time = 15,
              fadetime = 1,
              staytime = 29,
              sx = 100,
              sy = 410,
              dx = 70
            },
            {
              str = "純白的身躯，散發出無盡的真理",
              time = 18,
              fadetime = 1,
              staytime = 26,
              sx = 110,
              sy = 460,
              dx = 70
            },
            {
              str = "此刻，偉大的世界意志降臨於此",
              time = 21,
              fadetime = 1,
              staytime = 23,
              sx = 120,
              sy = 510,
              dx = 70
            },
            {
              str = "此即為世界",
              time = 24,
              fadetime = 1,
              staytime = 20,
              sx = 130,
              sy = 560,
              dx = 70
            },
            {
              str = "此即為法則",
              time = 27,
              fadetime = 1,
              staytime = 17,
              sx = 140,
              sy = 610,
              dx = 70
            },
            {
              str = "此即為真理",
              time = 30,
              fadetime = 1,
              staytime = 14,
              sx = 150,
              sy = 660,
              dx = 70
            },
            {
              str = "此即為永恆",
              time = 33,
              fadetime = 1,
              staytime = 11,
              sx = 160,
              sy = 710,
              dx = 70
            },
            {
              str = "此即為萬千世界意志的結合",
              time = 36,
              fadetime = 1,
              staytime = 8,
              sx = 170,
              sy = 760,
              dx = 70
            },
            {
              str = "此名為——",
              time = 39,
              fadetime = 1,
              staytime = 5,
              showtexttime = 2,
              sx = 180,
              sy = 810,
              dx = 70
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFFFFF99"
        })
        musiccolortext({
          keep_original_text = true,
          strz = {
            {
              str = "二階堂真紅",
              time = 41,
              fadetime = 1,
              staytime = 3,
              showtexttime = 3,
              sx = 480,
              sy = 810,
              dx = 70
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFCC0000"
        })
        ac.wait(45000, function()
          local x, y = getunit(NPC_Molijiedian):getxy()
          local boss = getunit(Boss_Zhenhong)
          boss:setxy(x, y - 100)
          boss_zhenhong(boss.handle)
        end)
        return
      end
      if Stage >= Stage_boss[3] and not zhenhongbattle2 then
        zhenhongbattle2 = true
        BossBattle = true
        ExBossBattle = true
        local boss = getunit(Boss_Zhenhong)
        boss:setdata("真红-二阶段开始判定")
        return
      end
      if Stage >= Stage_boss[4] and not zhenhongbattle3 then
        zhenhongbattle3 = true
        BossBattle = true
        ExBossBattle = true
        local boss = getunit(Boss_Zhenhong)
        boss:setdata("真红-三阶段开始判定")
        return
      end
    end
  end
  do
    local function numToChinese(num)
      local nums = {
        "零",
        
        "一",
        "二",
        "三",
        "四",
        "五",
        "六",
        "七",
        "八",
        "九"
      }
      if num < 0 or 100 <= num then
        return tostring(num)
      end
      if num < 10 then
        return nums[num + 1]
      end
      if num < 20 then
        return "十" .. (num % 10 == 0 and "" or nums[num % 10 + 1])
      end
      local ten = math.floor(num / 10)
      local one = num % 10
      return nums[ten + 1] .. "十" .. (one == 0 and "" or nums[one + 1])
    end
    
    if Daohangtu and Daohangtu.sync_from_stage then
      Daohangtu:sync_from_stage()
    end
    local curr_kind, curr_biome = "袭击"
    if Daohangtu and Daohangtu.get_current_wave_info then
      curr_kind, curr_biome = Daohangtu:get_current_wave_info()
    end
    if Boolean_TestMode and Stage >= Stage_boss[4] then
      curr_kind = "BOSS"
    end
    
    local function current_type_label()
      if Daohangtu and Daohangtu.get_current_wave_type then
        return Daohangtu:get_current_wave_type()
      end
      if curr_kind == "袭击" or curr_kind == "危险行星" then
        local name = curr_biome and curr_biome .. "行星" or "敌对行星"
        if curr_kind == "危险行星" then
          return "|cFFCC0000" .. name .. "（危险）|r"
        else
          return "|cFF949596" .. name .. "|r"
        end
      elseif curr_kind == "空间站" then
        return "|cFF66CCFF空间站|r"
      elseif curr_kind == "BOSS" then
        return "|cFF990000危险星团|r"
      end
      return "|cFFFF6699敌对行星|r"
    end
    
    SendMsgAll("|cffff0000第" .. numToChinese(Stage) .. "波|r")
    if Tianqiongshengyushijian > 0 then
      Tianqiongshengyushijian = 1
    end
    local BIOME_POOLS_BY_NAME = {
      ["陆地"] = {
        "巨型蜘蛛",
        "狂暴枭兽",
        "巨型蝙蝠",
        "野人"
      },
      ["辐射"] = {
        "飞机",
        "丧尸",
        "灰烬丧尸",
        "爬行者",
        "狂暴枭兽",
        "巨型蝙蝠"
      },
      ["冰原"] = {
        "恐怖猛犸",
        "冰霜巨人",
        "极寒冰蝎",
        "霜冻教徒"
      },
      ["火山"] = {
        "狂信徒",
        "火蝙蝠",
        "神灵武士",
        "掠夺者"
      },
      ["荒芜"] = {
        "再生磐石"
      },
      ["半影"] = {
        "深渊武士",
        "影狼",
        "术士",
        "吸血鬼",
        "教徒",
        "魔像",
        "女妖",
        "审问者",
        "虚空假面",
        "空间盗贼",
        "空间龙"
      },
      ["风暴"] = {
        "暴风骑士",
        "风暴龙鹰",
        "鸣雷者",
        "踏雷者",
        "引雷者",
        "召雷者"
      },
      ["海洋"] = {
        "深海鱼人",
        "狂暴灵兽",
        "海德拉",
        "深渊须",
        "遗忘者"
      },
      ["高山"] = {
        "高山战士",
        "高山狂人",
        "龙人战士",
        "龙人领主",
        "龙人巫师",
        "狮鹫"
      },
      ["森林"] = {
        "野人",
        "巨型蜘蛛",
        "野人祭祀",
        "狡猾野人",
        "水生野人",
        "巨型野人"
      }
    }
    local BIOME_NAME_ORDER = {
      "陆地",
      "辐射",
      "冰原",
      "火山",
      "荒芜",
      "半影",
      "风暴",
      "海洋",
      "高山",
      "森林"
    }
    local BOSS_BY_NAME = {
      ["武权王"] = {
        "法师",
        "战士",
        "武神卫",
        "勇士"
      },
      ["弗法"] = {
        "暴风骑士",
        "风暴龙鹰"
      },
      ["噩梦"] = {
        "巨型蜘蛛",
        "狂暴枭兽",
        "巨型蝙蝠",
        "野人"
      },
      ["暴怒"] = {
        "狂信徒",
        "掠夺者",
        "审问者"
      },
      ["暴食"] = {"深渊须", "遗忘者"}
    }
    local mondata = {
      {
        stage = 1,
        pools = {
          "丧尸",
          "爬行者",
          "变异蜘蛛"
        }
      },
      {
        stage = 2,
        pools = {
          "丧尸",
          "爬行者",
          "巨型蝙蝠",
          "变异蜘蛛",
          "狂暴枭兽"
        }
      },
      {
        stage = 3,
        pools = {
          "战士",
          "法师",
          "变异蜘蛛",
          "巨型蝙蝠"
        }
      },
      {
        stage = 4,
        pools = {
          "战士",
          "法师",
          "勇士",
          "变异蜘蛛"
        }
      },
      {
        stage = 5,
        pools = {
          "战士",
          "法师",
          "勇士",
          "变异蜘蛛"
        }
      },
      {
        stage = 6,
        pools = {
          "战士",
          "法师",
          "勇士",
          "武神卫",
          "变异蜘蛛"
        }
      },
      {
        stage = 7,
        pools = {
          "战士",
          "法师",
          "勇士",
          "武神卫"
        }
      },
      {
        stage = 8,
        pools = {
          "灰烬丧尸",
          "巨型蜘蛛",
          "深渊武士",
          "深海鱼人"
        }
      },
      {
        stage = 9,
        pools = {
          "灰烬丧尸",
          "巨型蜘蛛",
          "深渊武士",
          "深海鱼人"
        }
      },
      {
        stage = 10,
        pools = {
          "灰烬丧尸",
          "巨型蜘蛛",
          "深渊武士",
          "深海鱼人",
          "影狼",
          "吸血鬼"
        }
      },
      {
        stage = 11,
        pools = {
          "深渊武士",
          "深海鱼人",
          "影狼",
          "吸血鬼",
          "术士",
          "教徒"
        }
      },
      {
        stage = 12,
        pools = {
          "影狼",
          "吸血鬼",
          "术士",
          "教徒",
          "空间盗贼",
          "空间龙"
        }
      },
      {
        stage = 13,
        pools = {
          "影狼",
          "吸血鬼",
          "术士",
          "教徒",
          "空间盗贼",
          "空间龙",
          "魔像",
          "女妖"
        }
      },
      {
        stage = 14,
        pools = {
          "影狼",
          "吸血鬼",
          "术士",
          "教徒",
          "空间盗贼",
          "空间龙",
          "魔像",
          "女妖"
        }
      },
      {
        stage = 15,
        pools = {
          "高山战士",
          "狂信徒",
          "火蝙蝠"
        }
      },
      {
        stage = 16,
        pools = {
          "高山战士",
          "狂信徒",
          "火蝙蝠",
          "掠夺者",
          "龙人战士"
        }
      },
      {
        stage = 17,
        pools = {
          "龙人领主",
          "龙人巫师",
          "火蝙蝠",
          "掠夺者",
          "龙人战士"
        }
      },
      {
        stage = 18,
        pools = {
          "龙人领主",
          "龙人巫师",
          "火蝙蝠",
          "掠夺者",
          "龙人战士",
          "掠夺者",
          "审问者"
        }
      },
      {
        stage = 19,
        pools = {
          "龙人领主",
          "龙人巫师",
          "火蝙蝠",
          "掠夺者",
          "龙人战士",
          "掠夺者",
          "审问者",
          "风暴龙鹰",
          "狮鹫"
        }
      },
      {
        stage = 20,
        pools = {
          "龙人领主",
          "龙人巫师",
          "高山狂人",
          "审问者",
          "风暴龙鹰",
          "狮鹫"
        }
      },
      {
        stage = 21,
        pools = {
          "龙人领主",
          "龙人巫师",
          "高山狂人",
          "审问者",
          "风暴龙鹰",
          "狮鹫"
        }
      },
      {
        stage = 22,
        pools = {
          "龙人领主",
          "龙人巫师",
          "风暴龙鹰",
          "狮鹫"
        }
      }
    }
    
    local function gather_all_species()
      local set, list = {}, {}
      for _, biome in ipairs(BIOME_NAME_ORDER) do
        local names = BIOME_POOLS_BY_NAME[biome]
        for _, nm in ipairs(names) do
          if not set[nm] then
            set[nm] = true
            table.insert(list, nm)
          end
        end
      end
      return list
    end
    
    local function shuffle(a)
      for i = #a, 2, -1 do
        local j = GetRandomInt(1, i)
        a[i], a[j] = a[j], a[i]
      end
      return a
    end
    
    local function get_type_count(stage)
      if stage <= 1 then
        return 1
      end
      if stage <= 3 then
        return 2
      end
      if stage <= 6 then
        return 3
      end
      if stage <= 10 then
        return 4
      end
      return 4
    end
    
    local function resolve_candidate_species(kind, biome)
      if (kind == "袭击" or kind == "危险行星") and biome and BIOME_POOLS_BY_NAME[biome] then
        return {
          table.unpack(BIOME_POOLS_BY_NAME[biome])
        }
      end
      return {}
    end
    
    local function resolve_candidate_boss(name)
      return {
        table.unpack(BOSS_BY_NAME[name])
      }
    end
    
    local function set_monster_name_pool(names, count)
      local picked = {}
      if 0 < #names and 0 < count then
        shuffle(names)
        local maxc = math.min(count, #names)
        for i = 1, maxc do
          picked[i] = names[i]
        end
      end
      _G.MonsterNames = picked
      _G.MonsterType = #picked
      _G.MonsterAllNames = _G.MonsterAllNames or gather_all_species()
      _G.MonsterTypeCount = #_G.MonsterAllNames
    end
    
    if Stage == 0 then
      local names = {}
      names = {"活尸"}
      set_monster_name_pool(names, 1)
      Boolean_YiShuaguai = true
      return
    end
    local datapool = {
      "狂暴灵兽",
      "高山狂人",
      "风暴龙鹰",
      "狮鹫"
    }
    for index, value in ipairs(mondata) do
      if Stage == value.stage then
        datapool = value.pools
      end
    end
    set_monster_name_pool(datapool, #datapool)
    if curr_kind == "危险行星" or curr_kind ~= "BOSS" and curr_kind ~= "乐土商店" and Keyan_Jingyingjizeng then
      local count = 1
      if Keyan_Shuangchongcunzai then
        count = count * 2
      end
      for i = 1, count do
        local zu = {
          "u04C",
          "u04E",
          "u04G",
          "u04F"
        }
        local x, y = GetRandomXYInRect(RECT_PlayArea)
        local monster = CreateMonster(zu[GetRandomInt(1, #zu)], x, y, 270)
        local mj = getunit(monster)
        local change = 0
        if Nandu_Choose >= 6 then
          change = Stage * 0.25
        end
        mj:setdata("尖塔模式-精英怪")
        mj:setdata("系统-BOSS")
        mj:groupadd(HellGroup)
        attackshuaguai(monster)
        if 0 < change then
          mj:changemaxhp(change * mj:getmaxhp())
        end
        mj:changemaxhp(5000000)
        mj:addskill("A020")
        mj:groupadd(Jianta_Jingying)
        SetUnitPathing(mj.handle, false)
        for i = 1, 8 do
          UnitShareVision(mj.handle, Player(i - 1), true)
        end
        mj:buffset(mj.handle, 5, "暂停")
        mj:buffset(mj.handle, 5, "无敌")
        SendMsgAll("|cFFCC0000" .. GetUnitName(mj.handle) .. "出现了！|r")
      end
    end
    if curr_kind == "BOSS" then
      local boss = attacksetboss()
    end
    if curr_kind == "空间站" then
      if Boolean_Qiangjiejiaoyisuo then
        SendMsgAll("|cFFCC0000你们在天穹交易所的黑名单中……|r")
      else
        SendMsgAll("|cFF6699FF天穹交易所正在准备对接……|r")
        ac.wait(3000, function()
          tianqiongshangdianshuaxin()
          tianqiongshijian()
        end)
      end
    end
  end
end

local BOSS_BASE_HP_BY_RAWCODE = {
  u01O = 10000000,
  u02U = 10000000,
  u007 = 15000000,
  u00G = 15000000,
  u027 = 20000000,
  u00R = 25000000,
  u0D4 = 25000000,
  u01R = 25000000,
  u05E = 25000000,
  u004 = 25000000,
  u00Z = 10000000,
  u07K = 10000000,
  u05D = 10000000,
  u03U = 10000000
}

local function get_boss_base_hp(u)
  local typeid = GetUnitTypeId(u.handle)
  if (not typeid or typeid == 0) and u.type then
    typeid = u.type
  end
  if not typeid or typeid == 0 then
    return nil
  end
  local rawcode = ID2S(typeid)
  return BOSS_BASE_HP_BY_RAWCODE[rawcode], rawcode
end

function bosshpattackset(u, isextra)
  isextra = isextra or false
  local hpmax
  local addhp = 1 + 0.02 * Nandu_Level
  local addatk = 1 + 0.02 * Nandu_Level
  addhp = addhp * MWTQ_HpBOSS
  addatk = addatk * MWTQ_AtkBOSS
  addhp = addhp * (0.75 + 0.25 * PlayerCount)
  addhp = addhp * NanduJc_Hp
  addatk = addatk * NanduJc_Atk
  addhp = addhp * BOSSEWHp
  if not u:hasdata("BOSS-生命值初始化") then
    u:setdata("BOSS-生命值初始化")
    local rawcode
    hpmax, rawcode = get_boss_base_hp(u)
    if not hpmax then
      print("BOSS基础生命值数据库缺失:" .. tostring(rawcode))
      hpmax = u:getmaxhp()
    end
    SetUnitState(u.handle, UNIT_STATE_MAX_LIFE, 10000)
  else
    hpmax = u:getmaxhp()
  end
  u:setdata("怪物强度", addatk)
  local shjc = 500 + 50 * Stage
  SetUnitState(u.handle, ConvertUnitState(18), shjc * u:getdata("怪物强度"))
  u:setmaxhp(hpmax * addhp)
  u:setdata("怪物基础生命上限", u:getmaxhp())
  u:sethp(100, true)
  u:setdata("怪物-伤害修正", 1)
  if Keyan_Zhongzhuanghujia and not u:hasdata("科研模式-重装护甲提升") then
    local add = 1 * Nandu_Level
    u:changearmor(add)
    u:setdata("科研模式-重装护甲提升")
  end
end

function bossstateset(boss)
  boss.owner = Player(9)
  boss:changeowner(Player(9))
  print("BOSS注册成功:" .. boss:getname())
  TriggerRegisterUnitEvent(DamageSystemTrg, boss.handle, EVENT_UNIT_DAMAGED)
  TriggerRegisterUnitEvent(MonsterDead, boss.handle, EVENT_UNIT_DEATH)
  BossBattle = true
  BOSS = boss.handle
  bosshpattackset(boss)
  boss:setdata("神性", 5)
  MonsterSetXingcunzuAttackTarget(boss)
  boss:groupadd(Group_Monster)
  boss:addskill("A020")
  boss:setdata("系统-BOSS")
  boss:addskill("A11G")
  boss:setdata("光属性抗性", 25)
  boss:setdata("暗属性抗性", 25)
  boss:setdata("风属性抗性", 25)
  boss:setdata("雷属性抗性", 25)
  boss:setdata("冰属性抗性", 25)
  boss:setdata("水属性抗性", 25)
  boss:setdata("火属性抗性", 25)
  boss:setdata("心灵属性抗性", 25)
  SetUnitPathing(boss.handle, false)
  for i = 1, 8 do
    UnitShareVision(boss.handle, Player(i - 1), true)
  end
  BOSS_Kbd = 0
  BOSS_KbdJs = 1
  BOSS_KbdT = 0
  ac.wait(1, function()
    elitemonster(boss.handle)
  end)
end

local shuangchogncunzai = false

function shuangchogncunzaiboss()
  if not shuangchogncunzai then
    local stage = Stage
    shuangchogncunzai = true
    if Stage_Type[1] == 1 then
      Stage_Type[1] = 2
    else
      Stage_Type[1] = 1
    end
    Stage = Stage_boss[1]
    attacksetboss()
    Stage = stage
    ac.wait(100, function()
      shuangchogncunzai = false
    end)
  end
end

function attacksetboss()
  local x, y = GetRandomXYInRect(RECT_PlayArea)
  local boss
  if Stage == Stage_boss[1] then
    if Stage_Type[1] == 1 then
      BOSS_Wqw = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), "u01O", x, y, -90)
      BOSS = BOSS_Wqw
      boss = getunit(BOSS)
      boss_wqw(BOSS)
      boss:setdata("BOSS-名字", "武权王")
      boss:setdata("系统-道中BOSS")
    elseif Stage_Type[1] == 2 then
      BOSS_Fufa = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), "u02U", x, y, -90)
      BOSS = BOSS_Fufa
      boss = getunit(BOSS)
      boss:setplayername("弗法")
      boss_fufa(BOSS)
      boss:setdata("BOSS-名字", "弗法")
      boss:setdata("系统-道中BOSS")
    end
  end
  if Stage == Stage_boss[2] then
    BOSS = BOSS_Emeng
    boss = getunit(BOSS)
    boss_emeng(BOSS)
    boss:setdata("BOSS-名字", "噩梦")
    boss:setdata("系统-道中BOSS")
  end
  if Stage == Stage_boss[3] then
    BOSS = BOSS_Baonu
    boss = getunit(BOSS)
    boss_baonu(BOSS)
    boss:setdata("BOSS-名字", "暴怒")
    boss:setdata("系统-道中BOSS")
  end
  if Stage == Stage_boss[4] then
    BOSS = BOSS_Baoshi
    boss = getunit(BOSS)
    boss:setdata("BOSS-名字", "暴食")
    boss:setdata("系统-道中BOSS")
    boss:setdata("BOSS-暴食")
    boss:setdata("BOSS限伤-单次直伤限伤", 0.01)
    boss:setdata("BOSS限伤-单次附伤限伤", 0.005)
    ChangeBGM(BGM_Biexibo)
    if 3 <= Nandu_Choose then
      local u = boss
      local cs = 0
      ac.loop(1000, function(t)
        cs = cs + 1
        if cs == 15 then
          cs = 0
          if not u:hasdata("暴食-无尽吞噬") then
            u:effectadd("ATX\\[ATxNew]Green_12.mdl", "origin", 15)
            SendMsgAll("|cFF9966CC无尽吞噬-无尽|r")
            u:setdata("暴食-无尽吞噬")
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:deldata("暴食-无尽吞噬")
            end)
          else
            SendMsgAll("|cFF9966CC无尽吞噬-吞噬|r")
            u:deldata("暴食-无尽吞噬")
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:setdata("暴食-无尽吞噬")
            end)
          end
        end
        if not u:isalive() then
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:deldata("暴食-无尽吞噬")
          end)
          t:remove()
        end
      end)
    end
  end
  if Boolean_TestMode then
    if Stage == Stage_boss[4] + 1 then
      boss = getunit(BOSS_Pj)
      boss:setxy(x, y)
      boss_pj(BOSS_Pj)
    end
    if Stage == Stage_boss[4] + 2 then
      local npc = getunit(NPC_Wst_Diaoxiang)
      local x, y = npc:getxy()
      ac.wait(4000, function()
        ShowUnit(npc.handle, false)
      end)
      YisiSystem.chat({
        text = "你将戒指摁入雕像石台的凹槽中",
        priority = 3
      })
      YisiSystem.chat({
        text = "下起了雷雨……",
        priority = 3
      })
      YisiSystem.chat({
        text = "雕像好像产生了一些变化。",
        priority = 3
      })
      YisiSystem.chat({
        text = "一些变化？不，雕像好像活过来了！",
        priority = 3
      })
      boss = getunit(BOSS_Wst)
      boss:setxy(x, y)
      boss_wst(BOSS_Wst)
    end
    if Stage == Stage_boss[4] + 3 then
      boss = getunit(BOSS_Gesi)
      boss:setxy(x, y)
      boss_heisejianshi(BOSS_Gesi)
    end
  end
  if Stage <= Stage_boss[4] then
    boss:setxy(x, y)
    bossstateset(boss)
  end
  if Keyan_Shuangchongcunzai then
    shuangchogncunzaiboss()
  end
  return boss
end

function attackrelive()
  ForGroupLuaNew(Group_DeathHero, function(xq)
    xq:sendmessage("你已经复活")
    local npc = getunit(NPC_BAYUNZI)
    local x, y = npc:getxy()
    x, y = PolarXY(x, y, 100, npc:getface())
    HeroRelive(xq.handle, x, y, 5)
  end)
end

local WaveController = {}

function WaveController.install()
  init()
end

return WaveController
