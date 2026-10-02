-- 실제 피해 함수와 신쿠 보호 해제 타이머를 Lua 모의 환경에서 검증한다.
local no_op = function() end
function require(name)
  if name:match('^combat%.') then return no_op end
  return {}
end
local unit = assert(load(unit_source, '@unit.lua'))()
assert(load(damage_source, '@damagemonster.lua'))()
-- 피해량 산식과 외부 이펙트만 대체하고 실제 차단 분기와 체력 차감은 실행한다.
for i = 1, 100 do
  local name = debug.getupvalue(damagefunc, i)
  if not name then break end
  if name ~= '_ENV' and name ~= 'isDamageInvalid' then
    debug.setupvalue(damagefunc, i, no_op)
  end
end
local zeroes = setmetatable({}, {__index = function() return 0 end})
Correction_Magic_Count = zeroes
DamageSystem_Txsh = zeroes
Nandu_Choose = 3
Group_PlayHero = {}
Group_AllHero = {}
local effects = 0
function StexiaoFunc() effects = effects + 1 end
local serial = 0
local function make_unit(is_shinku)
  serial = serial + 1
  local u = {handle = serial, ownerid = 1, user_data = {['生命值'] = 1000}}
  if is_shinku then u.user_data['BOSS-真红'] = true end
  function u:hasdata(k) return self.user_data[k] ~= nil and self.user_data[k] ~= false end
  function u:getdata(k) return self.user_data[k] or 0 end
  function u:setdata(k, v) self.user_data[k] = v == nil and true or v end
  function u:deldata(k) self.user_data[k] = nil end
  function u:changedata(k, v) self:setdata(k, self:getdata(k) + v) end
  function u:gethp() return self:getdata('生命值') end
  function u:getmaxhp() return 1000 end
  function u:sethp(v, percent) self:setdata('生命值', percent and v * 10 or v) end
  function u:isalive() return self:gethp() > 0 end
  function u:hasbuff() return false end
  function u:ishasskill() return false end
  function u:isingroup() return false end
  function u:isboss() return self:hasdata('BOSS-真红') end
  function u:getshenxing() return 0 end
  function u:getownerid() return self.ownerid end
  function u:getxy() return 0, 0 end
  function u:flashhp() self.flashes = (self.flashes or 0) + 1 end
  return setmetatable(u, {__index = unit})
end
local source = make_unit(false)
local function hit(u, amount, vest, before_display)
  local info = {u = u, soc = source, hero = source, sy2 = 1, damage = amount,
    yssh = amount, level = 1, element = '无', damagetype = '物理',
    isvestdamage = vest or false, ismeleedamage = false,
    ignore_boss_cap = true, before_display = before_display}
  damagefunc(info)
  return info
end
local count = 0
local function check(value, message)
  assert(value, message)
  count = count + 1
end
local flags = {'永恒之轮', '真红永恒', '真红-世界之羽永恒'}
for _, flag in ipairs(flags) do
  local u = make_unit(true)
  u:setdata(flag)
  effects = 0
  hit(u, 100)
  check(u:gethp() == (patched and 1000 or 900), flag .. ': regular damage')
  if patched then check(effects == 0 and not u.flashes, flag .. ': no hit effects') end
  u:sethp(1000)
  hit(u, 100, true)
  check(u:gethp() == (patched and 1000 or 900), flag .. ': additional damage')
  u:sethp(1000)
  u:damagelosshp(2000, source)
  check(u:gethp() == (patched and 1000 or -1000), flag .. ': lethal direct damage')
  u:sethp(1000)
  u:setdata('小爱帮助')
  u:losshp(source, 20, 0, 0)
  check(u:gethp() == (patched and 1000 or 994), flag .. ': life loss')
  check(not u:hasdata('生命值-损耗判定中'), flag .. ': no stuck life loss lock')
  u:sethp(500)
  u:damagelosshp(-100, source)
  check(u:gethp() == 600, flag .. ': healing preserved')
  u:deldata(flag)
  u:sethp(1000)
  hit(u, 100)
  check(u:gethp() == 900, flag .. ': damage after removal')
  u:sethp(1000)
  u:losshp(source, 20, 0, 0)
  check(u:gethp() == 994, flag .. ': life loss after removal')
  local other = make_unit(false)
  other:setdata(flag)
  hit(other, 100)
  check(other:gethp() == 900, flag .. ': unrelated unit unchanged')
end
if patched then
  local u = make_unit(true)
  hit(u, 2000, false, function() u:setdata('永恒之轮') end)
  check(u:gethp() == 1000, 'protection activated during damage calculation')
  u:deldata('永恒之轮')
  hit(u, 2000)
  check(u:gethp() < 0, 'unprotected lethal damage preserved')
  -- 원본 보스 스크립트의 90초/180초 콜백을 그대로 실행한다.
  local timer_callback
  ac = {loop = function(ms, callback)
    assert(ms == 1000)
    timer_callback = callback
  end}
  SendMsgAll = no_op
  local start_expiry = assert(load('return function(u)\n' .. expiry_source .. '\nend'))()
  for _, assisted in ipairs({false, true}) do
    local boss = make_unit(true)
    boss:setdata('永恒之轮')
    if assisted then boss:setdata('两仪式帮助') end
    start_expiry(boss)
    local timer = {remove = function(self) self.removed = true end}
    local seconds = assisted and 90 or 180
    for tick = 1, seconds - 1 do timer_callback(timer) end
    hit(boss, 100)
    check(boss:gethp() == 1000 and not timer.removed, 'protected before expiry')
    timer_callback(timer)
    hit(boss, 100)
    check(boss:gethp() == 900 and timer.removed, 'damage resumes at expiry')
  end
  local boss = make_unit(true)
  boss:setdata('永恒之轮')
  boss:setdata('真红永恒')
  boss:deldata('永恒之轮')
  hit(boss, 100)
  check(boss:gethp() == 1000, 'other active protection survives ring expiry')
end
return count
