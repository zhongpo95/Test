-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local SHADOW_STAGE_TICK = 1000
local SHADOW_POWER_INTERVAL = 60000
local ciyuanget = rawget(_G, "ciyuanget")
local Vars_Huiyi_Dz = rawget(_G, "Vars_Huiyi_Dz")
local SEVEN_SHADOW_NAMES = {
  "阿尔法",
  "贝塔",
  "伽马",
  "德尔塔",
  "艾普西隆",
  "泽塔",
  "伊塔"
}
local SEVEN_SHADOW_ADVANCE_ICONS = {
  ["阿尔法"] = "Anying_Cq_AerfaJinjie.tga",
  ["贝塔"] = "Anying_Cq_BeitaJinjie.tga",
  ["伽马"] = "Anying_Cq_GamaJinjie.tga",
  ["德尔塔"] = "Anying_Cq_DeertaJinjie.tga",
  ["艾普西隆"] = "Anying_Cq_AipuxilongJinjie.tga",
  ["泽塔"] = "Anying_Cq_ZetaJinjie.tga",
  ["伊塔"] = "Anying_Cq_YitaJinjie.tga"
}
local install_seven_shadow_stage, refresh_shadow_pair_unlocks

function GetShadowEffectScale(u)
  if u:hasdata("暗影-世界最强") then
    return 1.5
  end
  return 1
end

local function shadow_refresh(u, key, calc, apply, interval)
  local marker = "暗影-动态刷新-" .. key
  if u:hasdata(marker) then
    return
  end
  u:setdata(marker)
  local old = 0
  
  local function refresh()
    apply(-old)
    old = calc()
    apply(old)
  end
  
  refresh()
  ac.loop(interval or SHADOW_STAGE_TICK, refresh)
end

local function shadow_refresh_data(u, key, calc, interval, target_key)
  shadow_refresh(u, "数据-" .. key, calc, function(add)
    u:changedata(target_key or key, add)
  end, interval)
end

local function shadow_refresh_multiplier(u, key, values, sy, calc, interval)
  local marker = "暗影-动态刷新-" .. key
  if u:hasdata(marker) then
    return
  end
  u:setdata(marker)
  local old = 1
  
  local function refresh()
    ChangeValue(values, sy, old, 2)
    old = calc()
    ChangeValue(values, sy, old, 1)
  end
  
  refresh()
  ac.loop(interval or SHADOW_STAGE_TICK, refresh)
end

local function shadow_damage(u, tg, damage, bj, damage_type, extradata)
  if not (tg and tg ~= 0 and tg:isalive()) or damage <= 0 then
    return
  end
  DamageUnit({
    bj = bj,
    unit = tg.handle,
    source = u.handle,
    damage = damage,
    level = 1,
    type = damage_type or "魔力",
    isvest = true,
    isattack = false,
    isnoarmor = extradata ~= nil,
    element = "无",
    extradata = extradata
  })
end

local function shadow_true_damage(u, tg, damage, bj)
  shadow_damage(u, tg, damage, bj, "物理", {
    "系统-本次伤害无视伤害抗性",
    "系统-本次伤害无视伤害免疫"
  })
end

local function shadow_stage_condition(u, count, magic)
  return count <= u:getdata("暗影计数") and magic <= u:getdata("魔力值")
end

local function update_shadow_ui(u, clickfunc, isclearclick, icon, smallicon, ishasphoto)
  u:uivar_change({
    keyname = "暗影大人",
    keytype = "传奇栏",
    size_h = 1,
    dx = 3,
    icon = icon,
    smallicon = smallicon,
    ishasphoto = ishasphoto,
    clickfunc = clickfunc,
    isclearclick = isclearclick
  })
end

local function unlock_shadow_world_strongest(u)
  if u:hasdata("暗影-世界最强") then
    return
  end
  u:setdata("暗影-世界最强")
  local sy = u.ownerid
  ChangeValue(DamageSystem_Shjc, sy, 1)
  u:changedata("全属性增幅", 0.25)
  u:sendmessage("|cFF6633FF[世界最强]七影效果提升|r")
end

local function install_aurora_chain(u)
  if u:hasdata("奥萝拉-封印之链") then
    return
  end
  u:setdata("奥萝拉-封印之链")
  ac.loop(1000, function()
    local x, y = u:getxy()
    for _, target in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
      local tg = getunit(target)
      shadow_damage(u, tg, u:getdata("魔力值") * 66, "奥萝拉-封印之链")
    end
    if u:getlevel() >= 75 and not u:hasdata("奥萝拉-75级暗影计数") then
      u:setdata("奥萝拉-75级暗影计数")
      u:changedata("暗影计数", 2)
    end
  end)
end

local function install_elisabeth_bloody_queen(u)
  if u:hasdata("伊丽莎白-血腥女王") then
    return
  end
  u:setdata("伊丽莎白-血腥女王")
  u:addstexiao("暗影伊丽莎白-血腥女王伤害", "直接伤害变更", function(args)
    if args.tg:isboss() then
      args.damageinfo.damage = args.damageinfo.damage * (1 + u:getdata("暗影计数") * 0.02)
    end
  end)
  u:addstexiao("暗影伊丽莎白-血腥女王击杀", "杀敌效果", function(args)
    if args.mon:isboss() then
      u:changedata("暗影计数", 1)
    end
  end)
end

function refresh_shadow_pair_unlocks(u)
  if not u:hasdata("变异判定-灾厄魔女 奥萝拉") or not u:hasdata("变异判定-噬血女王 伊丽莎白") then
    return
  end
  install_aurora_chain(u)
  install_elisabeth_bloody_queen(u)
  if u:hasdata("暗影-史莱姆剑神化") then
    unlock_shadow_world_strongest(u)
  end
end

local function apply_shadow_first_stage(u)
  local sy = u.ownerid
  shadow_refresh(u, "希德一阶-伤害加成", function()
    return u:getdata("暗影计数") * 0.015 + u:getlevel() * 0.02
  end, function(add)
    ChangeValue(DamageSystem_Shjc, sy, add)
  end)
  shadow_refresh(u, "希德一阶-智力", function()
    return u:getdata("魔力值") * 1.0E-4
  end, function(add)
    u:addint(add)
  end)
  u:setdata("系统-无视伤害免疫")
  update_shadow_ui(u, nil, nil, "Anying_Cq_Lv2_Big.tga", "Anying_Cq_Lv2.tga", true)
  PlayGlobalSound(Sound_Ay_Anying02)
  NPCChat({
    name = "|cFF9932CC希德·卡盖诺|r",
    chaticon = "Chat_Ay_Anying.tga",
    chattext = {
      {
        time = 0,
        text = "|cFF801111还|r|cFF7C0F1C远|r|cFF770E27远|r|cFF720C32称|r|cFF6E0A3D不|r|cFF6A0948上|r|cFF650754最|r|cFF60055F强|r|cFF5C036A呢|r"
      },
      {
        time = 14,
        text = "|cFF801111最|r|cFF7D1018强|r|cFF7A0F20的|r|cFF770E27馈|r|cFF740C2F赠|r|cFF710B36还|r|cFF6E0A3D在|r|cFF6B0945远|r|cFF68084C方|r|cFF650754这|r|cFF62065B才|r|cFF5F0562刚|r|cFF5C036A开|r|cFF590271始|r"
      },
      {
        time = 18,
        text = "|cFF801111同|r|cFF710B36样|r"
      },
      {
        time = 20,
        text = "|cFF801111吾|r|cFF7D101A名|r|cFF790E22S|r|cFF760D2Bh|r|cFF720C33a|r|cFF6F0A3Cd|r|cFF6B0944o|r|cFF68084Dw|r|cFF640755现|r|cFF61055E在|r|cFF5D0466开|r|cFF5A036F始|r"
      },
      {
        time = 25,
        text = "|cFF801111让|r|cFF780E24我|r|cFF710B36试|r|cFF6A0848试|r|cFF62065B吧|r"
      },
      {
        time = 37,
        text = "|cFF801111游|r|cFF7C0F1B戏|r|cFF780E25结|r|cFF740C2F束|r|cFF700B39了|r|cFF6C0943从|r|cFF67084E现|r|cFF630658在|r|cFF5F0562开|r|cFF5B036C始|r"
      },
      {
        time = 41,
        text = "|cFF801111踏|r|cFF7B0F1D上|r|cFF760D2A真|r|cFF710B36正|r|cFF6C0942最|r|cFF67084F强|r|cFF62065B之|r|cFF5D0467路|r"
      },
      {
        time = 45,
        text = "|cFF801111A|r|cFF7D1018r|r|cFF7B0F1Ec|r|cFF780E25h|r|cFF750D2Be|r|cFF730C32t|r|cFF700B38y|r|cFF6D0A3Fp|r|cFF6B0945e|r|cFF68084C |r|cFF660752A|r|cFF630659t|r|cFF60055Fo|r|cFF5E0466m|r|cFF5B036Ci|r|cFF580273c|r"
      }
    }
  })
  ac.wait(45000, function()
    flashphoto({
      photo = "Ph_Anying_02.tga",
      timeout = 1,
      timehold = 3,
      timein = 2
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 7, "绝对闪避")
    end)
  end)
end

