-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local PermissionToggle = require("gameplay.permission.permission_toggle")
local M = {
  ["斯卡蒂"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "斯卡蒂",
      name = "|cFF3366FF斯|r|cFF668CFF卡|r|cFF99B2FF蒂|r",
      icon = "war3mapImported\\BTNEwl_Skadi.blp"
    })
  end,
  ["幽灵鲨"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "幽灵鲨",
      name = "|cFF3366FF幽|r|cFF4C4CBF灵|r|cFF663380鲨|r",
      icon = "war3mapImported\\BTNEwl_Yls.blp"
    })
  end,
  ["雷之律者"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "雷之律者",
      name = "|cFF3399FF雷|r|cFF337AEB之|r|cFF335CD6律|r|cFF333DC2者|r",
      icon = "war3mapImported\\PASBTNEwl_Mei_Xuehuai.blp"
    })
  end,
  ["露娜"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "露娜",
      name = "|cFFFFCCFF樱|r|cFFFFC4FF小|r|cFFFFBCFF路|r|cFFFFB4FFル|r|cFFFFADFFナ|r",
      icon = "war3mapImported\\BTNEwl_Luna_Cq"
    })
  end,
  ["吉普利露"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "吉普利露",
      name = "|cFFCC00FF吉|r|cFFD600E0普|r|cFFE000C2莉|r|cFFEB00A3尔|r",
      icon = "war3mapImported\\BTNEwl_Jpll_Shenhua"
    })
  end,
  ["薄暝"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "薄暝",
      name = "|cFFFF9933破晓|r",
      icon = "war3mapImported\\BTNBaoming_ICON"
    })
  end,
  ["安吉拉"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "安吉拉",
      name = "|cFF8BB8CB安|r|cFFA8CAD8吉|r|cFFC5DCE5拉|r",
      icon = "BTNAngela_04"
    })
  end,
  ["古明地恋"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "古明地恋",
      name = "|cFF006C82古明地恋|r",
      icon = "Lianlian_Qx_2.tga"
    })
  end,
  ["忍野忍"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "忍野忍",
      name = "|cFFFFFF00忍|r|cFFFFF240野|r|cFFFFE680忍|r",
      icon = "war3mapImported\\BTNEwl_Ryr_Cq"
    })
  end,
  ["玉藻前"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "玉藻前",
      name = "|cFFFF66FF玉藻前|r",
      icon = "war3mapImported\\BTNEwl_Yuzaoqian.blp"
    })
  end,
  ["队长"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "队长",
      name = "|cFFFFFF33隐匿者|r",
      icon = "war3mapImported\\BTNEwl_Duizhang_06"
    })
  end,
  ["克萝蒂亚"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "克萝蒂亚",
      name = "|cFF6699FF爱丽丝.|r|cFFFF6666克萝蒂亚|r",
      icon = "war3mapImported\\BTNEwl_Kldy_03"
    })
  end,
  ["纳西妲"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "纳西妲",
      name = "|cFF66FF99纳|r|cFF8CFFB2西|r|cFFB2FFCC妲|r",
      icon = "Ewl_Naxida_10_10"
    })
  end,
  ["智慧树的枝条"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "智慧树的枝条",
      name = "|cFF66FF99智慧树的枝条|r",
      icon = "war3mapImported\\BTNThing_Sy_02"
    })
  end,
  ["阿米娅"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "阿米娅",
      name = "|cFF990000幼|r|cFF881122小|r|cFF772244的|r|cFF663366魔|r|cFF554488王|r",
      icon = "Amiya_Chuanqi_7"
    })
  end,
  ["星神之嗣"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "星神之嗣",
      name = "|cFFFF0066星虹の瞳|r",
      icon = "war3mapImported\\PASBTNXszs_06"
    })
  end,
  ["百百"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "百百",
      name = "|cFF999999百|r|cFFCCCCCC百|r",
      icon = "Ewl_Momo_Cq_02"
    })
  end,
  ["雪菜"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "雪菜",
      name = "|cFF3333FF姬|r|cFF3D47FF柊|r|cFF475CFF雪|r|cFF5270FF菜|r",
      icon = "war3mapImported\\BTNEwl_Jianwu_1.blp"
    })
  end,
  ["窥星"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "窥星",
      name = "|cFFCCFFFF星空|r|cFFADE0FF的|r|cFF8FC2FF记|r|cFF70A3FF忆|r",
      icon = "war3mapImported\\BTNEwl_Kuixing_10"
    })
  end,
  ["缠魇丸"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "缠魇丸",
      name = "|cFFFFFFFF杜|r|cFFCCCCCC兰|r|cFF999999达|r|cFF666666尔|r",
      icon = "Thing_Dldr_01"
    })
  end,
  ["朝武芳乃"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "朝武芳乃",
      name = "|cFFFF99FF朝|r|cFFFCA0FB武|r|cFFF1B6F1芳|r|cFFEEBDED乃|r",
      icon = "Ewl_Cwfn_Cq"
    })
  end,
  ["千子村正"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "千子村正",
      name = "|cFFFF0000千|r|cFFFF3D00子|r|cFFFF5C00村正|r",
      icon = "war3mapImported\\BTNEwl_Senji_03"
    })
  end,
  ["早苗"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "早苗",
      name = "|cFF66FF99东风谷早苗|r",
      icon = "war3mapImported\\BTNEwl_Sanae_Qijidexianrenshen"
    })
  end,
  ["桔梗"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "桔梗",
      name = "|cFF826DCA桔|r|cFF7A62C7梗|r",
      icon = "war3mapImported\\BTNEwl_Jg_02.tga"
    })
  end,
  ["朱雀院红叶"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "朱雀院红叶",
      name = "|cFFFFFFFF朱|r|cFFFFD4D4雀|r|cFFFFAAAA院|r|cFFFF8080红|r|cFFFF5555叶|r",
      icon = "Ewl_Hongye_01.tga"
    })
  end,
  ["八云紫"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "八云紫",
      name = "|cFF6633FF八云紫|r",
      icon = "war3mapImported\\BTNEwl_Bayunzi.blp"
    })
  end,
  ["祢豆子"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "祢豆子",
      name = "|cFFFF66FF灶门祢豆子|r",
      icon = "war3mapImported\\BTNEwl_Midouzi.blp"
    })
  end,
  ["卫宫士郎"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "卫宫士郎",
      name = "|cFFFF0000卫|r|cFFFF1F00宫|r|cFFFF3D00士|r|cFFFF5C00郎|r",
      icon = "war3mapImported\\BTNEwl_Shirou.blp"
    })
  end,
  ["忴"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "忴",
      name = "|cFFCC66FF忴|r",
      icon = "war3mapImported\\BTNWeapon_Liandao.blp"
    })
  end,
  ["黑龙"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "黑龙",
      name = "|cFF990000ミラ|r|cFF730000ボレ|r|cFF4C0000アス|r",
      icon = "war3mapImported\\BTNEwl_Gulong_1.blp"
    })
  end,
  ["鹿目圆"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "鹿目圆",
      name = "|cFFFF66FF鹿|r|cFFFF80FF目|r|cFFFF99FF圆|r",
      icon = "Ewl_Dz_Lumuyuan.tga"
    })
  end,
  ["狂乱者"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "狂乱者",
      name = "|cFFCC0033狂|r|cFF880022魔|r|cFF440011之|r|cFFCC9966理|r",
      icon = "war3mapImported\\BTNThing_Kuangmozhili.blp"
    })
  end,
  ["伊蕾娜"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "伊蕾娜",
      name = "|cFF99FFFF见|r|cFF7AD9FF习|r|cFF5CB3FF魔|r|cFF3D8DFF女|r",
      icon = "war3mapImported\\BTNEwl_Yln_Chuanqi"
    })
  end,
  ["祸灵梦"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "祸灵梦",
      name = "|cFFCC0000祸|r|cFF990000灵|r|cFF660000梦|r",
      icon = "Ewl_Hlm_Cq"
    })
  end,
  ["暗之书"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "暗之书",
      name = "|cFF9933CCリインフォース|r",
      icon = "war3mapImported\\BTNEwl_As_Azs.blp"
    })
  end,
  ["鬼灭权限"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "鬼灭权限",
      name = "|cFF33FFFF鬼灭之刃|r",
      icon = "war3mapImported\\BTNEwl_Guimiezhiren.blp"
    })
  end,
  ["大阿阇黎特殊权限"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "大阿阇黎特殊权限",
      name = "|cFFFFFF00大阿阇黎|r",
      icon = "war3mapImported\\BTNEwl_Asheli.blp"
    })
  end,
  ["老魔杖"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "老魔杖",
      name = "|cFF949596the Elder Wand|r",
      icon = "war3mapImported\\BTNThing_Laomozhang"
    })
  end,
  ["小天子"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "小天子",
      name = "|cFFFF66CC操纵大地程度的能力|r",
      icon = "war3mapImported\\BTNEwl_Tianzi.blp"
    })
  end,
  ["大天子"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "大天子",
      name = "|cFFFF66CC有顶天の大小姐|r",
      icon = "war3mapImported\\BTNEwl_Sh_Tz.blp"
    })
  end,
  ["猫头鹰因子"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "猫头鹰因子",
      name = "|cFF9999CC猫头鹰因子|r",
      icon = "war3mapImported\\BTNEwl_Maotouying.blp"
    })
  end,
  ["间桐樱"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "间桐樱",
      name = "|cFFCC33FF恶|r|cFFD63DF5兆|r|cFFE047EB之|r|cFFEB52E0花|r",
      icon = "war3mapImported\\BTNEwl_Sakura_04"
    })
  end,
  ["虹猫"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "虹猫",
      name = "|cFFE8443D白|r|cFFED6964衣|r|cFFF18F8B少|r|cFFF6B4B1侠|r",
      icon = "Ewl_Cq_Hongmao"
    })
  end,
  ["艾哲诅咒"] = function(u, sy)
    -- 원본 계정 경로에서도 저주 권한을 다시 활성화하지 않는다.
    u:deldata("判定-艾哲诅咒")
    u:deldata("权限-艾哲诅咒")
  end,
  ["狂战士之铠"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "狂战士之铠",
      name = "|cFFCC0000狂|r|cFFAD0A0A战|r|cFF8F1414士|r|cFF701F1F之铠|r",
      icon = "Thing_Kuangzhanshikaijia"
    })
  end,
  ["椿"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "椿",
      name = "|cFFCCFFFF刀|r|cFFD6CCCC仕|r|cFFE09999襧|r|cFFEB6666宜|r",
      icon = "war3mapImported\\BTNEwl_Chun_03"
    })
  end,
  ["小死神"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "小死神",
      name = "|cFFCC0000小|r|cFFB83D3D死|r|cFFAD5C5C神|r",
      icon = "Tlbk_Jinjie1"
    })
  end,
  ["特里诺"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "特里诺",
      name = "|cFFFFFF00Trinoline|r",
      icon = "war3mapImported\\BTNEwl_Trinoline.blp"
    })
  end,
  ["破碎的梦"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "破碎的梦",
      name = "|cFFCC0000破|r|cFFD61F00碎|r|cFFE03D00的|r|cFFEB5C00梦|r",
      icon = "Thing_Tjgd01.tga"
    })
  end,
  ["茸茸"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "茸茸",
      name = "|cFFFF66CC黄金体验|r",
      icon = "war3mapImported\\BTNEwl_Qiaolunuo1.blp"
    })
  end,
  ["夜夜"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "夜夜",
      name = "|cFFFFFF00机|r|cFFFFCC00巧|r|cFFFF9900少|r|cFFFF6600女|r",
      icon = "war3mapImported\\BTNYeye_2.blp"
    })
  end,
  ["愚者"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "愚者",
      name = "|cFF0066CC克|r|cFF0D73D2莱|r|cFF1A80D9恩|r|cFF268CDF.|r|cFF3399E6莫|r|cFF40A6EC雷蒂|r",
      icon = "Ewl_Yuzhe_01.tga"
    })
  end,
  ["老男人"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "老男人",
      name = "|cFFFFCC00卡|r|cFFFFC524莉|r|cFFFFBD49奥|r|cFFFFB66D斯|r|cFFFFAF92特|r|cFFFFA8B6萝|r",
      icon = "BTNLnr_03.tga"
    })
  end,
  ["礼奈"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "礼奈",
      name = "|cFFFF66CC龙宫礼奈|r",
      icon = "war3mapImported\\BTNEwl_Rena.blp"
    })
  end,
  ["王女"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "王女",
      name = "|cFFFFFFFF无名|r|cFFD6E0FF众神|r|cFFADC2FF的|r|cFF85A3FF王女|r",
      icon = "Thing_AliceDz.tga"
    })
  end,
  ["拟态"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "拟态",
      name = "|cffc91628拟态|r",
      icon = "Weapon_Nitai.tga"
    })
  end,
  ["利姆露"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "利姆露",
      name = "|cFF99CCFF转生史莱姆|r",
      icon = "war3mapImported\\BTNEwl_Rimuru_Chuanqi.blp"
    })
  end,
  ["暗影大人"] = function(u, sy)
    PermissionToggle.move({
      u = u,
      sy = sy,
      str = "暗影大人",
      name = "|cFF6633FF暗影大人|r",
      icon = "Anying_Cq_01.tga"
    })
  end
}
return M
