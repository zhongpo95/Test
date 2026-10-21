-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local test_japi_export = false
if test_japi_export then
  local output = require("jass.console")
  output.enable = true
  local ok, err = pcall(function()
    local available, result = pcall(function()
      return japi.KKCommandButtonGetAbilityId(japi.DzFrameGetCommandBarButton(0, 0))
    end)
    output.write("[TEST_JAPI] KKCommandButtonGetAbilityId 调用成功=", available, "，返回或错误=", tostring(result))
    output.write("[TEST_JAPI] 返回 0 可能只是按钮没有绑定技能，不代表接口不存在")
    local names = {}
    for name, value in pairs(japi) do
      if type(name) == "string" and type(value) == "function" then
        names[#names + 1] = name
      end
    end
    table.sort(names)
    local path = "D:/War3Lua/Demo3/japi_functions.txt"
    local file, open_error = io.open(path, "wb")
    if not file then
      error(open_error)
    end
    local written, write_error = file:write(table.concat(names, "\r\n"), "\r\n")
    local closed, close_error = file:close()
    if not written then
      error(write_error)
    end
    if not closed then
      error(close_error)
    end
    output.write("[TEST_JAPI] 已导出 ", #names, " 个可枚举函数：", path)
  end)
  if not ok then
    output.write("[TEST_JAPI] 导出失败：", tostring(err))
  end
  return
end
local player = require("jh.ac.player")
local jass = require("jass.common")
local debug = require("jass.debug")
local slk = require("jass.slk")
local console = require("jass.console")
local runtime = require("jass.runtime")
local dbg = require("jass.debug")
local message = require("jass.message")
local dzapi = require("jass.dzapi")
local PlayerImageHeadUI = require("gameplay.interface.ui.player_image_head")
local PermissionStore = require("gameplay.permission.permission_store")
local OshinoTaboo = require("gameplay.var.advance.oshino_taboo")
local Fengyun = require("gameplay.var.pools.mwx.fengyun_runtime")
local DanganView = require("gameplay.var.pools.mwx.danwanlunpo_view")
local DanganCourt = require("gameplay.var.pools.mwx.danwanlunpo_runtime")
require("xielou")
TestMode2 = false
if DebugText == false then
  TestMode = true
  TestMode2 = true
  Client_ready = true
  japi.UnLockFPS(true)
  japi.ShowFpsText(true)
end

function print(...)
  local arg = {
    ...
  }
  for k, v in ipairs(arg) do
    DisplayTimedTextToPlayer(Player(0), 0, 0, 60, v)
  end
  console.write(...)
end

console.enable = true
ClearTextMessages()
local unit = Hero[1]
if Hero[1] == 0 then
  unit = BOSS_DEATH
end
local u = getunit(unit)
local p = getplayer(u.owner)
local x, y = u:getxy()
local sy = u.ownerid
local jd = u:getface()
local angle = u:getface()

local function test_auto_start_and_select()
  if Hero[1] ~= 0 then
    return false
  end
  local start_button = ac.sync_key_map and ac.sync_key_map.nanduselect_end
  if not start_button then
    print("[TEST_BOOT] 开始游戏按钮尚未注册")
    return true
  end
  local start_player_id = SeletPlayerID or 1
  start_button:event_callback("on_sync_button_clicked", player[start_player_id])
  ac.wait(3000, function()
    local target = HeroAll["圣白莲"]
    if not target then
      print("[TEST_BOOT] 未找到圣白莲")
      return
    end
    HeroSelectConfirm(target, player[1].handle)
    if not HeroSelectConfirm(target, player[1].handle) then
      print("[TEST_BOOT] 圣白莲双击选择失败")
      return
    end
    ac.wait(3000, function()
      local selected = Hero[1]
      if selected ~= 0 and Player_Select[1] and getunit(selected).type == HeroType["圣白莲"] then
        print("[TEST_BOOT] 圣白莲选择完成，请再次按 F5")
      else
        print("[TEST_BOOT] 圣白莲选择失败")
      end
    end)
  end)
  return true
end

if test_auto_start_and_select() then
  return
end
StopSoundBJ(BGM_Start, false)
BGMChangeTime = 0
BGMBoolean[sy] = false
if BGMBoolean[LocalPlayerID] == true and not BGMIsChange then
  SetSoundVolumeBJ(BGM, 100.0)
else
  SetSoundVolumeBJ(BGM, 0.0)
end
FogEnable(false)
FogMaskEnable(false)

function bazicj()
  local x2, y2 = PolarXY(x, y, 1000, jd)
  local mj = CreateMonster("h008", x2, y2, 0)
  mj = getunit(mj)
  mj:setdata("伤害测试标记")
  bossstateset(mj)
  return mj
end

u:setdata("残机剩余数量", 10000)
u:setusedfodd(u:getdata("残机剩余数量"))
u:addgold(10000000)
u:addwood(10000000)
TalentCode[sy] = 1000
Hero_Tili_Huifu[sy] = 1000
local test_fengyun = false
if test_fengyun then
  local request = class.button:builder({
    x = 0,
    y = 0,
    w = 1,
    h = 1,
    sync_key = "test_fengyun",
    on_sync_button_clicked = function(self, sender)
      self:destroy()
      if sender.id ~= 1 or Hero[1] ~= unit then
        return
      end
      if not u:hasdata("变异判定-风云") then
        assert(Fengyun.can_start(u), "[TEST_FENGYUN] 风云已卸载，请重新开局")
        local result = herogetvar(unit, {
          Vars_Mwx
        }, "冥王星", "风云")
        assert(result == "风云" and u:hasdata("变异判定-风云"), "[TEST_FENGYUN] 启动获取失败，请检查启动负载与公共前置")
      end
      local added = 0
      for _, var in ipairs(Vars_Mwx_Fengyun) do
        if not u:hasdata("变异判定-" .. var.name) and Fengyun.can_get(u, var) then
          local result = herogetvar(unit, {
            Vars_Mwx_Fengyun
          }, "冥王星", var.name)
          assert(result == var.name and u:hasdata("变异判定-" .. var.name), "[TEST_FENGYUN] 武学获取失败：" .. var.name)
          added = added + 1
        end
      end
      if not MJTEST then
        local tx, ty = PolarXY(x, y, 1000, jd)
        local target = getunit(CreateMonster("h008", tx, ty, 0))
        target:setdata("伤害测试标记")
        bossstateset(target)
        target:setmaxhp(1500000000)
        MJTEST = target
      end
      print(("[TEST_FENGYUN] 本次新增%d门武学，已放置伤害木桩"):format(added))
      print("[TEST_FENGYUN] 启动图标左键选聂风、右键选步惊云；选线后再按F5补齐该线武学")
      print("[TEST_FENGYUN] 外功打木桩修炼，刀系/徒手对应加速；轻功步行或Q/W；内功存活每秒成长")
      print("[TEST_FENGYUN] 主修三门圆满后右键兼修，再按F5补齐另一线；不刷满、不重置进度")
    end
  })
  request:hide()
  game.add_event_sync(request, "on_button_clicked")
  return
end
local test_sam = false
if test_sam then
  local test_sam_finale = false
  for id = 2, 6 do
    if player[id]:isplayer() then
      print("[TEST_SAM] 仅支持单人手测")
      return
    end
  end
  local request = class.button:builder({
    x = 0,
    y = 0,
    w = 1,
    h = 1,
    sync_key = "test_sam",
    on_sync_button_clicked = function(self, sender)
      self:destroy()
      if sender.id ~= 1 then
        return
      end
      if ExBossBattle then
        print("[TEST_SAM] 当前挑战尚未结束")
        return
      end
      if not u:isalive() then
        HeroRelive(unit, x, y, 3)
      end
      local boss = getunit(BOSS_Sam)
      assert(boss and GetWidgetLife(boss.handle) > 0.405, "[TEST_SAM] 山姆原生单位不存在或已死亡")
      boss:setxy(x + 300, y)
      package.loaded["gameplay.monster.boss.Sam"] = nil
      package.loaded["gameplay.monster.boss.sam_actions"] = nil
      package.loaded["gameplay.monster.boss.sam_guard"] = nil
      require("gameplay.monster.boss.Sam")
      local session = boss_sam(boss.handle)
      if type(session) ~= "table" then
        error("[TEST_SAM] 山姆战斗未启动")
      end
      print("[TEST_SAM] 已启动，复仇=" .. tostring(session.revenge) .. "，难度=" .. session.difficulty)
      if test_sam_finale then
        ac.wait(8000, function()
          if session.active then
            boss:sethp(1, true)
          end
        end)
      end
    end
  })
  request:hide()
  game.add_event_sync(request, "on_button_clicked")
  return
end
if not MJTEST then
  local mj = bazicj()
  mj:setmaxhp(1500000000)
  MJTEST = mj
end
local mj = MJTEST
u:changedata("往世乐土-商店剩余刷新次数", 9999)
local test_alt_icon_chat = false
if test_alt_icon_chat then
  for id = 2, 6 do
    if player[id]:isplayer() then
      print("[TEST_ALT] 仅支持单人手测")
      return
    end
  end
  local request = class.button:builder({
    x = 0,
    y = 0,
    w = 1,
    h = 1,
    sync_key = "test_alt_icon_chat",
    on_sync_button_clicked = function(self, sender)
      self:destroy()
      if sender.id ~= sy or Hero[sy] ~= unit then
        return
      end
      local key = "TEST-Alt图标喊话"
      local session = u:hasdata(key) and u:getdata(key)
      
      local function cleanup()
        for _, trigger in ipairs(session.triggers) do
          jass.DestroyTrigger(trigger)
        end
        if session.item ~= 0 then
          jass.RemoveItem(session.item)
        end
        if session.unit ~= 0 then
          jass.RemoveUnit(session.unit)
        end
        u:deldata(key)
        if sender.handle == GetLocalPlayer() then
          ClearSelection()
          SelectUnit(unit, true)
        end
      end
      
      if session then
        local charges = jass.GetItemCharges(session.item)
        print(("[TEST_ALT] 第%d轮：药水喊话=%d 技能喊话=%d 总喊话=%d 使用=%d 施法=%d 剩余次数=%d"):format(session.phase, session.item_chat, session.skill_chat, session.chat, session.uses, session.casts, charges))
        local passed
        if session.phase == 1 then
          passed = session.item_chat == 1 and session.skill_chat == 1 and session.chat == 2 and session.uses == 0 and session.casts == 0 and charges == 3
        else
          passed = session.chat == 0 and session.uses == 1 and session.casts == 1 and charges == 2
        end
        if not passed then
          print("[TEST_ALT] FAIL：次数不符或尚未完成点击。资源已清理，再按 F5 重试")
          cleanup()
          return
        end
        print("[TEST_ALT] PASS：第" .. session.phase .. "轮")
        if session.phase == 2 then
          cleanup()
          print("[TEST_ALT] 完成：Alt 只喊话，普通左键正常执行。测试资源已清理")
          return
        end
        session.phase = 2
        session.item_chat, session.skill_chat, session.chat = 0, 0, 0
        session.uses, session.casts = 0, 0
        print("[TEST_ALT] 第2轮：松开 Alt，普通左键药水一次、疾风步一次；等待技能生效，再按 F5")
        return
      end
      session = {
        phase = 1,
        unit = 0,
        item = 0,
        triggers = {},
        item_chat = 0,
        skill_chat = 0,
        chat = 0,
        uses = 0,
        casts = 0
      }
      u:setdata(key, session)
      local ability_id = S2ID("AOwk")
      local ok = xpcall(function()
        local tx, ty = u:getxy()
        session.unit = jass.CreateUnit(sender.handle, S2ID("Obla"), tx + 250, ty, 0)
        assert(session.unit ~= 0, "[TEST_ALT] 测试剑圣创建失败")
        jass.UnitAddAbility(session.unit, S2ID("AInv"))
        jass.UnitAddAbility(session.unit, ability_id)
        assert(0 < jass.GetUnitAbilityLevel(session.unit, ability_id), "[TEST_ALT] 疾风步添加失败")
        jass.SetUnitInvulnerable(session.unit, true)
        jass.SetUnitState(session.unit, jass.UNIT_STATE_MANA, 100)
        session.item = jass.CreateItem(S2ID("pman"), tx + 250, ty)
        assert(session.item ~= 0 and jass.UnitAddItem(session.unit, session.item), "[TEST_ALT] 药水加入原生物品栏失败")
        jass.SetItemCharges(session.item, 3)
        local item_text = "物品：【" .. jass.GetItemName(session.item) .. "】"
        local skill_text = "技能：【" .. jass.GetObjectName(ability_id) .. "】"
        local chat = jass.CreateTrigger()
        session.triggers[#session.triggers + 1] = chat
        japi.DzTriggerRegisterSyncData(chat, "ChatTool", false)
        jass.TriggerAddAction(chat, function()
          if japi.DzGetTriggerSyncPlayer() ~= sender.handle then
            return
          end
          local text = japi.DzGetTriggerSyncData()
          session.chat = session.chat + 1
          if text == item_text then
            session.item_chat = session.item_chat + 1
          elseif text == skill_text then
            session.skill_chat = session.skill_chat + 1
          end
          print("[TEST_ALT] 收到真实喊话：" .. text)
        end)
        local use = jass.CreateTrigger()
        session.triggers[#session.triggers + 1] = use
        jass.TriggerRegisterUnitEvent(use, session.unit, jass.EVENT_UNIT_USE_ITEM)
        jass.TriggerAddAction(use, function()
          if jass.GetManipulatedItem() == session.item then
            session.uses = session.uses + 1
            print("[TEST_ALT] 观察到药水实际使用")
          end
        end)
        local spell = jass.CreateTrigger()
        session.triggers[#session.triggers + 1] = spell
        jass.TriggerRegisterUnitEvent(spell, session.unit, jass.EVENT_UNIT_SPELL_EFFECT)
        jass.TriggerAddAction(spell, function()
          if jass.GetSpellAbilityId() == ability_id then
            session.casts = session.casts + 1
            print("[TEST_ALT] 观察到疾风步实际施放")
          end
        end)
      end, runtime.error_handle)
      if not ok then
        cleanup()
        print("[TEST_ALT] FAIL：测试场景初始化失败，资源已清理")
        return
      end
      if sender.handle == GetLocalPlayer() then
        ClearSelection()
        SelectUnit(session.unit, true)
        local available, result = pcall(function()
          return japi.KKCommandButtonGetAbilityId(japi.DzFrameGetCommandBarButton(0, 0))
        end)
        print("[TEST_ALT] KK 接口调用：" .. tostring(available) .. "，返回=" .. tostring(result))
      end
      print("[TEST_ALT] 第1轮：保持选中测试剑圣，按住 Alt，左键魔法药水一次、疾风步一次")
      print("[TEST_ALT] 应各喊话一次，药水仍为3次且不施法；松开 Alt，等待喊话出现，再按 F5 判定")
    end
  })
  request:hide()
  game.add_event_sync(request, "on_button_clicked")
end