local function apply_shadow_divine_stage(u)
  local sy = u.ownerid
  shadow_refresh(u, "希德神化-暴击伤害", function()
    return u:getallattri() * 5.0E-4
  end, function(add)
    ChangeValue(DamageSystem_Baoshang, sy, add)
  end)
  shadow_refresh(u, "希德神化-暴击率", function()
    return u:getdata("暗影计数") * 8
  end, function(add)
    ChangeValue(DamageSystem_Baoji, sy, add)
  end)
  AddUISkill({
    text = "I Am Atomic",
    u = u,
    cd = 420,
    icon = "Anying_Cq_Lv3.tga",
    showtext = "|cffa98ef8I Am Atomic\n冷却420秒|r",
    func = function(args)
      if not u:isalive() then
        u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
        args.button._cd = 3
        args.button._max_cd = 3
        return
      end
      args.button._cd = 420
      args.button._max_cd = 420
      MovieAct.Atomic(u)
    end
  })
  refresh_shadow_pair_unlocks(u)
  update_shadow_ui(u, nil, nil, "Anying_Cq_Lv3_Big.tga", "Anying_Cq_Lv3.tga", true)
  PlayGlobalSound(Sound_Ay_Anying03)
  NPCChat({
    name = "|cFFA00E26「|r|cFF9E0E2FS|r|cFF9B0D38h|r|cFF990D40a|r|cFF970D49d|r|cFF950C52o|r|cFF920C5Bw|r|cFF900C64」|r|cFF8E0B6D希|r|cFF8C0B75德|r|cFF890B7E·|r|cFF870A87卡|r|cFF850A90盖|r|cFF820A99诺|r",
    chaticon = "Chat_Ay_Anying.tga",
    chattext = {
      {
        time = 46,
        text = "|cFF7E09AA好|r|cFF7C09B3的|r"
      },
      {
        time = 47,
        text = "|cFF8D0B6E我|r|cFF8C0B73也|r|cFF8B0B78不|r|cFF8A0B7D知|r|cFF880B82道|r|cFF870A86有|r|cFF860A8B什|r|cFF850A90么|r|cFF830A95好|r|cFF820A9A，|r|cFF81099E不|r|cFF8009A3过|r|cFF7E09A8应|r|cFF7D09AD该|r|cFF7C09B2是|r|cFF7B09B7好|r|cFF7908BB的|r"
      },
      {
        time = 51,
        text = "|cFF8D0B71好|r|cFF8C0B76不|r|cFF8A0B7A容|r|cFF890B7F易|r|cFF880A84转|r|cFF860A89生|r|cFF850A8E，|r|cFF840A93好|r|cFF830A98不|r|cFF810A9D容|r|cFF8009A2易|r|cFF7F09A7来|r|cFF7D09AC到|r|cFF7C09B1异|r|cFF7B09B6世|r|cFF7A08BB界|r"
      },
      {
        time = 54,
        text = "|cFF8B0B78还|r|cFF890B7E有|r|cFF880A83好|r|cFF870A89不|r|cFF850A8E容|r|cFF840A94易|r|cFF820A99得|r|cFF81099F来|r|cFF7F09A4的|r|cFF7E09AA·|r|cFF7D09AF·|r|cFF7B09B5·|r|cFF7A08BA·|r"
      },
      {
        time = 57,
        text = "|cFF8F0C66I|r|cFF8E0B6B |r|cFF8D0B6Fn|r|cFF8C0B73e|r|cFF8B0B78e|r|cFF8A0B7Cd|r|cFF890B80 |r|cFF880A85m|r|cFF870A89o|r|cFF850A8Dr|r|cFF840A91.|r|cFF830A96.|r|cFF820A9A.|r|cFF81099Ep|r|cFF8009A3o|r|cFF7F09A7w|r|cFF7E09ABe|r|cFF7D09B0r|r|cFF7B09B4.|r|cFF7A08B8.|r|cFF7908BC.|r"
      },
      {
        time = 65,
        text = "|cFF8F0C68魔|r|cFF8E0B6D力|r|cFF8D0B71，|r|cFF8C0B76我|r|cFF8A0B7A要|r|cFF890B7E与|r|cFF880B83这|r|cFF870A87终|r|cFF860A8C于|r|cFF850A90入|r|cFF840A94手|r|cFF820A99的|r|cFF810A9D新|r|cFF8009A2力|r|cFF7F09A6量|r|cFF7E09AA一|r|cFF7D09AF起|r|cFF7C09B3·|r|cFF7A09B8·|r|cFF7908BC·|r"
      },
      {
        time = 70,
        text = "|cFF860A89我|r|cFF850A90等|r|cFF830A97目|r|cFF810A9D标|r|cFF8009A4仅|r|cFF7E09AA有|r|cFF7C09B1一|r|cFF7A08B8个|r"
      },
      {
        time = 74,
        text = "|cFF8009A4出|r|cFF7D09AC发|r|cFF7B09B4吧|r"
      },
      {
        time = 87,
        text = "|cFF860A89这|r|cFF850A90次|r|cFF830A97我|r|cFF810A9D一|r|cFF8009A4定|r|cFF7E09AA要|r|cFF7C09B1实|r|cFF7A08B8现|r"
      },
      {
        time = 89,
        text = "|cFF870A85为|r|cFF860A8C此|r|cFF840A92我|r|cFF820A98愿|r|cFF81099F意|r|cFF7F09A5舍|r|cFF7E09AC弃|r|cFF7C09B2一|r|cFF7A08B8切|r"
      },
      {
        time = 93,
        text = "|cFF8E0B6A不|r|cFF8D0B6F，|r|cFF8C0B73我|r|cFF8B0B78会|r|cFF8A0B7C舍|r|cFF890B81弃|r|cFF870A85一|r|cFF860A8A切|r|cFF850A8E，|r|cFF840A93只|r|cFF830A98要|r|cFF820A9C能|r|cFF8009A1够|r|cFF7F09A5达|r|cFF7E09AA成|r|cFF7D09AE这|r|cFF7C09B3个|r|cFF7B09B7目|r|cFF7908BC标|r"
      },
      {
        time = 97,
        text = "|cFF8B0B75因|r|cFF8A0B7B为|r|cFF890B80即|r|cFF870A85便|r|cFF860A8B如|r|cFF850A90此|r|cFF830A95，|r|cFF820A9B我|r|cFF8109A0也|r|cFF7F09A5想|r|cFF7E09AB成|r|cFF7C09B0为|r|cFF7B09B5那|r|cFF7A08BA样|r"
      },
      {
        time = 100,
        text = "|cFF840A92既|r|cFF820A9A不|r|cFF8009A1是|r|cFF7E09A8主|r|cFF7D09AF人|r|cFF7B09B7公|r"
      },
      {
        time = 102,
        text = "|cFF870A85也|r|cFF860A8C不|r|cFF840A92是|r|cFF820A98最|r|cFF81099F终|r|cFF7F09A5B|r|cFF7E09ACO|r|cFF7C09B2S|r|cFF7A08B8S|r"
      },
      {
        time = 105,
        text = "|cFF900C65而|r|cFF8F0B69是|r|cFF8E0B6D从|r|cFF8D0B71故|r|cFF8C0B76事|r|cFF8A0B7A的|r|cFF890B7E幕|r|cFF880B82后|r|cFF870A86介|r|cFF860A8A入|r|cFF850A8F事|r|cFF840A93件|r|cFF830A97，|r|cFF820A9B并|r|cFF81099F展|r|cFF8009A4现|r|cFF7F09A8其|r|cFF7D09AC实|r|cFF7C09B0力|r|cFF7B09B4的|r|cFF7A08B8存|r|cFF7908BD在|r"
      },
      {
        time = 117,
        text = "|cFF870A85这|r|cFF860A8C样|r|cFF840A92的|r|cFF820A98影|r|cFF81099F之|r|cFF7F09A5实|r|cFF7E09AC力|r|cFF7C09B2者|r|cFF7A08B8！|r"
      }
    }
  })
  NPCChat({
    name = "|cFFC729B2「|r|cFFB124A5七|r|cFF9B2098影|r|cFF841B8A」|r|cFFFFFF00“一”阿尔法",
    chaticon = "Chat_Qiying.tga",
    chattext = {
      {
        time = 12,
        text = "|cFFFFFF00不必担心|r"
      },
      {
        time = 16,
        text = "|cFFFFFF00包围已经完成了|r"
      },
      {
        time = 19,
        text = "|cFFFFFF00那些家伙无路可逃|r"
      }
    }
  })
  NPCChat({
    name = "|cFFC729B2「|r|cFFB124A5七|r|cFF9B2098影|r|cFF841B8A」|r|cFF0000CC“三”伽玛",
    chaticon = "Chat_Qiying.tga",
    chattext = {
      {
        time = 22,
        text = "|cFF0000CC一切如主人所料|r"
      }
    }
  })
  NPCChat({
    name = "|cFFC729B2「|r|cFFB124A5七|r|cFF9B2098影|r|cFF841B8A」|r|cFF999999“二”贝塔|r",
    chaticon = "Chat_Qiying.tga",
    chattext = {
      {
        time = 25,
        text = "|cFF999999对您的深谋远虑，我只能叹为观止|r"
      }
    }
  })
  NPCChat({
    name = "|cFFC729B2「|r|cFFB124A5七|r|cFF9B2098影|r|cFF841B8A」|r|cFF333333“四”德尔塔|r",
    chaticon = "Chat_Qiying.tga",
    chattext = {
      {
        time = 30,
        text = "|cFF333333久违的大规模狩猎，我都等不及了|r"
      }
    }
  })
  NPCChat({
    name = "|cFFC729B2「|r|cFFB124A5七|r|cFF9B2098影|r|cFF841B8A」|r|cFFF5DEB3“六”泽塔|r",
    chaticon = "Chat_Qiying.tga",
    chattext = {
      {
        time = 33,
        text = "|cFFF5DEB3我不会手下留情的|r"
      }
    }
  })
  NPCChat({
    name = "|cFFC729B2「|r|cFFB124A5七|r|cFF9B2098影|r|cFF841B8A」|r|cFF530080“七”伊塔|r",
    chaticon = "Chat_Qiying.tga",
    chattext = {
      {
        time = 35,
        text = "|cFF530080嗯|r"
      }
    }
  })
  NPCChat({
    name = "|cFFC729B2「|r|cFFB124A5七|r|cFF9B2098影|r|cFF841B8A」|r|cFF33CCFF“五”艾普西隆|r",
    chaticon = "Chat_Qiying.tga",
    chattext = {
      {
        time = 38,
        text = "|cFF33CCFF大家，都在盼着主人的号令|r"
      }
    }
  })
  ac.wait(117000, function()
    flashphoto({
      photo = "Ph_Anying_03.tga",
      timeout = 1,
      timehold = 3,
      timein = 2
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 7, "绝对闪避")
    end)
  end)
  ac.wait(120000, function()
    PlayBGM({
      bgm = BGM_Ay_11,
      time = 215,
      ID = 252,
      unit = u.handle
    })
  end)
end

local function apply_forbidden_shadow(u)
  if u:hasdata("暗影-禁忌希德") then
    return
  end
  if u:getdata("魔力值") < 5000 or (Time_M or 0) < 15 then
    u:sendmessage("|cff701ac0条件未满足|r")
    return
  end
  u:setdata("暗影-禁忌希德")
  u:changedata("暗影计数", math.floor(u:getdata("系统-累积等级") / 15 + (PlayerCount or 0)))
  local sy = u.ownerid
  shadow_refresh(u, "禁忌希德-终结伤害", function()
    return u:getdata("暗影计数") * 0.01 + u:getlevel() * 0.005
  end, function(add)
    ChangeValue(DamageSystem_EndSh, sy, add)
  end)
  shadow_refresh_data(u, "影变异补正", function()
    return u:getlevel() * 0.25 + u:getdata("暗影计数")
  end)
  u:addstexiao("禁忌希德-免疫眩晕", "被施加Buff时效果-眩晕", function(args)
    args.time = 0
  end)
  u:addstexiao("禁忌希德-免疫混乱", "被施加Buff时效果-混乱", function(args)
    args.time = 0
  end)
  u:setdata("免疫混乱改变所属")
  u:addstexiao("禁忌希德-击杀成长", "杀敌效果", function()
    if u:getluckrandom(10) then
      u:addallstats(3)
    end
  end)
  update_shadow_ui(u, nil, true, "Anying_Cq_Jinji_Big.tga", "Anying_Cq_Jinji.tga", true)
  PlayGlobalSound(Sound_Ay_Anying04)
  NPCChat({
    name = "|cFF9932CC希德·卡盖诺|r",
    chaticon = "Chat_Ay_Anying.tga",
    chattext = {
      {
        time = 0.5,
        text = "|cFF9400D3从|r|cFF7E00B7前|r"
      },
      {
        time = 2.4,
        text = "|cFF9400D3神|r|cFF8F00CC明|r|cFF8900C5为|r|cFF8400BE了|r|cFF7E00B7告|r|cFF7900B0诉|r|cFF7400AA地|r|cFF6E00A3上|r|cFF69009C的|r|cFF630095人|r|cFF5E008E类|r"
      },
      {
        time = 5.6,
        text = "|cFF9400D3从|r|cFF8E00CB天|r|cFF8800C4空|r|cFF8200BC降|r|cFF7C00B5下|r|cFF7600AD了|r|cFF7100A6数|r|cFF6B009E道|r|cFF650097落|r|cFF5F008F雷|r"
      },
      {
        time = 8.8,
        text = "|cFF9400D3然|r|cFF9000CE而|r|cFF8D00CA人|r|cFF8900C5类|r|cFF8600C1却|r|cFF8200BC迷|r|cFF7E00B7恋|r|cFF7B00B3那|r|cFF7700AE股|r|cFF7300A9从|r|cFF7000A5天|r|cFF6C00A0空|r|cFF69009C降|r|cFF650097下|r|cFF610092的|r|cFF5E008E力|r|cFF5A0089量|r"
      },
      {
        time = 11.9,
        text = "|cFF9400D3並|r|cFF8B00C7渴|r|cFF8100BB望|r|cFF7800AF拥|r|cFF6F00A4有|r|cFF660098它|r"
      },
      {
        time = 13.8,
        text = "|cFF9400D3觉|r|cFF8F00CD得|r|cFF8A00C6自|r|cFF8500C0己|r|cFF8000B9必|r|cFF7B00B3须|r|cFF7600AD拥|r|cFF7100A6有|r|cFF6C00A0这|r|cFF67009A股|r|cFF620093力|r|cFF5D008D量|r"
      },
      {
        time = 16,
        text = "|cFF9400D3认|r|cFF9000CE为|r|cFF8C00C9自|r|cFF8800C3己|r|cFF8400BE一|r|cFF8000B9定|r|cFF7C00B4要|r|cFF7800AF得|r|cFF7400AA到|r|cFF6F00A4那|r|cFF6B009F股|r|cFF67009A力|r|cFF630095量|r|cFF5F0090不|r|cFF5B008A可|r"
      },
      {
        time = 18.5,
        text = "|cFF9400D3然|r|cFF8E00CB后|r|cFF8700C2，|r|cFF8000BA经|r|cFF7A00B2过|r|cFF7400A9多|r|cFF6D00A1年|r|cFF660099研|r|cFF600091究|r"
      },
      {
        time = 20,
        text = "|cFF9400D3人|r|cFF8F00CD类|r|cFF8A00C6终|r|cFF8500C0于|r|cFF8000B9将|r|cFF7B00B3那|r|cFF7600AD股|r|cFF7100A6力|r|cFF6C00A0量|r|cFF67009A得|r|cFF620093到|r|cFF5D008D手|r"
      },
      {
        time = 23.5,
        text = "|cFF9400D3换|r|cFF8700C2而|r|cFF7A00B2言|r|cFF6D00A1之|r"
      },
      {
        time = 24.3,
        text = "|cFF9400D3就|r|cFF9100CF是|r|cFF8E00CB构|r|cFF8B00C7成|r|cFF8800C3原|r|cFF8500BF子|r|cFF8100BB核|r|cFF7E00B7的|r|cFF7B00B3陽|r|cFF7800AF子|r|cFF7500AB与|r|cFF7200A8中|r|cFF6F00A4性|r|cFF6C00A0子|r|cFF69009C之|r|cFF660098间|r|cFF620094的|r|cFF5F0090核|r|cFF5C008C能|r|cFF590088量|r"
      },
      {
        time = 28,
        text = "|cFF9400D3产|r|cFF8B00C7生|r|cFF8100BB了|r|cFF7800AF核|r|cFF6F00A4分|r|cFF660098裂|r"
      },
      {
        time = 30,
        text = "|cFF9400D3到|r|cFF8E00CB达|r|cFF8800C4临|r|cFF8200BC界|r|cFF7C00B5.|r|cFF7600AD.|r|cFF7100A6.|r|cFF6B009E之|r|cFF650097类|r|cFF5F008F的|r"
      },
      {
        time = 32.2,
        text = "|cFF9400D3什|r|cFF9000CE么|r|cFF8D00CA指|r|cFF8900C5数|r|cFF8600C1函|r|cFF8200BC数|r|cFF7E00B7的|r|cFF7B00B3.|r|cFF7700AE.|r|cFF7300A9.|r|cFF7000A5.|r|cFF6C00A0因|r|cFF69009C为|r|cFF650097某|r|cFF610092些|r|cFF5E008E原|r|cFF5A0089因|r"
      },
      {
        time = 34.7,
        text = "|cFF9400D3在|r|cFF8F00CD连|r|cFF8B00C7锁|r|cFF8600C1反|r|cFF8100BB应|r|cFF7D00B5下|r|cFF7800AF发|r|cFF7400AA生|r|cFF6F00A4了|r|cFF6A009E各|r|cFF660098种|r|cFF610092事|r|cFF5C008C情|r"
      },
      {
        time = 36.5,
        text = "|cFF9400D3总|r|cFF9100CF之|r|cFF8E00CB就|r|cFF8B00C8是|r|cFF8800C4以|r|cFF8500C0一|r|cFF8200BC股|r|cFF7F00B9超|r|cFF7C00B5强|r|cFF7900B1的|r|cFF7600AD能|r|cFF7300A9力|r|cFF7100A6引|r|cFF6E00A2起|r|cFF6B009E了|r|cFF68009A爆|r|cFF650097炸|r|cFF620093性|r|cFF5F008F的|r|cFF5C008B破|r|cFF590088坏|r"
      },
      {
        time = 39.6,
        text = "|cFF9400D3算|r|cFF9000CD了|r|cFF8B00C8，|r|cFF8700C2原|r|cFF8300BD理|r|cFF7E00B7什|r|cFF7A00B2么|r|cFF7600AC的|r|cFF7100A7怎|r|cFF6D00A1么|r|cFF69009C样|r|cFF640096都|r|cFF600091好|r|cFF5C008B啦|r"
      },
      {
        time = 42.3,
        text = "|cFF9400D3天|r|cFF8700C2的|r|cFF7A00B2彼|r|cFF6D00A1方|r"
      },
      {
        time = 44.2,
        text = "|cFF9400D3从|r|cFF9000CE那|r|cFF8C00C9寂|r|cFF8900C4静|r|cFF8500BF的|r|cFF8100BB世|r|cFF7D00B6界|r|cFF7900B1降|r|cFF7500AC下|r|cFF7200A7的|r|cFF6E00A2究|r|cFF6A009D极|r|cFF660098破|r|cFF620094坏|r|cFF5E008F之|r|cFF5B008A力|r"
      },
      {
        time = 48,
        text = "|cFF9400D3那|r|cFF8E00CB是|r|cFF8800C4我|r|cFF8200BC必|r|cFF7C00B5须|r|cFF7600AD超|r|cFF7100A6越|r|cFF6B009E的|r|cFF650097东|r|cFF5F008F西|r"
      },
      {
        time = 51,
        text = "|cFF9400D3看|r|cFF8B00C7着|r|cFF8100BB这|r|cFF7800AF个|r|cFF6F00A4地|r|cFF660098方|r"
      },
      {
        time = 52.5,
        text = "|cFF9400D3透|r|cFF8B00C7过|r|cFF8100BB亲|r|cFF7800AF身|r|cFF6F00A4感|r|cFF660098受|r"
      },
      {
        time = 53.5,
        text = "|cFF9400D3让|r|cFF9000CD我|r|cFF8B00C8再|r|cFF8700C2次|r|cFF8300BD意|r|cFF7E00B7识|r|cFF7A00B2到|r|cFF7600AC自|r|cFF7100A7己|r|cFF6D00A1应|r|cFF69009C该|r|cFF640096做|r|cFF600091的|r|cFF5C008B事|r"
      },
      {
        time = 58.6,
        text = "|cFF9400D3这|r|cFF8F00CC就|r|cFF8900C5是|r|cFF8400BE所|r|cFF7E00B7谓|r|cFF7900B0的|r|cFF7400AA回|r|cFF6E00A3归|r|cFF69009C初|r|cFF630095心|r|cFF5E008E吗|r"
      },
      {
        time = 61.6,
        text = "|cFF9400D3这|r|cFF8C00C9都|r|cFF8400BE是|r|cFF7C00B4多|r|cFF7400AA亏|r|cFF6B009F了|r|cFF630095你|r"
      },
      {
        time = 63.5,
        text = "|cFF9400D3谢|r|cFF8400BE谢|r|cFF7400AA你|r"
      },
      {
        time = 65,
        text = "|cFF9400D3所|r|cFF8B00C7以|r|cFF8100BB这|r|cFF7800AF场|r|cFF6F00A4游|r|cFF660098戏|r"
      },
      {
        time = 66.7,
        text = "|cFF9400D3现|r|cFF8C00C9在|r|cFF8400BE也|r|cFF7C00B4该|r|cFF7400AA结|r|cFF6B009F算|r|cFF630095了|r"
      },
      {
        time = 68.8,
        text = "|cFF9400D3我|r|cFF8E00CB打|r|cFF8800C4算|r|cFF8200BC努|r|cFF7C00B5力|r|cFF7600AD地|r|cFF7100A6表|r|cFF6B009E现|r|cFF650097一|r|cFF5F008F下|r"
      },
      {
        time = 70.9,
        text = "|cFF9400D3还|r|cFF8F00CC请|r|cFF8900C5你|r|cFF8400BE务|r|cFF7E00B7必|r|cFF7900B0收|r|cFF7400AA下|r|cFF6E00A3我|r|cFF69009C的|r|cFF630095心|r|cFF5E008E意|r"
      },
      {
        time = 77.5,
        text = "|cFF9400D3I|r|cFF8F00CC |r|cFF8900C5A|r|cFF8400BEM|r|cFF7E00B7 |r|cFF7900B0A|r|cFF7400AAt|r|cFF6E00A3o|r|cFF69009Cm|r|cFF630095i|r|cFF5E008Ec|r"
      }
    }
  })
  ac.wait(79000, function()
    PlayBGM({
      bgm = BGM_Ay_11,
      time = 215,
      ID = 252,
      unit = u.handle
    })
  end)
