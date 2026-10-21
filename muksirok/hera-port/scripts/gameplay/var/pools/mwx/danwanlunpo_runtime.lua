-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local View = require("gameplay.var.pools.mwx.danwanlunpo_view")
local Court = {}
local state_key = "弹丸论破-调查"
local series = "弹丸论破"
local bear = "黑白熊"
local hero = "苗木诚"
local detective = "雾切响子"
local detective_ending_played = false
local mastermind = "江之岛盾子"
local pink = "|cFFFF99CC"
local body = "|cFFFFE6F0"
local search_tags = {
  "光明",
  "黑暗",
  "水",
  "炎",
  "冰",
  "雷",
  "影",
  "兽",
  "机械",
  "恶魔",
  "吸血鬼",
  "龙",
  "外域",
  "战士",
  "魔导",
  "同奏",
  "歌姬",
  "根源",
  "不死"
}
local definitions = {}
local appliers = {}
local tasks = {
  {
    kind = "move",
    text = "累计移动|cFF99FFFF30000|r|cFFFFE6F0码"
  },
  {
    kind = "kill",
    text = "击杀|cFF99FFFF50|r|cFFFFE6F0只怪物"
  },
  {
    kind = "box",
    text = "打开|cFF99FFFF20|r|cFFFFE6F0个任意补给箱"
  },
  {
    kind = "medicine",
    text = "使用|cFF99FFFF10|r|cFFFFE6F0瓶任意药剂"
  },
  {
    kind = "legendary",
    text = "获得一个传奇变异"
  },
  {
    kind = "ether2",
    text = "获得一个二阶以太变异"
  },
  {
    kind = "ether3",
    text = "获得一个三阶以太变异"
  }
}
for _, tag in ipairs(search_tags) do
  tasks[#tasks + 1] = {
    kind = "tag",
    tag = tag,
    text = "获得一个" .. tag .. "词条变异"
  }
end
local activity_targets = {
  move = 30000,
  kill = 50,
  box = 20,
  medicine = 10
}
local legendary_types = {
  ["次元"] = true,
  ["鲁纳斯"] = true,
  ["杀戮结晶"] = true,
  ["血坏"] = true,
  ["灵结晶"] = true
}

