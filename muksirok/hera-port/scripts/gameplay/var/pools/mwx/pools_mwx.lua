-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local gun_upgrade = require("gameplay.feature.gun.upgrade")
MWXSTR = "冥王栏"

function CreateNewUIButton(args)
  local b2 = false
  local dx = args.dx
  local dy = args.dy
  local dw = args.dw
  local dh = args.dh
  local img = args.img
  local showtext = args.showtext
  local keytext = args.keytext
  local size = args.size
  local func = args.func
  local test = class.button:builder({
    x = dx,
    y = dy,
    w = size * dw * 0.91,
    h = size * dh * 0.71,
    normal_image = img,
    on_button_update_drag = function(self, icon, x, y)
      self:set_position(x, y)
    end,
    on_button_right_clicked = function(self)
      if not b2 then
        b2 = true
        self:set_enable_drag(false)
      else
        b2 = false
        self:set_enable_drag(true)
      end
    end,
    on_button_mouse_enter = function(self)
      if self == Local_AliceKuaijietubiao then
        local u = getunit(Hero[LocalPlayerID])
        local bfb = u:getdata("梦游仙境-sen值") / 100
        if 1 <= bfb then
          bfb = 1
        end
        self:set_alpha(155 * bfb)
        self.show2:set_alpha(155 * (1 - bfb))
      else
        self:set_alpha(155)
      end
      if not b2 then
        uiy_show_text(showtext, "Yuanzhu")
      end
    end,
    on_button_mouse_leave = function(self)
      if self == Local_AliceKuaijietubiao then
        local u = getunit(Hero[LocalPlayerID])
        local bfb = u:getdata("梦游仙境-sen值") / 100
        if 1 <= bfb then
          bfb = 1
        end
        self:set_alpha(255 * bfb)
        self.show2:set_alpha(255 * (1 - bfb))
      else
        self:set_alpha(255)
      end
      uiy_hide()
    end,
    on_button_clicked = function(self, button)
      self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
      ac.wait(100, function()
        self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
      end)
      if self == Local_AliceKuaijietubiao then
        local show2 = Local_AliceKuaijietubiao.show2
        show2:set_control_size(show2:get_width() * 0.9, show2:get_height() * 0.9)
        ac.wait(100, function()
          show2:set_control_size(show2:get_width() / 0.9, show2:get_height() / 0.9)
        end)
      end
      ClearSelection()
      local u = getunit(Hero[LocalPlayerID])
      func(u)
    end
  })
  test:set_enable_drag(true)
  return test
end

local function resolve_mwx_effect_unit(expected, args)
  local event_u = args and args.u
  if not event_u or event_u.handle ~= expected.handle or event_u.ownerid ~= expected.ownerid then
    return
  end
  return event_u
end

function MwxJibingpanding(u)
end

function MwxSpiritLoadCost(var)
  return math.max(1, var and var.lv or 1)
end

function MwxStartSpiritLoadCost(var)
  return var and var.spirit_load or 3
end

function MwxSpiritLoadKey(var)
  return "系统-精神负载力来源-" .. var.name
end

function MwxApplySpiritLoadByLv(u, var)
  if not (var and var.lv) or var.lv <= 0 then
    return
  end
  if u:hasdata("幻想乡-临时获取") then
    return
  end
  local load = MwxSpiritLoadCost(var)
  u:changedata("系统-精神负载力", load)
  u:setdata(MwxSpiritLoadKey(var), load)
  if 0 < u:getdata("虚空形态-剩余次数") then
    u:changedata("虚空形态-剩余次数", -1)
    u:sendmessage("|cFFFF8040[虚空形态]不计入承载:" .. var.name)
    u:changedata("系统-精神负载力", -load)
    u:deldata(MwxSpiritLoadKey(var))
  end
end

function MwxRemoveSpiritLoadByLv(u, var)
  if not (var and var.lv) or var.lv <= 0 then
    return
  end
  local load = u:getdata(MwxSpiritLoadKey(var))
  if not load or load <= 0 then
    return
  end
  u:changedata("系统-精神负载力", -load)
  u:deldata(MwxSpiritLoadKey(var))
end

function MwxTongyong(u, var)
  u:setdata("变异判定-" .. var.name)
  if var.lv then
    u:changedata(var.lv .. "阶精神变异数量", 1)
  end
  MwxApplySpiritLoadByLv(u, var)
  if var.key then
    for index, value in ipairs(var.key) do
      u:changedata(value .. "变异数量", 1)
    end
  end
end

function Qidongshangxianpanding(u)
  local b = true
  if u:hasdata("变异判定-神印") then
    b = false
  end
  return b
end

function MwxJibingpanding_Jingshen(u)
end

function MwxQidongGet(u, var)
  u:setdata("变异判定-" .. var.name)
  local ignore_load = false
  if var.key then
    for index, value in ipairs(var.key) do
      if value == "启动" or value == "唯一" then
        u:changedata(value .. "变异数量", 1)
        if value == "启动" and u:getdata("虚空形态-剩余次数") > 0 then
          u:changedata("虚空形态-剩余次数", -1)
          u:sendmessage("|cFFFF8040[虚空形态]不计入承载:" .. var.name)
          u:changedata(value .. "变异数量", -1)
          ignore_load = true
        end
      end
    end
  end
  if not ignore_load then
    u:changedata("系统-启动负载力", MwxStartSpiritLoadCost(var))
  end
  MwxJibingpanding_Jingshen(u)
end

function MWXPools(u)
  local pools = {
    Vars_Mwx_Lv1,
    Vars_Mwx_Lv2,
    Vars_Mwx_Lv3
  }
  if u:getdata("系统-启动负载力") < u:getdata("系统-启动承载上限") then
    table.insert(pools, Vars_Mwx)
  elseif GetRandom100(5) then
    table.insert(pools, Vars_Mwx)
  end
  if u:hasdata("变异判定-神秘庭院") then
    table.insert(pools, Vars_Mwx_Tyzm)
  end
  if u:hasdata("变异判定-巴蛇之影") then
    table.insert(pools, Vars_Mwx_Bszy)
  end
  if u:hasdata("变异判定-千矢") then
    table.insert(pools, Vars_Mwx_Zhanbushishilian)
  end
  if u:hasdata("变异判定-天使学院") then
    table.insert(pools, Vars_Mwx_Tianshixuexiao)
  end
  if u:hasdata("变异判定-拟声乌托邦") then
    table.insert(pools, Vars_Mwx_Nishengwutuobang)
  end
  if u:hasdata("变异判定-重新链接") then
    table.insert(pools, Vars_Mwx_Chongxinlianjie)
  end
  if u:hasdata("变异判定-魔法都市") then
    table.insert(pools, Vars_Mwx_Mofadushi)
    if u:hasdata("变异判定-恩底弥翁皇国") then
      table.insert(pools, Vars_Mwx_Mfds_Huangguo)
    end
    if u:hasdata("变异判定-魔女术工坊") then
      table.insert(pools, Vars_Mwx_Mfds_Monvshugongfang)
    end
    if u:hasdata("变异判定-魔导书院") then
      table.insert(pools, Vars_Mwx_Mfds_Shuyuan)
    end
  end
  if u:hasdata("变异判定-格里芬安全承包商") then
  end
  if u:hasdata("变异判定-拉塔托斯克") then
    table.insert(pools, Vars_Mwx_Jingling)
  end
  if u:hasdata("变异判定-环都市") then
    table.insert(pools, Vars_Mwx_Delisha_Lv1)
  end
  if u:hasdata("变异判定-幻想乡") then
    table.insert(pools, Vars_Mwx_Dongfang_Lv2)
  end
  if u:hasdata("变异判定-梦游仙境") then
    table.insert(pools, Vars_Mwx_Alice_Lv1)
    table.insert(pools, Vars_Mwx_Alice_Lv2)
  end
  if u:hasdata("变异判定-武神意志") then
    table.insert(pools, Vars_Mwx_Wushen_Lv1)
    table.insert(pools, Vars_Mwx_Wushen_Lv2)
  end
  if u:hasdata("变异判定-天下会") then
    table.insert(pools, Vars_Mwx_Tianxiahui_Lv1)
    table.insert(pools, Vars_Mwx_Tianxiahui_Lv2)
  end
  if u:hasdata("变异判定-洗衣龙女的困境") then
    table.insert(pools, Vars_Mwx_Longnvpu_Lv1)
    table.insert(pools, Vars_Mwx_Longnvpu_Lv2)
  end
  if u:hasdata("变异判定-多彩星河") then
    table.insert(pools, Vars_Mwx_Duocaixinghe_Lv1)
    table.insert(pools, Vars_Mwx_Duocaixinghe_Lv2)
  end
  if u:hasdata("变异判定-妖怪少女") then
    table.insert(pools, Vars_Mwx_Ygsn_Lv1)
    table.insert(pools, Vars_Mwx_Ygsn_Lv2)
  end
  if u:hasdata("变异判定-异聚门扉") then
    table.insert(pools, Vars_Mwx_Yijumenfei)
  end
  if u:hasdata("变异判定-恶魔五月哭") then
    table.insert(pools, Vars_Mwx_Emowuyueku)
    if u:hasdata("变异判定-机械手臂") then
      table.insert(pools, Vars_Mwx_Emowuyueku_Jixieshou)
    end
  end
  if u:hasdata("变异判定-弹丸论破") then
    table.insert(pools, Vars_Mwx_Danwanlunpo)
  end
  if u:hasdata("变异判定-风云") then
    table.insert(pools, Vars_Mwx_Fengyun)
  end
  if u:hasdata("变异判定-最后的审判日") and u:getdata("使徒变异数量") >= 12 then
    table.insert(pools, Vars_Mwx_Yabolun)
  end
  return pools