end

local function start_shadow_progression(u)
  if u:hasdata("暗影-自动进阶运行中") then
    return
  end
  u:setdata("暗影-自动进阶运行中")
  ac.loop(SHADOW_STAGE_TICK, function()
    if not u:hasdata("暗影-七影一阶") and shadow_stage_condition(u, 2, 500) then
      u:setdata("暗影-七影一阶")
      for _, name in ipairs(SEVEN_SHADOW_NAMES) do
        if u:hasdata("变异判定-" .. name) then
          install_seven_shadow_stage(u, name, 1)
        end
      end
      u:sendmessage("|cFF6633FF[暗影庭院]七影进阶|r")
    end
    if not u:hasdata("暗影-七影二阶") and shadow_stage_condition(u, 7, 1000) then
      u:setdata("暗影-七影二阶")
      for _, name in ipairs(SEVEN_SHADOW_NAMES) do
        if u:hasdata("变异判定-" .. name) then
          install_seven_shadow_stage(u, name, 2)
        end
      end
      u:sendmessage("|cFF6633FF[暗影庭院]七影进阶|r")
    end
    if not u:hasdata("暗影-史莱姆剑一阶") and shadow_stage_condition(u, 2, 600) then
      u:setdata("暗影-史莱姆剑一阶")
      apply_shadow_first_stage(u)
      u:sendmessage("|cFF6633FF[暗影庭院]暗影进阶|r")
    end
    if not u:hasdata("暗影-史莱姆剑神化") and shadow_stage_condition(u, 7, 2000) then
      u:setdata("暗影-史莱姆剑神化")
      apply_shadow_divine_stage(u)
      u:sendmessage("|cFF6633FF[暗影庭院]暗影神化|r")
    end
    if not u:hasdata("暗影-禁忌可点击") and not u:hasdata("暗影-禁忌希德") and u:getdata("魔力值") >= 5000 and (Time_M or 0) >= 15 then
      u:setdata("暗影-禁忌可点击")
      update_shadow_ui(u, function(unit)
        apply_forbidden_shadow(unit)
      end, nil, "Anying_Cq_Lv3_Big.tga", "Anying_Cq_Lv3.tga", true)
    end
  end)
end

local function install_shadow_core_runtime(u)
  local sy = u.ownerid
  u:reduceshw()
  ac.wait(10, function()
    u:uivar_change({
      keyname = "暗影大人",
      keytype = "传奇栏",
      icon = "Anying_Cq_01_B.tga",
      size_h = 0.57,
      dx = 6,
      ishasphoto = true,
      smallicon = "Anying_Cq_01.tga"
    })
  end)
  u:addstexiao("暗影大人-魔力改造升级", "英雄升级时效果", function()
    u:changedata("全属性增幅", 0.0025)
    local count = u:getdata("系统-累积等级")
    ChangeValue(DamageSystem_Shjc, sy, count * 0.001)
    u:changemaxhp(count * 100)
    u:changedata("魔力值", count * 10)
  end)
  ModelReplace({
    u = u,
    model = "Darksama-test-01.mdx",
    modelsize = 1,
    modelname = "|cFF4935A8希|r|cFF7139C2德·|r|cFFA33CDA卡|r|cFFD547E8盖|r|cFFF06AF2诺|r",
    modelicon = "Portrait_Anying.tga",
    isforce = true
  })
  ChangeValue(DamageSplit_CountJzHit, sy, 1)
  ChangeValue(DamageSplit_CountJzMax, sy, 0.5)
  u:changedata("影变异补正", 100)
  shadow_refresh(u, "希德-全属性", function()
    return u:getdata("魔力值") * 0.01
  end, function(add)
    u:addallstats(add)
  end)
  shadow_refresh(u, "希德-近战伤害", function()
    return u:getdata("暗影计数") * 0.014 + u:getdata("系统-累积等级") * 0.003
  end, function(add)
    ChangeValue(Correction_Jzsh, sy, add)
  end)
  shadow_refresh(u, "希德-暗影庭院伤害", function()
    return u:getdata("暗影计数") * 0.05
  end, function(add)
    ChangeValue(DamageSystem_Shjc, sy, add)
  end)
  shadow_refresh_multiplier(u, "希德-论外伤害", DamageSystem_Shjc, sy, function()
    return 1 + u:getdata("暗影计数") * 0.1
  end)
  shadow_refresh(u, "希德-终结伤害", function()
    return u:getdata("暗影计数") * 0.003
  end, function(add)
    ChangeValue(DamageSystem_EndSh, sy, add)
  end)
  u:addstexiao("暗影大人-凡人的剑技附伤", "近战伤害特效", function(args)
    shadow_true_damage(u, args.tg, args.damageinfo.yssh * 0.5, "希德-凡人的剑技")
  end)
  local shadow_damage_sounds = {
    {
      sound = Sound_Ay_RdSnd01,
      chat = "Mission Complete"
    },
    {
      sound = Sound_Ay_RdSnd02,
      chat = "很遗憾 时间到了"
    },
    {
      sound = Sound_Ay_RdSnd03,
      chat = "那就潜下去吧 无论黑暗有多深"
    },
    {
      sound = Sound_Ay_RdSnd04,
      chat = "游戏结束了吗"
    },
    {
      sound = Sound_Ay_RdSnd05,
      chat = "怎么了 这才刚刚开始吧"
    },
    {
      sound = Sound_Ay_RdSnd06,
      chat = "这片天空早已在我的支配之下 野兽啊 用你的身体记住这件事情吧"
    },
    {
      sound = Sound_Ay_RdSnd07,
      chat = "真是丑陋"
    },
    {
      sound = Sound_Ay_RdSnd08,
      chat = "真是太棒了"
    }
  }
  u:addstexiao("暗影大人-直接伤害随机音效", "直接伤害特效", function()
    if u:hasdata("暗影大人-直接伤害随机音效冷却") then
      return
    end
    u:settimedata("暗影大人-直接伤害随机音效冷却", 10)
    local sound_info = shadow_damage_sounds[GetRandomInt(1, #shadow_damage_sounds)]
    u:playseensound(sound_info.sound)
    NPCChat({
      name = "|cFF9932CC希德·卡盖诺|r",
      chaticon = "Chat_Ay_Anying.tga",
      chattext = {
        {
          time = 0,
          text = "|cFF9932CC" .. sound_info.chat
        }
      }
    })
  end)
  u:addstexiao("暗影大人-暗影庭院杀敌魔力", "杀敌效果", function(args)
    local tg = args.tg
    ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
    u:changedata("魔力值", u:getdata("暗影计数") * 3)
    if tg:isboss() then
      PlayGlobalSound(Sound_Ay_AnyingKillBoss)
      flashphoto({
        photo = "Ph_Anying_KillBOss.tga",
        timeout = 1,
        timehold = 3,
        timein = 2
      })
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 7, "绝对闪避")
      end)
    end
  end)
  ac.wait(7000, function()
    u:setdata("暗影庭院-强制获取七影")
    herogetvar(u.handle, {
      Vars_Ciyuan_Qiying
    }, "次元", "阿尔法")
    u:deldata("暗影庭院-强制获取七影")
    ac.wait(35000, function()
      PlayBGM({
        bgm = BGM_Ay_10,
        time = 215,
        ID = 252,
        unit = u.handle
      })
    end)
  end)
  u:additem("I0Z0")
  ac.loop(SHADOW_POWER_INTERVAL, function()
    local bb = getunit(Beibao[sy])
    bb:additem("I0Z1")
  end)
  start_shadow_progression(u)
