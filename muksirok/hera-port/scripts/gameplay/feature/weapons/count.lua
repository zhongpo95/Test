-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
function jzshcount(u)
  local sy = u.ownerid
  
  local wq = u:getdata("装备武器")
  local wqlx = GetItemTypeId(wq)
  local jc = Correction_Jzsh[sy] - 1
  if u:hasdata("变异判定-利姆露") then
    jc = jc + 0.2
  end
  if u:hasdata("琪露诺-极地冰刃") then
    jc = jc + 0.25
  end
  if u:hasdata("变异判定-剪舌麻雀") then
    jc = jc + 0.15
  end
  if u:istype("H02J") or u:istype("H02K") then
    jc = jc + 0.25
  end
  if u:hasdata("变异判定-卫宫士郎") then
    if u:hasdata("士郎-圣骸布") then
      jc = jc + 0.3
    else
      jc = jc + 0.2
    end
  end
  if u:hasdata("乾神招来突强化") then
    jc = jc + 0.3
  end
  if u:hasdata("星爆气流斩状态") then
    jc = jc + 0.1
  end
  if u:hasdata("变异判定-鬼灭之刃") then
    jc = jc + 0.001 * u:getdata("鬼灭之刃杀敌")
  end
  if u:istype("H025") then
    jc = jc + 0.01 * Group_Counts(Group_Murasame_Shenli)
  end
  if u:hasdata("神降-丛雨") then
    jc = jc + 1
  end
  if u:ishasbuff("B090") then
    jc = jc + 1
  end
  if u:hasdata("丛雨-神力解放主") then
    jc = jc + 0.2
  end
  if u:hasdata("丛雨-神刀寄魂解放") then
    jc = jc + 0.34
  end
  if u:getdata("黑龙血统阶级") >= 2 then
    local jc2 = 0
    jc2 = jc2 + (Correction_Gun[sy] - 1) * 0.25
    jc2 = jc2 + (Correction_Magic[sy] - 1) * 0.25
    jc = jc + jc2
  end
  if u:hasdata("变异判定-楚子航") then
    jc = jc + 0.11
  end
  if u:hasdata("暗之书-暗黑裁决") then
    jc = jc + 0.25
  end
  if u:hasdata("秦心-神乐-神武灵佑") then
    jc = jc + 0.11
  end
  if u:hasdata("业物增伤") then
    jc = jc + u:getdata("业物增伤")
  end
  if u:ishasitem(Weapons["御神刀.村雨"]) then
    jc = jc + 0.18
  end
  if u:ishasitem(Weapons["阐释者"]) then
    jc = jc + 0.25
  end
  if u:ishasitem(Weapons["天殛之钥"]) then
    jc = jc + 0.2
  end
  if u:ishasitem(Weapons["天殛之镜.裁决"]) then
    jc = jc + 0.3
  end
  if u:ishasitem(Weapons["非想非非想の剑"]) then
    jc = jc + 0.14
  end
  if u:ishasitem(Weapons["日轮刀"]) then
    jc = jc + 0.15
  end
  if u:ishasskill("A09S") then
    jc = jc + 0.16
  end
  if wqlx == Weapons["白楼剑"] then
    jc = jc + 0.1
  end
  if wqlx == Weapons["都牟刈村正"] then
    jc = jc + 0.25
  end
  if wqlx == Weapons["童子切安纲"] then
    jc = jc + 0.25
  end
  if u:hasdata("变异判定-斯巴达之子") and u:istype("E002") then
    jc = 1 + (jc - 1) * 2
  end
  if u:hasdata("变异判定-大祸津日神") and wqlx ~= Weapons["绯"] then
    jc = jc - 10
  end
  if u:hasdata("火之神神乐") then
    jc = jc * (0.5 + 0.01 * u:getdata("火之神神乐增伤"))
  end
  if jc <= 0 then
    jc = 0
  end
  u:setdata("显示-近战伤害加成", jc)
  local ojc = jc
  if ojc > 0.5 * Stage then
    ojc = 0.5 * Stage + (ojc - 0.5 * Stage) * BOSSKX
  end
  u:setdata("系统-实际近战伤害加成", ojc)
  return jc
end