function Court.color_name(name)
  local chars = {}
  local steps = math.max(utf8.len(name) - 1, 1)
  for _, codepoint in utf8.codes(name) do
    local color = interpolateColor("FF99CC", "FFE6F0", #chars / steps)
    chars[#chars + 1] = "|cFF" .. color .. utf8.char(codepoint) .. "|r"
  end
  return table.concat(chars)
end

function Court.configure(entries, effects)
  definitions = entries
  appliers = effects
end

function Court.get_state(u)
  local state = u:getdata(state_key)
  if type(state) == "table" then
    return state
  end
end

local function student_count(state)
  local count = 0
  for _, var in ipairs(definitions) do
    if var.name ~= bear and state.owned[var.name] then
      count = count + 1
    end
  end
  return count
end

local function clear_movement(u, state)
  if state.move_x ~= nil then
    u:delstexiao(series, "脚本位移后效果")
    state.move_x, state.move_y = nil, nil
  end
end

local function activate_task(u, state, task)
  clear_movement(u, state)
  state.task = task
  state.task_progress = 0
  if task.kind == "move" then
    state.move_x, state.move_y = u:getxy()
    u:addstexiao(series, "脚本位移后效果", function(args)
      if args.u == u then
        state.move_x, state.move_y = u:getxy()
      end
    end)
  end
end

local function new_task(u, state)
  local previous
  local old_task = state.task
  if old_task then
    for index, task in ipairs(tasks) do
      if task.kind == old_task.kind and task.tag == old_task.tag then
        previous = index
        break
      end
    end
  end
  local index = GetRandomInt(1, #tasks - (previous and 1 or 0))
  if previous and previous <= index then
    index = index + 1
  end
  activate_task(u, state, tasks[index])
end

local function new_chains(state)
  local candidates = {}
  for _, var in ipairs(definitions) do
    if var.name ~= bear and not state.dead[var.name] then
      candidates[#candidates + 1] = var.name
    end
  end
  state.chains = {}
  for index = 1, 3 do
    local first = table.remove(candidates, GetRandomInt(1, #candidates))
    local second = table.remove(candidates, GetRandomInt(1, #candidates))
    state.chains[index] = {
      first = first,
      second = second,
      stage = 0
    }
  end
end

local trial_chances = {
  [3] = 0,
  [4] = 33,
  [5] = 67,
  [6] = 100
}

local function chance(state)
  return trial_chances[state.evidence] or 0
end

function Court.describe(u, var)
  local state = Court.get_state(u)
  local text = var.effecttext or ""
  if state and appliers[var.name] then
    local count = state.counts[var.name] or 0
    if 1 < count then
      text = text:gsub("(提升|cFF99FFFF)(%d+%.?%d*)(%%?|r)", function(prefix, value, suffix)
        return prefix .. ("%g"):format(tonumber(value) * count) .. suffix
      end)
    end
  end
  if not state or var.name ~= series then
    return var.effectname .. "\n" .. text
  end
  if state.result_var then
    return state.result_var.effectname .. "\n" .. state.result_var.effecttext
  end
  local extra = {
    pink .. "[学级裁判]" .. body
  }
  extra[#extra + 1] = ("已完成%d/3次，成功%d次，失败%d次"):format(state.trials, state.successes, state.trials - state.successes)
  local task, victim = state.task, state.victim
  if state.stopped then
    extra[#extra + 1] = "搜查已结束"
  elseif state.pending_trial then
    extra[#extra + 1] = ("第%d轮，学级裁判进行中"):format(state.round)
    extra[#extra + 1] = "本轮遇害学生：" .. state.pending_trial.result.victim
    extra[#extra + 1] = "案件结论将在处刑结束后结算"
  elseif not task or not victim then
    extra[#extra + 1] = ("学生集会进度：%d/6"):format(student_count(state))
  else
    extra[#extra + 1] = ("第%d轮，证据%d/6，当前裁判成功率%d%%"):format(state.round, state.evidence, chance(state))
    extra[#extra + 1] = "本轮遇害学生：" .. victim
    extra[#extra + 1] = pink .. "[搜查任务]" .. body
    extra[#extra + 1] = task.text
    local target = activity_targets[task.kind]
    if target then
      extra[#extra + 1] = ("进度：|cFF99FFFF%d/%d|r%s"):format(math.floor(state.task_progress), target, body)
    end
    extra[#extra + 1] = pink .. "[证言链]" .. body
    for _, chain in ipairs(state.chains) do
      local status = chain.stage == 2 and "已完成" or chain.stage == 1 and "关键证人" or "等待前者"
      extra[#extra + 1] = chain.first .. " → " .. chain.second .. "【" .. status .. "】"
    end
  end
  local addition = table.concat(extra, "\n") .. "|r"
  local prerequisite = text:find("【前置】", 1, true)
  if prerequisite then
    text = text:sub(1, prerequisite - 1) .. addition .. "\n" .. body .. text:sub(prerequisite)
  else
    text = text .. "\n" .. addition
  end
  return var.effectname .. "\n" .. text
end

local function refresh(u, state)
  local rows = {
    {
      var = state.start_var,
      text = Court.describe(u, state.start_var),
      icon = state.result_var and state.result_var.effectart or state.start_var.effectart,
      dead = false
    }
  }
  for _, var in ipairs(definitions) do
    if state.owned[var.name] then
      rows[#rows + 1] = {
        var = var,
        text = Court.describe(u, var),
        dead = state.dead[var.name] == true
      }
    end
  end
  View.refresh(u, rows)
end

function Court.can_get(u, var)
  local state = Court.get_state(u)
  if not state or state.stopped or state.ending or state.pending_trial or state.dead[var.name] or state.culprits[var.name] or state.taken[var.name] == state.round then
    return false
  end
  return state.owned[var.name] == true or Chengzaishangxianpanding(u, var.lv)
end

function Court.acquire_student(u, var)
  local state = Court.get_state(u)
  if not state or state.stopped or state.ending or state.pending_trial or state.dead[var.name] or state.culprits[var.name] then
    return
  end
  if not state.owned[var.name] then
    MwxTongyong(u, var)
    state.owned[var.name] = true
  end
  state.taken[var.name] = state.round
  appliers[var.name](u, 1)
  state.counts[var.name] = (state.counts[var.name] or 0) + 1
end

function Court.remove_student(u, var)
  local state = Court.get_state(u)
  if not state or not state.owned[var.name] then
    return
  end
  appliers[var.name](u, -(state.counts[var.name] or 0))
  state.counts[var.name] = nil
  state.owned[var.name] = nil
end

local function task_matches(task, var, vartype)
  if task.kind == "legendary" then
    return legendary_types[vartype] == true
  elseif task.kind == "ether2" or task.kind == "ether3" then
    return vartype == "以太" and var.lv == (task.kind == "ether2" and 2 or 3)
  elseif task.kind ~= "tag" then
    return false
  end
  for _, tag in ipairs(var.key or {}) do
    if tag == task.tag then
      return true
    end
  end
  return false
end

local function student_candidates(state, role, excluded, allow_mastermind)
  local candidates = {}
  for _, var in ipairs(definitions) do
    local name = var.name
    local allowed = name ~= bear and name ~= excluded and not state.dead[name] and not state.culprits[name]
    if role == "victim" then
      allowed = allowed and name ~= hero and name ~= detective and name ~= mastermind
    elseif role == "culprit" then
      allowed = allowed and name ~= hero and name ~= detective and (name ~= mastermind or allow_mastermind == true)
    else
      allowed = allowed and name ~= hero and name ~= mastermind
    end
    if allowed then
      candidates[#candidates + 1] = name
    end
  end
  return candidates
end

local function choose_student(state, role, excluded, allow_mastermind)
  local candidates = student_candidates(state, role, excluded, allow_mastermind)
  return candidates[GetRandomInt(1, #candidates)], candidates
end

local function begin_round(u, state)
  state.round = state.trials + 1
  state.evidence = 0
  local victim = choose_student(state, "victim")
  state.victim = victim
  state.dead[victim] = true
  u:sendmessage(body .. "尸体被发现，" .. victim .. "被杀害了！|r")
  new_task(u, state)
  new_chains(state)
end

local function finish(u, state)
  clear_movement(u, state)
  state.task = nil
  state.victim = nil
  state.task_progress = 0
  local name, text, icon
  local detective_ending = state.history[3].executed == detective and not detective_ending_played
  if state.successes == 3 then
    state.ending = "hope"
    name = "超高校级的希望"
    icon = "Mwx_Xwxy_Xiwang.tga"
    u:addallstats(250)
    ChangeValue(DamageSystem_Shjc, u.ownerid, 0.5)
    ChangeValue(DamageSystem_EndSh, u.ownerid, 0.1)
    text = "提升250点全属性\n提升50%伤害加成\n提升10%终结伤害\n" .. pink .. "[希望的延续]" .. body .. "\n过波时,未淘汰的每名学生各增加一次自身属性收益"
  elseif state.successes == 0 then
    state.ending = "despair"
    name = "超高校级的绝望"
    icon = "Mwx_Xwxy_Juewang.tga"
    u:changedata("系统-启动负载力", -state.start_load)
    text = ("返还%g点启动负载\n保留全部已获得属性"):format(state.start_load)
    state.start_load = 0
  else
    state.ending = "mixed"
    name = "未完成的真相"
    icon = "Mwx_Xwxy_Weichamingdezhenxiang.tga"
    text = "过波时，苗木诚增加一次自身属性收益\n保留全部已获得属性"
  end
  if detective_ending then
    detective_ending_played = true
    icon = "Mwx_Xwxy_Xiangzichuxing.tga"
  end
  state.last_wave = Stage - (Boolean_GuoboInterval and 1 or 0)
  state.chains = {}
  state.evidence = 0
  local var = {
    name = name,
    lv = 3,
    key = {"结局"},
    seckey = series,
    effectname = Court.color_name(name),
    effecttext = body .. "结局\n【所属】弹丸论破\n" .. ("已完成3/3次，成功%d次，失败%d次\n"):format(state.successes, 3 - state.successes) .. pink .. "[" .. name .. "]" .. body .. "\n" .. text .. "\n" .. pink .. "[左键]" .. body .. "查看调查名单|r",
    effectart = icon
  }
  state.result_var = var
  u:sendmessage(pink .. "[弹丸论破]" .. body .. "结局：" .. name .. "|r")
  return detective_ending
end

local opening_dialogue = {
  {
    time = 0,
    text = "|cffb9b9b9那么，开场白到此为止了|r"
  },
  {
    time = 3700,
    text = "|cffb9b9b9差不多要准备开始了！|r"
  },
  {
    time = 6100,
    text = "|cffb9b9b9首先是案件总结|r"
  },
  {
    time = 10100,
    text = "|cffb9b9b9现在，学级裁判……开始！|r"
  }
}

local function guarded_presentation(label, callback)
  local ok, err = xpcall(callback, debug.traceback)
  if not ok then
    print("弹丸论破裁判表现错误：" .. label, err)
  end
end

local function play_hope_ending(u, state)
  local timers = {}
  state.ending_timers = timers
  
  local function wait(delay, callback)
    timers[#timers + 1] = ac.wait(delay, function()
      if Court.get_state(u) == state and not state.stopped then
        callback()
      end
    end)
  end
  
  wait(1500, function()
    u:chat("虽然不知道该怎么形容……")
  end)
  wait(2000, function()
    PlayBGM({
      bgm = "BGM_Dwlp_01",
      time = 195,
      ID = 267,
      unit = u.handle
    })
    guarded_presentation("希望结局歌词", View.play_hope_lyrics)
  end)
  wait(3500, function()
    state.ending_timers = nil
    u:chat("果然……是毕业吧？")
  end)
  guarded_presentation("希望结局语音", function()
    PlayGlobalSound("Sound_Dwlp_08")
  end)
  u:chat("这……")
end

local function play_mixed_ending()
  guarded_presentation("未查明真相结局语音", function()
    PlayGlobalSound("Sound_Dwlp_07")
  end)
  NPCChat({
    name = "|cFFCCCCCC黑|r|cFF999999白|r|cFF666666熊|r",
    chaticon = "Chat_Heibaixiong.tga",
    chattext = {
      {
        text = "|cFF999999嗯咳，这是来自希望峰学园校外教学执行委员会的通知……",
        time = 0.6
      },
      {
        text = "|cFF999999现在时间是晚上10点",
        time = 7.1
      },
      {
        text = "|cFF999999请一边听着浪潮声,一边安稳入眠吧",
        time = 9.2
      },
      {
        text = "|cFF999999那么就祝各位有个好梦",
        time = 15.1
      },
      {
        text = "|cFF999999Good Night~",
        time = 17.7
      }
    }
  })
end

local function trial_is_active(u, state, session)
  return Court.get_state(u) == state and not state.stopped and state.pending_trial == session
end

local function schedule_trial(u, state, session, delay, callback)
  local timer = ac.wait(delay, function()
    if not trial_is_active(u, state, session) then
      return
    end
    callback()
  end)
  session.timers[#session.timers + 1] = timer
end

local function cancel_trial(state)
  local session = state.pending_trial
  if not session then
    return
  end
  state.pending_trial = nil
  for _, timer in ipairs(session.timers) do
    timer:remove()
  end
  session.timers = {}
end

local function execute_trial_result(u, state, session)
  local result = session.result
  state.dead[result.executed] = true
  if not result.success then
    state.culprits[result.culprit] = true
  end
  guarded_presentation("处刑音效", function()
    u:playselfsound("Sound_Dwlp_01")
  end)
  guarded_presentation("处刑字幕", function()
    u:sendmessage(body .. result.executed .. "已被处刑|r")
  end)
  guarded_presentation("处刑名单刷新", function()
    refresh(u, state)
  end)
end

local function settle_trial(u, state, session)
  local result = session.result
  state.pending_trial = nil
  session.timers = {}
  state.trials = state.trials + 1
  state.history[state.trials] = result
  if result.success then
    state.successes = state.successes + 1
  end
  state.evidence = 0
  if state.trials == 3 then
    local detective_ending = finish(u, state)
    if detective_ending then
      PlayBGM({
        bgm = "BGM_Dwlp_02",
        time = 82,
        ID = 267,
        unit = u.handle
      })
    end
    if state.ending == "hope" then
      play_hope_ending(u, state)
    elseif state.ending == "mixed" then
      play_mixed_ending()
    end
  else
    begin_round(u, state)
  end
  guarded_presentation("裁判结算刷新", function()
    refresh(u, state)
  end)
end

function Court.trial(u)
  local state = Court.get_state(u)
  if not state or state.stopped or state.ending or state.pending_trial or state.trials >= 3 then
    return false
  end
  if not state.victim then
    u:sendmessage(body .. "[学级裁判]先招募6名不同学生，发现尸体后才能调查|r")
    return false
  end
  if 3 > state.evidence then
    u:sendmessage(body .. "[学级裁判]至少需要3条证据|r")
    return false
  end
  local success = state.evidence == 6
  if state.evidence == 4 or state.evidence == 5 then
    success = GetRandom100(chance(state))
  end
  local culprit = choose_student(state, "culprit", nil, not success and state.trials == 2)
  local accused, candidate_names
  if not success and state.trials == 2 and state.owned[detective] and not state.dead[detective] then
    accused = detective
    candidate_names = student_candidates(state, "accused", culprit)
  else
    accused, candidate_names = choose_student(state, "accused", culprit)
  end
  local executed = success and culprit or accused
  if success then
    candidate_names[#candidate_names + 1] = culprit
  end
  local result = {
    success = success,
    victim = state.victim,
    culprit = culprit,
    accused = accused,
    executed = executed
  }
  local session = {
    result = result,
    candidate_names = candidate_names,
    timers = {}
  }
  state.pending_trial = session
  local timing = View.trial_timing
  local title_start = timing.opening_sound + timing.title_delay
  local title_end = title_start + timing.title_enter + timing.title_hold + timing.title_exit
  local rebuttal_start = title_end + timing.rebuttal_delay
  local reveal_time = rebuttal_start + timing.rebuttal_enter + timing.rebuttal_pulse + timing.rebuttal_fade
  local slots_start = success and reveal_time + timing.slots_delay or title_end
  local execution_time = slots_start + timing.slots
  local settlement_time = execution_time + timing.execution
  for _, line in ipairs(opening_dialogue) do
    local dialogue = line
    schedule_trial(u, state, session, dialogue.time, function()
      NPCChat({
        sy = u.ownerid,
        name = "|cFFCCCCCC黑|r|cFF999999白|r|cFF666666熊|r",
        chaticon = "Chat_Heibaixiong.tga",
        chattext = {
          {
            text = dialogue.text,
            time = 0
          }
        }
      })
    end)
  end
  schedule_trial(u, state, session, timing.opening_sound, function()
    u:playselfsound("Sound_Dwlp_03")
  end)
  schedule_trial(u, state, session, title_start, function()
    View.play_trial_title(u)
  end)
  schedule_trial(u, state, session, title_end, function()
    guarded_presentation("裁判指认字幕", function()
      u:sendmessage(body .. "案件凶手指向:" .. result.accused .. "|r")
    end)
    if not success then
      guarded_presentation("裁判处刑转盘", function()
        View.play_trial_slots(u, result.executed, session.candidate_names)
      end)
    end
  end)
  if success then
    schedule_trial(u, state, session, rebuttal_start, function()
      View.play_trial_rebuttal(u)
    end)
    schedule_trial(u, state, session, reveal_time, function()
      guarded_presentation("真凶字幕", function()
        u:sendmessage(body .. "指出真正的凶手为:" .. result.culprit .. "|r")
      end)
    end)
    schedule_trial(u, state, session, slots_start, function()
      guarded_presentation("裁判处刑转盘", function()
        View.play_trial_slots(u, result.executed, session.candidate_names)
      end)
    end)
  end
  schedule_trial(u, state, session, execution_time, function()
    execute_trial_result(u, state, session)
  end)
  schedule_trial(u, state, session, settlement_time, function()
    settle_trial(u, state, session)
  end)
  clear_movement(u, state)
  state.task = nil
  state.task_progress = 0
  guarded_presentation("裁判初始音效", function()
    u:playselfsound("Sound_Dwlp_04")
  end)
  guarded_presentation("裁判进行中说明刷新", function()
    refresh(u, state)
  end)
  return true
end

function Court.add_evidence(u, evidence)
  local state = Court.get_state(u)
  if not state or state.stopped or state.ending or state.pending_trial or not state.victim then
    return false
  end
  if 0 < evidence then
    state.evidence = math.min(6, state.evidence + evidence)
    u:sendmessage(body .. ("[搜查]获得%d条证据，当前%d/6|r"):format(evidence, state.evidence))
  end
  if state.evidence == 6 then
    Court.trial(u)
  else
    refresh(u, state)
  end
  return true
end

local function advance_activity(u, kind, amount)
  local state = Court.get_state(u)
  if not (state and not state.stopped and not state.ending and not state.pending_trial and state.task) or state.task.kind ~= kind or amount <= 0 then
    return
  end
  local before = state.task_progress
  state.task_progress = math.min(activity_targets[kind], before + amount)
  if state.task_progress == activity_targets[kind] then
    new_task(u, state)
    Court.add_evidence(u, 1)
  elseif kind ~= "move" or math.floor(before / 100) ~= math.floor(state.task_progress / 100) then
    View.refresh(u, {
      {
        var = state.start_var,
        text = Court.describe(u, state.start_var),
        dead = false
      }
    })
  end
end

function Court.on_move(u, distance)
  advance_activity(u, "move", distance)
end

function Court.sample_move(u, extra_distance)
  local state = Court.get_state(u)
  if not (state and not state.stopped and not state.ending and state.task) or state.task.kind ~= "move" then
    return
  end
  local x, y = u:getxy()
  local old_x, old_y = state.move_x, state.move_y
  state.move_x, state.move_y = x, y
  if not (old_x ~= nil and old_y ~= nil and u:isalive()) or u:gethp() <= 0 or IsUnitPaused(u.handle) or u:hasbuff("暂停") or u:hasdata("电影模式") or u:hasdata("系统-已删模") or u.owner == Player(PLAYER_NEUTRAL_PASSIVE) then
    return
  end
  Court.on_move(u, extra_distance or DistanceXY(old_x, old_y, x, y))
end

function Court.on_kill(u)
  advance_activity(u, "kill", 1)
end

function Court.on_box(u)
  advance_activity(u, "box", 1)
end

function Court.on_medicine(u)
  advance_activity(u, "medicine", 1)
end

function Court.on_acquired(u, var, vartype)
  local state = Court.get_state(u)
  if not state or state.stopped or state.ending or state.pending_trial then
    return
  end
  if not state.victim then
    if 6 <= student_count(state) then
      begin_round(u, state)
    end
    refresh(u, state)
    return
  end
  if var.name == series or var.name == bear then
    refresh(u, state)
    return
  end
  local evidence = 0
  if state.task and task_matches(state.task, var, vartype) then
    evidence = evidence + 1
    new_task(u, state)
  end
  for _, chain in ipairs(state.chains) do
    if chain.stage == 0 and chain.first == var.name and appliers[var.name] then
      chain.stage = 1
    elseif chain.stage == 1 and chain.second == var.name and appliers[var.name] then
      chain.stage = 2
      evidence = evidence + 1
    end
  end
  Court.add_evidence(u, evidence)
end

function Court.on_wave(u, wave_number)
  local state = Court.get_state(u)
  if not state or state.stopped or state.pending_trial or wave_number <= state.last_wave then
    return
  end
  state.last_wave = wave_number
  if not state.ending and state.victim then
    new_task(u, state)
  elseif state.ending == "hope" or state.ending == "mixed" then
    for _, var in ipairs(definitions) do
      local name = var.name
      if name ~= bear and state.owned[name] and not state.dead[name] and not state.culprits[name] and (state.ending == "hope" or name == hero) then
        appliers[name](u, 1)
        state.counts[name] = (state.counts[name] or 0) + 1
      end
    end
  end
  refresh(u, state)
end

function Court.start(u, var)
  if Court.get_state(u) then
    return
  end
  local before = u:getdata("系统-启动负载力")
  MwxQidongGet(u, var)
  local state = {
    round = 0,
    trials = 0,
    successes = 0,
    evidence = 0,
    owned = {},
    counts = {},
    taken = {},
    dead = {},
    culprits = {},
    chains = {},
    history = {},
    task_progress = 0,
    last_wave = Stage - (Boolean_GuoboInterval and 1 or 0),
    start_var = var,
    start_load = u:getdata("系统-启动负载力") - before
  }
  u:setdata(state_key, state)
  u:addstexiao(series, "波数开始时效果", function(args)
    if args.u == u then
      Court.on_wave(u, Stage)
    end
  end)
  refresh(u, state)
end

function Court.stop(u)
  local state = Court.get_state(u)
  if state then
    state.stopped = true
    cancel_trial(state)
    if state.ending_timers then
      for _, timer in ipairs(state.ending_timers) do
        timer:remove()
      end
      state.ending_timers = nil
    end
    clear_movement(u, state)
    state.task = nil
    state.victim = nil
    state.chains = {}
    state.task_progress = 0
  end
  u:delstexiao(series, "波数开始时效果")
  guarded_presentation("裁判表现清理", function()
    View.stop_trial(u)
  end)
end

return Court