end

local function install_alpha_base(u)
  local sy = u.ownerid
  shadow_refresh(u, "阿尔法-近战范围", function()
    return 0.3 * GetShadowEffectScale(u)
  end, function(add)
    u:changedata("近战范围倍率", add)
  end)
  u:addstexiao("阿尔法-剑术天才生命损耗", "近战伤害特效", function(args)
    if not u:hasdata("阿尔法-剑术天才冷却") then
      u:settimedata("阿尔法-剑术天才冷却", 0.5)
      LossHpUnit({
        u = u,
        tg = args.tg,
        damage = 0,
        perhp = 0,
        maxhp = u:getdata("暗影计数") * 0.1 * GetShadowEffectScale(u),
        bj = "[生命损耗]阿尔法-剑术的天才"
      })
    end
  end)
  shadow_refresh_data(u, "阿尔法-魔力控制魔力值", function()
    return u:getint() * 1.5 * GetShadowEffectScale(u)
  end, nil, "魔力值")
  shadow_refresh_data(u, "阿尔法-魔力控制固定格挡", function()
    return u:getdata("魔力值") * 0.03 * GetShadowEffectScale(u)
  end, nil, "固定格挡")
  ac.loop(60000, function()
    local shield = u:getdata("暗影计数") * 1000 * GetShadowEffectScale(u)
    local before = Hudun_Linshi[sy]
    hdzlinshiadd(u, shield)
    local added = math.max(0, Hudun_Linshi[sy] - before)
    if 0 < added then
      u:changedata("生命损耗临时护盾", added)
    end
  end)
  shadow_refresh(u, "阿尔法-经验积分", function()
    return u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Exp, sy, 2 * add)
    ChangeValue(Correction_Gold, sy, add)
  end)
  u:addlevel(5)
end

local function install_beta_base(u)
  local sy = u.ownerid
  u:addstexiao("贝塔-战斗技艺蓄力", "进入战斗状态时", function()
    if u:hasdata("贝塔-战斗技艺运行中") then
      return
    end
    u:setdata("贝塔-战斗技艺运行中")
    local add = 0
    ac.loop(1000, function(timer)
      if u:isingroup(SystemGroup_Battle) and u:isalive() then
        local scale = GetShadowEffectScale(u)
        local step = u:getdata("暗影计数") * 0.001 * scale
        local max = u:getdata("暗影计数") * 0.1 * scale
        local change = math.min(step, math.max(0, max - add))
        if 0 < change then
          add = add + change
          ChangeValue(DamageSystem_Shjc, sy, change)
        end
      else
        ChangeValue(DamageSystem_Shjc, sy, -add)
        u:deldata("贝塔-战斗技艺运行中")
        timer:remove()
      end
    end)
  end)
  u:addstexiao("贝塔-战斗技艺反击", "受伤后效果", function(args)
    if args.tg ~= 0 and not u:hasdata("贝塔-战斗技艺反击冷却") then
      u:settimedata("贝塔-战斗技艺反击冷却", 5)
      shadow_true_damage(u, args.tg, args.damage * u:getdata("魔力值") * GetShadowEffectScale(u), "贝塔-战斗技艺反击")
    end
  end)
  u:addstexiao("贝塔-冷静观察首击", "直接伤害特效", function(args)
    local tg = args.tg
    local key = "贝塔-冷静观察终结受伤-" .. sy
    if not tg:hasdata(key) then
      tg:setdata(key)
    end
    local chance = 15
    if u:hasdata("暗影-七影二阶") then
      chance = 20 + u:getdata("暗影计数") * 5
    end
    if not u:hasdata("贝塔-冷静观察附伤递归") and not u:hasdata("贝塔-冷静观察冷却") and u:getluckrandom(chance * args.damageinfo.txgl) then
      u:settimedata("贝塔-冷静观察冷却", 1)
      u:setdata("贝塔-冷静观察附伤递归")
      shadow_damage(u, tg, args.damageinfo.yssh, "贝塔-冷静观察二次伤害")
      u:deldata("贝塔-冷静观察附伤递归")
    end
  end)
  u:addstexiao("贝塔-冷静观察终结受伤", "终结伤害计算效果", function(args)
    if args.tg:hasdata("贝塔-冷静观察终结受伤-" .. sy) then
      args.damageinfo.enddown = args.damageinfo.enddown * (1 - 0.1 * GetShadowEffectScale(u))
    end
  end)
  shadow_refresh(u, "贝塔-三伤", function()
    return u:getdata("暗影计数") * 0.15 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Jzsh, sy, add)
    ChangeValue(Correction_Magic, sy, add)
    ChangeValue(Correction_Gun, sy, add)
  end)
  shadow_refresh(u, "贝塔-暗影庭院伤害", function()
    return u:getdata("暗影计数") * 0.001 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(DamageSystem_Shjc, sy, add)
  end)
  shadow_refresh(u, "贝塔-属性", function()
    return u:getdata("暗影计数") * 20 * GetShadowEffectScale(u)
  end, function(add)
    u:addallstats(add)
  end)
end

local function install_gamma_base(u)
  local sy = u.ownerid
  shadow_refresh(u, "伽马-积分获取", function()
    return u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Gold, sy, add)
  end)
  u:addstexiao("伽马-商业才能积分附伤", "直接伤害特效", function(args)
    if u:hasdata("伽马-商业才能附伤递归") or u:hasdata("伽马-商业才能冷却") then
      return
    end
    u:settimedata("伽马-商业才能冷却", 0.1)
    u:setdata("伽马-商业才能附伤递归")
    shadow_damage(u, args.tg, u:getgold() * 111, "伽马-商业的才能")
    u:deldata("伽马-商业才能附伤递归")
  end)
  shadow_refresh(u, "伽马-魔力天赋", function()
    return u:getdata("魔力值") * 1.0E-4 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Magic, sy, add)
  end)
  shadow_refresh(u, "伽马-魔力恢复", function()
    return 1 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(HeroMenu_MpCure_MaxMp, sy, add)
  end)
  shadow_refresh(u, "伽马-暗影庭院法伤", function()
    return u:getdata("暗影计数") * 0.01 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Magic, sy, add)
  end)
  shadow_refresh(u, "伽马-暗影庭院魔力伤害", function()
    return u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Damage_Type_Moli, sy, add)
  end)
  u:addgold(u:getdata("暗影计数") * 500)
end

local function install_delta_base(u)
  local sy = u.ownerid
  u:addstexiao("德尔塔-暴君削减生命上限", "直接伤害特效", function(args)
    local tg = args.tg
    if not u:hasdata("德尔塔-暴君冷却") then
      u:settimedata("德尔塔-暴君冷却", 1)
      tg:changemaxhp(-tg:getmaxhp() * u:getdata("暗影计数") * 5.0E-4 * GetShadowEffectScale(u))
    end
    local key = "德尔塔-野性本能额外受伤-" .. sy
    if not tg:hasdata(key) then
      tg:setdata(key)
      tg:changedata("怪物-额外受伤", 0.12 * GetShadowEffectScale(u))
    end
  end)
  local slowed = {}
  local slow_key = "德尔塔-野性本能减速-" .. sy
  ac.loop(100, function()
    for _, target in ipairs(slowed) do
      if target:hasdata(slow_key) then
        SetUnitMoveSpeed(target.handle, target:getdata(slow_key))
        target:deldata(slow_key)
      end
    end
    slowed = {}
    if not u:isalive() then
      return
    end
    local x, y = u:getxy()
    for _, target in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
      target = getunit(target)
      local speed = GetUnitMoveSpeed(target.handle)
      target:setdata(slow_key, speed)
      SetUnitMoveSpeed(target.handle, speed * math.max(0.01, 1 - 0.2 * GetShadowEffectScale(u)))
      table.insert(slowed, target)
    end
  end)
  shadow_refresh_multiplier(u, "德尔塔-野性本能减伤", DamageSystem_Ssjianshao, sy, function()
    return math.max(0.01, 1 - 0.15 * GetShadowEffectScale(u))
  end)
  shadow_refresh_multiplier(u, "德尔塔-论外伤害", DamageSystem_Shjc, sy, function()
    return 1 + u:getdata("暗影计数") * 0.1 * GetShadowEffectScale(u)
  end)
  shadow_refresh(u, "德尔塔-暗影庭院伤害", function()
    return u:getdata("暗影计数") * 0.01 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(DamageSystem_Shjc, sy, add)
  end)
  shadow_refresh(u, "德尔塔-额外移速", function()
    return u:getdata("暗影计数") * 15 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, add)
  end)
end

local function install_epsilon_base(u)
  local sy = u.ownerid
  shadow_refresh(u, "艾普西隆-全属性伤害", function()
    return u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Damage_Element_All, sy, add)
  end)
  shadow_refresh(u, "艾普西隆-永恒生命恢复", function()
    return u:getdata("暗影计数") * 0.1 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(HeroMenu_HpForever_MaxHp, sy, add)
  end)
  ChangeValue(DamageSplit_CountHit, sy, 1)
  shadow_refresh(u, "艾普西隆-法术伤害", function()
    return u:getdata("暗影计数") * 0.1 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Magic, sy, add)
  end)
  shadow_refresh(u, "艾普西隆-纷争系数", function()
    return u:getdata("暗影计数") * GetShadowEffectScale(u)
  end, function(add)
    ChangeZhanzhengqiyue(add, "FF8F70A8", false)
  end)
end

local function install_zeta_base(u)
  local sy = u.ownerid
  shadow_refresh(u, "泽塔-全武器伤害", function()
    return u:getdata("暗影计数") * 0.012 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Jzsh, sy, add)
    ChangeValue(Correction_Gun, sy, add)
  end)
  u:addstexiao("泽塔-武器主动无僵直", "武器使用后效果", function()
    u:clearbuff("僵直")
  end)
  ac.loop(10000, function()
    u:setdata("泽塔-暗杀式突袭准备")
  end)
  u:addstexiao("泽塔-暗杀式突袭", "直接伤害变更", function(args)
    if u:hasdata("泽塔-暗杀式突袭准备") then
      u:deldata("泽塔-暗杀式突袭准备")
      args.damageinfo.damage = args.damageinfo.damage * (1 + 0.3 * GetShadowEffectScale(u))
    end
  end)
  shadow_refresh_multiplier(u, "泽塔-暗影庭院减伤", DamageSystem_Ssjianshao, sy, function()
    return math.max(0.01, 1 - u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u))
  end)
  shadow_refresh(u, "泽塔-敏捷", function()
    return u:getdata("暗影计数") * 40 * GetShadowEffectScale(u)
  end, function(add)
    u:addagi(add)
  end)
end

local function install_eta_base(u)
  local sy = u.ownerid
  shadow_refresh_data(u, "伊塔-探索额外结果概率", function()
    return 30 * GetShadowEffectScale(u)
  end)
  shadow_refresh_data(u, "伊塔-不消耗子弹概率", function()
    return (20 + u:getdata("暗影计数") * 5) * GetShadowEffectScale(u)
  end)
  shadow_refresh_data(u, "伊塔-锻造消耗降低", function()
    local add = 0.2
    if u:hasdata("暗影-七影二阶") then
      add = add + u:getdata("暗影计数") * 0.03
    end
    return add * GetShadowEffectScale(u)
  end)
  shadow_refresh_data(u, "伊塔-枪械升级概率加成", function()
    return 10 * GetShadowEffectScale(u)
  end)
  shadow_refresh_data(u, "伊塔-枪械RPM加成", function()
    if not u:hasdata("暗影-七影二阶") then
      return 0
    end
    return u:getdata("暗影计数") * 0.02 * GetShadowEffectScale(u)
  end)
  u:addstexiao("伊塔-暗影庭院升级枪伤", "英雄升级时效果", function()
    ChangeValue(Correction_Gun, sy, 0.005 * GetShadowEffectScale(u))
  end)
  shadow_refresh(u, "伊塔-枪械伤害", function()
    return u:getdata("暗影计数") * 0.01 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Gun, sy, add)
  end)
  shadow_refresh(u, "伊塔-智力", function()
    return u:getdata("暗影计数") * 40 * GetShadowEffectScale(u)
  end, function(add)
    u:addint(add)
  end)
end

local function install_seven_shadow_base(u, name)
  if name == "阿尔法" then
    install_alpha_base(u)
  elseif name == "贝塔" then
    install_beta_base(u)
  elseif name == "伽马" then
    install_gamma_base(u)
  elseif name == "德尔塔" then
    install_delta_base(u)
  elseif name == "艾普西隆" then
    install_epsilon_base(u)
  elseif name == "泽塔" then
    install_zeta_base(u)
  elseif name == "伊塔" then
    install_eta_base(u)
  end
  if u:hasdata("暗影-七影一阶") then
    install_seven_shadow_stage(u, name, 1)
  end
  if u:hasdata("暗影-七影二阶") then
    install_seven_shadow_stage(u, name, 2)
  end
end