function weaponcount2(sh, unit, wq, wqlx, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  local lx = GetData(wqlx, "近战武器类型")
  if u:hasdata("变异判定-Blake") and (lx == 6 or lx == 10) then
    if u:getdata("跃影飞绫-类型") == "镰刀" then
      lx = 6
    else
      lx = 10
    end
  end
  if lx == 4 and u:getdata("巴御前-杀戮阶级") >= 3 then
    if u:hasdata("巴御前-真名解放") then
      sh = sh * 1.77
    else
      sh = sh * 1.25
    end
  end
  if lx == 5 then
    local add = 1
    if u:hasdata("变异判定-全垒打") then
      add = add + 0.5
    end
    if u:hasdata("神器判定-悟史的棒球棍") then
      add = add + 1.5
    end
    sh = sh * add
  end
  if lx == 6 then
    if u:hasdata("变异判定-圣魔之血") then
      sh = sh * 2
    end
    if u:hasdata("变异判定-Lily安娜") then
      sh = sh * 2.5
    end
    if u:hasdata("远吕智-镰刀伤害") then
      sh = sh * 1.25
    end
    if u:hasdata("变异判定-柊筱娅") then
      sh = sh * 1.44
    end
    if u:hasdata("变异判定-Blake") then
      sh = sh * 1.25
    end
  end
  if lx == 10 then
    local add = WeaponCount_Katana[sy]
    if u:hasdata("忍龙-遗志") then
      add = add + 0.25
    end
    if u:hasdata("变异判定-Blake") then
      sh = sh * 1.25
    end
    sh = sh * add
  end
  if lx == 9 then
    local add = 1
    if u:hasdata("变异判定-刀鬼") then
      add = add + u:getdata("刀鬼-提升刀伤害")
    end
    sh = sh * add
  end
  if lx == 8 then
    local add = Correction_Weapon_Quan[sy]
    if u:hasdata("隐藏职业-喵星人") then
      add = add + 1
    end
    if u:hasdata("潘迪-物理驱魔") then
      add = add + 0.4
    end
    sh = sh * add
  end
  if lx == 11 then
    local add = 1
    if u:hasdata("变异判定-剑魔") then
      add = add + u:getdata("剑魔-提升剑伤害")
    end
    if u:hasdata("变异判定-卫宫士郎") then
      if u:hasdata("士郎-圣骸布") then
        add = add + 0.5
      else
        add = add + 0.25
      end
    end
    if u:hasdata("变异判定-露西") then
      add = add + u:getdata("露西-方舟剑圣加成")
    end
    sh = sh * add
  end
  if lx == 3 and u:hasdata("变异判定-龙宫礼奈") then
    sh = sh * 1.5
  end
  if lx == 2 and not u:hasdata("武器判定-红城的律令") then
    local add = 1
    if u:hasdata("变异判定-刀鬼") then
      add = add + u:getdata("刀鬼-提升刀伤害")
    end
    if u:hasdata("变异判定-龙宫礼奈") then
      add = add + 0.25
    end
    sh = sh * add
  end
  if lx == 7 then
    if u:hasdata("隐藏职业-龙骑士") then
      sh = sh * 2
    end
    if u:hasdata("无名戒指-枪伤害提升") then
      sh = sh * 1.2
    end
    if u:hasdata("物品-贯穿梦想之枪") then
      if u:hasdata("贯穿梦想之枪-决死提升") then
        sh = sh * (1.5 + 0.1 * u:getdata("贯穿梦想之枪-凝结的梦"))
      else
        sh = sh * (1 + 0.1 * u:getdata("贯穿梦想之枪-凝结的梦"))
      end
    end
  end
  if lx == 12 and u:hasdata("物品-贯穿梦想之枪") then
    if u:hasdata("贯穿梦想之枪-决死提升") then
      sh = sh * (1.5 + 0.1 * u:getdata("贯穿梦想之枪-凝结的梦"))
    else
      sh = sh * (1 + 0.1 * u:getdata("贯穿梦想之枪-凝结的梦"))
    end
  end
  if u:hasdata("隐藏职业-圣堂武士") and (skill == GetWpSkill("空间之刃") or skill == GetWpSkill("光剑")) then
    sh = sh * 1.5
  end
  if skill == GetWpSkill("撬棍") or skill == GetWpSkill("物理学圣剑") then
    local add = 1
    if u:hasdata("变异判定-戈登") then
      add = add + 1
    end
    if u:hasdata("变异判定-奈亚子") then
      if u:hasdata("奈亚子-强化") then
        add = add + 2
      else
        add = add + 1
      end
    end
    if u:hasdata("羁绊判定-CQC超人") then
      add = add + 2.5
    end
    sh = sh * add
  end
  if u:hasdata("变异判定-全垒打") and skill == GetWpSkill("棒球棍") then
    sh = sh * 2
  end
  if u:hasdata("变异判定-圣魔之血") and u:hasdata("栗山未来-拟态武器中") then
    sh = sh * 5
  end
  if u:hasdata("莉莉娅-近战加强") then
    sh = sh * 2.5
  end
  if u:hasdata("神器判定-磨刀石") then
    sh = sh * 2
  end
  if u:hasdata("变异判定-千子村正") then
    sh = sh * 1.25
  end
  if u:hasdata("翁斯坦-狮子戒指") then
    sh = sh * 1.25
  end
  if u:hasdata("变异判定-卫宫士郎") then
    if u:hasdata("士郎-圣骸布") then
      sh = sh * 1.3
    else
      sh = sh * 1.2
    end
  end
  if HasData(wq, "士郎-物品强化属性") then
    if u:hasdata("特殊判定-士郎的正义") then
      sh = sh * (1 + GetData(wq, "士郎-物品强化属性") * 2)
    else
      sh = sh * (1 + GetData(wq, "士郎-物品强化属性"))
    end
  end
  if u:hasdata("变异判定-法琦尔") then
    sh = sh * 1.25
  end
  if u:hasdata("莲华-幻恋之观者") then
    sh = sh * 0.75
  end
  return sh
end

function weaponfwcount(unit, wq, wqlx, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  local lx = GetData(wqlx, "近战武器类型")
  local fw = 1
  if lx == 10 then
    fw = fw * WeaponCountFw_Katana[sy]
  end
  return fw
end
