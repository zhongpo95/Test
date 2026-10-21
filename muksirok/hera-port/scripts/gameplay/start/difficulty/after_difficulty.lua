-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local player = require("jh.ac.player")

function difselectact()
  ac.loop(3000, function()
    local str = ""
    str = str .. "버전:" .. GameVersion .. "    "
    str = str .. "비동기 검사:" .. GetRandomInt(0, 100)
    if IsWindowActive() then
      UI_jiance:set_text(str)
    end
  end)
  Stage_Type[1] = GetRandomInt(1, 2)
  for i = 1, 6 do
    player[i]:createrectfogcorrector(Glo.gg_rct_HeroSelect)
  end
  CameraSetupApplyForceDuration(Glo.gg_cam_Camera_001, true, 0)
  for _, xq in ac.selector():in_rangexy(0, 0, 50000):allow_ignoreselect():ipairs() do
    xq = getunit(xq)
    if xq:ishasskill("Avul") then
      xq:setdata("系统-无敌")
    end
  end
  guoboallsetstart()
  systemrank()
  require("gameplay.feature.npc.init")
  diffset()
  extraevent()
  System_YiwulanCount = 9
  require("gameplay.runtime.supplycreate")
  supplycreate()
  require("gameplay.runtime.centerloop")
  centerloop()
  for i = 7, 8 do
    local p = player[i]
    p:addtrgevent("玩家-聊天", function(args)
      local msg = args.chat
      local str = msg:sub(1, 1)
      if str == "-" or str == "+" then
        if string.lower(msg) == "-cc" and p.handle == LocalPlayer then
          ClearTextMessages()
          UI_NewChatClear()
        end
        return
      end
      local showname = p:getname()
      if Boolean_ColorName[p.id] then
        showname = ShowName[p.id] or ""
      end
      local message = string.format("%s%s|r:%s", p:getColorWord(), showname, msg)
      UI_NewChat(p, message, msg)
    end)
  end
  ac.wait(1000, function()
    if Mode_DanyiShenqi and not DanyiShenqi_Var then
      local pools = {
        Guoboyiwu_Normal,
        Guoboyiwu_Rare,
        Guoboyiwu_SuperRare,
        Guoboyiwu_BOSS
      }
      local var = herogetvar(BOSS_DEATH, pools, "普通过波遗物", "只返回变异")
      if type(var) == "table" then
        DanyiShenqi_Var = var
      end
    end
  end)
  if Mode_Keyan then
    local count = 2
    if Nandu_Choose >= 5 then
      count = 3
    end
    if Nandu_Shenzhao then
      count = 4
    end
    keyanjiesuo_initial(count)
  end
  ac.wait(10000, function()
    attackrelive()
  end)
  require("gameplay.permission.player_catalog_registration").install()
  require("gameplay.state.battlegroup.init")
  require("gameplay.feature.beibao.init")
  require("gameplay.var.init")
  require("gameplay.feature.remains.init")
  require("gameplay.hero.hidepro.herohideprofession")
  require("gameplay.hero.hidepro.init")
  require("gameplay.runtime.modelchange.init")
  require("gameplay.hero.levelup.init")
  require("gameplay.monster.init")
  attack_attackplace:resume()
  require("gameplay.runtime.fly.init")
  require("gameplay.runtime.mapmove.init")
  require("gameplay.runtime.extraspeed.init")
  require("gameplay.hero.death.init")
  require("gameplay.runtime.stamina")
  require("gameplay.hero.heroskill.init")
  HeroSelectAdd()
  YisiStory["加载完毕"]()
  ac.wait(1000, function()
    ChangeBGM()
  end)
end

