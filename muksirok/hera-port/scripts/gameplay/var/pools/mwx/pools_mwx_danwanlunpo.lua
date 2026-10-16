-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local Court = require("gameplay.var.pools.mwx.danwanlunpo_runtime")
local KEYSTRING = "弹丸论破"
local appliers = {}

local function make_var(args, apply)
  args.weight = args.weight or 100
  args.lv = 1
  args.seckey = KEYSTRING
  args.unique = false
  args.allowrepeat = true
  args.effectname = Court.color_name(args.name)
  args.condition = Court.can_get
  args.effect = Court.acquire_student
  args.removefunc = Court.remove_student
  appliers[args.name] = apply
  return args
end

Vars_Mwx_Danwanlunpo = {
  make_var({
    name = "苗木诚",
    effectart = "Mwx_Xwzf_Miaomucheng.tga",
    weight = 200,
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的幸运]|cFFFFE6F0\n提升|cFF99FFFF1%|r|cFFFFE6F0终结伤害\n提升|cFF99FFFF0.5|r|cFFFFE6F0幸运|r"
  }, function(u, count)
    ChangeValue(DamageSystem_EndSh, u.ownerid, 0.01 * count)
    u:changedata("幸运", 0.5 * count)
  end),
  make_var({
    name = "舞园沙耶香",
    effectart = "Mwx_Xwzf_Shayexiang.tga",
    key = {"学生", "歌姬"},
    effecttext = "|cFFFFE6F0学生 歌姬\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的偶像]|cFFFFE6F0\n提升|cFF99FFFF4%|r|cFFFFE6F0经验获取|r"
  }, function(u, count)
    ChangeValue(Correction_Exp, u.ownerid, 0.04 * count)
  end),
  make_var({
    name = "桑田怜恩",
    effectart = "Mwx_Xwzf_Sangtianlianen.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的棒球选手]|cFFFFE6F0\n提升|cFF99FFFF5%|r|cFFFFE6F0伤害加成|r"
  }, function(u, count)
    ChangeValue(DamageSystem_Shjc, u.ownerid, 0.05 * count)
  end),
  make_var({
    name = "雾切响子",
    effectart = "Mwx_Xwzf_Wuqiexiangzi.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的侦探]|cFFFFE6F0\n提升|cFF99FFFF2%|r|cFFFFE6F0暴击率\n提升|cFF99FFFF3%|r|cFFFFE6F0暴击伤害|r"
  }, function(u, count)
    ChangeValue(DamageSystem_Baoji, u.ownerid, 2 * count)
    ChangeValue(DamageSystem_Baoshang, u.ownerid, 0.03 * count)
  end),
  make_var({
    name = "十神白夜",
    effectart = "Mwx_Xwzf_Shishenbaiye.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的贵公子]|cFFFFE6F0\n提升|cFF99FFFF4%|r|cFFFFE6F0积分获取|r"
  }, function(u, count)
    ChangeValue(Correction_Gold, u.ownerid, 0.04 * count)
  end),
  make_var({
    name = "山田一二三",
    effectart = "Mwx_Xwzf_Shantianyiersan.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的同人作家]|cFFFFE6F0\n提升|cFF99FFFF2%|r|cFFFFE6F0生命上限|r"
  }, function(u, count)
    ChangeValue(Correction_MHp, u.ownerid, 0.02 * count)
  end),
  make_var({
    name = "大和田纹土",
    effectart = "Mwx_Xwzf_Dahetianwentu.tga",
    key = {"学生", "战士"},
    effecttext = "|cFFFFE6F0学生 战士\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的暴走族]|cFFFFE6F0\n提升|cFF99FFFF2.5%|r|cFFFFE6F0近战伤害\n提升|cFF99FFFF2.5%|r|cFFFFE6F0伤害加成|r"
  }, function(u, count)
    ChangeValue(Correction_Jzsh, u.ownerid, 0.025 * count)
    ChangeValue(DamageSystem_Shjc, u.ownerid, 0.025 * count)
  end),
  make_var({
    name = "腐川冬子",
    effectart = "Mwx_Xwzf_Fuchuandongzi.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的文学少女]|cFFFFE6F0\n提升|cFF99FFFF25|r|cFFFFE6F0全属性|r"
  }, function(u, count)
    u:addallstats(25 * count)
  end),
  make_var({
    name = "塞蕾丝缇雅·罗登贝克",
    effectart = "Mwx_Xwzf_Saileisitiya.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的赌徒]|cFFFFE6F0\n提升|cFF99FFFF0.5|r|cFFFFE6F0幸运\n提升|cFF99FFFF2%|r|cFFFFE6F0积分获取|r"
  }, function(u, count)
    u:changedata("幸运", 0.5 * count)
    ChangeValue(Correction_Gold, u.ownerid, 0.02 * count)
  end),
  make_var({
    name = "朝日奈葵",
    effectart = "Mwx_Xwzf_Chaorinaikui.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的游泳选手]|cFFFFE6F0\n提升|cFF99FFFF0.08|r|cFFFFE6F0体力恢复|r"
  }, function(u, count)
    ChangeValue(Hero_Tili_Huifu, u.ownerid, 0.08 * count)
  end),
  make_var({
    name = "石丸清多夏",
    effectart = "Mwx_Xwzf_Shiwanqingduoxia.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的风纪委员]|cFFFFE6F0\n提升|cFF99FFFF1%|r|cFFFFE6F0经验获取\n提升|cFF99FFFF500|r|cFFFFE6F0生命上限|r"
  }, function(u, count)
    ChangeValue(Correction_Exp, u.ownerid, 0.01 * count)
    u:changemaxhp(500 * count)
  end),
  make_var({
    name = "大神樱",
    effectart = "Mwx_Xwzf_Dashenying.tga",
    key = {"学生", "战士"},
    effecttext = "|cFFFFE6F0学生 战士\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的格斗家]|cFFFFE6F0\n提升|cFF99FFFF2%|r|cFFFFE6F0近战伤害\n提升|cFF99FFFF2%|r|cFFFFE6F0暴击伤害|r"
  }, function(u, count)
    ChangeValue(Correction_Jzsh, u.ownerid, 0.02 * count)
    ChangeValue(DamageSystem_Baoshang, u.ownerid, 0.02 * count)
  end),
  make_var({
    name = "叶隐康比吕",
    effectart = "Mwx_Xwzf_Yeyinkangbiblv.tga",
    key = {"学生", "星"},
    effecttext = "|cFFFFE6F0学生 星\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的占卜师]|cFFFFE6F0\n提升|cFF99FFFF1%|r|cFFFFE6F0暴击率\n提升|cFF99FFFF2%|r|cFFFFE6F0暴击伤害|r"
  }, function(u, count)
    ChangeValue(DamageSystem_Baoji, u.ownerid, 1 * count)
    ChangeValue(DamageSystem_Baoshang, u.ownerid, 0.02 * count)
  end),
  make_var({
    name = "江之岛盾子",
    effectart = "Mwx_Xwzf_Jiangzhidaodunzi.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的时尚达人]|cFFFFE6F0\n提升|cFF99FFFF15|r|cFFFFE6F0全属性\n提升|cFF99FFFF2%|r|cFFFFE6F0全属性增幅|r"
  }, function(u, count)
    u:addallstats(15 * count)
    u:changedata("全属性增幅", 0.02 * count)
  end),
  make_var({
    name = "不二咲千寻",
    effectart = "Mwx_Xwzf_Buerxiaoqianxun.tga",
    key = {"学生"},
    effecttext = "|cFFFFE6F0学生\n【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[超高校级的程序员]|cFFFFE6F0\n提升|cFF99FFFF4%|r|cFFFFE6F0经验获取|r"
  }, function(u, count)
    ChangeValue(Correction_Exp, u.ownerid, 0.04 * count)
  end),
  make_var({
    name = "黑白熊",
    effectart = "Mwx_Xwzf_Heibaixiong.tga",
    key = {},
    effecttext = "|cFFFFE6F0【阶级】1\n【所属】弹丸论破\n|cFFFF99CC[希望之峰学园学园长]|cFFFFE6F0\n提升|cFF99FFFF15%|r|cFFFFE6F0伤害加成\n提升|cFF99FFFF500|r|cFFFFE6F0生命上限|r"
  }, function(u, count)
    ChangeValue(DamageSystem_Shjc, u.ownerid, 0.15 * count)
    u:changemaxhp(500 * count)
  end)
}
Court.configure(Vars_Mwx_Danwanlunpo, appliers)
return function(qidongweightchange)
  local start_var = {
    name = KEYSTRING,
    weight = 1000,
    spirit_load = 3,
    key = {"启动"},
    rarity = "稀有",
    unique = false,
    cd = 0.2,
    addweight = function(u, var)
      return qidongweightchange(u, var, 0)
    end,
    condition = function(u)
      return not Court.get_state(u) and Qidongshangxianpanding(u)
    end,
    clickfunc = function(u)
      FlashUIVarGlobal(u, MWXSTR .. KEYSTRING)
    end,
    rightclickfunc = function(u)
      Court.trial(u)
    end,
    effect = function(u, var)
      Court.start(u, var)
    end,
    removefunc = function(u)
      Court.stop(u)
    end,
    effectname = Court.color_name("希望之峰学园"),
    effecttext = "|cFFFFE6F0启动\n【启动负载】3\n【稀有度】稀有\n召集6名不同学生后开始事件\n|cFFFF99CC[搜查]|cFFFFE6F0\n完成当前搜查任务或依序取得证言链两名学生，各获得1条证据\n完成任务立即换题；新波开始刷新任务，保留证据与证言链进度\n|cFFFF99CC[当前调查]|cFFFFE6F0\n至少3条证据可主动开庭；3/4/5/6条证据成功率为0%/33%/67%/100%\n达到6条证据时强制开庭，完成3次裁判后判定结局\n成功时揭露并处刑真凶；失败时误判并处刑一名学生\n|cFFFF99CC[左键]|cFFFFE6F0查看调查名单|r |cFFFF99CC[右键]|cFFFFE6F0主动开庭|r",
    effectart = "Mwx_Xwzf_Qidong.tga"
  }
  table.insert(Vars_Mwx, start_var)
end
