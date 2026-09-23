-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
require("gameplay.var.medicine.constants")
local Crafting = require("gameplay.feature.item.crafting")

local function add_recipe(id, output, ingredients, options)
  options = options or {}
  options.output = output
  options.ingredients = ingredients
  Crafting.add(id, options)
end

local function bullet_output_count(count)
  return function(context)
    if context.hero:hasdata("白洲梓-战略整装") then
      return math.floor(count * 1.25)
    end
    return count
  end
end

local function mark_ammunition(_, item)
  SetData(item, "不可回收")
end

add_recipe("bullet_bernoulli_explosive", Bullets["爆裂弹"], {
  {
    item = Bullets["伯奈利军弹"],
    count = 15
  },
  {item = "I009", count = 1}
}, {
  output_count = bullet_output_count(15),
  on_success = mark_ammunition
})
add_recipe("bullet_bernoulli_dum", Bullets["达姆弹-黑牙"], {
  {
    item = Bullets["伯奈利军弹"],
    count = 25
  },
  {item = "I07D", count = 1}
}, {
  output_count = bullet_output_count(25),
  on_success = mark_ammunition
})
add_recipe("bullet_heike_chlorophyte", Bullets["叶绿弹"], {
  {
    item = Bullets["黑科弹"],
    count = 100
  },
  {item = "I02F", count = 1}
}, {
  output_count = bullet_output_count(100),
  on_success = mark_ammunition
})
add_recipe("bullet_heike2_mechanical", Bullets["机巧弹"], {
  {
    item = Bullets["黑科弹-II"],
    count = 300
  },
  {item = "I09T", count = 1}
}, {
  output_count = bullet_output_count(300),
  on_success = mark_ammunition
})
add_recipe("bullet_heike2_tana", Bullets["塔纳活性能量弹"], {
  {
    item = Bullets["黑科弹-II"],
    count = 100
  },
  {item = "I00J", count = 1}
}, {
  output_count = bullet_output_count(100),
  on_success = mark_ammunition
})
add_recipe("bullet_walter_crystal", Bullets["水晶弹"], {
  {
    item = Bullets["瓦尔特弹"],
    count = 140
  },
  {item = "I08C", count = 1}
}, {
  output_count = bullet_output_count(140),
  on_success = mark_ammunition
})
add_recipe("bullet_walter_spiral", Bullets["螺旋塔弹"], {
  {
    item = Bullets["瓦尔特弹"],
    count = 280
  },
  {item = "I0DK", count = 1}
}, {
  output_count = bullet_output_count(280),
  on_success = mark_ammunition
})
add_recipe("bullet_penetrating_decay", Bullets["腐朽弹"], {
  {
    item = Bullets["贯彻弹"],
    count = 25
  },
  {item = "I07D", count = 1}
}, {
  output_count = bullet_output_count(25),
  on_success = mark_ammunition
})
add_recipe("bullet_penetrating_annihilation", Bullets["湮灭-P1"], {
  {
    item = Bullets["贯彻弹"],
    count = 25
  },
  {item = "I02V", count = 1}
}, {
  output_count = bullet_output_count(25),
  on_success = mark_ammunition
})
add_recipe("glimmer_conversion_aether", MEDICINE_YITAI_JJ, {
  {
    item = MEDICINE_YITAI,
    count = 1
  }
})
add_recipe("glimmer_conversion_blood", MEDICINE_BLOOD_TC, {
  {
    item = MEDICINE_BLOOD,
    count = 1
  }
})
add_recipe("glimmer_conversion_memory", MEDICINE_MWX, {
  {
    item = MEDICINE_HUIYI,
    count = 1
  }
})
add_recipe("bone_bundle", "I0HK", {
  {item = "I0HJ", count = 1}
}, {output_count = 3})
add_recipe("blood_decay_medicine", "I01Q", {
  {item = "I011", count = 4},
  {item = "I030", count = 4}
}, {
  text = "|cFF530080왜 이런 짓을 하는 걸까?|r"
})
add_recipe("witch_journey", "I0B9", {
  {item = "I030", count = 1},
  {item = "I02H", count = 1},
  {item = "I02F", count = 1},
  {item = "I09D", count = 1}
}, {
  text = "|cFF949596그래, 바로 나야.|r",
  visible = function(context)
    return context.hero:hasdata("判定-伊蕾娜")
  end
})
add_recipe("spirit_crystal", "I0GT", {
  {item = "I0A2", count = 1},
  {item = "I0A3", count = 1},
  {item = "I0GW", count = 1},
  {item = "I07D", count = 1},
  {item = "I08C", count = 1},
  {item = "I09D", count = 1}
})
add_recipe("invitation_brandz", "I0I4", {
  {item = "I0A0", count = 1},
  {item = "I0GW", count = 3}
})
add_recipe("invitation_stier", "I0I6", {
  {item = "I0A0", count = 1},
  {item = "I07D", count = 3}
})
add_recipe("invitation_vibo", "I0I5", {
  {item = "I0A0", count = 1},
  {item = "I0A3", count = 3}
})
add_recipe("invitation_ogros", "I0I3", {
  {item = "I0A0", count = 1},
  {item = "I0A2", count = 3}
})
add_recipe("medicine_aether", "I02F", {
  {item = "I0I1", count = 1},
  {item = "I0A2", count = 2}
}, {chance = 100})
add_recipe("medicine_pluto", "I02H", {
  {
    item = Materials["水"],
    count = 1
  },
  {
    item = Materials["紫阳花"],
    count = 2
  }
}, {chance = 100})
add_recipe("medicine_lunas_spring", "I02E", {
  {item = "I0I1", count = 2},
  {item = "I08C", count = 2}
}, {chance = 100})
add_recipe("mind_cube", "I097", {
  {item = "I08C", count = 4},
  {item = "I030", count = 1},
  {item = "I00J", count = 1}
})
add_recipe("water_star", "I098", {
  {item = "I08C", count = 5},
  {item = "I097", count = 2}
})
add_recipe("phantom_sea_crystal", "I08E", {
  {item = "I08C", count = 10},
  {item = "I035", count = 1}
}, {
  text = "|cFF66CCFF해정의 힘이 약제의 광폭화 인자를 중화했다.|r"
})
add_recipe("yangjian_liar_ghost", "I0Q3", {
  {item = "I08C", count = 2},
  {item = "I02E", count = 1},
  {item = "I071", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("变异判定-杨间") and not context.hero:hasdata("杨间-骗人鬼") and not context.hero:ishasitem("I0Q3") and not context.backpack:ishasitem("I0Q3")
  end
})
add_recipe("yangjian_ghost_child", "I0Q4", {
  {item = "I08C", count = 2},
  {item = "I011", count = 1},
  {item = "I071", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("变异判定-杨间") and not context.hero:hasdata("杨间-鬼童") and not context.hero:ishasitem("I0Q4") and not context.backpack:ishasitem("I0Q4")
  end
})
add_recipe("reimu_disaster", "I0KJ", {
  {item = "I09P", count = 1},
  {item = "I030", count = 2},
  {item = "I011", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-祸灵梦")
  end
})
add_recipe("twilight_armor", "I0KL", {
  {item = "I02F", count = 1},
  {item = "I02H", count = 1},
  {item = "I02E", count = 1},
  {item = "I030", count = 2},
  {item = "I0A2", count = 1},
  {item = "I0HS", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-薄暝") and not context.hero:hasdata("薄暝-甲已获取")
  end,
  on_success = function(context)
    context.hero:setdata("薄暝-甲已获取")
  end
})
add_recipe("old_man_relic", "I0LQ", {
  {item = "I0HN", count = 1},
  {item = "I09D", count = 1},
  {item = "I0I1", count = 1},
  {item = "I0GW", count = 1},
  {item = "I030", count = 1},
  {item = "I0A2", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-老男人")
  end
})
add_recipe("fangnai_dessert", "I0JZ", {
  {item = "I08X", count = 1},
  {item = "I059", count = 1},
  {item = "I0AH", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-朝武芳乃") and context.hero:getdata("朝武芳乃-Cia次数") >= 10
  end,
  on_success = function(context)
    if not context.hero:hasdata("朝武芳乃-合成语音") then
      context.hero:setdata("朝武芳乃-合成语音")
      PlayGlobalSound(Sound_Fangnai_03)
      SendMsgAll("|cFFFF99FF『|r|cFFFFA0FC料|r|cFFFFA7F8理|r|cFFFFADF5不|r|cFFFFB4F1放|r|cFFFFBBEE糖|r|cFFFFC2EB的|r|cFFFFC9E7都|r|cFFFFCFE4是|r|cFFFFD6E0邪|r|cFFFFDDDD道|r|cFFFFE4DA！|r|cFFFFEBD6！|r|cFFFFF1D3』|r")
    end
  end
})
add_recipe("fool_path_final", "I0L9", {
  {item = "I0L8", count = 1},
  {item = "I01Q", count = 1},
  {item = "I05G", count = 1},
  {item = "I035", count = 1},
  {item = "I02H", count = 3}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-愚者")
  end
})
add_recipe("fool_path_middle", "I0L8", {
  {item = "I0L7", count = 1},
  {item = "I030", count = 1},
  {item = "I0GW", count = 1},
  {item = "I0A2", count = 1},
  {item = "I09P", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-愚者")
  end
})
add_recipe("fool_path_start", "I0L7", {
  {item = "I02H", count = 2},
  {item = "I030", count = 1},
  {item = "I0A3", count = 1},
  {item = "I09D", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-愚者")
  end
})
add_recipe("fool_profane_card", "I0LC", {
  {item = "I01Q", count = 1},
  {item = "I09X", count = 1},
  {item = "I0A2", count = 1},
  {item = "I09D", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-愚者") and not context.hero:hasdata("愚者-亵渎之牌已合成")
  end,
  on_success = function(context)
    context.hero:setdata("愚者-亵渎之牌已合成")
  end
})
add_recipe("wonderland_mana_potion", "I0KB", {
  {item = "I09D", count = 1},
  {item = "I00J", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("变异判定-梦游仙境")
  end
})
add_recipe("evil_energy_potion", "I0IP", {
  {item = "I0IO", count = 1},
  {
    item = MEDICINE_MWX,
    count = 2
  }
}, {
  output_to = "hero",
  visible = function(context)
    return context.hero:hasdata("变异判定-雨宫莲")
  end
})
add_recipe("nahida_transmutation", "I0JA", {
  {item = "I0A2", count = 2},
  {
    items = {
      Materials["永远结冰"],
      Materials["火灵草"],
      Materials["海晶体"],
      Materials["紫阳花"]
    },
    count = 2
  }
}, {
  output_to = "hero",
  visible = function(context)
    return context.hero:hasdata("判定-纳西妲")
  end
})
local miracle_mallet_crafted = false

local function on_scarlet_life_flower(context)
  SendMsgAll("|cFF990000将一切吞噬殆尽的生之花|r")
  ac.wait(2000, function()
    SendMsgAll("|cFF990000凌乱地随风飘散....|r")
  end)
  context.hero:effectadd("war3mapImported\\27.mdx", "origin", -1)
end

local function on_origami_phoenix()
  PlayGlobalSound(Sound_Chun_32)
  DayNightRun = false
  local yxsj = GetTimeOfDay()
  SetTimeOfDay(12)
  SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
  CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.5, "war3mapImported\\Chun_Hd_1.tga", 100.0, 100.0, 100.0, 0)
  ac.wait(2001, function()
    CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1, "war3mapImported\\Chun_Hd_1.tga", 100.0, 100.0, 100.0, 0)
    ac.wait(1000, function()
      SetTimeOfDay(yxsj)
      DayNightRun = true
    end)
  end)
  ac.wait(900, function()
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『前进的道路就在眼前 现在只要朝前走就行了』|r", 30)
  end)
  ac.wait(7600, function()
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『不知道选择，前进的道路是否正确』|r", 30)
  end)
  ac.wait(13800, function()
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『虽然不知道 但是我已经不是一个人了』|r", 30)
  end)
  ac.wait(20300, function()
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『有人为我加油，有人支撑着我，有人爱着我.....』|r", 30)
  end)
  ac.wait(29400, function()
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『不管几次，我都会复苏，用这巨大的翅膀飞翔于空』|r", 30)
  end)
  ac.wait(34600, function()
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『和你一起点亮胸中的爱之火焰，钢之翼，浴火鸟一起飞向远方......』|r", 30)
  end)
  ac.wait(45900, function()
    DayNightRun = false
    yxsj = GetTimeOfDay()
    SetTimeOfDay(12)
    SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
    CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.5, "war3mapImported\\Chun_Hd_2.tga", 100.0, 100.0, 100.0, 0)
    ac.wait(2001, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1, "war3mapImported\\Chun_Hd_2.tga", 100.0, 100.0, 100.0, 0)
      ac.wait(1000, function()
        SetTimeOfDay(yxsj)
        DayNightRun = true
      end)
    end)
  end)
  ac.wait(47200, function()
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『那就是我选择的道路......我的刃道』|r", 30)
  end)
end

add_recipe("itemget_oshino_deluxe_donut", "I0GM", {
  {item = "I0AH", count = 3},
  {item = "I0GL", count = 2},
  {item = "I011", count = 2}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-忍野忍")
  end
})
add_recipe("itemget_oshino_donut", "I0GL", {
  {item = "I030", count = 1},
  {item = "I02F", count = 1},
  {item = "I08X", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-忍野忍")
  end
})
add_recipe("itemget_alice_special_fruit_wine", "I0GI", {
  {item = "I035", count = 1},
  {item = "I011", count = 3},
  {item = "I08X", count = 5},
  {item = "I033", count = 3}
}, {
  visible = function(context)
    return context.hero:hasdata("爱丽丝-任务开始")
  end
})
add_recipe("itemget_baibai_pure_white_flower", "I0JS", {
  {item = "I011", count = 3},
  {item = "I030", count = 3},
  {item = "I02E", count = 1},
  {item = "I07D", count = 5}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-百百")
  end
})
add_recipe("itemget_angela_invitation", "I0JV", {
  {item = "I036", count = 1},
  {item = "I0A2", count = 3}
}, {
  visible = function(context)
    return context.hero:hasdata("变异判定-安吉拉")
  end
})
add_recipe("itemget_destiny_medicine", "I0G4", {
  {item = "I0FY", count = 2},
  {item = "I0FX", count = 2},
  {item = "I0FZ", count = 2}
}, {
  visible = function(context)
    return context.hero:hasdata("变异判定-克萝蒂亚")
  end
})
add_recipe("itemget_disaster_medicine", "I0G3", {
  {item = "I0G2", count = 2},
  {item = "I0G1", count = 2},
  {item = "I0G0", count = 2}
}, {
  visible = function(context)
    return context.hero:hasdata("变异判定-克萝蒂亚")
  end
})
add_recipe("itemget_twisted_medicine", "I0DK", {
  {item = "I072", count = 1},
  {item = "I071", count = 1},
  {item = "I00J", count = 1}
})
add_recipe("itemget_blank_mask", "I06I", {
  {item = "I030", count = 1},
  {item = "I035", count = 2},
  {item = "I02E", count = 1},
  {item = "I02H", count = 1},
  {item = "I02F", count = 1}
}, {
  text = "|cFF7DBEF1조금 이상한데……?|r",
  visible = function(context)
    return context.hero.type == HeroType["秦心"] or context.hero:hasdata("判定-面灵气")
  end
})
add_recipe("itemget_forbidden_blood", "I07H", {
  {item = "I01Q", count = 1},
  {item = "I035", count = 1},
  {item = "I02E", count = 1},
  {item = "I011", count = 1},
  {item = "I02F", count = 1}
}, {
  text = "|cFFFF0000비룡들이 그 명에 따라 달리니, 전설의 서막이 열린다.|r"
})
add_recipe("itemget_rimuru_magic_essence", "I08P", {
  {item = "I036", count = 1},
  {item = "I035", count = 1},
  {item = "I030", count = 5},
  {item = "I011", count = 3}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-利姆露")
  end
})
add_recipe("itemget_holo_old_memory", "I0AJ", {
  {item = "I030", count = 2},
  {item = "I011", count = 3},
  {item = "I0AH", count = 5},
  {item = "I0AG", count = 3},
  {item = "I0AF", count = 1},
  {item = "I036", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("变异判定-赫萝神化")
  end
})
add_recipe("itemget_little_swan_fish_and_chips", "I05A", {
  {item = "I059", count = 5},
  {item = "I097", count = 2}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-小天鹅") and not Weiyi_Dz[3]
  end
})
add_recipe("itemget_miracle_mallet", "I07I", {
  {item = "I01A", count = 7}
}, {
  visible = function(context)
    return not miracle_mallet_crafted and (context.hero:hasdata("变异判定-少名针妙丸") or context.hero:hasdata("变异判定-小人族"))
  end,
  on_success = function(context)
    miracle_mallet_crafted = true
    context.hero:sendmessage("|cFFFF3399너희를 납작하게 만들어 줄 시간이야.|r")
  end
})
add_recipe("itemget_remilia_destiny", "I048", {
  {item = "I030", count = 3},
  {item = "I011", count = 3},
  {item = "I02H", count = 3},
  {item = "I09D", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-蕾米莉亚")
  end
})
add_recipe("itemget_captain_starlight", "I0EG", {
  {item = "I030", count = 2},
  {item = "I036", count = 1},
  {item = "I01Q", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-队长")
  end
})
add_recipe("itemget_scarlet_life_flower", "I024", {
  {item = "I00Z", count = 1},
  {item = "I010", count = 1},
  {item = "I01L", count = 1},
  {item = "I01M", count = 1},
  {item = "I00Y", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-红魔城之力")
  end,
  on_success = on_scarlet_life_flower
})
add_recipe("itemget_nahida_floating_dream", "I0JI", {
  {item = "I0JE", count = 1},
  {item = "I0JD", count = 1},
  {item = "I0JG", count = 1},
  {item = "I0JF", count = 1},
  {item = "I0JH", count = 1}
}, {
  visible = function(context)
    return context.hero:hasdata("判定-纳西妲")
  end
})
add_recipe("itemget_night_sky_book", "I0C8", {
  {item = "I052", count = 1},
  {item = "I053", count = 1},
  {item = "I054", count = 1},
  {item = "I051", count = 1},
  {item = "I050", count = 1}
}, {
  listed = false,
  visible = function(context)
    return context.hero:hasdata("变异判定-暗之书")
  end
})
add_recipe("itemget_starry_tears_book", "I04K", {
  {item = "I04J", count = 1},
  {item = "I04I", count = 1}
}, {listed = false})
add_recipe("itemget_melon_ice_cream", "I0PQ", {
  {item = "I0PO", count = 1},
  {item = "I0PP", count = 1}
}, {listed = false})
add_recipe("itemget_scarlet_secret", "I047", {
  {item = "I042", count = 1},
  {item = "I044", count = 1},
  {item = "I045", count = 1},
  {item = "I046", count = 1},
  {item = "I043", count = 1}
}, {listed = false})
add_recipe("itemget_witch_brooch", "I0BD", {
  {item = "I0BA", count = 1},
  {item = "I0BB", count = 1},
  {item = "I0BC", count = 1}
}, {listed = false})
add_recipe("itemget_quantum_machine_sword", "I0C4", {
  {item = "I05X", count = 1},
  {item = "I02V", count = 1}
})
add_recipe("itemget_origami_phoenix", "I0BV", {
  {item = "I0BW", count = 1},
  {item = "I030", count = 3},
  {item = "I033", count = 1},
  {item = "I02F", count = 3},
  {item = "I035", count = 1}
}, {
  text = "|cFFFF6699불꽃 속에서 다시 태어난 새|r",
  visible = function(context)
    return context.hero:hasdata("变异判定-朱雀院椿")
  end,
  on_success = on_origami_phoenix
})
return Crafting
