-- 상점 카드 설명은 완성 문장을 번역한 뒤 글꼴 폭에 맞춰 줄바꿈한다.
local slk = require("jass.slk")
local temptext = class.text:builder({
  x = 0,
  y = 0,
  w = 1,
  h = 1,
  align = "auto_size",
  font_size = 10,
  text = ""
})
temptext:hide()

local function getTextWidth(text)
  temptext:set_text(text)
  local w = temptext:get_width()
  temptext:set_text("")
  return w
end

local function smartWrapText(rawtext, max_width)
  local korean = require("hera_korean")
  local text = korean.translate(rawtext)
  return require("hera_text_width").wrap(text, 10,
    korean.has_hangul(text) and korean.font or TEXT_FONT_PATH, max_width)
end

local function getRandomUniqueNumbers(n, max)
  local pool = {}
  for i = 1, max do
    table.insert(pool, i)
  end
  for i = #pool, 2, -1 do
    local j = math.random(1, i)
    pool[i], pool[j] = pool[j], pool[i]
  end
  local result = {}
  for i = 1, n do
    table.insert(result, pool[i])
  end
  return result
end

local maodian
local shopItems = {}
local closeShopButton
local publicOffers = {}
local personalOffers = {}
local publicButtons = {}
local personalButtons = {}
local currentOfferOwner
local shopRefreshVersion = 0
local shopInterfaceInitialized = false
local PUBLIC_SLOT_COUNT = 6
local PERSONAL_SLOT_COUNT = 12

local function getOffer(scope, slot, player_id)
  if scope == "public" then
    return publicOffers[slot]
  end
  local offers = personalOffers[player_id]
  return offers and offers[slot]
end

local function getOfferList(scope, player_id)
  if scope == "public" then
    return publicOffers
  end
  return personalOffers[player_id] or {}
end

local function getButtonList(scope)
  if scope == "public" then
    return publicButtons
  end
  return personalButtons
end

local function hidePurchasedOffer(scope, slot, u)
  if scope == "public" or u:islocal() then
    local button = getButtonList(scope)[slot]
    if button then
      button:hide()
    end
  end
end