end

function PdianAdd(u, add)
  if 0 <= add then
    u:sendmessage(("|cFFFF0000获得%d点P点|r"):format(add))
  else
    u:sendmessage(("|cFFFF0000损失%d点P点|r"):format(-add))
  end
  u:addallstats(add)
  u:changedata("幻想乡-P点", add)
end

local function qidongweightchange(u, var, add)
  add = add or 0
  local start_count = u:getdata("系统-启动负载力")
  local target_weight = 10
  if start_count < 3 then
    target_weight = 1000
  elseif start_count < 6 then
    target_weight = 100
  end
  add = add + target_weight - var.weight
  return add
end

Vars_Mwx = {
  {
    name = "尘晶觉醒",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 1,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      MwxQidongGet(u, var)
      u:changedata("元气值", 1)
    end,
    effectname = "尘晶觉醒",
    effecttext = "启动\n【启动负载】1\n提升1点元气值\n解锁对应[传奇]变异池",
    effectart = "Mwx_Qd_Cjjx.tga",
    test = "    "
  },
  {
    name = "重新链接",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 1,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = true,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      return Qidongshangxianpanding(u)
    end,
    effect = function(u, var)
      MwxQidongGet(u, var)
    end,
    effectname = "|cFF80BFFF重新链接|r",
    effecttext = "|cFF80BFFF启动\n【启动负载】1\n解锁对应变异池|r",
    effectart = "Mwx_Relink.tga",
    test = "    "
  },
  {
    name = "宇宙联合行星保护机构",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = true,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      u:setdata("宇宙联合-不消耗次数")
      local cs = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        cs = cs + 1
        if 2 <= cs then
          cs = 0
          u:setdata("宇宙联合-不消耗次数")
          u:sendmessage("|cff93beff[宇宙联合行星保护机构]承载不消耗刷新")
        end
      end)
    end,
    effectname = "|cff93beff宇宙联合行星保护机构|r",
    effecttext = "|cff93beff启动 唯一\n【启动负载】2\n【等级】奇迹\n【效果】\n解锁对应[传奇]变异池\n使下一个获取的外域传奇不占用神力承载(不会超过5点,超过时只减少5点)\n每经过2波刷新这个效果(无法累加)|r",
    effectart = "Mwx_Qidong_Yzlh",
    test = "    "
  },
  {
    name = "最后的审判日",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 3,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = true,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        if u:getdata("使徒变异数量") < 12 then
          local dpools = {
            Vars_Mwx_Yabolun
          }
          local str = herogetvar(u.handle, dpools, "冥王星")
        end
      end)
      u:additem("I0PK")
      ac.loop(1000, function()
        if u:isalive() then
          if u:hasdata("物品判定-晋升之环") or u:hasdata("物品判定-终末之环") then
            u:deldata("最后的审判日-惩罚")
          else
            u:setdata("最后的审判日-惩罚")
            if u:getperhp() < 1 then
              u:kill()
            else
              u:losshp(u, 0, 0, 1)
            end
          end
        else
          u:deldata("最后的审判日-惩罚")
        end
      end)
    end,
    effectname = "|cFFFF9900最后的审判日|r",
    effecttext = "|cFFFF9900启动 唯一\n【启动负载】3\n【等级】奇迹\n【效果】\n获取时随机获得一个[亚波伦]变异(共12个)\n过波时随机获得一个[亚波伦]变异(共12个)\n获得物品[晋升之环]\n未拥有[晋升之环]或[终末之环]时阻止生命恢复同时每秒损耗1%最大生命值(致死)|r",
    effectart = "Mwx_Ybl_03",
    test = "        "
  },
  {
    name = "杀戮尖塔",
    clickfunc = function(u, var)
      local count1 = u:getdata("储君-铸造值")
      u:sendmessage("|cFFFF8040[储君]铸造值:" .. count1 .. "|r")
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 1,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
    end,
    effectname = "|cFFEE8E18我进塔！|r",
    effecttext = "|cFFEE8E18启动\n【启动负载】1\n【等级】奇迹\n【效果】\n解锁对应[传奇]变异池|r",
    effectart = "Mwx_Chujun",
    test = "        "
  },
  {
    name = "神秘庭院",
    clickfunc = function(u, var)
      local count1 = u:getdata("庭院之门-外域物质")
      local count2 = u:getdata("庭院之门-主动收割次数")
      u:sendmessage(("|cFF9999FF[庭院之门]外域物质数量:%d|r"):format(count1))
      u:sendmessage(("|cff961212[庭院之门]剩余主动收割次数:%d|r"):format(count2))
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    rightclickfunc = function(u, var)
      u:sendmessage("|cFF9999FF【名称】|r" .. u:getplayername() .. "|cFF9999FF的" .. u:getdata("庭院之门统计-名称") .. "|r")
      local name = ""
      for index, dvar in ipairs(Vars_Mwx_TyzmNew) do
        if u:hasdata("变异判定-" .. dvar.name) then
          name = name .. dvar.name .. "、"
        end
      end
      u:sendmessage("|cFF9999FF【住客(上限" .. u:getdata("神秘庭院-住客上限") .. ")】" .. string.sub(name, 1, -2))
      u:sendmessage(("|cFF9999FF【营业额(已创收)】%d|r"):format(u:getdata("庭院之门统计-营业额")))
      u:sendmessage(("|cFF9999FF【热度(访客数)】%d|r"):format(u:getdata("庭院之门统计-热度")))
      u:sendmessage(("|cFF9999FF【好评数(已收割)】%d|r"):format(u:getdata("庭院之门统计-好评数")))
      u:sendmessage(("|cFF9999FF【邻里友好交流次数(已反抗)】%d|r"):format(u:getdata("庭院之门统计-交流次数")))
      u:sendmessage(("|cFF9999FF【差评数(已逃跑)】%d|r"):format(u:getdata("庭院之门统计-差评数")))
    end,
    weight = 5,
    spirit_load = 3,
    cd = 1,
    key = {"启动", "外域"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      if u:hasdata("变异判定-犹格庭院") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      if u:islocal() then
        CreateNewUIButton({
          size = 65,
          dx = 1625,
          dy = 650,
          dw = 1.25,
          dh = 1.12,
          img = "UIButton_Mwx_Smty.blp",
          showtext = "|cFF336BA4打开神秘庭院界面\n(左键拖动 右键切换锁定拖动)|r",
          keytext = "冥王栏" .. var.name,
          func = function(u)
            local count1 = u:getdata("庭院之门-外域物质")
            local count2 = u:getdata("庭院之门-主动收割次数")
            u:sendmessage(("|cFF9999FF[庭院之门]外域物质数量:%d|r"):format(count1))
            u:sendmessage(("|cff961212[庭院之门]剩余主动收割次数:%d|r"):format(count2))
            FlashUIVarGlobal(u, MWXSTR .. var.name)
          end
        })
      end
      u:setdata("庭院之门-外域物质", 0)
      u:setdata("神秘庭院-员工上限", 1)
      u:setdata("神秘庭院-住客数量", 0)
      u:setdata("神秘庭院-住客上限", 6)
      u:setdata("庭院之门-主动收割次数", 2)
      u:setdata("庭院之门-剩余访客数量", 5)
      local str = {
        "神秘庭院",
        "小庭院",
        "温暖之家",
        "小别墅"
      }
      u:setdata("庭院之门统计-名称", str[GetRandomInt(1, #str)])
      u:setdata("庭院之门统计-营业额", 0)
      u:setdata("庭院之门统计-热度", 0)
      u:setdata("庭院之门统计-好评数", 0)
      u:setdata("庭院之门统计-交流次数", 0)
      u:setdata("庭院之门统计-差评数", 0)
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        local add = 50 * u:getdata("神秘庭院-住客数量") + 10 * u:getdata("神秘庭院-阴间住客数量")
        if u:hasdata("变异判定-清洁大师") then
          add = add + 10 * u:getdata("神秘庭院-阴间住客数量")
        end
        u:sendmessage("|cFF9999FF[庭院之门]收租获得" .. add .. "积分")
        u:changedata("庭院之门统计-营业额", add)
        u:setdata("庭院之门-剩余访客数量", 5)
        TingyuanShouge(u)
      end)
      u:setdata("庭院之门-收割恢复基础时间", 30)
      u:setdata("庭院之门-收割恢复时间", 30)
      local t = 0
      ac.loop(1000, function()
        if u:getdata("庭院之门-主动收割次数") < 2 then
          t = t + 1
          if t >= u:getdata("庭院之门-收割恢复时间") then
            t = 0
            u:changedata("庭院之门-主动收割次数", 1)
            u:changedata("庭院之门-收割恢复时间", u:getdata("庭院之门-收割恢复基础时间"))
            u:sendmessage("|cFF9999FF[庭院之门]收割次数恢复|r")
          end
        else
          t = 0
        end
      end)
      u:addstexiao(var.name, "波数开始时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        u:sendmessage("|cFF9999FF[庭院之门]收割次数刷新,刷新时间重置|r")
        local count = 2
        u:setdata("庭院之门-主动收割次数", count)
        u:setdata("庭院之门-收割恢复时间", u:getdata("庭院之门-收割恢复基础时间"))
      end)
      ac.loop(60000, function()
        if u:getdata("庭院之门-剩余访客数量") > 0 then
          u:changedata("庭院之门-剩余访客数量", -1)
          local dvar = herogetvar(u.handle, {
            Vars_Mwx_TyzmNew
          }, "冥王星", "只返回变异")
          if dvar ~= "失败" then
            u:changedata("庭院之门统计-热度", 1)
            local name = dvar.name
            if u:getdata("神秘庭院-住客数量") < u:getdata("神秘庭院-住客上限") then
              u:sendmessage("|cFF9999FF[庭院之门]入住了新的住客(" .. name .. ")|r")
              u:setdata("庭院之门-强制获取")
              herogetvar(u.handle, {
                Vars_Mwx_TyzmNew
              }, "冥王星", name)
              u:deldata("庭院之门-强制获取")
            else
              u:sendmessage("|cFF9999FF[庭院之门]没有足够的住房给" .. name .. "居住|r")
            end
          else
            u:sendmessage("|cFF9999FF[庭院之门]今天的庭院也很冷清呢|r")
          end
        end
      end)
      ac.wait(100, function()
        if not Weiyi_New[21] then
          local dpools = {
            Vars_Mwx_Tyzm_Spe
          }
          u:setdata("系统-特殊获取中")
          local str = herogetvar(u.handle, dpools, "冥王星", "黑猫")
          u:deldata("系统-特殊获取中")
        end
      end)
      AddUISkill({
        text = "业务-做活动",
        u = u,
        cd = 3,
        icon = "UI_Smty_Zuohuodong.tga",
        showtext = "|cFF3366FF做活动\n消耗300积分\n进行一次[入住大酬宾]的活动\n立刻获得3张入住申请券\n每次做活动,下一次做活动所需积分提升60,累加|r\n|cFF949596欢迎来到甜蜜之家|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          local xh = 300 + u:getdata("神秘庭院-做活动消耗积分")
          if u:addqiankuan(xh) then
          else
            u:sendmessage("|cFFFF9900存在贷款无法使用|r")
            return
          end
          u:changedata("神秘庭院-做活动消耗积分", 60)
          u:sendmessage("|cFF3366FF[神秘庭院]下一次做活动所需积分:" .. xh + 60)
          u:additem("I0M4", 3)
        end
      })
      AddUISkill({
        text = "业务-扩充庭院",
        u = u,
        cd = 3,
        icon = "UI_Smty_Kuojian.tga",
        showtext = "|cFF3366FF扩充庭院\n消耗[30*提升上限次数]外域物质\n提升1住客上限|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          local xh = 30 + 30 * u:getdata("庭院之门-提升上限次数")
          if xh > u:getdata("庭院之门-外域物质") then
            u:sendmessage("|cFF9999FF外域物质不足(所需" .. xh .. "点)|r")
            return
          end
          u:changedata("庭院之门-提升上限次数", 1)
          u:changedata("庭院之门-外域物质", -xh)
          u:changedata("神秘庭院-住客上限", 1)
          u:sendmessage("|cFF9999FF[神秘庭院]住客上限提升,当前上限" .. u:getdata("神秘庭院-住客上限") .. "|r")
        end
      })
      AddUISkill({
        text = "业务-超凡兑换",
        u = u,
        cd = 3,
        icon = "UI_Smty_Chaofan.tga",
        showtext = "|cFF3366FF超凡兑换券\n消耗100外域物质\n获得一张超凡物品兑换券|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          local xh = 100
          if xh > u:getdata("庭院之门-外域物质") then
            u:sendmessage("|cFF9999FF外域物质不足(所需" .. xh .. "点)|r")
            return
          end
          u:changedata("庭院之门-外域物质", -xh)
          if u:hasdata("妖梦皮肤-渎白之渊") and not u:hasdata("渎白之渊-银之键获取") then
            u:setdata("渎白之渊-银之键获取")
            u:additem("I0M6")
          else
            u:additem("I0M5")
          end
        end
      })
      ac.wait(10, function()
        u:uivar_change({
          keyname = "神秘庭院",
          keytype = "冥王栏",
          text = "|cFF3366FF神秘庭院|r\n|cFF99FFFF启动|r\n|cFF3366FF【启动负载】3\n【等级】奇迹\n【效果】\n每经过60秒,有概率有客户上门申请入住,如果有空余房间将会入住\n每波至多出现5名客户\n【查房】\n对指定住客[右键]可以尝试进行主动收割,初始2次(上限2次),每30秒恢复1次(下次恢复时间提升30秒)\n每波开始时刷新收割次数恢复时间\n主动收割时额外提升10%收割成功概率\n过波时进行一次大查(tu)房(sha),对所有住客进行一次收割判定\n【收租】\n过波时获得[住客数量*100]积分\n【高效利用】\n过波时获得[已被收割住客数量*10]积分\n【员工上限】1\n【住客上限】6\n【额外】\n第一位获取的玩家获得[黑猫]\n[左键]查看当前外域物质与收割次数\n[右键]查看当前员工与住客|r"
        })
      end)
    end,
    effectname = "|cFF3366FF神秘庭院|r",
    effecttext = "|cFF99FFFF启动|r\n|cFF3366FF【启动负载】3\n【等级】奇迹\n【效果】\n住客会随着时间自动入住\n收割住客来获取积分,追忆值,词条(外域为主)与属性加成|r",
    effectart = "Mwx_Qidong_Tingyuanzhimen_12",
    test = "    "
  },
  {
    name = "巴蛇之影",
    clickfunc = function(u, var)
      local count1 = u:getdata("巴蛇之影-剩余可分配蜕皮次数")
      u:sendmessage("|cFF66FF99[系统]剩余可分配蜕皮次数:" .. count1 .. "|r")
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 5,
    spirit_load = 3,
    cd = 1,
    key = {"启动", "蛇"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      if not u:hasdata("权限-巴蛇之影") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      if u:islocal() then
        CreateNewUIButton({
          size = 65,
          dx = 1625,
          dy = 650,
          dw = 1.25,
          dh = 1.65,
          img = "UIButton_Mwx_Bszy.blp",
          showtext = "|cFFFFEC9F打开沉眠之殿界面\n(左键拖动 右键切换锁定拖动)|r",
          keytext = "冥王栏" .. var.name,
          func = function(u)
            local count1 = u:getdata("巴蛇之影-剩余可分配蜕皮次数")
            u:sendmessage("|cFF66FF99[系统]剩余可分配蜕皮次数:" .. count1 .. "|r")
            FlashUIVarGlobal(u, MWXSTR .. var.name)
          end
        })
      end
      
      local function get_bashezhiying_var()
        local dpools = {
          Vars_Mwx_Bszy
        }
        return herogetvar(u.handle, dpools, "冥王星")
      end
      
      ac.wait(100, function()
        get_bashezhiying_var()
      end)
      local strz = {
        "邪神酱",
        "千石抚子",
        "白蛇",
        "美杜莎",
        "恶逆之王",
        "远吕智",
        "耶梦加得",
        "萨塔卡尔"
      }
      local xinshengpanding, tuipixiaoguo, randomtuipi
      
      function xinshengpanding(u, var)
        local count = u:getdata("系统-新生次数-" .. var.name)
        u:changedata(var.lv + count .. "阶精神变异数量", -1)
        u:changedata("系统-新生次数-" .. var.name, 1)
        u:changedata(var.lv + count + 1 .. "阶精神变异数量", 1)
        u:changedata("系统-累积新生触发次数", 1)
        u:changedata("系统-累积阶级新生数量-" .. count + 1, 1)
        if not u:hasdata("变异判定-觉醒之殿") and u:getdata("系统-累积新生触发次数") >= 5 then
          u:setdata("变异判定-觉醒之殿")
          u:sendmessage("|cFF66FF99☆☆☆[沉眠之殿]进阶☆☆☆|r")
          u:uivar_change({
            keyname = "巴蛇之影",
            keytype = "冥王栏",
            text = "|cFF66FF99觉醒之殿\n启动\n【启动负载】3\n【等级】卓越\n【效果】\n解锁对应变异池\n过波时降低1等级后提升1等级\n过波时获得2次可分配蜕皮次数(右键所属变异立刻蜕皮一次)\n【进阶】\n新生次数达到3的变异数量达到4以上\n【地标所属变异额外效果】\n升级时概率触发一次蜕皮\n蜕皮时[新生概率*(累积蜕皮次数/(累积新生次数+1))]触发新生\n【基础蜕皮概率】25%\n【基础新生概率】6%\n【基础新生上限次数】3\n[蜕皮]触发对应的蜕皮效果\n[新生]触发对应的新生效果,使阶级提升1,触发时清空累积蜕皮次数\n【额外】\n[左键]查看剩余可分配蜕皮次数\n解锁获取[传奇]变异[梅比乌斯]|r",
            icon = "Weizhitubiao.tga"
          })
        end
        if not u:hasdata("变异判定-吞世之殿") and u:getdata("系统-累积阶级新生数量-3") >= 4 then
          u:setdata("变异判定-吞世之殿")
          u:sendmessage("|cFFFFCC00☆☆☆[觉醒之殿]进阶☆☆☆|r")
          u:uivar_change({
            keyname = "巴蛇之影",
            keytype = "冥王栏",
            text = "|cFFFFCC00吞世之殿\n启动\n【启动负载】3\n【等级】超凡\n【效果】\n解锁对应变异池\n过波时降低2等级后提升2等级\n过波时获得3次可分配蜕皮次数(右键所属变异立刻蜕皮一次)\n等级达到上限时,等级归1并永久降低90%经验获取效率(只触发一次)\n【地标所属变异额外效果】\n升级时概率触发一次蜕皮\n蜕皮时[新生概率*(累积蜕皮次数/(累积新生次数+1))]触发新生\n【基础蜕皮概率】25%\n【基础新生概率】7%\n【基础新生上限次数】4\n[蜕皮]触发对应的蜕皮效果\n[新生]触发对应的新生效果,使阶级提升1,触发时清空累积蜕皮次数\n【额外】\n[左键]查看剩余可分配蜕皮次数|r",
            icon = "Weizhitubiao.tga"
          })
        end
        ac.wait(10, function()
          u:sendmessage("|cffffdc3f[新生触发]:|r" .. var.effectname)
        end)
        if var.xinshengeffect then
          var.xinshengeffect(u, var)
        end
      end
      
      function tuipixiaoguo(u, vardata)
        local xsgl = 5
        local max = 2
        if u:hasdata("变异判定-吞噬之殿") then
          xsgl = 7
          max = 4
        elseif u:hasdata("变异判定-觉醒之殿") then
          xsgl = 6
          max = 3
        end
        if vardata.xslevel then
          max = vardata.xslevel
        end
        local count = u:getdata("系统-新生次数-" .. vardata.name)
        if max > count then
          local gl = xsgl * (u:getdata("系统-蜕皮次数-" .. vardata.name) / (count + 1))
          if GetRandom100(gl) then
            xinshengpanding(u, vardata)
            u:setdata("系统-蜕皮次数-" .. vardata.name, 0)
          else
            u:changedata("系统-蜕皮次数-" .. vardata.name, 1)
          end
        else
          u:changedata("系统-蜕皮次数-" .. vardata.name, 1)
        end
        local nameall = u:getdata("系统-蜕皮文本显示")
        nameall = nameall .. vardata.name .. ","
        u:setdata("系统-蜕皮文本显示", nameall)
        if vardata.tuipieffect then
          vardata.tuipieffect(u, vardata)
        end
      end
      
      local function func(u, name)
        local count1 = u:getdata("巴蛇之影-剩余可分配蜕皮次数")
        if 0 < count1 then
          local vardata
          for _, data in ipairs(Vars_Mwx_Bszy) do
            if data.name == name then
              vardata = data
              break
            end
          end
          if vardata then
            tuipixiaoguo(u, vardata)
          end
          u:sendmessage("|cFF66FF99[系统]蜕皮成功(剩余" .. count1 - 1 .. "次)-" .. vardata.effectname)
          u:changedata("巴蛇之影-剩余可分配蜕皮次数", -1)
        else
          u:sendmessage("|cFF66FF99[系统]剩余次数不足")
        end
      end
      
      u:setdata("巴蛇之影-蜕皮运行函数", func)
      u:setdata("巴蛇之影-剩余可分配蜕皮次数", 0)
      u:setdata("系统-蜕皮文本显示", "")
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        if u:hasdata("变异判定-吞噬之殿") then
          u:addlevel(-2)
          u:addlevel(2)
          u:changedata("巴蛇之影-剩余可分配蜕皮次数", 3)
        elseif u:hasdata("变异判定-觉醒之殿") then
          u:addlevel(-1)
          u:addlevel(1)
          u:changedata("巴蛇之影-剩余可分配蜕皮次数", 2)
        else
          u:addlevel(1)
          u:changedata("巴蛇之影-剩余可分配蜕皮次数", 1)
        end
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        local count = 0
        local gl = 25
        for index, value in ipairs(strz) do
          if u:hasdata("变异判定-" .. value) and u:getluckrandom(gl) then
            count = count + 1
            local vardata
            for _, data in ipairs(Vars_Mwx_Bszy) do
              if data.name == value then
                vardata = data
                break
              end
            end
            if vardata then
              tuipixiaoguo(u, vardata)
            end
          end
        end
        local nameall = u:getdata("系统-蜕皮文本显示")
        if nameall ~= "" then
          u:sendmessage("|cFF66FF99[蜕皮触发]:" .. nameall)
          u:setdata("系统-蜕皮文本显示", "")
        end
        if u:hasdata("变异判定-吞世之殿") and u:getlevel() == 75 and not u:hasdata("吞世之殿-无限之蛇触发") then
          u:setdata("吞世之殿-无限之蛇触发")
          u:setlevel(1)
          u:sendmessage("|cFF66FF99觉|r|cFF75FFA3醒|r|cFF85FFAD之|r|cFF94FFB8殿|r|cFFA3FFC2-|r|cFFB3FFCC无|r|cFFC2FFD6限|r|cFFD1FFE0之|r|cFFE0FFEB蛇|r")
          u:changedata("吞世之殿-无限之蛇次数", 1)
        end
      end)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "巴蛇之影",
          keytype = "冥王栏",
          text = "|cFFEFF7FB沉眠之殿|r\n|cFFEFF7FB启动\n【启动负载】3\n【等级】凡俗\n【效果】\n获取时获得一个所属变异\n过波时提升1等级\n过波时获得1次可分配蜕皮次数(右键所属变异立刻蜕皮一次)\n【进阶】\n累积触发5次新生时进阶\n【地标所属变异额外效果】\n升级时概率触发一次蜕皮\n蜕皮时[新生概率*(累积蜕皮次数/(累积新生次数+1))]触发新生\n【基础蜕皮概率】25%\n【基础新生概率】5%\n【基础新生上限次数】2\n[蜕皮]触发对应的蜕皮效果\n[新生]触发对应的新生效果,使阶级提升1,触发时清空累积蜕皮次数\n【额外】\n[左键]查看剩余可分配蜕皮次数|r"
        })
      end)
    end,
    effectname = "|cFFEFF7FB沉眠之殿|r",
    effecttext = "|cFFEFF7FB启动\n【启动负载】3\n【等级】凡俗\n【效果】\n所属变异在自身升级时概率触发蜕皮提升属性|r",
    effectart = "Ewl_Snake_Qidong",
    test = "        "
  },
  {
    name = "天使学院",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动", "光明"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      u:changedata("光明变异补正", 25)
    end,
    effectname = "|cFF6DB6F1天使学院|r",
    effecttext = "|cFF6DB6F1启动\n【启动负载】2\n【等级】奇迹\n【效果】\n解锁对应冥王变异池\n提升25%光明补正|r",
    effectart = "Mwx_Tsxx_Qd",
    test = "        "
  },
  {
    name = "拟声乌托邦",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动", "同奏"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      u:changedata("战士变异补正", 25)
      u:changedata("同奏变异补正", 50)
    end,
    effectname = "|cffffc861拟声乌托邦|r",
    effecttext = "|cffffc861启动\n【启动负载】2\n【等级】奇迹\n【效果】\n解锁对应冥王变异池\n提升25%战士补正\n提升50%同奏补正|r",
    effectart = "Mwx_Nswtb_Qidong",
    test = "        "
  },
  {
    name = "魔法都市",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动", "魔导"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      ac.wait(100, function()
        herogetvar(u.handle, {
          Vars_Mwx_Mofadushi
        }, "冥王星")
      end)
      if u:islocal() then
        CreateNewUIButton({
          size = 65,
          dx = 1625,
          dy = 650,
          dw = 1.25,
          dh = 1.53,
          img = "UIButton_Mwx_Mofadushi.blp",
          showtext = "|cff84ceff打开魔法都市界面\n(左键拖动 右键切换锁定拖动)|r",
          keytext = "冥王栏" .. var.name,
          func = function(u)
            FlashUIVarGlobal(u, MWXSTR .. var.name)
          end
        })
      end
      u:changedata("魔导变异补正", 50)
    end,
    effectname = "|cff84ceff魔法都市|r",
    effecttext = "|cff84ceff启动\n【启动负载】2\n【等级】奇迹\n【效果】\n解锁对应冥王变异池\n获取时随机获得一个所属变异\n提升50%魔导补正\n【额外】\n[左键]查看已拥有的对应变异|r",
    effectart = "Mwx_Mfds",
    test = "        "
  },
  {
    name = "格里芬安全承包商",
    clickfunc = function(u, var)
      local count1 = u:getdata("格里芬公司-公司发展度")
      local count2 = u:getdata("格里芬公司-公司等级")
      u:sendmessage(("|cFFFF9900[格里芬公司]公司等级:%d 发展度:%d%% 仓库:%d/%d|r"):format(count2, count1, u:getdata("格里芬公司-人形数量"), u:getdata("格里芬公司-仓库上限")))
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 3,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      if u:islocal() then
        CreateNewUIButton({
          size = 65,
          dx = 1625,
          dy = 650,
          dw = 1.25,
          dh = 1.44,
          img = "UIButton_Mwx_Glf.blp",
          showtext = "|cFFED9FAB打开格里芬公司界面\n(左键拖动 右键切换锁定拖动)|r",
          keytext = "冥王栏" .. var.name,
          func = function(u)
            local count1 = u:getdata("格里芬公司-公司发展度")
            local count2 = u:getdata("格里芬公司-公司等级")
            u:sendmessage(("|cFFFF9900[格里芬公司]公司等级:%d 发展度:%d%% 仓库:%d/%d|r"):format(count2, count1, u:getdata("格里芬公司-人形数量"), u:getdata("格里芬公司-仓库上限")))
            FlashUIVarGlobal(u, MWXSTR .. var.name)
          end
        })
      end
      ac.wait(10, function()
        u:uivar_change({
          keyname = "格里芬安全承包商",
          keytype = "冥王栏",
          text = "|cFF949596格里芬公司|r\n|cFF949596启动\n【启动负载】3\n【等级】凡俗\n【效果】\n获取时获取人形[格林娜]\n解锁对应变异池\n过波时获得一张人形制造契约\n过波时提升公司发展度[40%+10%*人形数量]\n【仓库基础上限】4(每2级公司等级提升1仓库上限)\n【公司等级】\n每波结束时公司的盈利:[75*公司等级]积分\n每波结束时公司的任务收益:[随机(1~10)*公司等级*人形数量]积分\n公司上限12级\n公司发展度达到100%时升级公司并清空为0%\n公司达到3/6/9/12级时获得一份[火控元件]\n【额外】\n[左键]查看公司当前发展度\n解锁[格里芬公司业务](共4项)\n天使投资人(首位获取)会获得[帝国の董事长]|r"
        })
      end)
      local count = 0
      
      local function func(u, add)
        u:changedata("格里芬公司-公司发展度", add)
        if u:getdata("格里芬公司-公司等级") < 12 then
          if u:getdata("格里芬公司-公司发展度") >= 100 then
            u:sendmessage("|cFFFF9900[格里芬公司]公司等级提升|r")
            count = count + 1
            if 2 <= count then
              count = 0
              u:sendmessage("|cFFFF9900[格里芬公司]仓库上限提升|r")
              u:changedata("格里芬公司-仓库上限", 1)
            end
            u:changedata("格里芬公司-公司等级", 1)
            u:setdata("格里芬公司-公司发展度", 0)
            local lv = u:getdata("格里芬公司-公司等级")
            if lv == 3 or lv == 6 or lv == 9 or lv == 12 then
              u:additem("I0MC")
            end
          else
            u:sendmessage("|cFFFF9900[格里芬公司]公司发展度提升" .. math.floor(add) .. "%|r")
          end
        end
        local lv = u:getdata("格里芬公司-公司等级")
        if 12 <= lv then
          u:setdata("格里芬-公司扩建消耗", 500 * (lv - 10))
        end
      end
      
      u:changedata("格里芬公司-仓库上限", 4)
      u:changedata("格里芬公司-公司等级", 0)
      u:setdata("格里芬公司-人形数量", 0)
      u:changedata("格里芬公司-公司发展度", 0)
      u:setdata("格里芬公司-公司收益倍率", 1)
      u:setdata("格里芬公司-发展度提升函数", func)
      local dpools = {
        Vars_Mwx_Gelifen_Spe
      }
      local str = herogetvar(u.handle, dpools, "冥王星", "格琳娜")
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        u:additem("I0MB")
        u:getdata("格里芬公司-发展度提升函数")(u, 40 + 10 * u:getdata("格里芬公司-人形数量"))
        local lv = u:getdata("格里芬公司-公司等级")
        local gold = 75 * lv
        local gold2 = GetRandomInt(1, 10) * lv * u:getdata("格里芬公司-人形数量")
        if u:hasdata("变异判定-黑化董事长") then
          gold = gold * 2
        end
        gold = gold * u:getdata("格里芬公司-公司收益倍率")
        u:addgold(gold + gold2)
        u:sendmessage("|cFFFF9900[格里芬公司-营收]盈利:" .. math.floor(gold) .. " 任务收益:" .. math.floor(gold2) .. "|r")
      end)
      if not Weiyi_New[22] then
        local dpools = {
          Vars_Mwx_Gelifen_Spe
        }
        u:setdata("系统-特殊获取中")
        local str = herogetvar(u.handle, dpools, "冥王星", "帝国的董事长")
        u:deldata("系统-特殊获取中")
      end
      u:setdata("格里芬公司-购买火控元件消耗", 4000)
      AddUISkill({
        text = "业务-军火强化",
        u = u,
        cd = 0.2,
        icon = "UI_Glf_Qianghuapeijian.blp",
        showtext = "|cFFFF9900购买枪械强化|r\n|cFFFFCC66存在贷款时无法使用\n点击消耗350积分强化当前装备枪械|r",
        func = function(args)
          local u = args.u
          local gun = gun_upgrade.get_equipped_gun(u)
          if not gun_upgrade.is_valid_gun(gun) then
            u:sendmessage("|cFFFF9900[格里芬公司]未装备可强化枪支|r")
            return
          end
          if not u:addqiankuan(350) then
            u:sendmessage("|cFFFF9900存在贷款无法使用|r")
            return
          end
          local result = gun_upgrade.apply(gun, u)
          gun_upgrade.send_success_message(u, result, "|cFFFF9900")
        end
      })
      AddUISkill({
        text = "业务-军火购置",
        u = u,
        cd = 3,
        icon = "UI_Glf_Zhuangbeizhizao.tga",
        showtext = "|cFFFF9900装备制造契约|r\n|cFFFFCC66存在贷款时无法使用\n点击消耗250积分获得一份装备制造契约|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          if u:addqiankuan(250) then
          else
            u:sendmessage("|cFFFF9900存在贷款无法使用|r")
            return
          end
          u:additem("I0MD")
        end
      })
      AddUISkill({
        text = "业务-员工招募",
        u = u,
        cd = 3,
        icon = "UI_Glf_Renxingzhizao.tga",
        showtext = "|cFFFF9900人形制造契约|r\n|cFFFFCC66存在贷款时无法使用\n点击消耗300积分获得一张人形制造契约|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          if u:addqiankuan(300) then
          else
            u:sendmessage("|cFFFF9900存在贷款无法使用|r")
            return
          end
          u:additem("I0MB")
        end
      })
      u:setdata("格里芬-公司扩建消耗", 500)
      AddUISkill({
        text = "业务-公司扩建",
        u = u,
        cd = 0.2,
        icon = "UI_Glf_Gongsikuojian.tga",
        showtext = "|cFFFF9900公司扩建|r\n|cFFFFCC66存在贷款时无法使用\n点击消耗" .. u:getdata("格里芬-公司扩建消耗") .. "积分提升公司50%发展度|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          if u:getdata("格里芬公司-公司等级") >= 12 then
            u:sendmessage("|cFFFF9900已达到满级|r")
            return
          end
          if u:addqiankuan(u:getdata("格里芬-公司扩建消耗")) then
          else
            u:sendmessage("|cFFFF9900存在贷款无法使用|r")
            return
          end
          u:getdata("格里芬公司-发展度提升函数")(u, 50)
        end
      })
      AddUISkill({
        text = "业务-火控元件购买",
        u = u,
        cd = 1,
        icon = "UI_Glf_Huokongyuanjian.tga",
        showtext = "|cFFFF9900购买火控元件|r\n|cFFFFCC66消耗积分购买火控元件,每次购买翻倍下次购买消耗\n基础消耗积分4000|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          if u:getgold() >= u:getdata("格里芬公司-购买火控元件消耗") then
            u:addgold(-u:getdata("格里芬公司-购买火控元件消耗"))
            u:changedata("格里芬公司-购买火控元件消耗", 2, 1)
            u:additem("I0MC")
            u:sendmessage("|cFF7DBEF1购买成功,下一次购买消耗积分:" .. u:getdata("格里芬公司-购买火控元件消耗"))
          else
            u:sendmessage("|cFF7DBEF1积分不足,所需积分" .. u:getdata("格里芬公司-购买火控元件消耗"))
          end
        end
      })
    end,
    effectname = "|cFF949596格里芬公司|r",
    effecttext = "|cFF949596启动\n【启动负载】3\n【等级】凡俗\n【效果】\n解锁对应冥王变异池\n过波时获得一张人形制造契约\n【公司等级】\n每波结束时获得公司相关收益\n公司发展度足够时提升公司相关登记|r",
    effectart = "Ewl_Mwx_Qidong_Shaoqian",
    test = "        "
  },
  {
    name = "拉塔托斯克",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 3,
    cd = 1,
    key = {"启动", "唯一"},
    rarity = "稀有",
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("隐藏职业-始源精灵") then
        add = add + 500
      end
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      local dpools = {
        Vars_Mwx_Jingling_Spe
      }
      ac.wait(100, function()
        local str = herogetvar(u.handle, dpools, "冥王星", "五河士道")
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        u:sendmessage("|cFF6699FF[拉塔托斯克]作战会议召开完毕|r")
        u:additem("I0MF")
      end)
    end,
    effectname = "|cFF00A493拉塔托斯克|r",
    effecttext = "|cFF00A493唯一 启动\n【启动负载】3\n【等级】奇迹\n【效果】\n解锁对应冥王变异池\n获取时获得[五河士道]\n过波时召开一次作战会议(获得作战计划表)\n【额外】\n精灵附属变异均为极其稀有权重|r",
    effectart = "Mwx_Jl_Qidong",
    test = "            "
  },
  {
    name = "环都市",
    clickfunc = function(u, var)
      local count1 = u:getdata("环都市-病毒点数")
      u:sendmessage(("|cFFF9F0FA[环都市.德丽莎]病毒点数:%d|r"):format(count1))
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 5,
    spirit_load = 2,
    cd = 1,
    key = {
      "启动",
      "唯一",
      "德丽莎"
    },
    rarity = "稀有",
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0H3") then
        add = add + 200
      end
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      if not u:hasdata("权限-德丽莎观星") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      Danwei_Delisha = u.handle
      u:setdata("环都市-病毒点数", 0)
      u:setdata("环都市-都市等级", 1)
      
      local function get_delisha_var()
        local pools = {
          Vars_Mwx_Delisha_Lv1
        }
        return herogetvar(u.handle, pools, "冥王星")
      end
      
      ac.wait(100, function()
        get_delisha_var()
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        get_delisha_var()
        u:changedata("环都市-病毒点数", 1)
        if u:getdata("环都市-都市等级") >= 2 then
          u:additem("I0MG")
        end
        if u:getdata("环都市-都市等级") >= 3 then
          u:changedata("环都市-病毒点数", 1)
        end
      end)
      ac.loop(1000, function()
        if u:isalive() then
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if u.handle ~= xq.handle then
              local dis = DistanceBetweenUnits(xq.handle, u.handle)
              if u:getdata("环都市-都市等级") == 2 then
                if dis <= 1800 then
                  xq:setdata("环都市-感染概率", 10)
                else
                  xq:deldata("环都市-感染概率")
                end
              end
              if u:getdata("环都市-都市等级") == 3 then
                if dis <= 3600 then
                  xq:setdata("环都市-感染概率", 20)
                else
                  xq:deldata("环都市-感染概率")
                end
              end
            end
          end)
        else
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:deldata("环都市-感染概率")
          end)
        end
      end)
      ac.loop(3000, function(timer)
        local ds = u:getdata("环都市-病毒点数")
        if 10 <= ds and u:getdata("环都市-都市等级") == 1 then
          u:setdata("环都市-都市等级", 2)
          u:uivar_change({
            keyname = "环都市",
            keytype = "冥王栏",
            text = "|cFFF9F0FA环都市.德丽莎:二阶|r\n|cFFF9F0FA唯一 启动\n【启动负载】2\n【等级】奇迹\n【效果】\n过波时德丽傻病毒提升1点\n过波时获得一张德丽莎茶会券\n获得德丽莎变异时提升1点德丽傻病毒点数\n【病毒传播】\n获得变异时[10%+德丽莎病毒点数*0.5%](上限50%)使其被德丽傻病毒感染(不会感染德丽莎变异)\n(变异词条将会被强制替换为[德丽莎](多个也只计入一个)并获得1点德丽傻病毒点数)\n靠近自身1800范围的队友获得变异时也有10%概率被德丽傻病毒感染\n(自身获得德丽傻病毒点数,自身获得被感染变异的词条)\n(以下词条不会在替换中消失或额外获得:启动)\n【进阶】\n德丽傻病毒达到40点\n【额外】\n[左键]查看目前德丽傻病毒点数|r\n|cFF949596德丽莎病毒大举入侵！！|r",
            icon = "Weizhitubiao"
          })
        end
        if 40 <= ds and u:getdata("环都市-都市等级") == 2 then
          u:setdata("环都市-都市等级", 3)
          u:uivar_change({
            keyname = "环都市",
            keytype = "冥王栏",
            text = "|cFFF9F0FA环都市.德丽莎:三阶|r\n|cFFF9F0FA唯一 启动\n【启动负载】2\n【等级】超凡\n【效果】\n过波时德丽傻病毒提升2点\n过波时获得一张德丽莎茶会券\n获得德丽莎变异时提升1点德丽傻病毒点数\n【病毒传播】\n获得变异时[10%+德丽莎病毒点数*0.5%](上限75%)使其被德丽傻病毒感染(不会感染德丽莎变异)\n(变异词条将会被强制替换为[德丽莎](多个也只计入一个)并获得1点德丽傻病毒点数)\n靠近自身3600范围的队友获得变异时也有20%概率被德丽傻病毒感染\n(自身获得德丽傻病毒点数,自身获得被感染变异的词条)\n(以下词条不会在替换中消失或额外获得:启动)\n【额外】\n[左键]查看目前德丽傻病毒点数|r\n|cFF949596德丽莎病毒占领全世界！！|r",
            icon = "Weizhitubiao"
          })
          timer:remove()
        end
      end)
      if u:hasdata("隐藏职业-无用之人") then
        hideproshow(u.handle)
        local xg = 0
        local cs = 0
        ac.loop(5000, function()
          cs = cs + 1
          if 4 <= cs then
            cs = 0
            u:changedata("德丽莎变异数量", 1)
          end
          u:changedata("效果增强-德丽莎", -xg)
          xg = 0.01 * u:getdata("德丽莎变异数量")
          u:changedata("效果增强-德丽莎", xg)
        end)
        u:sendmessage("|cFF9B9BA8百亿德丽莎占领全世界！|r")
        u:setdata("变异判定-百亿德丽莎")
        u:uivar_add({
          keyname = "一亿瓜田人德丽莎",
          keytype = "传奇栏",
          text = "|cFF9B9BA8一|r|cFFA3A3AE亿|r|cFFACACB5瓜|r|cFFB4B4BB田|r|cFFBCBCC2人|r|cFFC4C4C8德|r|cFFCDCDCF丽|r|cFFD5D5D5莎|r\n|cFFFFBFBF[特殊]|r\n|cFF9B9BA8唯一 德丽莎|r\n|cFFD5D5D5德丽莎病毒对自身生效时,不再覆盖词条\n每20秒提升1德丽莎词条\n提升[1%*德丽莎变异数量]德丽莎变异效果|r",
          icon = "Cq_Spe_Yiyiren"
        })
      end
    end,
    effectname = "|cFFF9F0FA环都市.德丽莎:一阶|r",
    effecttext = "|cFFF9F0FA唯一 启动\n【启动负载】2\n【等级】凡俗\n【效果】\n过波时德丽傻病毒提升1点\n获得德丽莎变异时提升1点德丽傻病毒点数\n解锁对应冥王变异池\n【病毒传播】\n获得变异时[10%+德丽莎病毒点数*0.5%](上限25%)使其被德丽傻病毒感染(不会感染德丽莎变异)\n(变异词条将会被强制替换为[德丽莎](多个也只计入一个)并获得1点德丽傻病毒点数)\n(以下词条不会在替换中消失或额外获得:启动)\n【进阶】\n德丽傻病毒达到10点\n【额外】\n[左键]查看目前德丽傻病毒点数|r\n|cFF949596德丽莎病毒入侵！！|r",
    effectart = "Ewl_Mwx_Qidong_Delisha",
    test = "            "
  },
  {
    name = "梦游仙境",
    clickfunc = function(u, var)
      u:sendmessage("|cFF6699FF☆梦游仙境☆|r")
      u:sendmessage(("|cFF6699FF[冒险点]%d|r"):format(u:getdata("梦游仙境-冒险点")), 10)
      u:sendmessage(("|cFF6699FF[sen值]%d|r"):format(u:getdata("梦游仙境-sen值")), 10)
      if u:getdata("梦游仙境-遇到小红帽次数") > 0 then
        u:sendmessage(("|cFF6699FF[遇到小红帽次数]%d|r"):format(u:getdata("梦游仙境-遇到小红帽次数")), 10)
      end
      u:sendmessage(("|cFF6699FF[誓约点数]%d|r"):format(u:getdata("梦游仙境-誓约点数")), 10)
      if 0 < u:getdata("梦游仙境-相爱次数") then
        u:sendmessage(("|cffe66cff[相爱次数]%d|r"):format(u:getdata("梦游仙境-相爱次数")), 10)
      end
      if 0 < u:getdata("梦游仙境-侵犯数量") then
        u:sendmessage(("|cff990000[侵犯次数]%d(共%d人)|r"):format(u:getdata("梦游仙境-侵犯次数"), u:getdata("梦游仙境-侵犯数量")), 10)
      end
      if 0 < u:getdata("梦游仙境-杀害数量") then
        u:sendmessage(("|cff990000[杀害数量]%d|r"):format(u:getdata("梦游仙境-杀害数量")), 10)
      end
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    rightclickfunc = function(u, var)
      local sy = u.ownerid
      if u:hasdata("梦游仙境-已达成结局") then
        return
      end
      if u:getdata("梦游仙境-获取变异数量") < 10 then
        return
      end
      if 10 <= u:getdata("梦游仙境-遇到小红帽次数") then
        u:setdata("梦游仙境-已达成结局")
        SendMsgAll(u:getplayername() .. "|cFF6699FF结束了冒险，达成结局|r|cFFFF4B4B《G「end」(小红帽)》")
        herogetvar(u.handle, {
          Vars_Mwx_Alice_Spe
        }, "冥王星", "小红帽")
        return
      end
      if u:getdata("梦游仙境-相爱次数") >= 5 and 5 <= u:getdata("梦游仙境-誓约点数") then
        SendMsgAll(u:getplayername() .. "|cFF6699FF结束了冒险，达成结局|r|cffc7c7c7《我已经厌倦了,再见了爱丽丝》|r")
        u:setdata("梦游仙境-已达成结局")
        herogetvar(u.handle, {
          Vars_Mwx_Alice_Spe
        }, "冥王星", "白之兔诺登")
        return
      end
      if u:hasdata("变异判定-爱丽丝") and 10 <= u:getdata("爱丽丝-梦境值") and Hero_Shenhua_Now[sy] == 0 then
        SendMsgAll(u:getplayername() .. "|cFF6699FF结束了冒险，达成结局|r|cFFFFFF33《参加茶会》|r")
        u:setdata("梦游仙境-已达成结局")
        AdvanceGet["茶会爱丽丝"](u)
        return
      end
      if u:hasdata("变异判定-普利凯特") and u:getdata("梦游仙境-杀害数量") >= 1 then
        SendMsgAll(u:getplayername() .. "|cFF6699FF结束了冒险，达成结局|r|cFF1FBF00《F「end」(莉耶芙)》|r")
        u:setdata("梦游仙境-已达成结局")
        herogetvar(u.handle, {
          Vars_Mwx_Alice_Spe
        }, "冥王星", "莉耶芙")
        return
      end
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动", "唯一"},
    rarity = "稀有",
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("初始-兔子洞") then
        add = add + 1500
      end
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      if not u:hasdata("特殊判定-爱丽丝初始") and not u:hasdata("初始-兔子洞") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      if u:islocal() then
        Local_AliceKuaijietubiao = CreateNewUIButton({
          size = 65,
          dx = 1625,
          dy = 650,
          dw = 1.25,
          dh = 1.22,
          img = "UIButton_Mwx_Alice01.blp",
          showtext = "|cFF6699FF打开梦游仙境界面\n(左键拖动 右键切换锁定拖动)|r",
          keytext = "冥王栏" .. var.name,
          func = function(u)
            u:sendmessage("|cFF6699FF☆梦游仙境☆|r")
            u:sendmessage(("|cFF6699FF[冒险点]%d|r"):format(u:getdata("梦游仙境-冒险点")), 10)
            u:sendmessage(("|cFF6699FF[sen值]%d|r"):format(u:getdata("梦游仙境-sen值")), 10)
            if u:getdata("梦游仙境-遇到小红帽次数") > 0 then
              u:sendmessage(("|cFF6699FF[遇到小红帽次数]%d|r"):format(u:getdata("梦游仙境-遇到小红帽次数")), 10)
            end
            u:sendmessage(("|cFF6699FF[誓约点数]%d|r"):format(u:getdata("梦游仙境-誓约点数")), 10)
            if 0 < u:getdata("梦游仙境-相爱次数") then
              u:sendmessage(("|cffe66cff[相爱次数]%d|r"):format(u:getdata("梦游仙境-相爱次数")), 10)
            end
            if 0 < u:getdata("梦游仙境-侵犯数量") then
              u:sendmessage(("|cff990000[侵犯次数]%d(共%d人)|r"):format(u:getdata("梦游仙境-侵犯次数"), u:getdata("梦游仙境-侵犯数量")), 10)
            end
            if 0 < u:getdata("梦游仙境-杀害数量") then
              u:sendmessage(("|cff990000[杀害数量]%d|r"):format(u:getdata("梦游仙境-杀害数量")), 10)
            end
            FlashUIVarGlobal(u, MWXSTR .. var.name)
          end
        })
        Local_AliceKuaijietubiao.show2 = class.panel:builder({
          parent = Local_AliceKuaijietubiao,
          x = 0,
          y = 0,
          w = Local_AliceKuaijietubiao:get_width(),
          h = Local_AliceKuaijietubiao:get_height(),
          normal_image = "UIButton_Mwx_Alice02.blp"
        })
        Local_AliceKuaijietubiao.show2:set_alpha(0)
      end
      u:setdata("梦游仙境-sen值", 100)
      u:setdata("梦游仙境-冒险点", 2)
      u:setdata("梦游仙境-誓约点数", 0)
      u:setdata("梦游仙境-杀害数量", 0)
      u:setdata("梦游仙境-侵犯数量", 0)
      u:setdata("梦游仙境-相爱次数", 0)
      u:setdata("梦游仙境-侵犯次数", 0)
      u:setdata("梦游仙境-遇到小红帽次数", 0)
      u:setdata("梦游仙境-奇遇剩余次数", 14)
      if u:hasdata("特殊判定-爱丽丝初始") then
        u:additem("I0P7")
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        u:changedata("梦游仙境-冒险点", 2)
        if u:getdata("梦游仙境-奇遇剩余次数") > 0 then
          u:additem("I0P8")
          u:changedata("梦游仙境-奇遇剩余次数", -1)
        end
        if not u:hasdata("梦游仙境-已达成结局") and u:getdata("梦游仙境-获取变异数量") >= 10 then
          local b = false
          if 10 <= u:getdata("梦游仙境-遇到小红帽次数") then
            b = true
          end
          if u:hasdata("变异判定-爱丽丝") and 10 <= u:getdata("爱丽丝-梦境值") and Hero_Shenhua_Now[sy] == 0 then
            b = true
          end
          if u:getdata("梦游仙境-相爱次数") >= 5 and 5 <= u:getdata("梦游仙境-誓约点数") then
            b = true
          end
          if u:hasdata("变异判定-普利凯特") and u:getdata("梦游仙境-杀害数量") >= 1 then
            b = true
          end
          if b then
            u:sendmessage("|cFF6699FF[梦游仙境]已满足结局条件,右击图标进入结局结算|r")
          end
        end
      end)
      u:changedata("童话变异补正", 50)
    end,
    effectname = "|cFF6699FF梦游仙境|r",
    effecttext = "|cFF6699FF启动\n【启动负载】2\n【等级】奇迹\n【效果】\n提升50%童话变异补正\n解锁对应冥王变异池\n【奇遇】\n过波时获得2点冒险点\n过波时获得一张奇遇卡(至多14次)\n【额外】\n[右键]满足条件时进行结局结算(结局结算后仍能互动)|r",
    effectart = "Mwx_Alice_11",
    test = "        "
  },
  {
    name = "幻想乡",
    clickfunc = function(u, var)
      local count1 = u:getdata("幻想乡-P点")
      local count2 = count1 + u:getdata("幻想乡-累积P点") + u:getdata("幻想乡-累积消耗P点")
      u:sendmessage(("|cFFFFCCFF幻想乡-P点数量:%d(累积:%d)|r"):format(count1, count2))
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 3,
    cd = 1,
    key = {"启动", "东方"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      if u:hasdata("变异判定-古明地恋") then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      if u:islocal() then
        CreateNewUIButton({
          size = 65,
          dx = 1625,
          dy = 650,
          dw = 1.25,
          dh = 1.22,
          img = "UIButton_Mwx_Hxx.blp",
          showtext = "|cFFF88261打开幻想乡界面\n(左键拖动 右键切换锁定拖动)|r",
          keytext = "冥王栏" .. var.name,
          func = function(u)
            local count1 = u:getdata("幻想乡-P点")
            local count2 = count1 + u:getdata("幻想乡-累积P点") + u:getdata("幻想乡-累积消耗P点")
            u:sendmessage(("|cFFFFCCFF幻想乡-P点数量:%d(累积:%d)|r"):format(count1, count2))
            FlashUIVarGlobal(u, MWXSTR .. var.name)
          end
        })
      end
      Count_Huanxiangxiangshuliang = Count_Huanxiangxiangshuliang + 1
      if not u:hasdata("幻想乡-P点") then
        u:setdata("幻想乡-P点", 0)
      end
      u:setdata("幻想乡-等级", 1)
      u:setdata("幻想乡-住客数量", 0)
      u:setdata("幻想乡-累积消耗P点", 0)
      ac.loop(1000, function()
        if u:isalive() then
          local x, y = u:getxy()
          for index, tx in ipairs(DataGroup_Pdian) do
            local dx, dy = GetEffectXY(tx)
            local dis = DistanceXY(x, y, dx, dy)
            if dis <= 2000 then
              table.remove(DataGroup_Pdian, index)
              local angle = AngleXY(dx, dy, x, y)
              effectmove({
                effect = tx,
                time = 0.3,
                distance = dis,
                angle = angle,
                endfunc = function()
                  DestroyEffectLua(tx)
                  PdianAdd(u, 1)
                end
              })
            end
          end
        end
      end)
      u:setdata("幻想乡-限时变异组", {})
      u:addstexiao(var.name, "波数开始时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        u:sendmessage("|cFFFFCCFF[幻想乡]新的访客到来……|r")
        for index, value in ipairs(u:getdata("幻想乡-限时变异组")) do
          local varbut = u:uivar_get(value, "冥王栏", "幻想乡")
          if varbut and varbut.vardata then
            varbut.vardata.removefunc(u, varbut.vardata)
          end
        end
        u:setdata("幻想乡-限时变异组", {})
        for i = 1, 2 + u:getdata("幻想乡-等级") do
          local pools = {
            Vars_Mwx_Dongfang
          }
          u:setdata("幻想乡-临时获取")
          local str = herogetvar(u.handle, pools, "冥王星")
          u:deldata("幻想乡-临时获取")
          if str ~= "失败" then
            table.insert(u:getdata("幻想乡-限时变异组"), str)
          end
        end
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = resolve_mwx_effect_unit(u, args)
        if not u then
          return
        end
        PdianAdd(u, 5 + 5 * u:getdata("幻想乡-等级"))
      end)
      ac.loop(3000, function(timer)
        if u:getdata("幻想乡-P点") + u:getdata("幻想乡-累积消耗P点") >= 200 then
          u:setdata("幻想乡-等级", 2)
          Count_Huanxiangxiangshuliang = Count_Huanxiangxiangshuliang + 1
          u:sendmessage("|cFFFFCCFF☆☆☆[幻想乡]进阶☆☆☆|r")
          local qsx = 0
          ac.loop(1000, function()
            if qsx ~= u:getdata("幻想乡-累积消耗P点") then
              u:addallstats(u:getdata("幻想乡-累积消耗P点") - qsx)
              qsx = u:getdata("幻想乡-累积消耗P点")
            end
          end)
          u:uivar_change({
            keyname = "幻想乡",
            keytype = "冥王栏",
            text = "|cFFFFCCFF众神眷恋的幻想乡|r\n|cFFFFCCFF启动\n【启动负载】3\n【等级】超凡\n【效果】\n每波怪物有概率幻想化(变红),击败后掉落P点(可拾取,提升1点全属性,存在60秒)\n每波幻想化的怪物上限数量提升\n自身死亡时损失10%P点,随后掉落50%P点\n过波时获得15点P点\n提升[累积消耗P点*1]点全属性\n【访客】\n每波开始时随机4名访客拜访,持续至下一波开始;可以右键指定访客花费P点锁定为永久\n【额外】\n[左键]查看目前P点数量|r",
            icon = "Mwx_Qidong_Hxx_02"
          })
          timer:remove()
        end
      end)
    end,
    effectname = "|cFFFFCCFF幻想乡|r",
    effecttext = "|cFFFFCCFF启动\n【启动负载】3\n【等级】奇迹\n【效果】\n每波怪物有概率幻想化(变红),击败后掉落P点(可拾取,提升1点全属性,存在60秒)\n自身死亡时损失10%P点,随后掉落50%P点\n过波时获得10点P点\n【访客】\n每波开始时随机3名访客拜访,持续至下一波开始;可以右键指定访客花费P点锁定为永久\n【进阶】\nP点达到200点(包括锁定变异消耗)\n【额外】\n[左键]查看目前P点数量|r",
    effectart = "Mwx_Qidong_Leyuanjihua_15",
    test = "        "
  },
  {
    name = "多彩星河",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      if not u:hasdata("变异判定-天外来信") then
        b = false
      end
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
    end,
    effectname = "|cFFCCCCFF多|r|cFFD6B8F5彩|r|cFFE0A3EB星|r|cFFEB8FE0河|r",
    effecttext = "|cFFCCCCFF启动\n【启动负载】2|r\n|cFFD6B8F5限女性|r\n|cFFE0A3EB解锁对应冥王变异池|r",
    effectart = "Mwx_Qidong_Duocaixinghe_15",
    test = "        "
  },
  {
    name = "洗衣龙女的困境",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动", "龙"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      u:changedata("龙变异补正", 50)
    end,
    effectname = "|cFF3366FF洗衣龙女的困境|r",
    effecttext = "|cFF3366FF启动\n【启动负载】2\n解锁对应冥王变异池\n[精准堆墓]效果触发间隔翻倍,指定药剂概率提升0.5倍\n提升50%龙变异补正|r",
    effectart = "Mwx_Longnvpu_09_12",
    test = "        "
  },
  {
    name = "武神意志",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动", "战士"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
    end,
    effectname = "|cFF6699CC武神意志|r",
    effecttext = "|cFF6699CC启动\n【启动负载】2\n解锁对应冥王变异池|r",
    effectart = "BTNMwx_Qidong_Wushen",
    test = "        "
  },
  {
    name = "妖怪少女",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动", "不死"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      local add = 0
      add = qidongweightchange(u, var, add)
      return add
    end,
    condition = function(u)
      local b = true
      b = Qidongshangxianpanding(u)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
      u:changedata("不死变异补正", 25)
    end,
    effectname = "|cFFADE1DE妖怪少女|r",
    effecttext = "|cFFADE1DE启动\n【启动负载】2\n解锁对应冥王变异池\n提升25%不死变异补正|r",
    effectart = "Mwx_Ygsn_Qd",
    test = "        "
  },
  {
    name = "异聚门扉",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 5,
    cd = 1,
    key = {"唯一", "启动"},
    rarity = "稀有",
    unique = true,
    addweight = function(u, var)
      return qidongweightchange(u, var, 0)
    end,
    condition = function(u)
      return Qidongshangxianpanding(u)
    end,
    effect = function(u, var)
      MwxQidongGet(u, var)
      herogetvar(u.handle, {
        Vars_Mwx_Yijumenfei
      }, "冥王星", "意识海战神")
    end,
    effectname = "|cFFC9696A异聚门扉|r",
    effecttext = "|cFFC9696A唯一 启动|r\n|cFFF7A8B1【精神承载】5\n【等级】禁忌\n【效果】\n获取时获得[意识海战神]|r",
    effectart = "Cq_Lxy_Qidong.tga",
    test = "        "
  },
  {
    name = "天下会",
    clickfunc = function(u, var)
      FlashUIVarGlobal(u, MWXSTR .. var.name)
    end,
    weight = 1000,
    spirit_load = 2,
    cd = 1,
    key = {"启动"},
    rarity = "稀有",
    unique = false,
    addweight = function(u, var)
      return qidongweightchange(u, var, 0)
    end,
    condition = function(u)
      return Qidongshangxianpanding(u)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxQidongGet(u, var)
    end,
    effectname = "|cFF6699CC侠义天下|r",
    effecttext = "|cFF6699CC启动\n【精神承载】2\n【等级】凡俗\n解锁对应变异池|r",
    effectart = "BTNMwx_Qidong_Tianxiahui",
    test = "        "
  }
}
local dmc_qidong_name = "恶魔五月哭"
if GetRandomInt(1, 100) > 75 then
  local other_names = {
    "相亲相爱一家人",
    "父慈子孝",
    "兄弟和睦"
  }
  dmc_qidong_name = other_names[GetRandomInt(1, #other_names)]
end
table.insert(Vars_Mwx, {
  name = "恶魔五月哭",
  clickfunc = function(u, var)
    FlashUIVarGlobal(u, MWXSTR .. var.name)
  end,
  weight = 1000,
  spirit_load = 2,
  cd = 1,
  key = {"启动"},
  rarity = "稀有",
  addweight = function(u, var)
    return qidongweightchange(u, var, 0)
  end,
  condition = function(u)
    return Qidongshangxianpanding(u)
  end,
  effect = function(u, var)
    local sy = u.ownerid
    MwxQidongGet(u, var)
    u:changedata("鬼泣计数", 1)
    local devil_count_bonus = 0
    ac.loop(3000, function()
      u:changedata("恶魔变异数量", -devil_count_bonus)
      devil_count_bonus = math.floor(u:getdata("鬼泣计数") / 3)
      u:changedata("恶魔变异数量", devil_count_bonus)
    end)
  end,
  effectname = "|cFFA5B2CC" .. dmc_qidong_name .. "|r",
  effecttext = "|cFFA5B2CC启动\n【启动负载】2\n【等级】稀有\n【效果】\n鬼泣计数+1\n每3点鬼泣计数提升1恶魔词条\n解锁相关变异池\n【额外】\n获得[维吉尔]和[但丁]时:\n返还2点启动负载\n降低10点精神负载力\n传奇池解锁[尼禄]|r",
  effectart = "Mwx_Dmc_Qidong.tga"
})
require("gameplay.var.pools.mwx.pools_mwx_sgs")(qidongweightchange)
require("gameplay.var.pools.mwx.pools_mwx_danwanlunpo")(qidongweightchange)
