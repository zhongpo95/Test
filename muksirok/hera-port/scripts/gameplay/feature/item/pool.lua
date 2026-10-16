-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
Pools_Basic = {
  {
    name = "医疗",
    weight = 100,
    itemtype = "I0N6"
  },
  {
    name = "资源",
    weight = 100,
    itemtype = "I0N7"
  }
}
Pools_Bjx_Buji = {
  {
    name = "手榴弹",
    weight = 50,
    itemtype = "I009"
  },
  {
    name = "燃烧弹",
    weight = 50,
    itemtype = "I00N"
  },
  {
    name = "弹药",
    weight = 100,
    itemtype = "I0N5"
  }
}
Pools_Bjx_Yiliao = {
  {
    name = "医疗包",
    weight = 100,
    itemtype = "I00C"
  },
  {
    name = "止痛药",
    weight = 100,
    itemtype = "I00L"
  },
  {
    name = "净化药剂",
    weight = 40,
    itemtype = "I00J"
  }
}
Pools_Resource = {
  {
    name = "撬锁工具",
    weight = 50,
    itemtype = "I0MH"
  },
  {
    name = "钥匙包",
    weight = 50,
    itemtype = "I0MS"
  },
  {
    name = "炸鱼薯条",
    weight = 100,
    itemtype = "I059"
  },
  {
    name = "咖啡",
    weight = 100,
    itemtype = "I05G"
  },
  {
    name = "麻婆豆腐",
    weight = 100,
    itemtype = "I02G"
  },
  {
    name = "糖果",
    weight = 100,
    itemtype = "I08X"
  },
  {
    name = "脆脆鲨",
    weight = 75,
    itemtype = "I0BX"
  },
  {
    name = "牛奶",
    weight = 75,
    itemtype = "I037"
  },
  {
    name = "封魔壶",
    weight = 75,
    itemtype = "I071"
  },
  {
    name = "镇妖壶",
    weight = 75,
    itemtype = "I072"
  },
  {
    name = "清酒",
    weight = 75,
    itemtype = "I019"
  },
  {
    name = "啤酒",
    weight = 75,
    itemtype = "I034"
  },
  {
    name = "血腥玛丽",
    weight = 50,
    itemtype = "I033"
  },
  {
    name = "红酒",
    weight = 50,
    itemtype = "I032"
  },
  {
    name = "魔君兴奋剂",
    weight = 25,
    itemtype = "I035"
  },
  {
    name = "星辉注射剂",
    weight = 5,
    itemtype = "I036"
  },
  {
    name = "天人仙桃",
    weight = 5,
    itemtype = "I0C2"
  },
  {
    name = "蓬莱仙药",
    weight = 5,
    itemtype = "I04F"
  },
  {
    name = "万宝槌",
    weight = 25,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("变异判定-少名针妙丸") then
        add = add + weight * 0.5
      end
      if u:ishasitem("I06Z") then
        add = add + weight * 0.5
      end
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("变异判定-小人族") or u:hasdata("最强的两人-天子") then
        b = true
      end
      return b
    end,
    itemtype = "I01A"
  }
}
Pools_Boxs = {
  {
    name = "近战武器",
    weight = 50,
    itemtype = "I0ND"
  },
  {
    name = "模组",
    weight = 25,
    itemtype = "I0EA"
  },
  {
    name = "自适应军火箱池",
    weight = 100,
    itemtype = "I0NE"
  },
  {
    name = "魔弹",
    weight = 0.1,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("判定-安吉拉") then
        add = add + 1
      end
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0J3"
  }
}
Pools_Junhuo_Fjz = {
  {
    name = "模块",
    weight = 40,
    itemtype = "I0EB"
  },
  {
    name = "普通枪械",
    weight = 40,
    itemtype = "I0E8"
  },
  {
    name = "特殊枪械",
    weight = 10,
    itemtype = "I0DY"
  }
}
Pools_Junhuo_Danyao = {
  {
    name = "弹药",
    weight = 90,
    itemtype = "I0NF"
  },
  {
    name = "特殊子弹",
    weight = 20,
    itemtype = "I0DV"
  }
}
Pools_Junhuo_Jz = {}
Pools_Junhuo_Jzwq = {
  {
    name = "普通近战武器",
    weight = 90,
    itemtype = "I0E9"
  },
  {
    name = "特殊近战武器",
    weight = 10,
    itemtype = "I065"
  }
}
Pools_Module = {
  {
    name = "冰霜模组",
    weight = 100,
    itemtype = "I00G"
  },
  {
    name = "风暴模组",
    weight = 100,
    itemtype = "I00B"
  },
  {
    name = "烈焰模组",
    weight = 100,
    itemtype = "I01J"
  },
  {
    name = "战争模组",
    weight = 100,
    itemtype = "I00F"
  },
  {
    name = "鲜血模组",
    weight = 100,
    itemtype = "I006"
  },
  {
    name = "幸运模组",
    weight = 100,
    itemtype = "I01C"
  },
  {
    name = "锋芒模组",
    weight = 100,
    itemtype = "I015"
  },
  {
    name = "魅魔模组",
    weight = 5,
    unique = true,
    itemtype = "I0E3"
  },
  {
    name = "梦魇模组",
    weight = 5,
    unique = true,
    itemtype = "I01E"
  }
}
Pools_Ciyuan = {
  {
    name = "药水",
    weight = 95,
    itemtype = "I0NG"
  },
  {
    name = "特殊物品",
    weight = 5,
    itemtype = "I0NH"
  }
}
Pools_GunModule = {
  {
    name = "模块-弹匣",
    weight = 25,
    itemtype = "I0P4"
  },
  {
    name = "模块-内部系统",
    weight = 100,
    itemtype = "I0P6"
  },
  {
    name = "模块-枪口",
    weight = 25,
    itemtype = "I0P5"
  },
  {
    name = "模块-下挂",
    weight = 25,
    itemtype = "I0P3"
  }
}
Pools_GunModule_Danxia = {}
Pools_GunModule_Xiagua = {}
Pools_GunModule_Xitong = {}
Pools_GunModule_Qiangkou = {}
Pools_Weapon = {
  {
    name = "消防斧",
    weight = 100,
    itemtype = "I00H"
  },
  {
    name = "铁剑",
    weight = 100,
    itemtype = "I00D"
  },
  {
    name = "武士刀",
    weight = 100,
    itemtype = "I00M"
  },
  {
    name = "撬棍",
    weight = 100,
    itemtype = "I00O"
  },
  {
    name = "钢爪",
    weight = 100,
    itemtype = "I062"
  },
  {
    name = "光剑",
    weight = 100,
    itemtype = "I060"
  },
  {
    name = "镰刀",
    weight = 100,
    itemtype = "I061"
  },
  {
    name = "战斧",
    weight = 100,
    itemtype = "I063"
  },
  {
    name = "棒球棍",
    weight = 100,
    itemtype = "I027"
  }
}