function systemrank()
  local dif = Nandu_Choose
  local str = {}
  str[1] = "|cFF33FF66몽경|r"
  str[2] = "|cFFFF3300현실|r"
  str[3] = "|cFF333333악몽|r"
  str[4] = "|cFF990000지옥|r"
  str[5] = "|cFF6600FF환몽|r"
  if Nandu_Shenzhao then
    str[5] = "|cFF3333FF신|r|cFF6666FF조|r"
  end
  local modesel
  modesel = "|cFFCCFFFF교|r|cFFCCCCCC야|r"
  if ModeSelect_Infinite then
    modesel = "|cFF66CCFF은|r|cFF6699CC하|r"
  end
  if ModeSelect_Difficult then
    modesel = "|cFF990000혼|r|cFF993333돈|r"
  end
  if ModeSelect_Revenge then
    modesel = modesel .. "|cFFFF6666복수|r"
  end
  local player = require("jh.ac.player")
  local board = CreateLeaderboardBJ(GetPlayersAll(), "난이도:")
  for i = 1, 6 do
    if player[i]:isplayer() then
      LeaderboardAddItemBJ(player[i].handle, board, player[i]:getname(), 0)
      PlayerSetLeaderboard(player[i].handle, board)
    end
  end
  local time = 0
  local cs2 = 0
  ac.loop(70, function()
    cs2 = cs2 + 1
    time = time + 0.07
    Time_All = time
    local t1 = Time_All / 60
    local t2 = Time_All % 60
    Time_M = math.floor(t1)
    Time_S = math.floor(t2)
    LeaderboardSetLabel(board, math.floor(Stage) .. "라운드 " .. modesel .. " " .. str[dif] .. " 시간:" .. Time_M .. "분" .. Time_S .. "초")
    for i = 1, 6 do
      LeaderboardSetPlayerItemValueBJ(player[i].handle, board, Fenshu[player[i].id])
      if Hero[player[i].id] ~= 0 then
        local u = getunit(Hero[player[i].id])
        local showname = player[i]:getname()
        if Boolean_ColorName[i] then
          showname = ShowName[i] or ""
        end
        LeaderboardSetPlayerItemLabelBJ(player[i].handle, board, showname .. " " .. math.floor(u:getperhp()) .. "%")
      else
        LeaderboardSetPlayerItemLabelBJ(player[i].handle, board, player[i]:getname())
      end
    end
    if cs2 == 20 then
      cs2 = 0
      LeaderboardSortItemsBJ(board, bj_SORTTYPE_SORTBYVALUE, false)
    end
  end)
end

function diffset()
  if Nandu_Choose >= 3 then
    SetTimeOfDay(18.01)
  else
    SetTimeOfDay(12.01)
  end
  if Nandu_Choose == 1 then
    Stage = -1
  else
    Stage = 0
  end
  PlayerCount = 0
  ComCount = 0
  for i = 1, 6 do
    if player[i]:isplayer() then
      PlayerCount = PlayerCount + 1
    end
    if GetPlayerController(ConvertedPlayer(i)) == MAP_CONTROL_COMPUTER then
      ComCount = ComCount + 1
    end
  end
  Nandu_Level = 0
  Nandu_Jiangli_Exp = 2
  Nandu_Jiangli_Gold = 2
  ac.loop(3000, function()
    Nandu_Level = 5 * Stage + Time_M + 25 * Count_Zhanzhengqiyue
    UI_Text_Gwqd:set_text("|cFF990000怪物强度:" .. string.sub(Nandu_Level, 1, 4) .. "级|r")
  end)
end

function leiyumz(xq)
  if xq:hasdata("变异判定-雷之律者") or xq:getdata("雷变异数量") >= 3 then
    xq:sendmessage("|cFF3366FF雷|r|cFF3D52FF之|r|cFF473DFF洗|r|cFF5229FF礼|r")
    xq:curehp(xq.handle, 0, 25, 4)
    DamageSystem_Shjc[xq.ownerid] = DamageSystem_Shjc[xq.ownerid] + 0.025
    ac.wait(60000, function()
      DamageSystem_Shjc[xq.ownerid] = DamageSystem_Shjc[xq.ownerid] - 0.025
    end)
  else
    local ss
    if xq:isboss() then
      ss = 1
    else
      ss = 50
    end
    xq:losshp(getunit(BOSS_DEATH), 0, ss)
    xq:buffset(xq.handle, 10, "僵直")
    xq:buffset(xq.handle, 1, "眩晕")
    xq:settimedata("雷狱破抗", 10)
  end
  if xq:hasdata("变异判定-影之革命者") then
    if xq:hasdata("变异判定-宇智波佐助") then
      DamageSystem_Shjc[xq.ownerid] = DamageSystem_Shjc[xq.ownerid] + 0.003
    else
      DamageSystem_Shjc[xq.ownerid] = DamageSystem_Shjc[xq.ownerid] + 0.002
    end
  end
  if xq:ishasitem("I09D") and xq:isingroup(Group_PlayHero) then
    local wp = xq:getitem("I09D")
    if 1 >= GetItemCharges(wp) then
      UnitRemoveItemSwapped(wp, xq.handle)
      RemoveItemLua(wp)
    else
      SetItemCharges(wp, GetItemCharges(wp) - 1)
    end
    xq:additem("I09V")
    xq:sendmessage("|cFF7DBEF1魔力石吸收了雷电之力|r")
  end