local function install_alpha_stage(u, stage)
  local sy = u.ownerid
  if stage == 1 then
    shadow_refresh(u, "阿尔法一阶-近战伤害", function()
      return u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u)
    end, function(add)
      ChangeValue(Correction_Jzsh, sy, add)
    end)
    local vision = CreateFogModifierRect(u.owner, FOG_OF_WAR_VISIBLE, RECT_PlayArea, false, false)
    FogModifierStart(vision)
    u:addstexiao("阿尔法一阶-首次伤害", "直接伤害变更", function(args)
      local key = "阿尔法-首次伤害-" .. sy
      if not args.tg:hasdata(key) then
        args.tg:setdata(key)
        args.damageinfo.damage = args.damageinfo.damage * (1 + u:getdata("暗影计数") * 0.1 * GetShadowEffectScale(u))
      end
    end)
    return
  end
  u:addstexiao("阿尔法二阶-魔力控制四击", "直接伤害特效", function(args)
    local tg = args.tg
    local key = "阿尔法-魔力控制命中-" .. sy
    tg:changedata(key, 1)
    if tg:getdata(key) >= 4 then
      tg:setdata(key, 0)
      shadow_damage(u, tg, u:getdata("魔力值") * 66 * GetShadowEffectScale(u), "阿尔法-魔力控制抹除魔力")
      LossHpUnit({
        u = u,
        tg = tg,
        damage = 0,
        perhp = 0,
        maxhp = u:getdata("暗影计数") * 0.1 * GetShadowEffectScale(u),
        bj = "[生命损耗]阿尔法-魔力控制"
      })
    end
  end)
  shadow_refresh(u, "阿尔法二阶-百分比生命上限", function()
    return (u:getdata("魔力值") * 1.0E-6 + u:getdata("暗影计数") * 0.01) * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(HeroMenu_HpForever_MaxHp, sy, add)
  end)
  u:addstexiao("阿尔法二阶-受伤破抗", "受伤后效果", function(args)
    local tg = args.tg
    local key = "阿尔法-魔力控制破抗-" .. sy
    if tg ~= 0 and not tg:hasdata(key) then
      tg:setdata(key)
      tg:changedata("全属性抗性", -20)
      tg:changearmor(-20)
    end
  end)
end

local function install_beta_stage(u, stage)
  local sy = u.ownerid
  if stage == 1 then
    shadow_refresh(u, "贝塔一阶-近战伤害", function()
      return u:getdata("暗影计数") * u:getdata("魔力值") * 1.0E-6 * GetShadowEffectScale(u)
    end, function(add)
      ChangeValue(Correction_Jzsh, sy, add)
    end)
    u:setdata("贝塔-坚实消耗品属性")
    return
  end
  u:addstexiao("贝塔二阶-杀敌生命上限", "杀敌效果", function()
    u:changemaxhp((1 + u:getdata("暗影计数") * 0.2) * GetShadowEffectScale(u))
  end)
  u:addstexiao("贝塔二阶-生命上限附伤", "直接伤害特效", function(args)
    if u:hasdata("贝塔二阶-生命上限附伤冷却") then
      return
    end
    u:settimedata("贝塔二阶-生命上限附伤冷却", 0.1)
    shadow_damage(u, args.tg, u:getmaxhp() * 0.005 * GetShadowEffectScale(u), "贝塔-暗影庭院生命上限附伤")
  end)
end

local function install_gamma_stage(u, stage)
  local sy = u.ownerid
  if stage == 1 then
    shadow_refresh(u, "伽马一阶-积分伤害加成", function()
      return u:getgold() * 1.0E-4 * GetShadowEffectScale(u)
    end, function(add)
      ChangeValue(DamageSystem_Shjc, sy, add)
    end)
    shadow_refresh(u, "伽马一阶-体力恢复", function()
      return u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u)
    end, function(add)
      ChangeValue(Hero_Tili_Huifu, sy, add)
    end)
    shadow_refresh(u, "伽马一阶-生命恢复", function()
      return u:getdata("暗影计数") * 0.05 * GetShadowEffectScale(u)
    end, function(add)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, add)
    end)
    return
  end
  shadow_refresh_data(u, "伽马-魔力天赋总量加成", function()
    return u:getdata("魔力值") * 0.2 * GetShadowEffectScale(u)
  end, nil, "魔力值")
  u:addstexiao("伽马二阶-杀敌魔力值", "杀敌效果", function()
    u:changedata("魔力值", (1 + u:getdata("暗影计数") * 2) * GetShadowEffectScale(u))
  end)
end

local function install_delta_stage(u, stage)
  local sy = u.ownerid
  if stage == 1 then
    u:addstexiao("德尔塔一阶-暴君击杀成长", "杀敌效果", function()
      u:changemaxhp((1 + u:getdata("暗影计数") * 0.25) * GetShadowEffectScale(u))
    end)
    u:addstexiao("德尔塔一阶-强者为尊", "直接伤害变更", function(args)
      if args.damageinfo.distance <= 1500 and u:getshenxing() > args.tg:getdata("神性") then
        args.damageinfo.damage = args.damageinfo.damage * (1 + u:getdata("暗影计数") * 0.02 * GetShadowEffectScale(u))
      end
    end)
    return
  end
  shadow_refresh_data(u, "闪避值", function()
    return u:getstr() * 1.0E-4 * GetShadowEffectScale(u)
  end)
  shadow_refresh(u, "德尔塔二阶-固定伤害", function()
    return u:getdata("魔力值") * 5 * GetShadowEffectScale(u)
  end, function(add)
    u:changedata("固定伤害", add)
  end)
end

local function install_epsilon_stage(u, stage)
  local sy = u.ownerid
  if stage == 1 then
    shadow_refresh(u, "艾普西隆一阶-法术修正", function()
      return u:getdata("魔力值") * 1.0E-4 * GetShadowEffectScale(u)
    end, function(add)
      ChangeValue(Correction_Magic, sy, add)
    end)
    shadow_refresh(u, "艾普西隆一阶-护甲", function()
      return u:getdata("魔力值") * 1.0E-4 * GetShadowEffectScale(u)
    end, function(add)
      u:changearmor(add)
    end)
    return
  end
  u:addstexiao("艾普西隆二阶-等额魔力附伤", "直接伤害特效", function(args)
    if u:hasdata("艾普西隆二阶-等额魔力附伤冷却") then
      return
    end
    u:settimedata("艾普西隆二阶-等额魔力附伤冷却", 0.8)
    shadow_damage(u, args.tg, args.damageinfo.yssh, "艾普西隆-魔力斩击")
  end)
  shadow_refresh_data(u, "固定格挡", function()
    return u:getdata("魔力值") * 0.001 * GetShadowEffectScale(u)
  end)
end

local function install_zeta_stage(u, stage)
  local sy = u.ownerid
  if stage == 1 then
    u:setdata("泽塔-撬锁经验翻倍")
    shadow_refresh(u, "泽塔一阶-固定伤害", function()
      return HeroMenu_ExtraMoveSpeed[sy] * 5 * GetShadowEffectScale(u)
    end, function(add)
      u:changedata("固定伤害", add)
    end)
    return
  end
  shadow_refresh(u, "泽塔二阶-近战伤害", function()
    return u:getdata("暗影计数") * 0.015 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Jzsh, sy, add)
  end)
  shadow_refresh_data(u, "泽塔-额外杀敌概率", function()
    return (10 + u:getdata("暗影计数") * 2) * GetShadowEffectScale(u)
  end)
end

local function install_eta_stage(u, stage)
  local sy = u.ownerid
  if stage == 1 then
    u:addstexiao("伊塔一阶-枪械魔力附伤", "直接伤害特效", function(args)
      if (args.damageinfo.xs_qx or 0) <= 0 or u:hasdata("伊塔一阶-枪械魔力附伤递归") then
        return
      end
      u:setdata("伊塔一阶-枪械魔力附伤递归")
      shadow_damage(u, args.tg, u:getdata("魔力值") * GetShadowEffectScale(u), "伊塔-阴之睿智")
      u:deldata("伊塔一阶-枪械魔力附伤递归")
    end)
    shadow_refresh(u, "伊塔一阶-终结伤害", function()
      return u:getdata("暗影计数") * 0.01 * GetShadowEffectScale(u)
    end, function(add)
      ChangeValue(DamageSystem_EndSh, sy, add)
    end)
    return
  end
  shadow_refresh(u, "伊塔二阶-伤害加成", function()
    return (u:getlevel() * 0.04 + u:getdata("暗影计数") * 0.025) * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(DamageSystem_Shjc, sy, add)
  end)
  shadow_refresh(u, "伊塔二阶-魔力枪械伤害", function()
    return u:getdata("魔力值") * 1.0E-5 * GetShadowEffectScale(u)
  end, function(add)
    ChangeValue(Correction_Gun, sy, add)
  end)
end

function install_seven_shadow_stage(u, name, stage)
  local marker = "暗影-七影-" .. name .. "-" .. stage .. "阶效果"
  if u:hasdata(marker) then
    return
  end
  u:setdata(marker)
  if name == "阿尔法" then
    install_alpha_stage(u, stage)
  elseif name == "贝塔" then
    install_beta_stage(u, stage)
  elseif name == "伽马" then
    install_gamma_stage(u, stage)
  elseif name == "德尔塔" then
    install_delta_stage(u, stage)
  elseif name == "艾普西隆" then
    install_epsilon_stage(u, stage)
  elseif name == "泽塔" then
    install_zeta_stage(u, stage)
  elseif name == "伊塔" then
    install_eta_stage(u, stage)
  end
  if stage == 2 then
    local icon = SEVEN_SHADOW_ADVANCE_ICONS[name]
    u:uivar_change({
      keyname = name,
      keytype = "传奇栏",
      icon = icon,
      smallicon = icon,
      ishasphoto = false
    })
  end
end

local function get_seven_shadow(u, var)
  ciyuanget(u, var, true)
  u:changedata("暗影计数", 1)
  if not u:hasdata("暗影庭院-强制获取七影") then
    u:changedata("传奇数量", -1)
  end
end