local function shenbingpanding(item)
  System_Count_Weapon = System_Count_Weapon + 1
  SetData(item, "物品判定-神兵")
  SetData(item, "神兵-获取")
end

Pools_SpeGun = {
  {
    name = "星光魔术师",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0E0"
  },
  {
    name = "竞争者",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0E1"
  },
  {
    name = "加斯尔豺狼",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0E2"
  },
  {
    name = "光之剑超新星",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0HF"
  }
}
Pools_SpeNormalWeapon = {
  {
    name = "银冰之枪",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("血统判定-银冰的庇护") then
        add = add + 1
      end
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("冰变异数量") > 0 then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0AA"
  },
  {
    name = "辉煌耀世",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
      local x = GetItemX(item)
      local y = GetItemY(item)
      Effectcreate("ss.mdx", x, y, 1.1)
      u:playsound(Sound_SsSg)
    end,
    itemtype = "I05Y"
  },
  {
    name = "斩机刀-那由他",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05X"
  },
  {
    name = "观世正宗",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05V"
  },
  {
    name = "空间之刃",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I064"
  },
  {
    name = "业物",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05Z"
  },
  {
    name = "九字兼定",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I03N"
  },
  {
    name = "布都御魂",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05Q"
  },
  {
    name = "白楼剑",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05T"
  },
  {
    name = "黑刀-夜",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I06P"
  },
  {
    name = "灰狐刀",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05W"
  },
  {
    name = "童子切安纲",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05R"
  },
  {
    name = "洋流",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I03Z"
  },
  {
    name = "鬼丸国纲",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05O"
  },
  {
    name = "七夜",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I03Y"
  },
  {
    name = "楼观剑",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05U"
  },
  {
    name = "村正",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05N"
  },
  {
    name = "绯",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05P"
  },
  {
    name = "邪神剑",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I01P"
  },
  {
    name = "和泉守兼定",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05S"
  },
  {
    name = "日轮刀",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I03V"
  },
  {
    name = "日轮刀赤炎",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-炎之呼吸") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0MY"
  },
  {
    name = "菊一文字则宗",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I020"
  },
  {
    name = "灵刀.樱吹雪",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0AD"
  },
  {
    name = "御神刀.村雨",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I07F"
  },
  {
    name = "环印骑士直剑",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("变异判定-正道骑士") then
        add = add + 5
      end
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0HD"
  },
  {
    name = "濡湿小镰刀",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("变异判定-正道骑士") then
        add = add + 5
      end
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0HC"
  },
  {
    name = "压切长谷部",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05M"
  }
}
Pools_DuanzaoSpeWeapon = {
  {
    name = "都牟刈村正",
    weight = 3,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("神化判定-千子村正") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0A5"
  }
}
Pools_SpeWeapon = {
  {
    name = "神刀-丛雨丸",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      local sy = u.ownerid
      add = add + 0.03 * KillCount_Katana[sy]
      if Boolean_Murasame[2] then
        add = add + 7.5
      end
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("丛雨结缘") or u:hasdata("丛雨") then
        b = true
      end
      if Qiyue_Murasame_Master == 0 then
        b = false
      end
      if Boolean_Murasame[1] then
        b = false
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
      Boolean_Murasame[3] = true
    end,
    itemtype = "I07J",
    nocanforging = true
  },
  {
    name = "楔丸",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-只狼") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0FO",
    nocanforging = true
  },
  {
    name = "权力之刃",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-权力之刃") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I01W"
  },
  {
    name = "破戒刀",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-破戒刀") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I025"
  },
  {
    name = "雷霆长枪",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-雷霆长枪") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0DS",
    nocanforging = true
  },
  {
    name = "潮汐",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-潮汐") or u:hasdata("判定-斯卡蒂") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I029"
  },
  {
    name = "高频村雨刀",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-高频村雨刀") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0HE",
    nocanforging = true
  },
  {
    name = "薄暝",
    weight = 0.05,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("判定-薄暝") then
        add = add + 1
      end
      if u:hasdata("判定-薄暝高概率") then
        add = add + 2.5
      end
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0AQ",
    nocanforging = true
  }
}
Pools_SpeDzWeapon = {
  {
    name = "丧钟",
    weight = 0.05,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("判定-愚者") then
        add = add + 1.7
      end
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0PB"
  },
  {
    name = "柴刀",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-礼奈") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I08O"
  },
  {
    name = "诡异柴刀",
    weight = 2.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("杨间-初始") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0PJ"
  },
  {
    name = "长虹剑",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-虹猫") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0KK"
  },
  {
    name = "拟态",
    weight = 2.0,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:getdata("拟态权重") >= 30 then
        add = add + 10000
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-拟态") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0PN"
  },
  {
    name = "忴",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-忴") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I05E"
  },
  {
    name = "魔镜",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-愚者") and u:hasdata("变异判定-愚者初始") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0PA"
  },
  {
    name = "天翼种之镰",
    weight = 1.75,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-吉普利露") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0C7"
  },
  {
    name = "缠魇丸",
    weight = 2.75,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-缠魇丸") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0EJ",
    nocanforging = true
  },
  {
    name = "青色怒火",
    weight = 2.75,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-阿米娅") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0JJ",
    nocanforging = true
  },
  {
    name = "涤罪七雷",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("特殊判定-雷律初始") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0DZ",
    nocanforging = true
  },
  {
    name = "死神镰刀",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-百百") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I0JT",
    nocanforging = true
  },
  {
    name = "雪霞狼",
    weight = 2.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-雪菜") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      shenbingpanding(item)
    end,
    itemtype = "I05D"
  }
}
Pools_Gun = {
  {
    name = "M16A1",
    weight = 100,
    itemtype = "I002"
  },
  {
    name = "AUG",
    weight = 100,
    itemtype = "I00W"
  },
  {
    name = "M249",
    weight = 100,
    itemtype = "I00K"
  },
  {
    name = "SG552",
    weight = 100,
    itemtype = "I00V"
  },
  {
    name = "Ak-47",
    weight = 100,
    itemtype = "I001"
  },
  {
    name = "Mac10",
    weight = 100,
    itemtype = "I00S"
  },
  {
    name = "MP5",
    weight = 100,
    itemtype = "I00P"
  },
  {
    name = "P90",
    weight = 100,
    itemtype = "I00Q"
  },
  {
    name = "UMP45",
    weight = 100,
    itemtype = "I00R"
  },
  {
    name = "M3",
    weight = 100,
    itemtype = "I00U"
  },
  {
    name = "Xm1014",
    weight = 100,
    itemtype = "I005"
  },
  {
    name = "AWP",
    weight = 100,
    itemtype = "I004"
  },
  {
    name = "SG550",
    weight = 100,
    itemtype = "I018"
  },
  {
    name = "G3SG1",
    weight = 100,
    itemtype = "I017"
  },
  {
    name = "AX338",
    weight = 100,
    itemtype = "I01H"
  }
}
Pools_Medicine = {
  {
    name = "冥王星之药",
    weight = 37,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    itemtype = "I02H"
  },
  {
    name = "以太药水",
    weight = 37,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    itemtype = "I02F"
  },
  {
    name = "鲁纳斯泉水",
    weight = 7,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    itemtype = "I02E"
  },
  {
    name = "伊希斯血晶",
    weight = 17,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    itemtype = "I011"
  },
  {
    name = "次元の回忆",
    weight = 17,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    itemtype = "I030"
  },
  {
    name = "星幽药剂",
    weight = 150,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if Nandu_Choose <= 2 then
        b = true
      end
      return b
    end,
    itemtype = "I0GQ"
  },
  {
    name = "万宝槌",
    weight = 10,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("变异判定-少名针妙丸") then
        add = add + weight * 0.5
      end
      if u:ishasitem("I06Z") then
        add = add + weight * 0.5
      end
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("变异判定-小人族") or u:hasdata("最强的两人-天子") then
        b = true
      end
      return b
    end,
    itemtype = "I01A"
  },
  {
    name = "圣杯残片",
    weight = 1,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      if u:hasdata("圣杯残片-获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("圣杯残片-获取")
    end,
    itemtype = "I08Y"
  }
}
Pools_Fate = {
  {
    name = "魔君兴奋剂",
    weight = 100,
    itemtype = "I035"
  },
  {
    name = "次元の回忆",
    weight = 100,
    itemtype = "I030"
  },
  {
    name = "星辉注射剂",
    weight = 100,
    itemtype = "I036"
  },
  {
    name = "蓬莱仙药",
    weight = 100,
    itemtype = "I04F"
  },
  {
    name = "天人仙桃",
    weight = 100,
    itemtype = "I0C2"
  },
  {
    name = "阿戈尔之赞",
    weight = 100,
    itemtype = "I0IF"
  }
}
Pools_NormalAmmu = {
  {
    name = "黑科弹",
    weight = 100,
    itemtype = "I000"
  },
  {
    name = "黑科弹II",
    weight = 100,
    itemtype = "I00E"
  },
  {
    name = "瓦尔特弹",
    weight = 100,
    itemtype = "I00T"
  },
  {
    name = "伯奈利军弹",
    weight = 100,
    itemtype = "I003"
  }
}
Pools_SpecialAmmu = {
  {
    name = "S02-SU弹",
    weight = 50,
    itemtype = "I06A"
  },
  {
    name = "叶绿弹",
    weight = 50,
    itemtype = "I0FT"
  },
  {
    name = "爆裂弹",
    weight = 50,
    itemtype = "I0FV"
  },
  {
    name = "机巧弹",
    weight = 50,
    itemtype = "I0FW"
  },
  {
    name = "水晶弹",
    weight = 25,
    itemtype = "I0FU"
  },
  {
    name = "塔纳活性能量弹",
    weight = 25,
    itemtype = "I06B"
  },
  {
    name = "腐朽弹",
    weight = 25,
    itemtype = "I0BP"
  },
  {
    name = "螺旋塔弹",
    weight = 25,
    itemtype = "I066"
  },
  {
    name = "贯彻弹",
    weight = 25,
    itemtype = "I01I"
  },
  {
    name = "达姆弹黑牙",
    weight = 25,
    itemtype = "I05L"
  },
  {
    name = "化武弹",
    weight = 25,
    itemtype = "I06C"
  },
  {
    name = "湮灭弹",
    weight = 1,
    itemtype = "I069"
  },
  {
    name = "星光弹",
    weight = 25,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if IsTimeNight() then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0DW"
  },
  {
    name = "幻想虚弹",
    weight = 10,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      local time = GetTimeOfDay()
      if 22 <= time or time <= 2 then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0DX"
  }
}
Pools_Spe = {
  {
    name = "混沌传送权杖",
    weight = 30,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      if u:hasdata("混沌传送权杖-获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("混沌传送权杖-获取")
    end,
    itemtype = "I03C"
  },
  {
    name = "1i至上之冠",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 1 and u:hasdata("原质-拥有1") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LP"
  },
  {
    name = "2i创辉之光",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 2 and u:hasdata("原质-拥有2") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LM"
  },
  {
    name = "3i理解之冠",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 3 and u:hasdata("原质-拥有3") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LG"
  },
  {
    name = "4i慈悲之泪",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 4 and u:hasdata("原质-拥有4") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LH"
  },
  {
    name = "5i律行之履",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 5 and u:hasdata("原质-拥有5") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LI"
  },
  {
    name = "6i绮曜之羽",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 6 and u:hasdata("原质-拥有6") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LJ"
  },
  {
    name = "7i涅瑟之翼",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 7 and u:hasdata("原质-拥有7") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LN"
  },
  {
    name = "8i赫德之碑",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 8 and u:hasdata("原质-拥有8") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LK"
  },
  {
    name = "9i源流之花",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 9 and u:hasdata("原质-拥有9") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LL"
  },
  {
    name = "10i静默之冕",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("原质-随机数") == 10 and u:hasdata("原质-拥有10") then
        b = true
      end
      if u:hasdata("魔之原质-已获取") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("魔之原质-已获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0LO"
  },
  {
    name = "头环",
    weight = 1.0E-4,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      local sy = u.ownerid
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = false,
    effect = function(unit, item)
      local u = getunit(unit)
      u:addgold(250)
    end,
    itemtype = "I0L5"
  },
  {
    name = "罪之镰",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      local sy = u.ownerid
      if u:hasdata("变异判定-见习死神") then
        add = add + 1
      end
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("变异判定-黑猫") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
      shenbingpanding(item)
    end,
    itemtype = "I0L4"
  },
  {
    name = "灵鸽小七",
    weight = 5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      local sy = u.ownerid
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-虹猫") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0L3"
  },
  {
    name = "夏娃的心脏",
    weight = 5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      local sy = u.ownerid
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-夜夜") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I057"
  },
  {
    name = "丛雨丸伴剑",
    weight = 5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      local sy = u.ownerid
      return add
    end,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      local sy = u.ownerid
      if CIUC[sy] == "1726349655" and u:hasdata("丛雨") then
        b = true
      end
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0A8"
  },
  {
    name = "假面",
    weight = 0.5,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      local sy = u.ownerid
      if CIUC[sy] == "1155201793" then
        add = add + 1
      end
      return add
    end,
    condition = function(unit)
      local b = true
      return b
    end,
    unique = true,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0IO"
  },
  {
    name = "狮心会徽章",
    weight = 2,
    addweight = function(unit, weight)
      local add = 0
      local u = getunit(unit)
      if u:hasdata("神器判定-雨夜的迈巴赫") then
        add = add + 5
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0EY"
  },
  {
    name = "达摩克里斯之剑",
    weight = 1.5,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0ET"
  },
  {
    name = "砰砰礼物",
    weight = 1.5,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      local sy = u.ownerid
      u:sendmessage("|cFFCC0000你觉得不要轻易捡起前面这个像炸弹一样的东西比较好,你将它塞入背包里面|r")
      local bb = getunit(Beibao[sy])
      bb:addspeitem(item)
    end,
    itemtype = "I0H1"
  },
  {
    name = "无名长裙",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:isgirl() then
        add = add + 0.5
      end
      if u:hasdata("变异判定-魔眼") then
        add = add + 0.75
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I02D"
  },
  {
    name = "诚之旗",
    weight = 0.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("变异判定-病弱") then
        add = add + 0.75
      end
      if u:hasdata("变异判定-冲田总司") then
        add = add + 0.75
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I021"
  },
  {
    name = "石鬼面",
    weight = 0.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      add = add + 0.15 * u:getdata("吸血鬼变异数量")
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
      SetData(item, "石鬼面彩蛋")
    end,
    itemtype = "I06H"
  },
  {
    name = "魔人经卷",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("变异判定-大阿阇黎") then
        add = add + 0.5
      end
      if u:hasdata("变异判定-星莲华") then
        add = add + 1
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I07C"
  },
  {
    name = "利比亚碎片",
    weight = 0.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I07M"
  },
  {
    name = "潘多拉之心",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      if Morihuanjing_String == "潘多拉" then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("潘多拉之心-所有者")
      SetData(item, "童话物品")
      Count_Tonghuawupin = Count_Tonghuawupin + 1
      PlayBGM({
        bgm = BGM_PandoraHeart,
        time = 70,
        ID = 68,
        unit = u.handle
      })
    end,
    itemtype = "I0AP"
  },
  {
    name = "妖精的尾巴",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("龙变异数量") then
        add = add + 0.5 * u:getdata("龙变异数量")
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I09A"
  },
  {
    name = "Romanの祝福",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I01N"
  },
  {
    name = "红魔秘史",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      add = add + 0.05 * (u:getdata("魔导变异数量") + u:getdata("炎变异数量"))
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I042"
  },
  {
    name = "无限烤薄饼",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if 0 < u:getdata("女神力") then
        add = add + 0.5 * u:getdata("女神力")
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:getdata("女神力") > 0 then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("美狄亚-制作烤薄饼")
      SetData(item, "制作者", unit)
    end,
    itemtype = "I09F"
  },
  {
    name = "他乡的歌谣-泪",
    weight = 5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-幽灵鲨") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I04I"
  },
  {
    name = "他乡的歌谣-悲",
    weight = 5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-斯卡蒂") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I04J"
  },
  {
    name = "百鬼枷锁",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-孤狼") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      local sy = u.ownerid
      local x, y = u:getxy()
      SetItemPosition(item, x, y)
    end,
    itemtype = "I09H"
  },
  {
    name = "权力之冠",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-权力之冠") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I01Y"
  },
  {
    name = "日轮竹",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("判定-祢豆子") then
        add = add + 2
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-日轮竹") or u:hasdata("判定-祢豆子") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I016"
  },
  {
    name = "残暴心",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-残暴心") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I03J"
  },
  {
    name = "狮子戒指",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-狮子戒指") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0DT"
  },
  {
    name = "猎龙臂甲",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-猎龙盔甲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0DQ"
  },
  {
    name = "猎龙铠甲",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-猎龙盔甲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0DP"
  },
  {
    name = "猎龙头盔",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-猎龙盔甲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0DO"
  },
  {
    name = "粽子精",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-粽子精") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0H9"
  },
  {
    name = "儿童节雪糕",
    weight = 0.75,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      if u:hasdata("儿童节雪糕-获取") then
        b = false
      end
      if not u:hasdata("权限-儿童节雪糕") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("儿童节雪糕-获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0L1"
  },
  {
    name = "哈密瓜雪糕(上)",
    weight = 1,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      if not u:hasdata("权限-哈密瓜雪糕") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0PO"
  },
  {
    name = "哈密瓜雪糕(下)",
    weight = 1,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      if not u:hasdata("权限-哈密瓜雪糕") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
    end,
    itemtype = "I0PP"
  },
  {
    name = "无暇之钥",
    weight = 0.75,
    addweight = function(unit, weight)
      local add = 0
      return add
    end,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      if u:hasdata("无暇之钥-获取") then
        b = false
      end
      if not u:hasdata("权限-无暇之钥") then
        b = false
      end
      return b
    end,
    effect = function(unit, item)
      local u = getunit(unit)
      u:setdata("无暇之钥-获取")
      SetData(item, "所属玩家", u.owner)
    end,
    itemtype = "I0JM"
  },
  {
    name = "奴隶头巾",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0KP"
  },
  {
    name = "宠爱戒指",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("变异判定-正道骑士") then
        add = add + 5
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JP"
  },
  {
    name = "猎龙腿甲",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-猎龙盔甲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0DR"
  },
  {
    name = "无名众神的王女",
    weight = 4,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-王女") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0PM"
  },
  {
    name = "虚黑的刻印",
    weight = 0.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("判定-黑龙") then
        add = add + 1
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I012"
  },
  {
    name = "朱红之瑰",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-朱红之瑰") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0C9"
  },
  {
    name = "白蛇传记",
    weight = 5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 1 * Stage
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:ishasitem("I01B") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0BG"
  },
  {
    name = "团扇",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      local u = getunit(unit)
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0IL"
  },
  {
    name = "白羽扇",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-德丽莎观星") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0H3"
  },
  {
    name = "甜甜圈礼盒",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-忍野忍") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0GK"
  },
  {
    name = "残缺的光之种",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:getdata("光之种权重") >= 30 then
        add = add + 10000
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("特殊判定-安吉拉初始") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0J5"
  },
  {
    name = "露娜酱玩偶",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-露娜") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0GJ"
  },
  {
    name = "杀生石",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-玉藻前") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I039"
  },
  {
    name = "星之奇迹",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-队长") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0EF"
  },
  {
    name = "初生白枝",
    weight = 2.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-纳西妲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JC"
  },
  {
    name = "迷宫的游人",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-纳西妲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JD"
  },
  {
    name = "翠蔓的智者",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-纳西妲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JE"
  },
  {
    name = "贤者的定期",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-纳西妲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JF"
  },
  {
    name = "迷雾者之灯",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-纳西妲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JG"
  },
  {
    name = "月桂的宝冠",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-纳西妲") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JH"
  },
  {
    name = "星之泪",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-星神之嗣") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0CB"
  },
  {
    name = "延绵后世之物",
    weight = 2.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-千子村正") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0CI"
  },
  {
    name = "匠之年糕",
    weight = 2.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-千子村正") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0A7"
  },
  {
    name = "神乐铃",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-朝武芳乃") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0JY"
  },
  {
    name = "虫箭",
    weight = 15,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("变异判定-流氓巨星") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I04O"
  },
  {
    name = "箭",
    weight = 15,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-茸茸") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I04N"
  },
  {
    name = "破碎的梦",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-破碎的梦") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0KS"
  },
  {
    name = "智慧树的枝条",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-智慧树的枝条") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0EW"
  },
  {
    name = "四魂之玉",
    weight = 10,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-桔梗") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0CC"
  },
  {
    name = "迷路帖",
    weight = 1.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("权限-千矢") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I06D"
  },
  {
    name = "风祝の御币",
    weight = 0.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("判定-早苗") then
        add = add + 3.5
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I02B"
  },
  {
    name = "Episode夺走的左腿",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("变异判定-忍野忍神化") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0K1"
  },
  {
    name = "Dramaturgy夺走的右腿",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("变异判定-忍野忍神化") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0K2"
  },
  {
    name = "星之仗",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-愚者") and u:hasdata("变异判定-愚者初始") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0LB"
  },
  {
    name = "Cutter夺走的双臂",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("变异判定-忍野忍神化") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0K3"
  },
  {
    name = "蔷薇花开",
    weight = 4.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-鹿目圆") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I073"
  },
  {
    name = "卑劣者的枷锁",
    weight = 3,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-狂乱者") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0C5"
  },
  {
    name = "狂战士之铠",
    weight = 3,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-狂战士之铠") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0KO"
  },
  {
    name = "魔女衣袍",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-伊蕾娜") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0BC"
  },
  {
    name = "魔女帽子",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-伊蕾娜") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0BA"
  },
  {
    name = "魔女扫帚",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-伊蕾娜") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0BB"
  },
  {
    name = "紫阳伞",
    weight = 1.75,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local b = false
      local u = getunit(unit)
      if u:hasdata("判定-八云紫") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I06F"
  },
  {
    name = "定海古心",
    weight = 0.2,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0.1 * u:getdata("水变异数量")
      if u:hasdata("变异判定-文向") then
        add = add + 0.5
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:getdata("水变异数量") > 0 then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0DI"
  },
  {
    name = "流光匕首",
    weight = 1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I06Y"
  },
  {
    name = "东方求闻史记",
    weight = 0.25,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("东方角色") then
        add = add + 0.75
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = true
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I06Z"
  },
  {
    name = "精灵之泉",
    weight = 0.1,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      add = add + 0.1 * u:getdata("自然变异数量")
      if u:hasdata("隐藏职业-园丁") then
        add = add + 1.25
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:getdata("自然变异数量") > 0 or u:hasdata("隐藏职业-园丁") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0K5"
  },
  {
    name = "老魔杖",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-老魔杖") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0FS"
  },
  {
    name = "大贤者",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-利姆露") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I08Q"
  },
  {
    name = "白音的日记本",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-特里诺") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0AC"
  },
  {
    name = "双刃下弦月",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("变异判定-残影的菲奥雷托") or u:isinmaxvar("黑暗") or u:isinmaxvar("影") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0MP"
  },
  {
    name = "要石",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-大天子") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I09L"
  },
  {
    name = "暗的书页I",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if Weiyi_New[15] then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      SendMsgAll("|cFF0033CC是么,终究还是迎来了这一天么…|r")
    end,
    itemtype = "I052"
  },
  {
    name = "暗的书页II",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if Weiyi_New[15] then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      SendMsgAll("|cFF0033CC迷雾世界的曙光.究竟在何方…|r")
    end,
    itemtype = "I053"
  },
  {
    name = "暗的书页III",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if Weiyi_New[15] then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
      SendMsgAll("|cFF0033CC或许这一切只有神灵才能拯救吧...|r")
    end,
    itemtype = "I054"
  },
  {
    name = "魔神人形",
    weight = 2.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-祸灵梦") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0KI"
  },
  {
    name = "折纸无铭",
    weight = 5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("判定-椿") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0BI"
  },
  {
    name = "天剑十字",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("变异判定-暗之书") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I050"
  },
  {
    name = "艾哲诅咒",
    weight = 1.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      return add
    end,
    unique = true,
    condition = function(unit)
      -- 저주 아이템은 모든 계정의 특수 아이템 추첨에서 제외한다.
      return false
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0BJ"
  },
  {
    name = "卡兹戴尔纹章",
    weight = 0.5,
    addweight = function(unit, weight)
      local u = getunit(unit)
      local add = 0
      if u:hasdata("变异判定-博士") then
        add = add + 1.5
      end
      return add
    end,
    unique = true,
    condition = function(unit)
      local u = getunit(unit)
      local b = false
      if u:hasdata("权限-卡兹戴尔纹章") then
        b = true
      end
      return b
    end,
    effect = function(unit, item)
    end,
    itemtype = "I0K7"
  }
}