end

function extraevent()
  local yx = {}
  yx[1] = Yx1
  yx[2] = Yx2
  yx[3] = Yx3
  yx[4] = Yx4
  yx[5] = Yx5
  yx[6] = Yx6
  yx[7] = Yx7
  yx[8] = Yx8
  yx[9] = Yx9
  yx[10] = Yx10
  yx[11] = Yx11
  ac.loop(70000, function()
    PlayGlobalSound(yx[GetRandomInt(1, 11)])
  end)
  ac.wait(140000, function()
    if Chushi_Murasame then
      local g = CreateGroupLua()
      for i = 1, 6 do
        if Xuanze[i] then
          local u = getunit(Hero[i])
          if Player_Select[i] and not u:hasdata("丛雨") then
            u:groupadd(g)
          end
        end
      end
      if Group_Counts(g) ~= 0 then
        local u2 = Group_Randomunit(g)
        if type(u2) ~= "table" then
          error("丛雨结缘组计数与内容不一致")
        end
        u2:setdata("丛雨结缘")
        Qiyue_Murasame_Master = u2.handle
      end
    end
    if GetRandom100(10) then
      local u = Group_Randomunit(Group_PlayHero)
      if type(u) ~= "table" then
        error("玩家英雄组为空")
      end
      u:setdata("伊卡洛斯-主人标记")
      u:setdata("伊卡洛斯-触发概率", 10)
      u:addstexiao("天降之物", "过波时效果", function(args)
        u:setdata("伊卡洛斯-触发概率", 10)
      end)
    end
  end)
  ac.loop(250, function(t)
    if Weiyi_Yiwu[2] then
      t:remove()
      return
    end
    local byz = getunit(NPC_BAYUNZI)
    if not byz:hasdata("零时迷子-继承冷却") and (GetTimeOfDay() >= 23.55 or GetTimeOfDay() <= 0.05) then
      ForGroupLuaNew(Group_PlayHero, function(u)
        if GetRandom100(0.4) and not Weiyi_Yiwu[2] and not u:hasdata("系统-已删模") then
          local x, y = u:getxy()
          HeroRelive(u.handle, x, y)
          Weiyi_Yiwu[2] = true
          local wp = remainget(u.handle, {
            Remains_Spe
          }, "零时迷子")
          SetData(wp, "神器所属者", u.owner)
          u:addspeitem(wp)
          u:sendmessage("|cFF3366FF零时迷子选择了你|r")
        end
      end)
      byz:settimedata("零时迷子-继承冷却", 180)
    end
  end)
  if 3 <= Nandu_Choose then
    local x, y = GetRandomXYInRect(RECT_PlayArea)
    local ly = player[8]:createunit("u0B1", x, y)
    for i = 1, 6 do
      UnitShareVision(ly.handle, ConvertedPlayer(i), true)
    end
    local cs = 0
    ac.loop(1000, function()
      cs = cs + 1
      local cf
      for _, xq in ac.selector():in_rangexy(x, y, 2000):isingroup(Group_PlayHero):ipairs() do
        xq = getunit(xq)
        if xq:ishasitem("I09D") and GetRandom100(0.1 + 0.3 * xq:getstate("雷变异")) then
          local wp = xq:getitem("I09D")
          if 1 >= GetItemCharges(wp) then
            UnitRemoveItemSwapped(wp, xq.handle)
            RemoveItemLua(wp)
          else
            SetItemCharges(wp, GetItemCharges(wp) - 1)
          end
          xq:additem("I09V")
          xq:sendmessage("|cFF7DBEF1魔力石吸收了雷电之力|r")
        end
      end
      if Surr_Leiyu then
        cf = 1
      else
        cf = 10
      end
      if cf <= cs then
        cs = 0
        local jd = GetRandomReal(0, 360)
        local jl = GetRandomReal(0, 2000)
        local x2, y2 = PolarXY(x, y, jl, jd)
        PlaySoundXY(x, y, LightningBolt01)
        Effectcreate("AATX\\[AATxNew]Thunder31.mdl", x2, y2, 0, 2)
        for _, xq in ac.selector():in_rangexy(x2, y2, 300):ipairs() do
          xq = getunit(xq)
          leiyumz(xq)
        end
      end
    end)
  end
  ac.loop(330, function()
    if not BossBattle_Wj then
      local boss = getunit(BOSS_DEATH)
      for _, xq in ac.selector():in_rect(RECT_Jianyu):ipairs() do
        xq = getunit(xq)
        if xq:isingroup(Group_PlayHero) or xq:isingroup(Group_Monster) then
          if xq:isnormal() then
            xq:losshp(boss, 0, 3.3)
          else
            xq:losshp(boss, 0, 0.1)
          end
          if xq:isingroup(Group_PlayHero) then
            xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          end
        end
      end
    end
  end)
  local dt = GetRandomInt(180, 540)
  ac.wait(dt * 1000, function()
    local dx, dy = GetRandomXYInRect(RECT_PlayArea)
    CreateItemLua("I0JR", dx, dy)
    PingMinimapEx(dx, dy, 5, 0, 0, 255, false)
    SendMsgAll("|cFF6699FF有一道流星划过天际……|r")
  end)
  ac.loop(1500, function(timer)
    if GetRandom100(0.01) then
      local dx, dy = GetRandomXYInRect(RECT_PlayArea)
      CreateItemLua("I089", dx, dy)
      timer:remove()
    end
  end)
  openShopInterface()
  do
    local b2 = false
    Eventmaodian = class.button:builder({
      parent = OriginPanel,
      x = 1920,
      y = 250,
      w = 489.19199999999995,
      h = 40,
      normal_image = "Touming.tga",
      on_button_update_drag = function(self, icon, x, y)
        self:set_position(x, y)
      end
    })
    Eventmaodian:set_enable_drag(true)
    local show = class.panel:builder({
      parent = Eventmaodian,
      x = 0,
      y = -85,
      w = 489.19199999999995,
      h = 418.47200000000004,
      normal_image = "UI_Extra_Thing.blp"
    })
    show:set_alpha(200)
    local eventtext = class.text:builder({
      parent = Eventmaodian,
      x = 25,
      y = 55,
      w = 1,
      h = 1,
      text = "",
      align = "topleft",
      font_size = 11
    })
    eventtext:set_alpha(255)
    local titletext = class.text:builder({
      parent = Eventmaodian,
      x = 244.59599999999998,
      y = 20,
      w = 1,
      h = 1,
      text = "",
      align = "center",
      font_size = 13
    })
    titletext:set_alpha(255)
    local timetext = class.text:builder({
      parent = Eventmaodian,
      x = 474.19199999999995,
      y = 11,
      w = 1,
      h = 1,
      text = "倒计时:0",
      align = "topright",
      font_size = 9
    })
    titletext:set_alpha(255)
    Eventmaodian.title = titletext
    Eventmaodian.eventtext = eventtext
    Eventmaodian.timetext = timetext
    Eventmaodian.button = {}
    for j = 1, 6 do
      Eventmaodian.button[j] = {}
      for i = 1, 4 do
        local buttonnewtext
        local button = class.button:builder({
          parent = Eventmaodian,
          x = 10,
          y = 40 * i + 213 - 85,
          w = 469.19199999999995,
          h = 38,
          normal_image = "UI_Extra_ThingUp.blp",
          sync_key = "TSB" .. j .. i,
          on_button_clicked = function(self)
            self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
            ac.wait(100, function()
              self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
            end)
          end,
          on_button_mouse_enter = function(self)
            self:set_alpha(255)
            local nowuse = Eventmaodian.nowuse[j]
            if nowuse.act[i].extra ~= "" then
              uiy_show_text("|cFFFFFFFF" .. nowuse.act[i].extra .. "|r", "Yuanzhu")
            end
          end,
          on_button_mouse_leave = function(self)
            self:set_alpha(0)
            uiy_hide()
            buttonnewtext:set_alpha(255)
          end,
          on_sync_button_clicked = function(self, p, button)
            p = getplayer(p.handle)
            local sy = p.id
            local u = getunit(Hero[sy])
            local nowuse = Eventmaodian.nowuse[sy]
            if u:hasdata(nowuse.key) then
              u:deldata(nowuse.key)
              nowuse.act[i].func(u)
            end
            if u:islocal() then
              uiy_hide()
              self:set_alpha(0)
              buttonnewtext:set_alpha(255)
              Eventmaodian:hide()
            end
          end
        })
        button:set_alpha(0)
        buttonnewtext = class.text:builder({
          parent = button,
          x = 11,
          y = 9,
          w = 1,
          h = 1,
          text = "",
          align = "topleft",
          font_size = 12
        })
        buttonnewtext:set_alpha(255)
        button:hide()
        button.showtext = buttonnewtext
        Eventmaodian.button[j][i] = button
      end
    end
    local closeButton = class.button:builder({
      parent = Eventmaodian,
      x = 289.19199999999995,
      y = 110,
      w = 62.85714285714286,
      h = 48.57142857142858,
      sync_key = "TSBClose",
      normal_image = "UI_Button_X.tga",
      on_button_mouse_enter = function(self)
        self:set_alpha(155)
        uiy_show_text("|cFFFFFFFF拒绝所有选项|r", "Yuanzhu")
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(255)
        uiy_hide()
      end,
      on_sync_button_clicked = function(self, p, button)
        p = getplayer(p.handle)
        local sy = p.id
        local u = getunit(Hero[sy])
        local nowuse = Eventmaodian.nowuse[sy]
        if u:hasdata(nowuse.key) then
          u:deldata(nowuse.key)
        end
        if u:islocal() then
          uiy_hide()
          Eventmaodian:hide()
          self:set_alpha(255)
        end
      end
    })
    Eventmaodian.closebutton = closeButton
    local allevent = {
      ["物资援助"] = {
        title = "物  资  援  助",
        text = "补充物资已经准备好跃迁,选择所需物资",
        time = 10,
        key = "每90秒奖励",
        closebutton = true,
        act = {
          {
            text = "物资补充",
            extra = "物资清单:3颗止痛药和2组手榴弹或燃烧瓶",
            func = function(u)
              u:additem("I00L", 3)
              u:sendmessage("物资补充已送达!")
              local lx = {"I00N", "I009"}
              u:additem(lx[GetRandomInt(1, 2)], 8)
            end
          }
        }
      },
      ["强化物资-1"] = {
        title = "强 化 物 资",
        text = "强化物资已经准备好跃迁,请尽快接收\n清单:1瓶以太结晶药剂",
        time = 20,
        key = "每150秒奖励",
        act = {
          {
            text = "接收物资",
            extra = "获得一瓶大幅提升对应词条补正的以太药水",
            func = function(u)
              u:additem("I0J2")
              u:sendmessage("强化物资已送达!")
            end
          },
          {
            text = "拒绝接收",
            extra = "",
            func = function(u)
            end
          }
        }
      },
      ["强化物资-2"] = {
        title = "强 化 物 资",
        text = "强化物资已经准备好跃迁,请尽快接收\n清单:1瓶回忆药剂",
        time = 20,
        key = "每150秒奖励",
        act = {
          {
            text = "接收物资",
            extra = "获得一瓶次元の回忆药剂",
            func = function(u)
              u:additem("I030")
              u:sendmessage("强化物资已送达!")
            end
          },
          {
            text = "拒绝接收",
            extra = "",
            func = function(u)
            end
          }
        }
      },
      ["强化物资-3"] = {
        title = "强 化 物 资",
        text = "强化物资已经准备好跃迁,请尽快接收\n清单:3瓶冥王星药剂",
        time = 20,
        key = "每150秒奖励",
        act = {
          {
            text = "接收物资",
            extra = "获得3瓶冥王星药剂",
            func = function(u)
              u:additem("I02H", 3)
              u:sendmessage("强化物资已送达!")
            end
          },
          {
            text = "拒绝接收",
            extra = "",
            func = function(u)
            end
          }
        }
      },
      ["强化物资-4"] = {
        title = "强 化 物 资",
        text = "强化物资已经准备好跃迁,请尽快接收\n清单:1瓶鲁纳斯泉水",
        time = 20,
        key = "每150秒奖励",
        act = {
          {
            text = "接收物资",
            extra = "获得1瓶鲁纳斯泉水",
            func = function(u)
              u:additem("I02E")
              u:sendmessage("强化物资已送达!")
            end
          },
          {
            text = "拒绝接收",
            extra = "",
            func = function(u)
            end
          }
        }
      }
    }
    Eventmaodian.nowuse = {}
    for i = 1, 6 do
      Eventmaodian.nowuse[i] = allevent["物资援助"]
    end
    Eventmaodian.timer = {}
    
    function Eventact(u, eventname)
      local sy = u.ownerid
      local event = allevent[eventname]
      Eventmaodian.nowuse[sy] = event
      if u:islocal() then
        local dy = 250
        Eventmaodian:set_position(1920, dy)
        Eventmaodian:show()
        local dx = 1920
        local all = 489
        local dcount = 50
        ac.timer(10, dcount, function()
          dx = dx - all / dcount
          Eventmaodian:set_position(dx, dy)
        end)
        Eventmaodian.title:set_text(event.title)
        Eventmaodian.eventtext:set_text("干员:" .. u:getplayername() .. "\n" .. event.text)
        if event.closebutton then
          Eventmaodian.closebutton:show()
        else
          Eventmaodian.closebutton:hide()
        end
        local count = #event.act
        for i = 1, 4 do
          local button = Eventmaodian.button[sy][i]
          button:hide()
        end
        for i = 1, count do
          local button = Eventmaodian.button[sy][i]
          button.showtext:set_text(event.act[i].text)
          button:show()
        end
        Eventmaodian.timetext:set_text("倒计时:" .. event.time)
      end
      u:setdata("正在进行事件")
      u:setdata(event.key)
      local dtime = event.time + 1
      if Eventmaodian.timer[sy] then
        Eventmaodian.timer[sy]:remove()
      end
      Eventmaodian.timer[sy] = ac.loop(1000, function(timer)
        dtime = dtime - 1
        if u:islocal() then
          Eventmaodian.timetext:set_text("倒计时:" .. dtime)
        end
        if dtime <= 0 or not u:hasdata(event.key) then
          u:deldata("正在进行事件")
          if u:hasdata(event.key) then
            u:deldata(event.key)
          end
          if u:islocal() then
            Eventmaodian:hide()
          end
          timer:remove()
        end
      end)
    end
    
    EventQueue = {}
    for i = 1, 6 do
      EventQueue[i] = {}
    end
    
    function PushEvent(u, eventname)
      local sy = u.ownerid
      table.insert(EventQueue[sy], eventname)
    end
    
    ac.loop(500, function()
      ForGroupLuaNew(Group_AllHero, function(u)
        local sy = u.ownerid
        if not u:hasdata("正在进行事件") and EventQueue[sy] and #EventQueue[sy] > 0 then
          local eventname = table.remove(EventQueue[sy], 1)
          Eventact(u, eventname)
        end
      end)
    end)
    if Nandu_Choose <= 3 then
      ac.loop(1000, function(timer)
        if AllNumofMonster >= 5 then
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              xq:changedata("90秒存活时间", 1)
              if xq:getdata("90秒存活时间") >= 90 and not xq:hasdata("正在进行事件") then
                xq:setdata("90秒存活时间", 0)
                PushEvent(xq, "物资援助")
              end
              xq:changedata("150秒存活时间", 1)
              if xq:getdata("150秒存活时间") >= 150 and not xq:hasdata("正在进行事件") then
                xq:setdata("150秒存活时间", 0)
                PushEvent(xq, "强化物资-" .. GetRandomInt(1, 3))
              end
            end
          end)
        end
        if 5 <= Stage then
          SendMsgAll("|cFFCC0000支援中心物资耗尽|r")
          timer:remove()
        end
      end)
    end
  end
end
