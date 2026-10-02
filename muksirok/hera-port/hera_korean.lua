-- 게임 데이터 키는 유지하고 화면에 표시하는 공통 문구만 한국어로 바꾼다.
local dialogue_weather = require('hera_korean_dialogue_weather')
local M = {font = 'Fonts\\NanumGothic-Regular.ttf'}
local live_templates = require('hera_korean_live_templates')
local displayed_tags = {
  ['光明']='빛', ['黑暗']='어둠', ['水']='물', ['炎']='화염', ['冰']='얼음', ['土']='대지',
  ['风']='바람', ['雷']='번개', ['毒']='독', ['影']='그림자', ['兽']='야수', ['机械']='기계',
  ['恶魔']='악마', ['吸血鬼']='흡혈귀', ['龙']='용', ['外域']='외역', ['战士']='전사',
  ['魔导']='마도', ['同奏']='합주', ['东方']='동방', ['童话']='동화', ['歌姬']='가희',
  ['根源']='근원', ['自然']='자연', ['不死']='불사', ['星']='별', ['虫']='곤충', ['蛇']='뱀',
  ['源石']='오리지늄', ['念力']='염력', ['灵魂']='영혼', ['三国']='삼국', ['德丽莎']='테레사',
  ['唯一']='유일', ['巫女']='무녀', ['珠泪哀歌']='티아라멘츠', ['白毛']='백발',
  ['学生']='학생', ['精灵']='정령', ['舰娘']='함선 소녀', ['魅魔']='서큐버스', ['天狗']='텐구',
}
local words = {
  ['休息时间'] = '라운드 준비 시간',
  ['游戏模式选择'] = '게임 모드 선택',
  ['游 戏 模 式 选 择'] = '게임 모드 선택',
  ['开始游戏'] = '게임 시작',
  ['开 始 游 戏'] = '게임 시작',
  ['难度'] = '난이도', ['难 度'] = '난이도',
  ['额外模式'] = '추가 모드', ['额 外 模 式'] = '추가 모드',
  ['介绍'] = '설명', ['介 绍'] = '설명',
  ['标准模式'] = '일반 모드', ['新手模式'] = '초보자 모드',
  ['梦境'] = '몽경', ['现实'] = '현실', ['噩梦'] = '악몽',
  ['地狱'] = '지옥', ['幻梦'] = '환몽', ['神兆'] = '신조',
  ['银河模式'] = '은하 모드', ['往世乐土'] = '과거의 낙원',
  ['打靶模式'] = '표적 연습', ['测试模式'] = '테스트 모드',
  ['科研模式'] = '연구 모드', ['单一神器'] = '단일 신기',
  ['准备'] = '준비', ['商店'] = '상점', ['后勤'] = '보급 담당',
  ['八云紫'] = '야쿠모 유카리', ['跳过'] = '건너뛰기',
  ['【选择一项】[跳过]放弃本次选择'] = '【하나 선택】 [건너뛰기] 이번 보상 포기',
  ['全队共享背包（左键取出到选中单位 未选中则放地面 I关闭）'] = '공유 가방 (좌클릭 꺼내기 · 선택 유닛이 없으면 바닥에 놓기 · I 닫기)',
  ['全队共享背包（左键取出到选中单位 Alt+左键喊话 右键取出 I关闭）'] = '공유 가방 (좌클릭 꺼내기 · Alt+좌클릭 아이템 알리기 · 우클릭 꺼내기 · I 닫기)',
  ['全队共享背包(I)'] = '공유 가방 (I)',
  ['-bb切换背包物品是否进入共享背包'] = '-bb 가방 물품의 공유 가방 이동 전환',
  ['-bb2切换英雄拾取消耗品是否进入共享背包'] = '-bb2 영웅이 주운 소모품의 공유 가방 이동 전환',
  ['谢谢，不用了'] = '괜찮아요. 감사합니다.', ['我是高手'] = '숙련자입니다.',
  ['请给我一些新手指导'] = '초보자 안내를 부탁해요.',
  ['好的我明白了。'] = '알겠습니다.',
  ['这就是目前的新手指导了！暂时没有了！'] = '현재 준비된 초보자 안내는 여기까지입니다.',
}
for source, translated in pairs(require('hera_korean_stats')) do words[source] = translated end
for source, translated in pairs(require('hera_korean_tamamo')) do words[source] = translated end
for source, translated in pairs(require('hera_korean_help')) do words[source] = translated end
for source, translated in pairs(require('hera_korean_ether')) do words[source] = translated end
for source, translated in pairs(require('hera_korean_cards')) do words[source] = translated end
for source, translated in pairs(require('hera_korean_commands').labels) do words[source] = translated end
local blocks = {}
local exact_blocks = {}
for _, module in ipairs({'hera_korean_reference', 'hera_korean_command_cards', 'hera_korean_relics', 'hera_korean_advanced', 'hera_korean_blood', 'hera_korean_collections', 'hera_korean_integrated', 'hera_korean_v54', 'hera_korean_v137'}) do
  for source, translated in pairs(require(module)) do
    if source:find('\n', 1, true) then
      exact_blocks[source] = translated
      exact_blocks[source:gsub('|[cC]%x%x%x%x%x%x%x%x',''):gsub('|r','')] = translated
      blocks[#blocks + 1] = {source = source, translated = translated, pattern = source:gsub('([^%w])', '%%%1')}
    else
      words[source] = translated
    end
  end
end
table.sort(blocks, function(a, b) return #a.source > #b.source end)
local function has_han(text)
  for _, code in utf8.codes(text) do
    if (code >= 0x3400 and code <= 0x9FFF) or (code >= 0xF900 and code <= 0xFAFF) then return true end
  end
  return false
end
function M.translate(text)
  if type(text) ~= 'string' then return text end
  if dialogue_weather[text] then return dialogue_weather[text] end
  if words[text] then return words[text] end
  if exact_blocks[text] then return exact_blocks[text] end
  -- 체력·시간처럼 중국어가 없는 빈번한 HUD 갱신은 사전을 탐색하지 않는다.
  if not has_han(text) then return (text:gsub('|n', '\n')) end
  local normalized = text:gsub('|n', '\n')
  -- 전체 알림의 플레이어 이름은 번역하지 않고, 확인된 보상/항법 안내만 옮긴다.
  local announcements = {
    ['准备紧急起飞']=' · 긴급 출항을 준비합니다.',
    ['准备多停留一会']=' · 체류 시간을 연장합니다.',
    ['在板条箱里面搜出来金条']=' · 나무 상자에서 금괴를 발견했습니다.',
    ['投掷了命运金币']=' · 운명의 동전을 던졌습니다.',
    ['获得了赐福']=' · 축복을 받았습니다.',
    ['干了一杯曼陀罗汁']=' · 만드라고라 즙을 한 잔 들이켰습니다.',
    ['的诅咒爆发了……』']='의 저주가 폭발했다……』',
    ['的矿石病彻底爆发了，生命进入了最后的倒计时……']='의 광석병이 완전히 발현되었다. 생명의 마지막 카운트다운이 시작된다……',
    ['在技术突破时触发灵光一闪']=' · 기술 돌파 중 번뜩이는 영감을 얻었습니다.',
  }
  local plain = normalized:gsub('|[cC]%x%x%x%x%x%x%x%x',''):gsub('|r','')
  if exact_blocks[plain] then return exact_blocks[plain] end
  -- 수치가 바뀌는 학급재판 설명만 표시 단계에서 번역한다.
  local trial_patterns = {
    {'^返还([%d%.]+)点启动负载$', function(a) return '시동 부하 '..a..' 반환' end},
    {'^%[弹丸论破%]结局：(.+)$', function(a) return '[단간론파] 결말. '..M.translate(a) end},
    {'^已完成(%d+)/3次，成功(%d+)次，失败(%d+)次$', function(a,b,c) return '완료 '..a..'/3회, 성공 '..b..'회, 실패 '..c..'회' end},
    {'^第(%d+)轮，证据(%d+)/6，当前裁判成功率(%d+)%%$', function(a,b,c) return a..'번째 사건, 증거 '..b..'/6, 현재 재판 성공률 '..c..'%' end},
    {'^第(%d+)轮，学级裁判进行中$', function(a) return a..'번째 사건, 학급재판 진행 중' end},
    {'^学生集会进度：(%d+)/6$', function(a) return '학생 집결 진행도 '..a..'/6' end},
    {'^本轮遇害学生：(.+)$', function(a) return '이번 사건의 피해자. '..M.translate(a) end},
    {'^获得一个(.+)词条变异$', function(a) return M.translate(a)..' 특성 변이 1개 획득' end},
    {'^进度：(%d+)/(%d+)$', function(a,b) return '진행도 '..a..'/'..b end},
    {'^坐标：([%d%.%-]+)，([%d%.%-]+)；范围([%d%.]+)码$', function(a,b,c) return '좌표 '..a..', '..b..' · 범위 '..c end},
    {'^(.+) → (.+)【(已完成)】$', function(a,b,c) return M.translate(a)..' → '..M.translate(b)..'【완료】' end},
    {'^(.+) → (.+)【(关键证人)】$', function(a,b,c) return M.translate(a)..' → '..M.translate(b)..'【핵심 증인】' end},
    {'^(.+) → (.+)【(等待前者)】$', function(a,b,c) return M.translate(a)..' → '..M.translate(b)..'【앞선 증언자 대기】' end},
  }
  for _, entry in ipairs(trial_patterns) do
    if plain:match(entry[1]) then
      local result = plain:gsub(entry[1], entry[2])
      return (normalized:match('^(|[cC]%x%x%x%x%x%x%x%x)') or '') .. result .. '|r'
    end
  end

  -- 이스투아르의 실제 조합 대사는 닉네임 부분을 그대로 두고 바깥 문장만 옮긴다.
  local yisi_patterns = {
    {'^我喜欢(.+),还有大家$', function(name) return '나는 '..name..'도, 모두도 좋아.' end},
    {'^次回！(.+)之死！$', function(name) return '다음 이야기! '..name..'의 죽음!' end},
    {'^得想个办法，把(.+)变成骑空士$', function(name) return name..'을 기공사로 만들 방법을 찾아야겠어.' end},
    {'^连一刻都没有为(.+)的死亡哀悼，立刻赶到战场的是————$', function(name) return name..'의 죽음을 슬퍼할 틈도 없이 전장에 달려온 것은————' end},
    {'^魔法少女(.+)!$', function(name) return '마법소녀 '..name..'!' end},
    {'^(.+)，恐怖如斯！$', function(name) return name..', 이토록 무섭다니!' end},
  }
  if not plain:find('\n',1,true) then
    for _, entry in ipairs(yisi_patterns) do
      local name = plain:match(entry[1])
      if name then return entry[2](name) end
    end
    local speed = plain:match('^你的移动速度是(%d+)，想必你的手速一定更优秀，至少在选择英雄上$')
    if speed then return '이동 속도는 '..speed..'인데 손은 더 빠른가 봐. 적어도 영웅을 고를 때는 말이야.' end
    local game_patterns = {
      {'^(.+)？启动！$', function(game) return game..'? 실행!' end},
      {'^我喜欢玩(.+),你呢？$', function(game) return '난 '..game..' 하는 게 좋아. 너는?' end},
      {'^玩不到(.+)我要死了,啊,我只是系统,那没事了$', function(game) return game..'을 못 하면 죽을 것 같아. 아, 난 시스템일 뿐이니 괜찮네.' end},
      {'^你一定要去玩一玩(.+)!非常好玩！$', function(game) return game..'을 꼭 해 봐! 정말 재미있어!' end},
    }
    for _, entry in ipairs(game_patterns) do
      local game = plain:match(entry[1])
      if game then
        game = M.translate(game)
        if not has_han(game) then return entry[2](game) end
      end
    end
  end
  for suffix,korean in pairs(announcements) do
    if not plain:find('\n',1,true) and #plain>#suffix and plain:sub(-#suffix)==suffix then
      return plain:sub(1,#plain-#suffix)..korean
    end
  end
  local live = words[plain] or live_templates.translate(plain, M.translate)
  if live then
    return (normalized:match('^(|[cC]%x%x%x%x%x%x%x%x)') or '') .. live .. (normalized:sub(-2)=='|r' and '|r' or '')
  end
  -- 라운드 공지는 원본이 숫자를 한자로 바꾼 뒤 출력하므로 여기서만 되돌린다.
  local round = plain:match('^第(.-)波$')
  if round then
    local digits = {['零']=0,['一']=1,['二']=2,['三']=3,['四']=4,['五']=5,['六']=6,['七']=7,['八']=8,['九']=9}
    local units = {['十']=10,['百']=100,['千']=1000}
    local total, digit, valid = 0, 0, true
    for _,code in utf8.codes(round) do
      local char = utf8.char(code)
      if digits[char] then digit=digits[char]
      elseif units[char] then total=total+(digit==0 and 1 or digit)*units[char];digit=0
      else valid=false;break end
    end
    if valid and round~='' then return tostring(total+digit)..'라운드' end
  end
  -- 카운터 이름과 값은 분리되어 들어오므로 검토된 이름에 숫자만 붙은 행을 처리한다.
  local counter, value, unit = plain:match('^(.-[:：])([%+%-]?[%d%.]+)(.*)$')
  local counter_units = {['']='', ['层']='중첩', ['秒']='초', ['次']='회', ['%']='%'}
  if counter and words[counter] and counter_units[unit] then
    return (normalized:match('^(|[cC]%x%x%x%x%x%x%x%x)') or '') .. words[counter] .. ' ' .. value .. counter_units[unit] .. (normalized:sub(-2)=='|r' and '|r' or '')
  end
  -- 긴 설명은 검토한 원문 전체가 일치할 때만 교체한다.
  for _, entry in ipairs(blocks) do
    normalized = normalized:gsub(entry.pattern, function() return entry.translated end)
  end
  local translated = normalized:gsub('[^\r\n]+', function(line)
    local body = line:gsub('|[cC]%x%x%x%x%x%x%x%x', ''):gsub('|r', '')
    local target = words[body] or live_templates.translate(body, M.translate)
    if not target then
      local version = body:match('^版本号：([%w%.%-_]*)$')
      if version then target = '버전. '..version end
    end
    if not target then
      local tier = body:match('^元素 %- 阶级%[(%d+)%]$')
      if tier then target = '원소 - 단계[' .. tier .. ']' end
    end
    if not target then
      -- 거래소의 남은 시간과 구매 결과는 표시 시점에 값이 결합된다.
      local reward = body:match('^圣代剩余杀敌奖励次数：(%d+)$')
      if reward then target = '선데이 추가 처치 보상 잔여 횟수 · ' .. reward end
      reward = body:match('^小熊饼干获得追忆值:(%d+)$')
      if reward then target = '곰돌이 쿠키로 추억 수치 ' .. reward .. ' 획득' end
      local seconds = body:match('^下一波开始时或在(%d+)秒后结束$')
      if seconds then target = '다음 웨이브 시작 시 또는 ' .. seconds .. '초 후 종료됩니다.' end
      local item = body:match('^购买成功：(.*)$')
      if item then target = '구매 완료 · ' .. M.translate(item) end
      item = body:match('^打劫成功：(.*)$')
      if item then target = '강탈 성공 · ' .. M.translate(item) end
      local dividend, investment = body:match('^你获得了([%d%.%-]+)的分红%(总投资额:([%d%.%-]+)%)$')
      if dividend then target = '배당금 ' .. dividend .. ' 획득 (총 투자액 ' .. investment .. ')' end
    end
    if not target then
      -- 실제 항법 화면에서 조합하는 행만 번역하며 항로 데이터 키는 유지한다.
      local nav = {
        ['当前所在星系:']='현재 성계 · ', ['下一站:']='다음 목적지 · ',
        ['简要介绍:']='간략 정보 · ', ['前方情报:']='전방 정보 · ',
        ['当前航线:']='현재 항로 · ', ['危险星团距离:']='위험 성단까지 · ',
        ['剩余跃迁次数:']='남은 도약 횟수 · ', ['已经过航线:']='지나온 항로 · ',
      }
      local navwords = {
        ['危险星团']='위험 성단', ['危险行星']='위험 행성', ['敌对行星']='적대 행성',
        ['空间站']='우주 정거장', ['乐土商店']='낙원 상점', ['母星']='모성',
        ['陆地']='대지', ['辐射']='방사능', ['冰原']='빙원', ['火山']='화산',
        ['半影']='반영', ['风暴']='폭풍', ['海洋']='해양', ['高山']='고산',
        ['森林']='삼림', ['荒芜']='황무지', ['行星']=' 행성', ['生态']=' 생태계',
        ['星系']=' 성계', ['航线']='항로', ['（危险）']=' (위험)',
      }
      local function navtext(s)
        local exact = words[s]
        if exact then return exact end
        for a,b in pairs(navwords) do s=s:gsub(a,function() return b end) end
        return s
      end
      for prefix,korean in pairs(nav) do
        if body:sub(1,#prefix)==prefix then target=korean..navtext(body:sub(#prefix+1)); break end
      end
      local wave,kind=body:match('^当前波次%(#(%d+)%)︰(.*)$')
      if not wave then wave,kind=body:match('^当前波次%(#(%d+)%)%:(.*)$') end
      if wave then target='현재 웨이브 (#'..wave..') · '..navtext(kind) end
      local who=body:match('^当前导航员:(.*)$')
      if who then target='현재 항법사 · '..who end
      local reason=body:match('^切换失败：(.*)$')
      if reason then target='변경 실패 · '..(words[reason] or reason) end
      local lane=body:match('^2%) 切换至(.*)（消耗1次跃迁）$')
      if lane then target='2) '..navtext(lane)..'로 변경 (도약 1회 소모)' end
      local n=body:match('^(%d+)%) 紧急起飞 （10秒后强制起飞 无过波奖励）$')
      if n then target=n..') 긴급 출항 (10초 후 강제 출항, 웨이브 보상 없음)' end
      n=body:match('^(%d+)%) 多停留一会 （延长300秒起飞时间）$')
      if n then target=n..') 더 머무르기 (출항까지 300초 연장)' end
      local value=body:match('^追忆值不足，需要([%d%.]+)点$')
      if value then target='추억 수치가 부족합니다. 필요량 '..value end
      value=body:match('^消耗([%d%.]+)点追忆值刷新$')
      if value then target='추억 수치 '..value..' 소모하여 새로고침' end
      value=body:match('^剩余次数[:：]?(%d+)$')
      if value then target='남은 횟수 · '..value end
      value=body:match('^冷却:([%d%.]+)秒$')
      if value then target='재사용 대기시간 · '..value..'초' end
    end
    if not target then
      -- 영웅 정보창의 수치 행은 접두사와 숫자 수식을 확인한 뒤 표시 이름만 바꾼다.
      local labels = {
        ['神性']='신성', ['始源']='시원', ['原罪']='원죄', ['角色基础伤害']='캐릭터 기본 피해',
        ['经验获取']='경험치 획득', ['积分获取']='포인트 획득', ['幸运']='행운',
        ['生命上限']='최대 생명력', ['生命修正']='생명력 보정',
        ['枪械修正']='총기 보정', ['枪械加成']='총기 보너스',
        ['近战修正']='근접 보정', ['近战加成']='근접 보너스',
        ['法术修正']='주문 보정', ['法术加成']='주문 보너스',
        ['召唤伤害']='소환 피해', ['召唤加成']='소환 보너스',
        ['伤害修正']='피해 보정', ['伤害加成']='피해 보너스', ['固定伤害']='고정 피해',
        ['受伤修正']='받는 피해 보정', ['受伤减少']='받는 피해 감소', ['额外受伤']='추가로 받는 피해',
        ['最终减伤']='최종 피해 감소', ['最终受伤']='최종 받는 피해',
        ['固定减伤']='고정 피해 감소', ['固定受伤']='고정 받는 피해',
        ['终结减伤']='종결 피해 감소', ['终结受伤']='종결 받는 피해',
        ['暴击']='치명타', ['暴击率']='치명타 확률', ['终结伤害']='종결 피해', ['杀敌数']='처치 수',
      }
      local label,formula=body:match('^([^%[]+)(%[.*)$')
      if label and labels[label] then
        local candidate=labels[label]..formula
        for a,b in pairs(labels) do candidate=candidate:gsub(a,function() return b end) end
        if not has_han(candidate) then target=candidate end
      end
      local movement=body:match('^移动速度([%d%+%-%=%[%]%.]+)$')
      if movement then target='이동 속도 '..movement end
      local gender=body:match('^性别:(.*)$')
      if gender then target='성별 · '..(({['男']='남성',['女']='여성',['无']='없음',['未知']='불명'})[gender] or gender) end
      local count,left=body:match('^神化数量%[(%d+)/剩余(%d+)%]$')
      if count then target='신화 수 ['..count..'/남음 '..left..']' end
      local elements=body:match('^属性伤害:?%[(.*)%]$')
      if elements then
        local names={['全属']='모든 속성',['心灵']='정신',['光']='빛',['暗']='어둠',['风']='바람',['雷']='번개',['冰']='얼음',['水']='물',['火']='불',['土']='대지',['无']='없음'}
        for a,b in pairs(names) do elements=elements:gsub(a,function() return b end) end
        if not has_han(elements) then target='속성 피해 ['..elements..']' end
      end
      local rank=body:match('^深空污染 %- 污染等级(%d+)$')
      if rank then target='심우주 오염 - 오염 등급 '..rank end
      local damage=body:match('^对%[世界的意志%]提升%(([%d%.]+W)%)结算伤害$')
      if damage then target='[세계의 의지]에게 주는 정산 피해 ('..damage..') 증가' end
      local factor=body:match('^降低%[(%d+%%)%*层数%]所有生命恢复效果$')
      if factor then target='모든 생명력 회복 효과 ['..factor..'*중첩 수] 감소' end
      local equation=body:match('^提升%[(%([%d%.%%%+]+)%*最大生命值%)%*层数%]结算受伤$')
      if equation then target='받는 정산 피해 ['..equation..'*최대 생명력)*중첩 수] 증가' end
    end
    if not target then
      -- NPC와 낙원 상점의 수치 안내는 확인된 표시 접두사 뒤의 숫자만 허용한다.
      local prefixes = {
        ['当前成功率:']='현재 성공률 · ', ['当前成功率：']='현재 성공률 · ',
        ['积分消耗:']='포인트 소모 · ', ['消耗积分：']='포인트 소모 · ',
        ['追忆值消耗:']='추억 수치 소모 · ', ['启动承载:']='기동 수용량 · ',
        ['剩余刷新:']='남은 새로고침 · ', ['剩余刷新次数:']='남은 새로고침 횟수 · ',
        ['所需积分：']='필요 포인트 · ', ['积分不足 所需积分：']='포인트 부족. 필요량 · ',
        ['积分不足,所需杀敌积分:']='포인트 부족. 필요한 처치 포인트 · ',
        ['购买成功 当前消耗积分：']='구매 완료. 소모한 포인트 · ',
        ['能源不足,所需能源:']='에너지 부족. 필요량 · ',
        ['兑换成功 剩余军功：']='교환 완료. 남은 군공 · ',
        ['军功不足 当前军功：']='군공 부족. 현재 군공 · ',
        ['回收成功 剩余军功：']='회수 완료. 남은 군공 · ',
        ['星域污染等级提升,当前等级:']='성역 오염 등급 상승. 현재 등급 · ',
        ['命中次数：']='명중 횟수 · ', ['训练完成,总计命中次数：']='훈련 완료. 총 명중 횟수 · ',
        ['当前进度:']='현재 진행도 · ', ['力量权柄:']='힘의 권능 · ', ['物质权柄:']='물질의 권능 · ',
        ['[灵光一闪],进度迅速推进,进度改变:']='[번뜩이는 영감] 진행도가 급상승했습니다. 변화량 · ',
        ['成功,进度改变:']='성공. 진행도 변화량 · ',
        ['[灵光一闪],失败补救回来了,进度改变:']='[번뜩이는 영감] 실패를 만회했습니다. 진행도 변화량 · ',
        ['失败,进度改变:']='실패. 진행도 변화량 · ',
        ['数量:']='수량 · ', ['剩余']='남음 · ', ['消耗']='소모 · ',
      }
      for prefix,korean in pairs(prefixes) do
        if body:sub(1,#prefix)==prefix then
          local tail=body:sub(#prefix+1)
          local numeric=tail:gsub('次$','')
          if numeric:match('^[%d%.%+%-%[%]%(%)/%%]+$') then
            target=korean..tail:gsub('次$','회');break
          end
        end
      end
      local energy=body:match('^填充了([%d%.]+)单位的能源$')
      if energy then target='에너지 '..energy..' 충전' end
      local stat=body:match('^提升了([%d%.]+)点全属性$')
      if stat then target='모든 능력치 '..stat..' 증가' end
      local level=body:match('^%[撬锁%]经验等级提升,当前:(%d+)级$')
      if level then target='[자물쇠 따기] 숙련도 상승. 현재 '..level..'레벨' end
      local gold,memory=body:match('^过波奖励:([%d%.]+)积分与([%d%.]+)追忆值$')
      if gold then target='웨이브 보상 · 포인트 '..gold..' 및 추억 수치 '..memory end
      gold=body:match('^过波奖励:([%d%.]+)积分$')
      if gold then target='웨이브 보상 · 포인트 '..gold end
      local actual=body:match('^实际生效([%d%.%+%-]+%%)$')
      if actual then target='실제 적용 '..actual end
      local delay=body:match('^第一刀将在倒计时结束([%d%.]+)秒后开始$')
      if delay then target='카운트다운이 끝나고 '..delay..'초 뒤 첫 참격이 시작됩니다.' end
      local density=body:match('^血液源石结晶密度:%[([%d%.%%]+)%]$')
      if density then target='혈중 오리지늄 결정 밀도 ['..density..']' end
      local weapon=body:match('^目前锻造中武器：(.*)$')
      if weapon then
        local name=M.translate(weapon)
        if not has_han(name) then target='현재 단조 중인 무기 · '..name end
      end
      local project=body:match('^技术突破项研究完毕:%[(.*)%]$')
      if project then
        local name=M.translate(project)
        if not has_han(name) then target='기술 돌파 연구 완료 ['..name..']' end
      end
      local place,action=body:match('^%[(.-)%](开始搜寻……)$')
      if not place then place,action=body:match('^%[(.-)%](停止搜寻)$') end
      if place then
        local name=M.translate(place)
        if not has_han(name) then target='['..name..'] '..(action=='停止搜寻' and '수색 중단' or '수색 시작……') end
      end
    end
    if not target then
      local kind,list=body:match('^(主变异)：(.*)$')
      if not kind then kind,list=body:match('^(次变异)：(.*)$') end
      if kind then
        local result={}
        local complete=true
        for tag in list:gmatch('%S+') do
          if not displayed_tags[tag] then complete=false;break end
          result[#result+1]=displayed_tags[tag]
        end
        if complete then target=(kind=='主变异' and '주 변이 · ' or '보조 변이 · ')..table.concat(result,'  ') end
      elseif body:find('[',1,true) then
        local found=false
        local complete=true
        local result=body:gsub('([^%s%[%]]+)%[(%d+)%]',function(tag,count)
          if not displayed_tags[tag] then complete=false;return tag..'['..count..']' end
          found=true;return displayed_tags[tag]..'['..count..']'
        end)
        if found and complete and not has_han(result) then target=result end
      end
    end
    if not target then return line end
    local prefix = line:match('^(|[cC]%x%x%x%x%x%x%x%x)') or ''
    local suffix = line:sub(-2) == '|r' and '|r' or ''
    -- 글자별 그라데이션 제목은 첫 색상을 사용하고 문장·단축키를 온전히 유지한다.
    return prefix .. target .. suffix
  end)
  -- 짧은 문단 치환이 다음 행의 접두사와 겹치면 원본의 완전한 행으로 다시 번역한다.
  if has_han(translated) and (text:find('[\r\n]') or text:find('|n',1,true)) then
    translated = text:gsub('|n','\n'):gsub('[^\r\n]+', function(line) return M.translate(line) end)
  end
  -- 미번역 한자가 남은 설명은 원문 전체를 유지해 혼용 글꼴의 누락을 피한다.
  if has_han(translated) then return text end
  return translated
end
local translate_uncached = M.translate
local translation_cache, translation_cache_count = {}, 0
function M.translate(text)
  if type(text) ~= 'string' then return text end
  text = require('hera_text_width').sanitize_utf8(text)
  if not has_han(text) then return translate_uncached(text) end
  local cached = translation_cache[text]
  if cached ~= nil then return cached end
  local result = translate_uncached(text)
  if translation_cache_count >= 2048 then
    translation_cache, translation_cache_count = {}, 0
  end
  translation_cache[text] = result
  translation_cache_count = translation_cache_count + 1
  return result
end
function M.has_hangul(text)
  for _, code in utf8.codes(require('hera_text_width').sanitize_utf8(text)) do
    if code >= 0xAC00 and code <= 0xD7A3 then return true end
  end
  return false
end
function M.install_movie_text()
  if M._movie_text_installed or type(textjbchange) ~= 'function' then return end
  local original = textjbchange
  textjbchange = function(args)
    -- 호출자의 연출 설정은 보존하고 글자 분할 전에 표시 문장만 번역한다.
    local display = {}
    for key,value in pairs(args) do display[key]=value end
    for _,key in ipairs({'strz','strstart','strend','origintext','endtext'}) do
      if type(display[key])=='string' then display[key]=M.translate(display[key]) end
    end
    return original(display)
  end
  M._movie_text_installed = true
end
function M.install_music_text()
  if M._music_text_installed then return end
  local function display_copy(source)
    local result = {}
    for key,value in pairs(source) do
      if type(value)=='string' and (key=='str' or key=='translation' or key=='translate' or key=='trans' or key=='fy') then
        result[key]=M.translate(value)
      elseif type(value)=='table' and (key=='strz' or key=='text' or key=='words' or key=='segments' or key=='timing' or type(key)=='number') then
        result[key]=display_copy(value)
      else result[key]=value end
    end
    return result
  end
  for _,name in ipairs({'musiccolortext','shigecolortext','songtext','songchat'}) do
    local original = _G[name]
    if type(original)=='function' then
      _G[name]=function(args)
        if args.keep_original_text then return original(args) end
        return original(display_copy(args))
      end
    end
  end
  M._music_text_installed = true
end
return M