local function createShopSlotButton(parent, scope, slot)
  local ds = 0.8
  local button = class.button:builder({
    parent = parent,
    x = 0,
    y = 0,
    w = ds * 168 * 0.88,
    h = ds * 202 * 0.68,
    sync_key = scope == "public" and "SHOP_PUBLIC_" .. slot or "SHOP_PERSONAL_" .. slot,
    normal_image = "UI_Shop_BtnBack_Red.blp",
    on_button_mouse_enter = function(self)
      self:set_alpha(155)
      local item = self.display_offer
      if item then
        uiy_show_text(item.name .. "\n" .. item.desc .. "|r", "Yuanzhu")
      end
    end,
    on_button_mouse_leave = function(self)
      self:set_alpha(255)
      uiy_hide()
    end,
    on_button_clicked = function(self)
      self:add_cd_animation(0, 0, 1, 1)
      self:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
    end,
    on_sync_button_clicked = function(self, p)
      if self.sync_data ~= shopRefreshVersion then
        return
      end
      local sy = p.id
      if not Xuanze[sy] then
        return
      end
      local u = getunit(Hero[sy])
      local item = getOffer(scope, slot, sy)
      if not item then
        return
      end
      if item.hasbeenget then
        u:sendmessage("|cFF99FF99已被购买|r")
        return
      end
      if item.buy_group then
        for _, other in ipairs(getOfferList(scope, sy)) do
          if other ~= item and other.buy_group == item.buy_group and other.hasbeenget then
            item.hasbeenget = true
            u:sendmessage("|cFF99FF99同组商品已被购买|r")
            hidePurchasedOffer(scope, slot, u)
            return
          end
        end
      end
      if u:getgold() >= item.price or Boolean_Qiangjiejiaoyisuo then
        if not Boolean_Qiangjiejiaoyisuo then
          u:addgold(-item.price)
          u:sendmessage("|cFF99FF99购买成功：" .. item.name .. "|r")
        else
          u:sendmessage("|cFFCC0000打劫成功：" .. item.name .. "|r")
        end
        item.hasbeenget = true
        if item.func then
          item.func(item, u)
        end
        hidePurchasedOffer(scope, slot, u)
        if item.buy_group then
          local offers = getOfferList(scope, sy)
          for other_slot, other in ipairs(offers) do
            if other ~= item and other.buy_group == item.buy_group then
              other.hasbeenget = true
              hidePurchasedOffer(scope, other_slot, u)
            end
          end
        end
        if u:islocal() then
          PlayGlobalSound(Sound_UI_Buy)
          uiy_hide()
        end
        shangdianxiaofeipanding(u)
      else
        u:sendmessage("|cFFFF0000金币不足！|r")
      end
    end
  })
  button.price_text = class.text:builder({
    parent = button,
    x = 54,
    y = 97,
    w = 1,
    h = 1,
    text = "",
    align = "center",
    font_size = 11
  })
  button.icon = class.panel:builder({
    parent = button,
    x = 15.5,
    y = 11,
    w = 88,
    h = 66,
    normal_image = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
  })
  button.discount = class.panel:builder({
    parent = button,
    x = 60,
    y = -6,
    w = 70.4,
    h = 54.400000000000006,
    normal_image = "UI_NewB_Off.blp"
  })
  button.discount:hide()
  button:hide()
  shopItems[#shopItems + 1] = button
  return button
end

local function renderShopButton(button, item)
  button.sync_data = shopRefreshVersion
  button.display_offer = item
  if not item or item.hasbeenget then
    button:hide()
    return
  end
  button:set_position(item.ui_x, item.ui_y)
  button:set_normal_image(item.ui_background or "UI_Shop_BtnBack_Red.blp")
  button.price_text:set_text("|cFFFFFF00$" .. item.price)
  button.icon:set_normal_image(item.icon or "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
  if item.isdiscount then
    button.discount:show()
  else
    button.discount:hide()
  end
  button:set_alpha(255)
  button:show()
end

local function renderShopOffers()
  for slot = 1, PUBLIC_SLOT_COUNT do
    renderShopButton(publicButtons[slot], publicOffers[slot])
  end
  local offers = personalOffers[LocalPlayerID] or {}
  for slot = 1, PERSONAL_SLOT_COUNT do
    renderShopButton(personalButtons[slot], offers[slot])
  end
end

local function registerShopOffer(item, x, y, extraph)
  local dazhe = item.isdiscount or false
  if dazhe then
    item.price = math.floor(item.price * GetRandomReal(0.2, 0.5))
  end
  item.ui_x = x
  item.ui_y = y
  item.ui_background = extraph
  item.hasbeenget = false
  if currentOfferOwner then
    local offers = personalOffers[currentOfferOwner]
    offers[#offers + 1] = item
  else
    publicOffers[#publicOffers + 1] = item
  end
  return item
end

function openShopInterface()
  if shopInterfaceInitialized then
    return
  end
  shopInterfaceInitialized = true
  maodian = class.panel:builder({
    x = 0,
    y = 0,
    w = 1,
    h = 1,
    normal_image = "Touming.tga"
  })
  local ds = 1.5
  local shopPanel = class.panel:builder({
    parent = maodian,
    x = 20,
    y = 165,
    w = ds * 1382 * 0.88,
    h = ds * 575 * 0.68,
    normal_image = "UI_Shop_Back.tga"
  })
  shopPanel.bgm = true
  shopPanel:set_level(2)
  shopPanel:set_alpha(225)
  for slot = 1, PUBLIC_SLOT_COUNT do
    publicButtons[slot] = createShopSlotButton(shopPanel, "public", slot)
  end
  for slot = 1, PERSONAL_SLOT_COUNT do
    personalButtons[slot] = createShopSlotButton(shopPanel, "personal", slot)
  end
  UI_ShopBGM = class.button:builder({
    parent = shopPanel,
    x = 388,
    y = 522,
    w = 46.31578947368421,
    h = 35.78947368421053,
    normal_image = "UI_Shop_BGMSW.blp",
    on_button_mouse_enter = function(self)
      self:set_alpha(155)
      if shopPanel.bgm then
        uiy_show_text("背景音乐:开")
      else
        uiy_show_text("背景音乐:关")
      end
    end,
    on_button_mouse_leave = function(self)
      self:set_alpha(255)
      uiy_hide()
    end,
    on_button_clicked = function(self, p)
      if shopPanel.bgm then
        shopPanel.bgm = false
        StopSoundBJ(BGM_UI_Buy, true)
        uiy_show_text("背景音乐:关")
      else
        shopPanel.bgm = true
        PlayGlobalSound(BGM_UI_Buy)
        SetSoundVolume(BGM_UI_Buy, 97)
        uiy_show_text("背景音乐:开")
      end
      self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
      ac.wait(100, function()
        self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
      end)
    end
  })
  closeShopButton = class.button:builder({
    parent = shopPanel,
    x = 1700,
    y = 495,
    w = 73.33333333333334,
    h = 56.66666666666667,
    normal_image = "UI_Button_X.tga",
    on_button_mouse_enter = function(self)
      self:set_alpha(155)
      uiy_show_text("关闭|cFF6699FF天|r|cFF6688FF穹|r|cFF6677FF交|r|cFF6666FF易|r|cFF6655FF所|r", "Yuanzhu")
    end,
    on_button_mouse_leave = function(self)
      self:set_alpha(255)
      uiy_hide()
    end,
    on_button_clicked = function(self, p)
      StopSoundBJ(BGM_UI_Buy, true)
      maodian:hide()
      self:set_alpha(255)
      uiy_hide()
    end
  })
  class.text:builder({
    parent = shopPanel,
    x = 1099,
    y = 38,
    w = 1,
    h = 1,
    text = "|cFF6699FF天    |r|cFF6688FF穹    |r|cFF6677FF交    |r|cFF6666FF易    |r|cFF6655FF所|r",
    align = "center",
    font_size = 15
  })
  class.text:builder({
    parent = shopPanel,
    x = 785,
    y = 85,
    w = 1,
    h = 1,
    text = "|cFF99FFFF共  享  贸  易  库",
    align = "center",
    font_size = 11
  })
  class.text:builder({
    parent = shopPanel,
    x = 1395,
    y = 85,
    w = 1,
    h = 1,
    text = "|cFF99CCFF个  体  记  忆  源",
    align = "center",
    font_size = 11
  })
  do
    local ddd = 0.82
    class.panel:builder({
      parent = shopPanel,
      x = 155,
      y = 530,
      w = ddd * 283 * 0.88,
      h = ddd * 29 * 0.68,
      normal_image = "UI_Shop_Text.tga"
    })
  end
  maodian:hide()
  
  function tianqiongshangdianshuaxin()
    shopRefreshVersion = shopRefreshVersion + 1
    for _, button in ipairs(shopItems) do
      button.sync_data = shopRefreshVersion
      button.display_offer = nil
      button:hide()
    end
    publicOffers = {}
    personalOffers = {}
    currentOfferOwner = nil
    SendMsgAll("|cFF6699FF天穹交易所开始对接……(180秒后结束)|r")
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local tzz = xq:getdata("天穹交易所-投资值")
      if 0 < tzz then
        local fh = math.floor(tzz * 0.25)
        xq:sendmessage("|cFF7DBEF1你获得了|cFF1FBF00" .. fh .. "|cFF7DBEF1的分红(总投资额:|cFF1FBF00" .. tzz .. "|cFF7DBEF1)|r")
        xq:addgold(fh)
      end
    end)
    Tianqiongshengyushijian = 180
    ac.loop(1000, function(timer)
      Shouce_Shop.showtext = "|cFF6699FF天|r|cFF6688FF穹|r|cFF6677FF交|r|cFF6666FF易|r|cFF6655FF所|r\n|cFF6699FF积分交换物品\n下一波开始时或在" .. Tianqiongshengyushijian .. "秒后结束|r"
      Tianqiongshengyushijian = Tianqiongshengyushijian - 1
      if Tianqiongshengyushijian <= 0 then
        require("hera_gameplay_diagnostic").phase("SHOP_CLOSE_BEGIN", {})
        SendMsgAll("|cFF6699FF天穹交易所对接结束|r")
        Shouce_Shop:hide()
        maodian:hide()
        require("hera_gameplay_diagnostic").phase("SHOP_HIDE_BEGIN", {})
        uiy_hide()
        require("hera_gameplay_diagnostic").phase("SHOP_HIDE_END", {})
        require("hera_gameplay_diagnostic").phase("SHOP_SOUND_STOP_BEGIN", {})
        StopSoundBJ(BGM_UI_Buy, true)
        require("hera_gameplay_diagnostic").phase("SHOP_SOUND_STOP_END", {})
        require("hera_gameplay_diagnostic").phase("SHOP_CLOSE_END", {})
        timer:remove()
      end
    end)
    Shouce_ShopGantan:show()
    Shouce_Shop:show()
    local ax = 170
    local ay = 150
    local starty = 120
    do
      local dazhe = {}
      for i = 1, 9 do
        dazhe[i] = false
      end
      local dazhecount = 2
      local result = getRandomUniqueNumbers(dazhecount, 9)
      for _, v in ipairs(result) do
        dazhe[v] = true
      end
      for i = 1, 3 do
        local u = getunit(BOSS_DEATH)
        local pools = {
          Pools_SpeNormalWeapon,
          Pools_SpeGun
        }
        u:setdata("只返回值")
        local x, y = u:getxy()
        local data = herogetitem(u.handle, pools, x, y)
        local itemtype
        if data then
          itemtype = data.itemtype
        end
        u:deldata("只返回值")
        if not itemtype then
          break
        end
        local text = slk.item[itemtype].Name
        local text2 = slk.item[itemtype].Ubertip
        local dicon = slk.item[itemtype].Art or "war3mapImported\\Black.blp"
        if not dicon:match("%.tga$") and not dicon:match("%.blp$") then
          dicon = dicon .. ".tga"
        end
        text2 = text2:gsub(",DataA1.*", "")
        text2 = text2:gsub(",Dur1.*", "")
        local str = text .. "\n" .. text2
        local item
        item = {
          name = text,
          desc = text2,
          icon = dicon,
          price = 500 * i + GetRandomInt(-400, 400),
          func = function(item, u)
            local x, y = u:getxy()
            local wp = herogetitem(u.handle, pools, x, y, itemtype)
            u:addspeitem(wp)
          end,
          isdiscount = dazhe[i + 3]
        }
        registerShopOffer(item, 785 - ax - 60 + (i - 1) * ax, starty + ay * 1, "UI_Shop_BtnBack_Purple.blp")
      end
      local itemtype = "I087"
      for i = 1, 3 do
        local item
        item = {
          name = "传奇箱",
          desc = "打开后获得一件传说稀有度以上的遗物",
          icon = "ReplaceableTextures\\CommandButtons\\BTNMagicVault.blp",
          price = 500 + 250 * i + GetRandomInt(-375, 375),
          func = function(item, u)
            local x, y = u:getxy()
            local wp = CreateItemLua(itemtype, x, y)
            u:addspeitem(wp)
          end,
          isdiscount = dazhe[i + 6]
        }
        registerShopOffer(item, 785 - ax - 60 + (i - 1) * ax, starty + ay * 2, "UI_Shop_BtnBack_Brown.blp")
      end
    end
    ForGroupLuaNew(Group_AllHero, function(u)
      currentOfferOwner = u.ownerid
      personalOffers[currentOfferOwner] = {}
      local dazhe = {}
      for i = 1, 9 do
        dazhe[i] = false
      end
      local dazhecount = 2
      if u:hasdata("神器判定-微笑面具") then
        dazhecount = 6
      end
      local result = getRandomUniqueNumbers(dazhecount, 9)
      for _, v in ipairs(result) do
        dazhe[v] = true
      end
      do
        local pools = {
          Vars_Mwx
        }
        local poolsstr = "冥王星"
        local dvar = generateThreeRandomVars(u, pools, poolsstr)
        for i = 1, #dvar do
          local var = dvar[i]
          local rawtext = var.effecttext
          local wrapped = smartWrapText(rawtext, 385)
          local dicon = var.effectart or "war3mapImported\\Black.blp"
          if not dicon:match("%.tga$") and not dicon:match("%.blp$") then
            dicon = dicon .. ".tga"
          end
          local item
          item = {
            name = var.effectname,
            desc = wrapped,
            icon = dicon,
            price = 500 + 500 * i + GetRandomInt(-500, 500),
            func = function(item, u)
              u:setdata("伊丝-商店获取变异")
              local result = herogetvar(u.handle, pools, poolsstr, var.name)
              u:deldata("伊丝-商店获取变异")
              if result == "失败" then
                u:sendmessage("|cFFCC0000获取失败|r")
              end
            end,
            isdiscount = dazhe[i],
            buy_group = "天穹交易所-启动售卖-" .. u.ownerid
          }
          registerShopOffer(item, 785 - ax - 60 + (i - 1) * ax, starty, "UI_Shop_BtnBack_Green.blp")
        end
      end
      do
        local poolsstr = "次元"
        local memory_sources = {
          {
            name = "Lv1 个体记忆源",
            pools = {
              Vars_Ciyuan_Lv1
            },
            price = 500,
            fluctuation = 500
          },
          {
            name = "Lv2 个体记忆源",
            pools = {
              Vars_Ciyuan_Lv2
            },
            price = 1000,
            fluctuation = 750
          },
          {
            name = "Lv3 个体记忆源",
            pools = {
              Vars_Ciyuan_Lv3
            },
            price = 1500,
            fluctuation = 1000
          }
        }
        for i, source in ipairs(memory_sources) do
          local dvar = generateThreeRandomVars(u, source.pools, poolsstr, 1)
          local var = dvar[1]
          if not var then
            goto lbl_203
          end
          local rawtext = var.effecttext
          local wrapped = smartWrapText(rawtext, 385)
          local dicon = var.effectart or "war3mapImported\\Black.blp"
          if not dicon:match("%.tga$") and not dicon:match("%.blp$") then
            dicon = dicon .. ".tga"
          end
          local item
          item = {
            name = var.effectname,
            desc = wrapped,
            icon = dicon,
            price = source.price + GetRandomInt(-source.fluctuation, source.fluctuation),
            func = function(item, u)
              u:setdata("伊丝-商店获取变异")
              local result = herogetvar(u.handle, source.pools, poolsstr, var.name)
              u:deldata("伊丝-商店获取变异")
              if result == "失败" then
                u:sendmessage("|cFFCC0000获取失败|r")
              else
                u:changedata("传奇数量", 1)
              end
            end,
            isdiscount = dazhe[i]
          }
          registerShopOffer(item, 1395 - ax - 60 + (i - 1) * ax, starty, "UI_Shop_BtnBack_Red.blp")
        end
      end
      ::lbl_203::
      do
        local pools = {
          Guoboyiwu_Normal
        }
        local poolsstr = "普通过波遗物"
        local dvar = generateThreeRandomVars(u, pools, poolsstr, 2)
        for i = 1, #dvar do
          local var = dvar[i]
          local rawtext = var.effecttext
          local wrapped = smartWrapText(rawtext, 385)
          local dicon = var.effectart or "war3mapImported\\Black.blp"
          if not dicon:match("%.tga$") and not dicon:match("%.blp$") then
            dicon = dicon .. ".tga"
          end
          local item
          item = {
            name = var.effectname,
            desc = wrapped,
            icon = dicon,
            price = 600 + GetRandomInt(-400, 400),
            func = function(item, u)
              u:setdata("伊丝-商店获取变异")
              local result = herogetvar(u.handle, pools, poolsstr, var.name)
              u:deldata("伊丝-商店获取变异")
              if result == "失败" then
                u:sendmessage("|cFFCC0000获取失败|r")
              else
                yiwuhuoqu(u, var)
              end
            end,
            isdiscount = dazhe[i + 3]
          }
          registerShopOffer(item, 1395 - ax - 60 + (i - 1) * ax, starty + ay, "UI_Shop_BtnBack_Cyan.blp")
        end
      end
      do
        local pools = {
          Guoboyiwu_Rare,
          Guoboyiwu_SuperRare,
          Guoboyiwu_Spe
        }
        local poolsstr = "稀有过波遗物"
        local dvar = generateThreeRandomVars(u, pools, poolsstr, 1)
        for i = 1, #dvar do
          local var = dvar[i]
          local rawtext = var.effecttext
          local wrapped = smartWrapText(rawtext, 385)
          local dicon = var.effectart or "war3mapImported\\Black.blp"
          if not dicon:match("%.tga$") and not dicon:match("%.blp$") then
            dicon = dicon .. ".tga"
          end
          local item
          item = {
            name = var.effectname,
            desc = wrapped,
            icon = dicon,
            price = 900 + GetRandomInt(-800, 800),
            func = function(item, u)
              u:setdata("伊丝-商店获取变异")
              local result = herogetvar(u.handle, pools, poolsstr, var.name)
              u:deldata("伊丝-商店获取变异")
              if result == "失败" then
                u:sendmessage("|cFFCC0000获取失败|r")
              else
                yiwuhuoqu(u, var)
              end
            end,
            isdiscount = dazhe[i + 5]
          }
          registerShopOffer(item, 1395 - ax - 60 + 2 * ax, starty + ay, "UI_Shop_BtnBack_Cyan.blp")
        end
      end
      do
        local x, y = u:getxy()
        for i = 1, 3 do
          local pools = {
            Pools_Spe,
            Pools_SpeDzWeapon
          }
          u:setdata("只返回值")
          local data = herogetitem(u.handle, pools, x, y)
          local itemtype
          if data then
            itemtype = data.itemtype
          end
          u:deldata("只返回值")
          if not itemtype then
            break
          end
          local text = slk.item[itemtype].Name
          local text2 = slk.item[itemtype].Ubertip
          local dicon = slk.item[itemtype].Art or "war3mapImported\\Black.blp"
          if not dicon:match("%.tga$") and not dicon:match("%.blp$") then
            dicon = dicon .. ".tga"
          end
          text2 = text2:gsub(",DataA1.*", "")
          text2 = text2:gsub(",Dur1.*", "")
          local str = text .. "\n" .. text2
          local item
          item = {
            name = text,
            desc = text2,
            icon = dicon,
            price = 600 + GetRandomInt(-600, 600),
            func = function(item, u)
              local x, y = u:getxy()
              local wp = herogetitem(u.handle, pools, x, y, itemtype)
              u:addspeitem(wp)
            end,
            isdiscount = dazhe[i + 6]
          }
          registerShopOffer(item, 1395 - ax - 60 + (i - 1) * ax, starty + ay * 2, "UI_Shop_BtnBack_Yellow.blp")
        end
      end
    end)
    currentOfferOwner = nil
    renderShopOffers()
  end
  
  local ddx = 1350
  local ddy = 690
  if EnableCustomUI then
    ddx = 1270
    ddy = 760
  end
  local b2 = false
  Shouce_Shop = class.button:builder({
    x = ddx,
    y = ddy,
    w = 105.6,
    h = 81.6,
    showtext = "|cFF6699FF天|r|cFF6688FF穹|r|cFF6677FF交|r|cFF6666FF易|r|cFF6655FF所|r\n|cFF6699FF积分交换物品\n下一波开始时或在480秒后结束|r",
    normal_image = "UI_YisiShop.blp",
    sync_key = "GBOptionBook",
    on_button_clicked = function(self)
      self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
      ac.wait(100, function()
        self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
      end)
      Shouce_ShopGantan:hide()
      self:set_alpha(255)
      if maodian then
        if maodian:get_is_show() then
          maodian:hide()
          StopSoundBJ(BGM_UI_Buy, true)
        else
          maodian:show()
          if shopPanel.bgm then
            PlayGlobalSound(BGM_UI_Buy)
            SetSoundVolume(BGM_UI_Buy, 97)
          end
        end
      end
    end,
    on_button_mouse_enter = function(self)
      self:set_alpha(155)
      if self.showtext then
        uiy_show_text(self.showtext, "Skill")
      end
    end,
    on_button_mouse_leave = function(self)
      self:set_alpha(255)
      if self.showtext then
        uiy_hide()
      end
    end,
    on_button_update_drag = function(self, icon, x, y)
      self:set_alpha(0)
      self:set_position(x, y)
    end,
    on_button_right_clicked = function(self)
      if not b2 then
        b2 = true
        self:set_enable_drag(true)
      else
        b2 = false
        self:set_enable_drag(false)
      end
    end
  })
  Shouce_Shop:hide()
  Shouce_ShopGantan = class.texture:builder({
    parent = Shouce_Shop,
    x = 40,
    y = -10,
    w = 25,
    h = 25,
    normal_image = "UI_Chat_ICONGANTAN.tga"
  })
  Shouce_ShopGantan:hide()
end

function tianqiongshijian()
  ForGroupLuaNew(Group_PlayHero, function(xq)
    local u = xq
    local tzsz
    if u:getgold() >= 100 then
      tzsz = GetRandomInt(100, u:getgold())
    else
      tzsz = u:getgold()
    end
  end)
end
