-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local unit = require("jh.ac.unit")
local validTexts = {
  ["伤害判定后效果"] = true,
  ["伤害判定后特效"] = true,
  ["伤害系统计算效果"] = true,
  ["抗性判定后效果"] = true,
  ["怪物减伤计算"] = true,
  ["抗性破坏阶段"] = true,
  ["抗性破坏结算阶段"] = true,
  ["施加流血层数时"] = true,
  ["直接伤害变更"] = true,
  ["直接伤害特效"] = true,
  ["伤害判定前变更"] = true,
  ["英雄直接伤害特效"] = true,
  ["伤害判定前效果"] = true,
  ["暴击系统计算效果"] = true,
  ["超暴系统计算效果"] = true,
  ["暴击系统触发效果"] = true,
  ["终结伤害计算效果"] = true,
  ["BOSS减伤计算"] = true,
  ["伤害吸血效果"] = true,
  ["伤害吸血结算效果"] = true,
  ["近战伤害效果"] = true,
  ["近战伤害特效"] = true,
  ["伤害显示后效果"] = true,
  ["武器使用后效果"] = true,
  ["枪械装弹时效果"] = true,
  ["子弹创建时效果"] = true,
  ["子弹碰撞时效果"] = true,
  ["子弹伤害前效果"] = true,
  ["子弹伤害后效果"] = true,
  ["位移技能后效果"] = true,
  ["脚本位移后效果"] = true,
  ["进入战斗状态时"] = true,
  ["脱离战斗状态时"] = true,
  ["受到医疗恢复时"] = true,
  ["伤害格挡效果"] = true,
  ["受伤后效果"] = true,
  ["绝对闪避伤害时效果"] = true,
  ["英雄升级时效果"] = true,
  ["过波时效果"] = true,
  ["波数开始时效果"] = true,
  ["决死效果"] = true,
  ["决死效果触发后"] = true,
  ["杀敌效果"] = true,
  ["英雄死亡时效果"] = true
}
local buff = {
  "永恒",
  "停滞",
  "锁定",
  "飞行",
  "暂停",
  "冰冻",
  "缠绕",
  "混乱",
  "僵直",
  "绝对闪避",
  "麻痹",
  "燃烧",
  "伤害限制",
  "伤害免疫",
  "伤害限制",
  "石化",
  "睡眠",
  "无敌",
  "眩晕",
  "冻结",
  "灼烧"
}
for index, value in ipairs(buff) do
  validTexts["施加Buff时效果-" .. value] = true
  validTexts["被施加Buff时效果-" .. value] = true
end

function unit:delstexiao(id, text)
  local function del_in(tbl)
    if not tbl then
      return
    end
    for i = #tbl, 1, -1 do
      if tbl[i].name == id then
        table.remove(tbl, i)
      end
    end
  end
  
  if text then
    del_in(self[text])
  else
    for k, _ in pairs(validTexts) do
      del_in(self[k])
    end
  end
end

function unit:clearstexiao()
  for k, _ in pairs(validTexts) do
    if rawget(self, k) then
      self[k] = nil
    end
  end
end

function unit:addstexiao(id, text, func)
  if not validTexts[text] then
    print("不存在的伤害特效类型:" .. text .. "/名称：" .. id)
    return
  end
  if not self[text] then
    self[text] = {}
  end
  if self:hasdata("抉择抉择-额外数字") then
    id = id .. self:getdata("抉择抉择-额外数字")
  end
  for index, value in ipairs(self[text]) do
    if value.name == id then
      print("重复的特效:" .. text .. "/名称：" .. id)
      return
    end
  end
  table.insert(self[text], {name = id, func = func})
end

AllTexiao = {}

function AddAllSTexiao(id, text, func)
  if not validTexts[text] then
    print("不存在的全体伤害特效类型:" .. text .. "/名称：" .. id)
    return
  end
  if not AllTexiao[text] then
    AllTexiao[text] = {}
  end
  for index, value in ipairs(AllTexiao[text]) do
    if value.name == id then
      print("重复的全体特效:" .. text .. "/名称：" .. id)
      return
    end
  end
  table.insert(AllTexiao[text], {name = id, func = func})
end

local function run_effect(tbl, text, args)
  local effects = tbl and tbl[text]
  if effects then
    for _, v in ipairs(effects) do
      local trace_move = text == "位移技能后效果" or text == "脚本位移后效果"
      if trace_move then require("hera_move_trace").effect("BEGIN", text, v.name) end
      local diagnostic = args.diagnostic_cirno_qw and require("hera_gameplay_diagnostic")
      if diagnostic then diagnostic.monster("QW_EFFECT_BEGIN", {unit=args.unit, effect=v.name, kind=text}) end
      local round_trace = text == "波数开始时效果" or text == "过波时效果"
      if round_trace then require("hera_gameplay_diagnostic").phase("CARD_BEGIN", {kind=text, effect=v.name, slot=args.u and args.u.ownerid, unit=args.u and args.u.handle}) end
      v.func(args)
      if round_trace then require("hera_gameplay_diagnostic").phase("CARD_END", {kind=text, effect=v.name, slot=args.u and args.u.ownerid, unit=args.u and args.u.handle}) end
      if diagnostic then diagnostic.monster("QW_EFFECT_END", {unit=args.unit, effect=v.name, kind=text}) end
      if trace_move then require("hera_move_trace").effect("END", text, v.name) end
    end
  end
end

function StexiaoFunc(args)
  local text = args.text
  if not text then
    return args
  end
  run_effect(AllTexiao, text, args)
  local u = args.u or (args.unit and getunit(args.unit))
  if u then
    run_effect(u, text, args)
  end
  local tg = args.tg or (args.target and getunit(args.target))
  if tg and tg ~= u then
    run_effect(tg, text, args)
  end
  return args
end