table.insert(Vars_Huiyi_Dz, {
  name = "暗影大人",
  weight = 5,
  lv = 3,
  key = {
    "唯一",
    "根源",
    "影"
  },
  unique = true,
  addweight = function(u, var)
    return 0
  end,
  condition = function(u)
    return u:hasdata("判定-暗影大人") and u:hasdata("暗影-初始")
  end,
  effect = function(u, var)
    ciyuanget(u, var)
    PlayGlobalSound(Sound_Ay_Anying)
    NPCChat({
      name = "|cFF9932CC希德·卡盖诺|r",
      chaticon = "Chat_Ay_Anying.tga",
      chattext = {
        {
          time = 1,
          text = "|cFFCC0033吾|r|cFFB40042乃|r|cFF9C0052暗|r|cFF830061影|r"
        },
        {
          time = 3,
          text = "|cFFCC0033潜|r|cFFBD003D伏|r|cFFAE0046于|r|cFF9F0050暗|r|cFF90005A影|r|cFF800063之|r|cFF71006D中|r"
        },
        {
          time = 5,
          text = "|cFFCC0033狩|r|cFFBB003E猎|r|cFFA90049暗|r|cFF980054影|r|cFF87005F之|r|cFF76006A人|r"
        }
      }
    })
    flashphoto({
      photo = "Ph_Ay_01.tga",
      timeout = 3,
      timehold = 2,
      timein = 2
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 7, "绝对闪避")
    end)
    install_shadow_core_runtime(u)
  end,
  effectname = "|cFF4935A8希|r|cFF7139C2德·|r|cFFA33CDA卡|r|cFFD547E8盖|r|cFFF06AF2诺|r",
  effecttext = "|cFFBFA8EA作为龙套角色，一边隐藏力量，\n一边暗中介入故事展示实力的“影之实力者”的形象无比憧憬的少年，\n转生到异世界。享受自己梦想中的“影之实力者”的设定|r",
  effectart = "Anying_Cq_01.tga"
})
Vars_Ciyuan_Qiying = {
  {
    name = "阿尔法",
    weight = 300,
    lv = 3,
    key = {"影", "战士"},
    unique = true,
    condition = function(u)
      return u:hasdata("变异判定-暗影大人")
    end,
    effect = function(u, var)
      get_seven_shadow(u, var)
      PlayGlobalSound(Sound_Ay_Aerfa)
      NPCChat({
        name = "|cFFD69436阿|r|cFFF0B85A尔|r|cFFFFD27A法|r",
        chaticon = "Chat_Ay_Aerfa.tga",
        chattext = {
          {
            time = 1,
            text = "|cFFFFFFCC唉|r|cFFFFFFBD，|r|cFFFFFFAF你|r|cFFFFFFA0又|r|cFFFFFF92在|r|cFFFFFF83一|r|cFFFFFF75个|r|cFFFFFF66人|r|cFFFFFF57想|r|cFFFFFF49事|r|cFFFFFF3A情|r|cFFFFFF2C吗|r|cFFFFFF1D？|r"
          },
          {
            time = 5,
            text = "|cFFFFFFCC又|r|cFFFFFFBE露|r|cFFFFFFB1出|r|cFFFFFFA3那|r|cFFFFFF96遥|r|cFFFFFF88望|r|cFFFFFF7A远|r|cFFFFFF6D方|r|cFFFFFF5F的|r|cFFFFFF52忧|r|cFFFFFF44郁|r|cFFFFFF36神|r|cFFFFFF29情|r|cFFFFFF1B~|r"
          },
          {
            time = 11,
            text = "|cFFFFFFCC难|r|cFFFFFFBE道|r|cFFFFFFB1我|r|cFFFFFFA3没|r|cFFFFFF96办|r|cFFFFFF88法|r|cFFFFFF7A为|r|cFFFFFF6D你|r|cFFFFFF5F分|r|cFFFFFF52忧|r|cFFFFFF44解|r|cFFFFFF36劳|r|cFFFFFF29吗|r|cFFFFFF1B？|r"
          },
          {
            time = 16,
            text = "|cFFFFFFCC我|r|cFFFFFFBE们|r|cFFFFFFB1的|r|cFFFFFFA3实|r|cFFFFFF96力|r|cFFFFFF88，|r|cFFFFFF7A的|r|cFFFFFF6D确|r|cFFFFFF5F远|r|cFFFFFF52远|r|cFFFFFF44不|r|cFFFFFF36及|r|cFFFFFF29你|r|cFFFFFF1B。|r"
          },
          {
            time = 22,
            text = "|cFFFFFFCC不|r|cFFFFFF99过|r|cFFFFFF66~|r"
          },
          {
            time = 24,
            text = "|cFFFFFFCC希|r|cFFFFFFC0望|r|cFFFFFFB4你|r|cFFFFFFA8别|r|cFFFFFF9C总|r|cFFFFFF90是|r|cFFFFFF84独|r|cFFFFFF78自|r|cFFFFFF6C承|r|cFFFFFF60担|r|cFFFFFF54那|r|cFFFFFF48沉|r|cFFFFFF3C重|r|cFFFFFF30的|r|cFFFFFF24忧|r|cFFFFFF18虑|r"
          },
          {
            time = 28,
            text = "|cFFFFFFCC今|r|cFFFFFFC0天|r|cFFFFFFB4就|r|cFFFFFFA8让|r|cFFFFFF9C我|r|cFFFFFF90帮|r|cFFFFFF84你|r|cFFFFFF78分|r|cFFFFFF6C担|r|cFFFFFF60其|r|cFFFFFF54中|r|cFFFFFF48一|r|cFFFFFF3C部|r|cFFFFFF30分|r|cFFFFFF24吧|r|cFFFFFF18。|r"
          },
          {
            time = 32,
            text = "|cFFFFFFCC~|r|cFFFFFFAA可|r|cFFFFFF88以|r|cFFFFFF66吧|r|cFFFFFF44？|r"
          }
        }
      })
      install_seven_shadow_base(u, var.name)
    end,
    effectname = "|cFFD69436阿|r|cFFF0B85A尔|r|cFFFFD27A法|r",
    effecttext = "|cFFB38CFF[暗影庭院]|r\n|cFFF0B54A【剑术的天才】|r\n|cFFF0B54A【魔力控制】|r\n|cFFF0B54A【暗影庭院】|r\n|cFFFFE0A3暗影庭园最初的成员，“七影”的第一席。\n金发蓝眼的精灵。全能型人才，完美的超人，暗影庭院实质性的管理者。|r",
    effectart = "Anying_Cq_Aerfa.tga"
  },
  {
    name = "贝塔",
    weight = 300,
    lv = 3,
    key = {"影", "战士"},
    unique = true,
    condition = function(u)
      return u:hasdata("变异判定-暗影大人")
    end,
    effect = function(u, var)
      get_seven_shadow(u, var)
      PlayGlobalSound(Sound_Ay_Beita)
      NPCChat({
        name = "|cFF4D8FC4贝|r|cFF72BDD7塔|r",
        chaticon = "Chat_Ay_Beita.tga",
        chattext = {
          {
            time = 1,
            text = "|cFFFFFFFF你|r|cFFF4F4F4似|r|cFFE8E8E8乎|r|cFFDDDDDD很|r|cFFD2D2D2疲|r|cFFC6C6C6惫|r|cFFBBBBBB呢|r|cFFB0B0B0。|r"
          },
          {
            time = 4,
            text = "|cFFFFFFFF一|r|cFFF5F5F5直|r|cFFEBEBEB以|r|cFFE0E0E0来|r|cFFD6D6D6辛|r|cFFCCCCCC苦|r|cFFC2C2C2您|r|cFFB8B8B8了|r|cFFADADAD。|r"
          },
          {
            time = 7,
            text = "|cFFFFFFFF偶|r|cFFF6F6F6尔|r|cFFECECEC也|r|cFFE3E3E3要|r|cFFDADADA放|r|cFFD1D1D1松|r|cFFC7C7C7一|r|cFFBEBEBE下|r|cFFB5B5B5喔|r|cFFACACAC~|r"
          },
          {
            time = 10,
            text = "|cFFFFFFFF想|r|cFFF4F4F4要|r|cFFE8E8E8重|r|cFFDDDDDD振|r|cFFD2D2D2精|r|cFFC6C6C6神|r|cFFBBBBBB吗|r|cFFB0B0B0？|r"
          },
          {
            time = 13,
            text = "|cFFFFFFFF今|r|cFFF7F7F7天|r|cFFEFEFEF就|r|cFFE7E7E7让|r|cFFE0E0E0贝|r|cFFD8D8D8塔|r|cFFD0D0D0来|r|cFFC8C8C8帮|r|cFFC0C0C0助|r|cFFB8B8B8您|r|cFFB1B1B1吧|r|cFFA9A9A9！|r"
          }
        }
      })
      install_seven_shadow_base(u, var.name)
    end,
    effectname = "|cFF4D8FC4贝|r|cFF72BDD7塔|r",
    effecttext = "|cFFB38CFF[暗影庭院]|r\n|cFF8ED6E6【战斗技艺】|r\n|cFF8ED6E6【冷静观察】|r\n|cFF8ED6E6【暗影庭院】|r\n|cFFD5F4FA暗影庭院“七影”的第二座。银发蓝眼的精灵。\n对《暗影大人戟记》充满敬畏之心，每次都发生在都市的写照上。|r",
    effectart = "Anying_Cq_Beita.tga"
  },
  {
    name = "伽马",
    weight = 300,
    lv = 3,
    key = {"影", "魔导"},
    unique = true,
    condition = function(u)
      return u:hasdata("变异判定-暗影大人")
    end,
    effect = function(u, var)
      get_seven_shadow(u, var)
      PlayGlobalSound(Sound_Ay_Gama)
      NPCChat({
        name = "|cFF667BB0伽|r|cFFAAB9DE玛|r",
        chaticon = "Chat_Ay_Gama.tga",
        chattext = {
          {
            time = 1,
            text = "|cFF3333FF我|r|cFF2E2EF6已|r|cFF2A2AEC恭|r|cFF2525E3候|r|cFF2020DA多|r|cFF1C1CD1时|r|cFF1717C7，|r|cFF1313BE吾|r|cFF0E0EB5主|r|cFF0909AC。|r"
          },
          {
            time = 4,
            text = "|cFF3333FF我|r|cFF2E2EF6今|r|cFF2A2AEC天|r|cFF2525E3务|r|cFF2020DA必|r|cFF1C1CD1要|r|cFF1717C7让|r|cFF1313BE吾|r|cFF0E0EB5主|r|cFF0909AC~|r"
          },
          {
            time = 6,
            text = "|cFF3333FF哎|r|cFF2D2DF2呀|r|cFF2626E6！|r|cFF2020D9（|r|cFF1A1ACC摔|r|cFF1313BF倒|r|cFF0D0DB2）|r"
          },
          {
            time = 10,
            text = "|cFF3333FF~|r|cFF2C2CF0咳|r|cFF2424E2~|r|cFF1D1DD3咳|r|cFF1616C5咳|r|cFF0F0FB6！|r"
          },
          {
            time = 12,
            text = "|cFF3333FF穿|r|cFF3030F9~|r|cFF2D2DF4穿|r|cFF2A2AEE着|r|cFF2828E8不|r|cFF2525E3习|r|cFF2222DD惯|r|cFF1F1FD7的|r|cFF1C1CD2高|r|cFF1919CC跟|r|cFF1717C6鞋|r|cFF1414C1很|r|cFF1111BB难|r|cFF0E0EB5走|r|cFF0B0BB0路|r|cFF0808AA呢|r|cFF0606A4。|r"
          },
          {
            time = 16,
            text = "|cFF3333FF我|r|cFF3030F8今|r|cFF2C2CF1天|r|cFF2929EB要|r|cFF2525E4让|r|cFF2222DD吾|r|cFF1F1FD6主|r|cFF1B1BCF消|r|cFF1818C9除|r|cFF1414C2平|r|cFF1111BB日|r|cFF0E0EB4的|r|cFF0A0AAD疲|r|cFF0707A7劳|r"
          },
          {
            time = 22,
            text = "|cFF3333FF好|r|cFF3030F9好|r|cFF2D2DF2享|r|cFF2929EC受|r|cFF2626E6时|r|cFF2323DF光|r|cFF2020D9，|r|cFF1D1DD2因|r|cFF1A1ACC此|r|cFF1616C6才|r|cFF1313BF请|r|cFF1010B9您|r|cFF0D0DB2前|r|cFF0A0AAC来|r|cFF0606A6。|r"
          },
          {
            time = 25,
            text = "|cFF3333FF我|r|cFF2C2CF0也|r|cFF2424E2很|r|cFF1D1DD3期|r|cFF1616C5待|r|cFF0F0FB6~|r"
          },
          {
            time = 27,
            text = "|cFF3333FF能|r|cFF2F2FF8够|r|cFF2C2CF0悠|r|cFF2828E9闲|r|cFF2424E2的|r|cFF2121DB倾|r|cFF1D1DD3听|r|cFF1919CC吾|r|cFF1616C5主|r|cFF1212BD说|r|cFF0F0FB6话|r|cFF0B0BAF呢|r|cFF0707A8。|r"
          },
          {
            time = 32,
            text = "|cFF3333FF~|r|cFF2D2DF2来|r|cFF2626E6，|r|cFF2020D9这|r|cFF1A1ACC边|r|cFF1313BF请|r|cFF0D0DB2。|r"
          },
          {
            time = 37,
            text = "|cFF3333FF哎|r|cFF2D2DF2呀|r|cFF2626E6！|r|cFF2020D9（|r|cFF1A1ACC摔|r|cFF1313BF倒|r|cFF0D0DB2）|r"
          }
        }
      })
      install_seven_shadow_base(u, var.name)
    end,
    effectname = "|cFF667BB0伽|r|cFFAAB9DE马|r",
    effecttext = "|cFFB38CFF[暗影庭院]|r\n|cFFAAB9DE【商业的才能】|r\n|cFFAAB9DE【魔力的天赋】|r\n|cFFAAB9DE【暗影庭院】|r\n|cFFE3E8F5暗影庭院“七影”的第三座。拥有清晰的头脑，\n暗影说的每句话都能记住和理解，但运动能力是最差的。|r",
    effectart = "Anying_Cq_Gama.tga"
  },
  {
    name = "德尔塔",
    weight = 300,
    lv = 3,
    key = {
      "影",
      "兽",
      "战士"
    },
    unique = true,
    condition = function(u)
      return u:hasdata("变异判定-暗影大人")
    end,
    effect = function(u, var)
      get_seven_shadow(u, var)
      PlayGlobalSound(Sound_Ay_Deerta)
      NPCChat({
        name = "|cFF4D365B德|r|cFF684778尔|r|cFF865990塔|r",
        chaticon = "Chat_Ay_Deerta.tga",
        chattext = {
          {
            time = 1,
            text = "|cFF333333老大，我抓到一只好大的野猪！|r"
          },
          {
            time = 4,
            text = "|cFF333333等一下大家一起吃吧！|r"
          },
          {
            time = 8,
            text = "|cFF333333老大，你在这种地方~睡午觉吗？|r"
          },
          {
            time = 14,
            text = "|cFF333333啊！难不成老大在~执行任务？|r"
          },
          {
            time = 18,
            text = "|cFF333333德尔塔打扰到老大了吗~？|r"
          },
          {
            time = 22,
            text = "|cFF333333没有？~太好了！|r"
          },
          {
            time = 25,
            text = "|cFF333333既然不是在执行任务~|r"
          },
          {
            time = 29,
            text = "|cFF333333那来跟德尔塔比赛跑步吧！|r"
          },
          {
            time = 31,
            text = "|cFF333333预备~开始！|r"
          }
        }
      })
      install_seven_shadow_base(u, var.name)
    end,
    effectname = "|cFF4D365B德|r|cFF684778尔|r|cFF865990塔|r",
    effecttext = "|cFFB38CFF[暗影庭院]|r\n|cFFA56BC0【暴君】|r\n|cFFA56BC0【野性本能】|r\n|cFFA56BC0【暗影庭院】|r\n|cFFE4CFE8暗影庭园“七影”的第四座。拥有即使在“七影”中也突出的战斗能力，\n但是战斗方式粗暴，无论是人还是物都会被破坏。|r",
    effectart = "Anying_Cq_Deerta.tga"
  },
  {
    name = "艾普西隆",
    weight = 300,
    lv = 3,
    key = {"影", "魔导"},
    unique = true,
    condition = function(u)
      return u:hasdata("变异判定-暗影大人")
    end,
    effect = function(u, var)
      get_seven_shadow(u, var)
      PlayGlobalSound(Sound_Ay_Aipuxilong)
      NPCChat({
        name = "|cFF67B9DC艾|r|cFF83C4E2普|r|cFFA2B9E8西|r|cFFBCA8EA隆|r",
        chaticon = "Chat_Ay_Aipuxilong.tga",
        chattext = {
          {
            time = 1,
            text = "|cFF66FFCC吾|r|cFF61FAD1主|r|cFF5DF6D5，|r|cFF58F1DA我|r|cFF53ECDF已|r|cFF4FE8E3恭|r|cFF4AE3E8候|r|cFF46DFEC多|r|cFF41DAF1时|r|cFF3CD5F6。|r"
          },
          {
            time = 6,
            text = "|cFF66FFCC呵|r|cFF61FAD1呵|r|cFF5CF5D6，|r|cFF57F0DB吓|r|cFF52EBE0到|r|cFF4DE6E5您|r|cFF47E0EB了|r|cFF42DBF0吗|r|cFF3DD6F5？|r"
          },
          {
            time = 11,
            text = "|cFF66FFCC因|r|cFF61FAD1为|r|cFF5DF6D5您|r|cFF58F1DA每|r|cFF53ECDF天|r|cFF4FE8E3都|r|cFF4AE3E8很|r|cFF46DFEC忙|r|cFF41DAF1碌|r|cFF3CD5F6~|r"
          },
          {
            time = 17,
            text = "|cFF66FFCC为|r|cFF62FBD0了|r|cFF5EF6D4替|r|cFF59F2D9您|r|cFF55EEDD抚|r|cFF51EAE1平|r|cFF4CE6E6身|r|cFF48E1EA心|r|cFF44DDEE的|r|cFF40D9F2疲|r|cFF3CD4F6惫|r"
          },
          {
            time = 19,
            text = "|cFF66FFCC我|r|cFF62FBD0才|r|cFF5EF6D4会|r|cFF59F2D9像|r|cFF55EEDD这|r|cFF51EAE1样|r|cFF4CE6E6在|r|cFF48E1EA此|r|cFF44DDEE等|r|cFF40D9F2候|r|cFF3CD4F6您|r"
          },
          {
            time = 23,
            text = "|cFF66FFCC来|r|cFF5FF8D3，|r|cFF57F0DB别|r|cFF50E9E2客|r|cFF49E2E9气|r|cFF42DBF0。|r"
          },
          {
            time = 25,
            text = "|cFF66FFCC今|r|cFF62FBD0天|r|cFF5EF6D4把|r|cFF59F2D9一|r|cFF55EEDD切|r|cFF51EAE1都|r|cFF4CE6E6交|r|cFF48E1EA给|r|cFF44DDEE我|r|cFF40D9F2吧|r|cFF3CD4F6。|r"
          }
        }
      })
      install_seven_shadow_base(u, var.name)
    end,
    effectname = "|cFF67B9DC艾|r|cFF83C4E2普|r|cFFA2B9E8西|r|cFFBCA8EA隆|r",
    effecttext = "|cFFB38CFF[暗影庭院]|r\n|cFFA5B9EA【魔力结合】|r\n|cFFA5B9EA【魔力斩击】|r\n|cFFA5B9EA【暗影庭院】|r\n|cFFE1E7FA暗影庭园“七影”的第五座。拥有魔力操作天赋的精灵。\n另一方面，对自己的孩子体型感到自卑，使用史莱姆战斗装束来掩饰自己的身材。|r",
    effectart = "Anying_Cq_Aipuxilong.tga"
  },
  {
    name = "泽塔",
    weight = 300,
    lv = 3,
    key = {
      "影",
      "兽",
      "战士"
    },
    unique = true,
    condition = function(u)
      return u:hasdata("变异判定-暗影大人")
    end,
    effect = function(u, var)
      get_seven_shadow(u, var)
      PlayGlobalSound(Sound_Ay_Zeta)
      NPCChat({
        name = "|cFF47777A泽|r|cFF79BFC0塔|r",
        chaticon = "Chat_Ay_Zeta.tga",
        chattext = {
          {
            time = 1,
            text = "|cFFD2B48C~|r|cFFD6B890呵|r|cFFD9BC94呵|r|cFFDCC198，|r|cFFE0C59C我|r|cFFE4C9A0在|r|cFFE7CDA3这|r|cFFEAD1A7里|r|cFFEED6AB。|r"
          },
          {
            time = 5,
            text = "|cFFD2B48C以|r|cFFD6B990你|r|cFFDABD95敏|r|cFFDEC299锐|r|cFFE2C79D的|r|cFFE5CBA2观|r|cFFE9D0A6察|r|cFFEDD5AA力|r"
          },
          {
            time = 7,
            text = "|cFFD2B48C应|r|cFFD5B88F该|r|cFFD8BB92早|r|cFFDBBE96就|r|cFFDEC299察|r|cFFE1C69C觉|r|cFFE3C9A0到|r|cFFE6CCA3我|r|cFFE9D0A6了|r|cFFECD4A9吧|r|cFFEFD7AC？|r"
          },
          {
            time = 11,
            text = "|cFFD2B48C平|r|cFFD5B890常|r|cFFD8BC93您|r|cFFDCBF97总|r|cFFDFC39A会|r|cFFE2C79E伪|r|cFFE5CBA1装|r|cFFE8CFA5成|r|cFFEBD3A8学|r|cFFEFD6AC生|r"
          },
          {
            time = 15,
            text = "|cFFD2B48C很|r|cFFD5B88F少|r|cFFD8BB92显|r|cFFDBBE96露|r|cFFDEC299真|r|cFFE1C69C实|r|cFFE3C9A0的|r|cFFE6CCA3一|r|cFFE9D0A6面|r|cFFECD4A9呢|r|cFFEFD7AC。|r"
          },
          {
            time = 20,
            text = "|cFFD2B48C嗯|r|cFFD4B78F~|r|cFFD7BA92不|r|cFFDABD94过|r|cFFDCC097，|r|cFFDEC39A我|r|cFFE1C69D也|r|cFFE4C99F一|r|cFFE6CCA2样|r|cFFE8CFA5就|r|cFFEBD2A8是|r|cFFEED5AB了|r|cFFF0D8AD。|r"
          },
          {
            time = 25,
            text = "|cFFD2B48C那|r|cFFD4B68E么|r|cFFD6B890，|r|cFFD8BB92我|r|cFFD9BD94们|r|cFFDBBF96要|r|cFFDDC198不|r|cFFDFC39A要|r|cFFE1C69C试|r|cFFE3C89E着|r|cFFE4CAA1去|r|cFFE6CCA3深|r|cFFE8CFA5入|r|cFFEAD1A7了|r|cFFECD3A9解|r|cFFEED5AB彼|r|cFFEFD7AD此|r|cFFF1DAAF？|r"
          },
          {
            time = 32,
            text = "|cFFD2B48C~|r|cFFD4B78F我|r|cFFD7BA91可|r|cFFD9BC94不|r|cFFDBBF96一|r|cFFDEC299定|r|cFFE0C59C会|r|cFFE2C89E说|r|cFFE5CAA1出|r|cFFE7CDA3真|r|cFFE9D0A6心|r|cFFECD3A9话|r|cFFEED6AB喔|r|cFFF0D8AE。|r"
          }
        }
      })
      install_seven_shadow_base(u, var.name)
    end,
    effectname = "|cFF47777A泽|r|cFF79BFC0塔|r",
    effecttext = "|cFFB38CFF[暗影庭院]|r\n|cFF8CCBCC【初见即精通】|r\n|cFF8CCBCC【暗杀式突袭】|r\n|cFF8CCBCC【暗影庭院】|r\n|cFFD5ECE8暗影庭院“七影”的第六座。负责秘密活动。\n通常与其他成员分开行动，独自在世界各地东奔西走，进行谍报活动。|r",
    effectart = "Anying_Cq_Zeta.tga"
  },
  {
    name = "伊塔",
    weight = 300,
    lv = 3,
    key = {"影", "机械"},
    unique = true,
    condition = function(u)
      return u:hasdata("变异判定-暗影大人")
    end,
    effect = function(u, var)
      get_seven_shadow(u, var)
      PlayGlobalSound(Sound_Ay_Yita)
      NPCChat({
        name = "|cFF7A243D伊|r|cFFE7A6B8塔|r",
        chaticon = "Chat_Ay_Yita.tga",
        chattext = {
          {
            time = 1,
            text = "|cFF9933FF~|r|cFF8A2DE1~|r|cFF7B27C3~|r|cFF6B20A6~|r"
          },
          {
            time = 3,
            text = "|cFF9933FF唔|r|cFF8A2DE1~|r|cFF7B27C3~|r|cFF6B20A6！|r"
          },
          {
            time = 5,
            text = "|cFF9933FF少|r|cFF8C2EE6主|r|cFF8029CD~|r|cFF7324B4~|r|cFF661E9C？|r"
          },
          {
            time = 8,
            text = "|cFF9933FF来|r|cFF9531F7得|r|cFF9130EE正|r|cFF8C2EE6好|r|cFF882CDE~|r|cFF842AD6~|r|cFF8029CD应|r|cFF7B27C5该|r|cFF7725BD说|r|cFF7324B5~|r|cFF6F22AC~|r|cFF6B20A4我|r|cFF661E9C正|r|cFF621D93在|r|cFF5E1B8B找|r|cFF5A1983您|r|cFF55177B。|r"
          },
          {
            time = 15,
            text = "|cFF9933FF我|r|cFF9331F4整|r|cFF8D2EE8晚|r|cFF872CDD~|r|cFF8229D1~|r|cFF7C27C6都|r|cFF7625BA在|r|cFF7022AF做|r|cFF6A20A3实|r|cFF641E98验|r|cFF5F1B8C~|r|cFF591981~|r"
          },
          {
            time = 22,
            text = "|cFF9933FF却|r|cFF9130F0~|r|cFF8A2DE1~|r|cFF822AD2没|r|cFF7B27C3有|r|cFF7323B4收|r|cFF6B20A6获|r|cFF641D97~|r|cFF5C1A88~|r"
          },
          {
            time = 31,
            text = "|cFF9933FF如|r|cFF9330F3果|r|cFF8C2EE6~|r|cFF862BDA~|r|cFF8029CD和|r|cFF7926C1少|r|cFF7323B5主|r|cFF6D21A8聊|r|cFF661E9C聊|r|cFF601C8F~|r|cFF5A1983~|r"
          },
          {
            time = 37,
            text = "|cFF9933FF也|r|cFF9130F0许|r|cFF8A2DE1能|r|cFF822AD2找|r|cFF7B27C3到|r|cFF7323B4灵|r|cFF6B20A6感|r|cFF641D97~|r|cFF5C1A88~|r"
          },
          {
            time = 41,
            text = "|cFF9933FF啊|r|cFF9330F3~|r|cFF8C2EE6~|r|cFF862BDA如|r|cFF8029CD果|r|cFF7926C1您|r|cFF7323B5不|r|cFF6D21A8方|r|cFF661E9C便|r|cFF601C8F~|r|cFF5A1983~|r"
          },
          {
            time = 43,
            text = "|cFF9933FF也|r|cFF9431F5可|r|cFF8F2FEB以|r|cFF8A2DE1~|r|cFF852BD7~|r|cFF8029CD当|r|cFF7B27C3我|r|cFF7625B9的|r|cFF7022B0实|r|cFF6B20A6验|r|cFF661E9C对|r|cFF611C92象|r|cFF5C1A88~|r|cFF57187E~|r"
          },
          {
            time = 50,
            text = "|cFF9933FF怎|r|cFF8E2FEA么|r|cFF832AD4样|r|cFF7826BF~|r|cFF6E21AA~|r|cFF631D95?|r"
          }
        }
      })
      install_seven_shadow_base(u, var.name)
    end,
    effectname = "|cFF7A243D伊|r|cFFE7A6B8塔|r",
    effecttext = "|cFFB38CFF[暗影庭院]|r\n|cFFE7A6B8【阴之睿智】|r\n|cFFE7A6B8【超一流的科学领域天才】|r\n|cFFE7A6B8【暗影庭院】|r\n|cFFF6D9E1暗影庭园“七影”的第七座。负责研究的精灵。\n技术出色，作为建筑师也非常优秀，但因为我行我素，\n所以一睡就很难起床，睡相也很差，睡相会滚滚而来。|r",
    effectart = "Anying_Cq_Yita.tga"
  }
}
Vars_Ciyuan_AnyingExtra = {
  {
    name = "灾厄魔女 奥萝拉",
    weight = 300,
    lv = 3,
    key = {
      "影",
      "魔导",
      "黑暗"
    },
    unique = true,
    condition = function(u)
      return u:hasdata("暗影-初始") and u:getdata("暗影计数") >= 7 and u:hasdata("暗影-史莱姆剑一阶")
    end,
    effect = function(u, var)
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ay_Aoluola)
      NPCChat({
        name = "|cFFCC00FF奥|r|cFFC700FA萝|r|cFFC200F5拉|r",
        chaticon = "Chat_Ay_All.tga",
        chattext = {
          {
            time = 1,
            text = "|cFFB900EB虽|r|cFFB400E6然|r|cFFAF00E1想|r|cFFAA00DB象|r|cFFA500D6自|r|cFFA000D1己|r|cFF9C00CC变|r|cFF9700C7成|r|cFF9200C2最|r|cFF8D00BD糟|r|cFF8800B8糕|r|cFF8300B3的|r|cFF7F00AE魔|r|cFF7A00A9女|r|cFF7500A4这|r|cFF70009E件|r|cFF6B0099事|r|cFF660094很|r|cFF62008F可|r|cFF5D008A悲|r"
          },
          {
            time = 10,
            text = "|cFFA900DB但|r|cFFA100D2这|r|cFF9800C9真|r|cFF9000BF的|r|cFF8700B6很|r|cFF7E00AD有|r|cFF7600A4意|r|cFF6D009B思|r|cFF640092的|r"
          },
          {
            time = 14,
            text = "|cFFB100E3稍|r|cFFAA00DC微|r|cFFA400D5跑|r|cFF9D00CE一|r|cFF9600C7跑|r|cFF8F00C0，|r|cFF8900B8做|r|cFF8200B1个|r|cFF7B00AA热|r|cFF7500A3身|r|cFF6E009C运|r|cFF670095动|r|cFF60008E吧|r"
          },
          {
            time = 20,
            text = "|cFFB700E9被|r|cFFB200E3骑|r|cFFAC00DE士|r|cFFA700D8大|r|cFFA200D3人|r|cFF9D00CD守|r|cFF9700C8护|r|cFF9200C2着|r|cFF8D00BD的|r|cFF8800B7感|r|cFF8200B2觉|r|cFF7D00AC，|r|cFF7800A7真|r|cFF7300A1的|r|cFF6D009C好|r|cFF680096舒|r|cFF630091服|r|cFF5E008B啊|r"
          },
          {
            time = 28,
            text = "|cFFB800EA就|r|cFFB300E5算|r|cFFAE00DF我|r|cFFA900DA消|r|cFFA400D5失|r|cFF9F00CF了|r|cFF9A00CA，|r|cFF9500C5也|r|cFF9000C0想|r|cFF8A00BA永|r|cFF8500B5远|r|cFF8000B0记|r|cFF7B00AA住|r|cFF7600A5今|r|cFF7100A0天|r|cFF6C009A这|r|cFF670095份|r|cFF620090心|r|cFF5D008B情|r"
          }
        }
      })
      ChangeZhanzhengqiyue(1)
      ac.loop(600000, function()
        u:changedata("暗影计数", 1)
      end)
      shadow_refresh_data(u, "奥萝拉-全属性增幅", function()
        return (u:getdata("暗影计数") + (Count_Zhanzhengqiyue or 0)) * 0.01
      end, nil, "全属性增幅")
      u:addstexiao("暗影奥萝拉-月夜受伤回魔", "受伤后效果", function()
        if not u:hasdata("奥萝拉-月夜受伤回魔冷却") then
          u:settimedata("奥萝拉-月夜受伤回魔冷却", 0.1)
          u:changedata("魔力值", u:getdata("暗影计数") / 4)
        end
      end)
      u:addstexiao("暗影奥萝拉-月夜伤害回魔", "直接伤害特效", function()
        if not u:hasdata("奥萝拉-月夜伤害回魔冷却") then
          u:settimedata("奥萝拉-月夜伤害回魔冷却", 0.1)
          u:changedata("魔力值", u:getdata("暗影计数") / 3)
        end
      end)
      refresh_shadow_pair_unlocks(u)
    end,
    effectname = "|cFF8F70A8灾厄魔女 奥萝拉|r",
    effecttext = "|cFF8F70A8【灾厄魔女】\n【月夜摇曳】\n【封印之链】\n曾经给世界带来混乱和破坏的最强女性。\n但那究竟是真实的混乱和破坏，至今还不清楚。\n在与强大相称的“女神的试炼”中，被暗影召唤成功。|r",
    effectart = "Anying_Cq_Aoluola.tga"
  },
  {
    name = "噬血女王 伊丽莎白",
    weight = 300,
    lv = 3,
    key = {
      "影",
      "黑暗",
      "吸血鬼"
    },
    unique = true,
    condition = function(u)
      return u:hasdata("暗影-初始") and u:getdata("暗影计数") >= 7 and u:hasdata("暗影-史莱姆剑一阶")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ay_Yilishabai)
      NPCChat({
        name = "|cFFFF0000伊|r|cFFF70102丽|r|cFFEF0104莎|r|cFFE70205白|r",
        chaticon = "Chat_Ay_Ylsb.tga",
        chattext = {
          {
            time = 1,
            text = "|cFFD60309我|r|cFFCE040B也|r|cFFC6040D不|r|cFFBE050E奢|r|cFFB60610求|r|cFFAE0612什|r|cFFA60714么|r|cFF9E0816救|r|cFF950818赎|r|cFF8D0919了|r"
          },
          {
            time = 4,
            text = "|cFFDE0406为|r|cFFD80407了|r|cFFD10508不|r|cFFCB0609重|r|cFFC4070A蹈|r|cFFBD080C覆|r|cFFB7080D辙|r|cFFB0090E，|r|cFFAA0A0F请|r|cFFA30A10就|r|cFF9D0B11此|r|cFF960C12离|r|cFF900D14开|r|cFF890E15吧|r"
          },
          {
            time = 12,
            text = "|cFFAD090E逃|r|cFF9D0B11吧|r"
          },
          {
            time = 16,
            text = "|cFFE10305趁|r|cFFDB0406你|r|cFFD50507还|r|cFFCF0508没|r|cFFC90609对|r|cFFC3070A喜|r|cFFBD070B欢|r|cFFB8080D的|r|cFFB2090E人|r|cFFAC0A0F，|r|cFFA60A10犯|r|cFFA00B11下|r|cFF9A0C12新|r|cFF940C13的|r|cFF8E0D14过|r|cFF880E15错|r"
          },
          {
            time = 20,
            text = "|cFFE90204人|r|cFFE50305类|r|cFFE00405与|r|cFFDC0406吸|r|cFFD80407血|r|cFFD30508鬼|r|cFFCF0608之|r|cFFCB0609间|r|cFFC6060A，|r|cFFC2070B那|r|cFFBD080C片|r|cFFB9080C能|r|cFFB5080D让|r|cFFB0090E我|r|cFFAC0A0F们|r|cFFA80A0F偶|r|cFFA30A10尔|r|cFF9F0B11共|r|cFF9B0C12存|r|cFF960C12的|r|cFF920C13安|r|cFF8D0D14息|r|cFF890E15之|r|cFF850E15地|r"
          },
          {
            time = 26,
            text = "|cFFD80407我|r|cFFD10508虽|r|cFFC90609然|r|cFFC1070B不|r|cFFBA080C知|r|cFFB2090E它|r|cFFAA0A0F究|r|cFFA30B10竟|r|cFF9B0B12在|r|cFF930C13何|r|cFF8B0D14方|r"
          },
          {
            time = 29,
            text = "|cFFDD0406但|r|cFFD60507总|r|cFFCF0608有|r|cFFC8060A一|r|cFFC1070B天|r|cFFBA080C，|r|cFFB3090D我|r|cFFAC090F会|r|cFFA50A10抵|r|cFF9E0B11达|r|cFF980C12那|r|cFF910D13里|r|cFF8A0D15的|r"
          }
        }
      })
      ChangeZhanzhengqiyue(1)
      u:addstexiao("暗影伊丽莎白-血镰格挡", "伤害格挡效果", function(args)
        local source = args.tg
        local key = "伊丽莎白-血镰已格挡-" .. sy
        if source ~= 0 and not args.b and not source:hasdata(key) then
          source:setdata(key)
          args.b = true
        end
      end)
      u:addstexiao("暗影伊丽莎白-血镰破甲", "直接伤害特效", function(args)
        local tg = args.tg
        local key = "伊丽莎白-血镰护甲削减-" .. sy
        local old = tg:getdata(key)
        tg:changearmor(old)
        local add = u:getdata("暗影计数") * 5
        tg:setdata(key, add)
        tg:changearmor(-add)
      end)
      u:addstexiao("暗影伊丽莎白-始祖击杀成长", "杀敌效果", function(args)
        ChangeValue(Correction_Jzsh, sy, 1.0E-4)
        ChangeValue(Correction_Magic, sy, 1.0E-4)
        local add = 1
        if args.mon:isboss() then
          add = 100
        elseif args.mon:iselite() then
          add = 10
        end
        u:changedata("魔力值", u:getdata("暗影计数") * add)
      end)
      refresh_shadow_pair_unlocks(u)
    end,
    effectname = "|cFFCC3366噬血女王 伊丽莎白|r",
    effecttext = "|cFFCC3366【血の女王の镰】\n【始祖吸血鬼】\n【血腥女王】\n吸血鬼的始祖，绰号「噬血女王」。\n传闻千年前毁灭多国后被消灭，其部下克里姆森计划在无法都市「深红之塔」复活她。|r",
    effectart = "Anying_Cq_Yilishabai.tga"
  },
  {
    name = "最初の三英雄",
    weight = 300,
    lv = 3,
    key = {
      "影",
      "战士",
      "兽",
      "光明"
    },
    unique = true,
    condition = function(u)
      return u:hasdata("暗影-初始") and u:getdata("暗影计数") >= 7 and u:hasdata("暗影-史莱姆剑一阶")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ay_Sanyingxiong)
      NPCChat({
        name = "|cFFFFFF00奥莉薇|r",
        chaticon = "Chat_Ay_Syx.tga",
        chattext = {
          {
            time = 1,
            text = "|cFFFFFF00这里是玻利维亚，我不知道未来它会被如何称呼|r"
          },
          {
            time = 5,
            text = "|cFFFFFF00但我能做的，只有让吸血鬼的种群不再壮大|r"
          },
          {
            time = 9,
            text = "|cFFFFFF00别碍事！|r"
          }
        }
      })
      NPCChat({
        name = "|cFFFF9933莉莉|r",
        chaticon = "Chat_Ay_Syx.tga",
        chattext = {
          {
            time = 11,
            text = "|cFFFF9933让我们战斗吧，如果我们不战斗|r"
          },
          {
            time = 15,
            text = "|cFFFF9933受害会越来越严重。我们要保护大家|r"
          }
        }
      })
      NPCChat({
        name = "|cFF999999芙蕾雅|r",
        chaticon = "Chat_Ay_Syx.tga",
        chattext = {
          {
            time = 19,
            text = "|cFF999999就在今天，为这场战争画上句号家|r"
          },
          {
            time = 22,
            text = "|cFF999999我绝不会任由吸血鬼为所欲为！|r"
          }
        }
      })
      ChangeZhanzhengqiyue(1)
      shadow_refresh(u, "最初三英雄-固定伤害", function()
        return u:getdata("魔力值") * 5
      end, function(add)
        u:changedata("固定伤害", add)
      end)
      shadow_refresh(u, "最初三英雄-终结伤害", function()
        return (Count_Zhanzhengqiyue or 0) * 0.01
      end, function(add)
        ChangeValue(DamageSystem_EndSh, sy, add)
      end)
      
      local function activate_death_refusal()
        if u:hasdata("最初三英雄-死亡抗拒冷却") then
          return false
        end
        u:settimedata("最初三英雄-死亡抗拒冷却", 300)
        u:settimedata("最初三英雄-死亡抗拒生效", 5)
        u:curehp(u.handle, 0, 50, 2)
        return true
      end
      
      u:addstexiao("最初三英雄-奥莉薇决死", "决死效果", function(args)
        if not args.dt then
          return
        end
        if u:hasdata("最初三英雄-死亡抗拒生效") or activate_death_refusal() then
          args.dt = false
        end
      end)
      u:addstexiao("最初三英雄-奥莉薇低血", "受伤后效果", function()
        if u:isalive() and u:getperhp() <= 20 then
          activate_death_refusal()
        end
      end)
      u:addstexiao("最初三英雄-奥莉薇等额附伤", "直接伤害特效", function(args)
        if u:hasdata("最初三英雄-奥莉薇等额附伤冷却") then
          return
        end
        u:settimedata("最初三英雄-奥莉薇等额附伤冷却", 1)
        shadow_damage(u, args.tg, args.damageinfo.yssh, "最初三英雄-奥莉薇等额附伤")
      end)
      ac.loop(40000, function()
        u:curehp(u.handle, 0, u:getdata("暗影计数") * 2, 2)
        ChangeValue(DamageSystem_Shjc, sy, 0.5)
        ac.wait(20000, function()
          ChangeValue(DamageSystem_Shjc, sy, -0.5)
        end)
      end)
      u:setdata("最初三英雄-消耗品回魔")
    end,
    effectname = "|cFFFFCC66最初の三英雄|r",
    effecttext = "|cFFFFCC66【芙蕾雅】\n【奥莉薇】\n【莉莉】\n奥莉薇拥有超越常理的战斗能力，莉莉拥有凌驾于人类智慧的恢复能力。\n芙蕾雅明明没有一眼就能看出的特殊能力，却做得如此出色，\n仿佛不用亲眼看到战场，就能掌握一切。|r",
    effectart = "Anying_Cq_Zuichudesanyingxiong.tga"
  }
}
for _, var in ipairs(Vars_Ciyuan_AnyingExtra) do
  table.insert(Vars_Huiyi_Dz, var)
end
for _, var in ipairs(Vars_Ciyuan_Qiying) do
  table.insert(Vars_Huiyi_Dz, var)
end
