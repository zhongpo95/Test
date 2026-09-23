-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local OshinoTaboo = require("gameplay.var.advance.oshino_taboo")
local slk = require("jass.slk")

local function set_oshino_color_name(u, name, colors)
  local sy = u.ownerid
  if TP_ID[sy] then
    TP_ID[sy]:remove()
    TP_ID[sy] = nil
  end
  ColorName[sy][1] = {
    method = 1,
    name = name,
    colors = colors,
    lengthcd = 30,
    offsetspeed = 0.25
  }
  ShowNameCount[sy] = 1
  Boolean_ColorName[sy] = true
end

local function start_oshino_element_panel_bonus(u, element_values)
  local sy = u.ownerid
  local bonus = 0
  
  local function refresh()
    ChangeValue(element_values, sy, -bonus)
    bonus = OshinoTaboo.sweet_element_bonus(u:getdata("忍野忍-甜食值"))
    ChangeValue(element_values, sy, bonus)
  end
  
  refresh()
  ac.loop(1000, refresh)
end

local function add_fine_donut_uivar(u)
  local item_data = slk.item[OshinoTaboo.FINE_DONUT_ITEM]
  u:uivar_add({
    keyname = "甜甜圈礼盒",
    keytype = "传奇栏",
    text = "|cFFFF0000鲜红の|r|cFFFF401A甜甜圈|r|cFFFF8033礼盒|r\n|cFFFF99CC唔|r|cFFFF9DC8姆|r|cFFFFA1C4！|r|cFFFFA4C1只|r|cFFFFA8BD要|r|cFFFFACB9有|r|cFFFFB0B5甜|r|cFFFFB3B2甜|r|cFFFFB7AE圈|r|cFFFFBBAA存|r|cFFFFBFA6在|r|cFFFFC3A2的|r|cFFFFC69F一|r|cFFFFCA9B天|r|cFFFFCE97，|r|cFFFFD293吾|r|cFFFFD590就|r|cFFFFD98C不|r|cFFFFDD88会|r|cFFFFE184毁|r|cFFFFE580掉|r|cFFFFE87D这|r|cFFFFEC79个|r|cFFFFF075世|r|cFFFFF471界|r|cFFFFF76E。|r",
    icon = item_data.Art
  })
end

RegisterAdvanceEntries({
  ["丛雨解放"] = function(u)
    local sy = u.ownerid
    local dstr = "丛雨-解放"
    if not u:hasdata(dstr) then
      u:setdata(dstr)
      local zr = getunit(Qiyue_Murasame_Master)
      local sy2 = zr.ownerid
      NameAChange[sy] = "|cFF66FF99丛|r|cFF99FF99雨|r|cFFCCFFCC绫|r"
      local x, y = u:getxy()
      HeroRelive(u.handle, x, y, 3)
      HeroRelive(zr.handle, x, y, 3)
      u:setdata("丛雨-解放")
      u:setdata("丛雨-主人", zr)
      u:setdata("变身状态")
      zr:setdata("丛雨-神刀寄魂解放")
      zr:settimedata("丛雨演出中", 300)
      ChangeValue(DamageSystem_EndSh, sy2, 0.012)
      ChangeValue(DamageSystem_Shjc, sy2, 0.012)
      for i = 1, 6 do
        ChangeValue(Correction_Cbxs, i, 0.1)
      end
      u:addstexiao(dstr, "英雄升级时效果", function(args)
        u:changedata("全属性增幅", 0.005)
        zr:changedata("全属性增幅", 0.005)
      end)
      zr:uivar_add({
        keyname = "神刀寄魂",
        keytype = "传奇栏",
        text = "|cFF00FF99神刀寄魂|r\n|cFF66FF99与丛雨共享杀敌\n提升18%近战伤害(独立)\n提升2.4%伤害加成\n提升2.4%终结伤害\n直接伤害时14%附带[丛雨全属性*144+60%*伤害值]近战物理伤害(伤害来源为丛雨),触发冷却0.7秒|r",
        icon = "war3mapImported\\PASBTNMurasame_Jihun_Jiefang.blp"
      })
      u:uivar_change({
        keyname = "丛雨初始",
        keytype = "传奇栏",
        text = "|cFF66FF99丛|r|cFF99FF99雨|r|cFFCCFFCC绫|r\n|cFF00FF99神性 4\n五百年的等待|r\n|cFF66FF99获取时等级归1\n获取时自身与主人全属性变为两人合计\n升级时提升自身与主人0.5%全属性|r\n|cFF00FF99超越百年的恋爱|r\n|cFF66FF99与主人共享杀敌\n主人死亡或超出3000码时丛雨无法造成伤害\n主人受到致死伤害时抵挡该次伤害并完全恢复状态,触发冷却360秒\n主人死亡时原地复活并将丛雨拉回身边,触发冷却360秒|r\n|cFF00FF99神刀丛雨丸|r\n|cFF66FF99全队提升0.1超暴系数\n全队提升100%近战武器伤害|r",
        icon = "war3mapImported\\PASBTNMurasame_Jiefang.blp"
      })
      ac.timer(1000, 45, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 1.1, "绝对闪避")
          xq:buffset(u.handle, 1.1, "暂停")
        end)
      end)
      Movie_Boolean = true
      ac.wait(45000, function()
        Movie_Boolean = false
      end)
      PlayGlobalSound(Murasame_End_01)
      u:chat("主人！干得漂亮！")
      ac.wait(3500, function()
        PlayGlobalSound(Murasame_End_02)
        u:chat("好啦，你还要一直握着刀柄到什么时候，已经结束了")
      end)
      ac.wait(9000, function()
        PlayGlobalSound(Murasame_End_03)
        u:chat("手脚的感觉比以前清楚了许多")
      end)
      ac.wait(14000, function()
        PlayGlobalSound(Murasame_End_04)
        u:chat("而且还听到了丛雨丸的声音")
      end)
      ac.wait(18000, function()
        PlayGlobalSound(Murasame_End_05)
        u:chat("吾辈啊——听到它说“这些日子、辛苦你了”")
      end)
      ac.wait(23500, function()
        PlayGlobalSound(Murasame_End_06)
        u:chat("还说了“祝你幸福”")
      end)
      ac.wait(30000, function()
        PlayGlobalSound(Murasame_End_07)
        flashphoto({
          photo = "war3mapImported\\Pho_Murasame.blp",
          timeout = 5,
          timehold = 7,
          timein = 3
        })
      end)
      ac.wait(35000, function()
        PlayGlobalSound(Murasame_End_08)
        SendMsgAll("|cFF66FF99「希望你们管吾辈叫“小丛雨”！」|r", 30)
        u:adddivinity(2)
        u:getgoddessforce(1, true)
        u:setlevel(1)
        local str = u:getoriginstr()
        local agi = u:getoriginagi()
        local int = u:getoriginint()
        u:addstats(zr:getoriginstr(), zr:getoriginagi(), zr:getoriginint())
        zr:addstats(str, agi, int)
        japi.SetUnitProperName(u.handle, "|cFF66FF99丛|r|cFF99FFBB雨|r")
        ModelReplace({
          u = u,
          model = "war3mapImported\\congyu.mdl",
          modelsize = 0.9,
          modelname = "|cFF66FF99有|r|cFF8CFFB2地|r|cFFB2FFCC绫|r",
          modelicon = "Congyu_portrait.blp",
          isforce = true
        })
        ac.loop(5000, function()
          japi.SetUnitProperName(u.handle, "|cFF66FF99丛|r|cFF99FFBB雨|r")
          u:setdata("模型-变化", "war3mapImported\\congyu.mdl")
          u:setdata("模型-大小", 0.9)
          u:setdata("模型-名字", "|cFF66FF99有|r|cFF8CFFB2地|r|cFFB2FFCC绫|r")
          u:setdata("模型-大头像", "Congyu_portrait.blp")
          u:setdata("单位-大头像", u:getdata("模型-大头像"))
          japi.SetUnitModel(u.handle, u:getdata("模型-变化"))
          u:setsize(u:getdata("模型-大小"))
          japi.SetUnitName(u.handle, u:getdata("模型-名字"))
        end)
        u:delskill("A0OY")
        u:addskill("A0OY")
        u:addskill("A00N")
        u:addskill("A0P2")
        u:buffset(u.handle, 4, "无敌")
        SetUnitInvulnerable(u.handle, true)
        u:setdata("系统-无敌")
        u:groupremove(Group_PlayHero)
        u:groupremove(Group_Xingcunzu)
        u:groupremove(Group_DeathHero)
        ac.loop(3000, function()
          if DistanceBetweenUnits(u.handle, zr.handle) >= 3000.0 or not zr:isalive() then
            u:buffset(u.handle, 4, "伤害限制")
          end
          Hero_Tili[sy] = Hero_Tili_Max[sy]
          u:buffset(u.handle, 4, "无敌")
          SetUnitInvulnerable(u.handle, true)
          u:setdata("系统-无敌")
          u:groupremove(Group_PlayHero)
          u:groupremove(Group_Xingcunzu)
          u:groupremove(Group_DeathHero)
        end)
      end)
      StopSoundBJ(BGM_Murasame_01)
      PlayGlobalSound(BGM_Murasame_03)
      ac.wait(60000, function()
        StopSoundBJ(BGM_Murasame_03)
        PlayGlobalSound(BGM_Murasame_02)
      end)
      PlayBGM({
        bgm = 0,
        time = 300,
        ID = 51,
        unit = u.handle
      })
    end
  end,
  ["吉普利露-禁忌化"] = function(u)
    local sy = u.ownerid
    local str = "吉普利露-禁忌化"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      NameID[sy] = "|cFF6600FF虚|r|cFF8000E6神|r|cFF9900CCの|r|cFFB200B2残|r|cFFCC0099羽|r"
      u:setplayername(NameID[sy])
      PlayGlobalSound(Sound_Jpll_101)
      SendDtimeMsgAll(0, "|cFF6600FF「|r|cFF6C00F9原|r|cFF7300F2来|r|cFF7900EC如|r|cFF8000E6此|r|cFF8600DF |r|cFF8C00D9你|r|cFF9300D2们|r|cFF9900CC生|r|cFF9F00C6来|r|cFFA600BF即|r|cFFAC00B9为|r|cFFB200B2人|r|cFFB900AC类|r|cFFBF00A6种|r|cFFC6009F |r|cFFCC0099实|r|cFFD20093在|r|cFFD9008C太|r|cFFDF0086可|r|cFFE60080惜|r|cFFEC0079了|r|cFFF20073」|r")
      SendDtimeMsgAll(4.4, "|cFF6600FF「|r|cFF6D00F8那|r|cFF7400F1么|r|cFF7B00EA |r|cFF8200E3这|r|cFF8900DC次|r|cFF9000D5我|r|cFF9700CE更|r|cFF9E00C7要|r|cFFA500C0饱|r|cFFAC00B9含|r|cFFB300B2感|r|cFFB900AC谢|r|cFFC000A5和|r|cFFC7009E尊|r|cFFCE0097敬|r|cFFD50090来|r|cFFDC0089作|r|cFFE30082答|r|cFFEA007B了|r|cFFF10074」|r")
      SendDtimeMsgAll(12.2, "|cFF6600FF「|r|cFF6C00F9明|r|cFF7200F3白|r|cFF7800ED了|r|cFF7E00E7吗|r|cFF8500E0 |r|cFF8B00DA这|r|cFF9100D4份|r|cFF9700CE差|r|cFF9D00C8距|r|cFFA300C2就|r|cFFA900BC是|r|cFFAF00B6人|r|cFFB600AF类|r|cFFBC00A9绝|r|cFFC200A3对|r|cFFC8009D无|r|cFFCE0097法|r|cFFD40091跨|r|cFFDA008B越|r|cFFE00085的|r|cFFE7007E障|r|cFFED0078壁|r|cFFF30072」|r")
      SendDtimeMsgAll(18.5, "|cFF6600FF「|r|cFF7100F4你|r|cFF7C00E9们|r|cFF8700DE已|r|cFF9200D3经|r|cFF9D00C8没|r|cFFA800BD有|r|cFFB200B3反|r|cFFBD00A8抗|r|cFFC8009D的|r|cFFD30092方|r|cFFDE0087法|r|cFFE9007C」|r")
      SendDtimeMsgAll(21.5, "|cFF6600FF「|r|cFF6B00FA最|r|cFF7100F4后|r|cFF7600EF你|r|cFF7B00EA们|r|cFF8000E5会|r|cFF8600DF败|r|cFF8B00DA在|r|cFF9000D5自|r|cFF9500D0己|r|cFF9B00CA布|r|cFFA000C5下|r|cFFA500C0的|r|cFFAB00BA这|r|cFFB000B5个|r|cFFB500B0无|r|cFFBA00AB声|r|cFFC000A5的|r|cFFC500A0世|r|cFFCA009B界|r|cFFD00095和|r|cFFD50090灼|r|cFFDA008B热|r|cFFDF0086的|r|cFFE50080大|r|cFFEA007B地|r|cFFEF0076里|r|cFFF40071」|r")
      SendDtimeMsgAll(28.4, "|cFF6600FF「|r|cFF7700EE获|r|cFF8800DD胜|r|cFF9900CC的|r|cFFAA00BB会|r|cFFBB00AA是|r|cFFCC0099我|r|cFFDD0088」|r")
      u:deldata("诅咒-灵体化")
      u:uivar_remove("灵体化", "传奇栏")
      local ewl = getunit(Ewl_Skill[sy])
      ewl:setskillcd("A1D4", 0)
      u:adddivinity(1)
      SetHeroLevel(u.handle, 75, false)
      local add = 0
      ac.loop(1000, function()
        if u:isalive() then
          u:clearbuff()
        end
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -add)
        add = HeroMenu_MpCure_MaxMp[sy]
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, add)
        local txsh = u:getlevel() / 200
        local x2, y2 = u:getxy()
        for _, xq in ac.selector():in_rangexy(x2, y2, 1500):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          local txsh2
          if xq:isboss() then
            txsh2 = txsh * 0.01 * xq:gethp()
          elseif xq:iselite() then
            txsh2 = txsh * 0.1 * xq:gethp()
          else
            txsh2 = txsh * 1 * xq:getmaxhp()
          end
          DamageUnit({
            bj = "吉普利露禁忌化",
            unit = xq.handle,
            source = u.handle,
            damage = txsh2,
            level = 4,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {""}
          })
        end
      end)
      u:addskill("S07Q")
      u:setdata("吉普利露-禁忌化一")
      u:setdata("吉普利露-禁忌化二")
      u:setdata("吉普利露-禁忌化三")
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        tg:banrelive()
      end)
      u:uivar_change({
        keyname = "天翼种",
        keytype = "传奇栏",
        text = "|cFF6600FF虚|r|cFF8000E6神|r|cFF9900CCの|r|cFFB200B2残|r|cFFCC0099羽|r\n|cFF9900CC我会挑战你，砍下你那高傲的首级，拭目以待吧！|r\n|cFFB200B2不管最后是站着，躺着，还是死了。|r\n|cFFCC0099胜利的人都是我！|r",
        icon = "war3mapImported\\PASBTNEwl_Jpll_Jjh"
      })
    end
  end,
  ["星神之嗣禁忌"] = function(u)
    local sy = u.ownerid
    local str = "禁忌化-星神の辉光"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:changedata("残机剩余数量", 1)
      u:setusedfodd(u:getdata("残机剩余数量"))
      NameID[sy] = "|cFF0000CC【|r|cFF200DB2星|r|cFF401A99神|r|cFF602680の|r|cFF803366辉|r|cFF9F404C光|r|cFFBF4C33】|r"
      u:setplayername(NameID[sy])
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 120)
      u:adddivinity(1)
      u:changedata("幸运", 3)
      u:getgoddessforce(1, true)
      SendDtimeMsgAll(0, "|cFF0000FF【|r|cFF0300FD星|r|cFF0600FB之|r|cFF0900F9旅|r|cFF0C00F7人|r|cFF1000F6的|r|cFF1300F4旅|r|cFF1600F2途|r|cFF1900F0尚|r|cFF1C00EE未|r|cFF1F00EC结|r|cFF2200EA束|r|cFF2500E8—|r|cFF2800E6】|r")
      SendDtimeMsgAll(4, "|cFF3200E1【|r|cFF3500DF化|r|cFF3800DD为|r|cFF3B00DB星|r|cFF3E00D9之|r|cFF4100D7森|r|cFF4400D5般|r|cFF4800D4梦|r|cFF4B00D2幻|r|cFF4E00D0的|r|cFF5100CE色|r|cFF5400CC彩|r|cFF5700CA—|r|cFF5A00C8】|r")
      SendDtimeMsgAll(8, "|cFF6400C3【|r|cFF6700C1超|r|cFF6A00BF越|r|cFF6D00BD时|r|cFF7000BB间|r|cFF7300B9的|r|cFF7600B7歌|r|cFF7900B5唱|r|cFF7C00B3声|r|cFF8001B2—|r|cFF8301B0】|r")
      SendDtimeMsgAll(12, "|cFF8C01AA【|r|cFF8F01A8载|r|cFF9201A6着|r|cFF9501A4祈|r|cFF9801A2愿|r|cFF9C01A1回|r|cFF9F019F想|r|cFFA2019D着|r|cFFA5019B梦|r|cFFA80199幻|r|cFFAB0197的|r|cFFAE0195铃|r|cFFB10193声|r|cFFB40191—|r|cFFB80190】|r")
      SendDtimeMsgAll(16, "|cFFC1018A【|r|cFFC40188与|r|cFFC70186那|r|cFFCA0184位|r|cFFCD0182少|r|cFFD00180年|r|cFFD4017F一|r|cFFD7017D同|r|cFFDA017B寻|r|cFFDD0179求|r|cFFE00177着|r|cFFE30175内|r|cFFE60173心|r|cFFE90171的|r|cFFEC016F渴|r|cFFF0016E望|r|cFFF3016C—|r|cFFF6016A】|r")
      local cs = 0
      ac.loop(1000, function()
        cs = cs + 1
        if cs == 10 then
          cs = 0
          u:clearbuff("眩晕")
          u:clearbuff("僵直")
          u:clearbuff()
        end
        if (GetTimeOfDay() <= 0.1 or GetTimeOfDay() >= 23.5) and not u:hasdata("星神之嗣-午夜冷却") then
          u:settimedata("星神之嗣-午夜冷却", 240)
          u:addallstats(12)
        end
      end)
      PlayBGM({
        bgm = BGM_Xszs_01,
        time = 255,
        ID = 118,
        unit = u.handle
      })
      u:uivar_change({
        keyname = "星虹之眸",
        keytype = "传奇栏",
        text = "|cFF0000CC【|r|cFF200DB2星|r|cFF401A99神|r|cFF602680の|r|cFF803366辉|r|cFF9F404C光|r|cFFBF4C33】|r\n|cFFCC0033星神の嗣はあなたの宿願を実現したいです——|r",
        icon = "PASBTNXszs_10"
      })
    end
  end,
  ["黄金体验镇魂曲"] = function(u, xs)
    local sy = u.ownerid
    local str = "变异判定-黄金体验镇魂曲"
    if not u:hasdata(str) then
      u:setdata(str)
      if CIUC[sy] ~= "1155201793" then
        u:reduceshw()
      end
      NameID[sy] = "|cFFFF0000乔|r|cFFFF2006鲁|r|cFFFF400D诺|r|cFFFF6013·|r|cFFFF801A乔|r|cFFFF9F20巴|r|cFFFFBF26纳|r"
      local dx, dy = u:getxy()
      local jd = u:getface()
      dx, dy = PolarXY(dx, dy, -100, jd)
      local huangzhen = u:createunit("u04T", dx, dy, jd + 90)
      huangzhen:setcolor(255, 255, 255, 175)
      u:setdata("茸茸-黄镇模型", huangzhen)
      local angle = jd
      huangzhen:setdata("黄镇-角度变化", -60)
      ac.loop(30, function()
        local dx, dy = u:getxy()
        local jd = u:getface()
        if u:hasdata("茸茸-木大释放中") then
          dx, dy = PolarXY(dx, dy, 80, jd)
        else
          dx, dy = PolarXY(dx, dy, -40, jd)
          dx, dy = PolarXY(dx, dy, 50, jd - 90)
        end
        huangzhen:setxy(dx, dy)
        huangzhen:setface(jd + huangzhen:getdata("黄镇-角度变化"))
      end)
      u:setplayername(NameID[sy])
      u:buffset(u.handle, 47, "暂停")
      u:buffset(u.handle, 47, "绝对闪避")
      u:buffset(u.handle, 47, "无敌")
      u:setface(0)
      local p = getplayer(u.owner)
      local x, y = u:getxy()
      local jd = u:getface()
      PlayGlobalSound(Sound_rongrong_Gold_xperience2)
      SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
      ac.wait(3000, function()
        huangzhen:animeact(4)
        huangzhen:animespeed(0.5)
        huangzhen:setdata("黄镇-角度变化", 90)
        u:shockcamera(150, 0.3)
        p:setcameraheight(-800, 0.2)
        ac.wait(400, function()
          p:setcameraheight(1650, 1)
        end)
        EffectcreateArgs({
          effect = "war3mapImported\\tx_rongrong_guangquan2.mdx",
          x = x,
          y = y,
          size = 4,
          height = -200,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "war3mapImported\\tx_rongrong_juguang2.mdx",
          x = x,
          y = y,
          time = 0.5,
          size = 1,
          height = 100,
          zxz = jd,
          yxz = 30,
          animespeed = 1
        })
      end)
      ac.wait(3500, function()
        local cs = 0
        ac.loop(500, function(t)
          cs = cs + 1
          u:playsound(BOSS_Zhenhong_Xintiao)
          u:shockcamera(50, 0.3)
          p:setcameraheight(1400, 0.2)
          ac.wait(200, function()
            p:setcameraheight(1650, 0.2)
          end)
          EffectcreateArgs({
            effect = "war3mapImported\\tx_rongrong_guangquan1.mdx",
            x = x,
            y = y,
            size = cs,
            height = -100 * cs,
            zxz = jd,
            animespeed = 0.5
          })
          EffectcreateArgs({
            effect = "war3mapImported\\tx_rongrong_guangquan1.mdx",
            x = x,
            y = y,
            size = 2,
            height = 1,
            zxz = jd,
            animespeed = 0.5
          })
          EffectcreateArgs({
            effect = "war3mapImported\\tx_rongrong_juguang2.mdx",
            x = x,
            y = y,
            time = 0.5,
            size = 1,
            height = 10,
            zxz = jd,
            animespeed = 0.5
          })
          EffectcreateArgs({
            effect = "war3mapImported\\tx_rongrong_juguang1.mdx",
            x = x,
            y = y,
            time = 0.5,
            size = cs,
            height = 10,
            zxz = GetRandomAngle(),
            xxz = GetRandomAngle(),
            yxz = GetRandomAngle(),
            animespeed = 1
          })
          for i = 1, 2 do
            EffectcreateArgs({
              effect = "tx_rongrong_Text.mdx",
              x = x,
              y = y,
              size = 1,
              height = 300,
              zxz = GetRandomAngle(),
              animespeed = 1
            })
          end
          if cs < 10 then
            CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.2, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 10.0, 0.0, 0.0, 0.0)
          end
          if cs == 9 then
            CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 0.0, 0.0, 0.0, 0.0)
            ac.wait(550, function()
              PlayGlobalSound(Sound_rongrong_Gold_xperience3)
            end)
            ac.wait(700, function()
              PlayGlobalSound(Sound_rongrong_Gold_xperience4)
            end)
            ac.wait(2000, function()
              huangzhen:animeact("stand")
              huangzhen:animespeed(1)
              huangzhen:setdata("黄镇-角度变化", -60)
              PlayGlobalSound(Sound_RR_103)
              SendDtimeMsgAll(0, "|cFFFF0000『|r|cFFFF1705这|r|cFFFF2E09就|r|cFFFF460E是|r|cFFFF5D13「|r|cFFFF7417镇|r|cFFFF8B1C魂|r|cFFFFA220曲|r|cFFFFB925」|r|cFFFFD12A』|r")
              SendDtimeMsgAll(4.3, "|cFFFF0000『|r|cFFFF1103你|r|cFFFF2207所|r|cFFFF330A看|r|cFFFF440E到|r|cFFFF5511的|r|cFFFF6614确|r|cFFFF7718实|r|cFFFF881B是|r|cFFFF991F「|r|cFFFFAA22真|r|cFFFFBB25实|r|cFFFFCC29」|r|cFFFFDD2C』|r")
              SendDtimeMsgAll(8.6, "|cFFFF0000『|r|cFFFF0C02你|r|cFFFF1805的|r|cFFFF2407能|r|cFFFF310A力|r|cFFFF3D0C确|r|cFFFF490F实|r|cFFFF5511看|r|cFFFF6113到|r|cFFFF6D16了|r|cFFFF7918实|r|cFFFF861B际|r|cFFFF921D已|r|cFFFF9E20发|r|cFFFFAA22起|r|cFFFFB624的|r|cFFFFC227动|r|cFFFFCE29作|r|cFFFFDB2C。|r|cFFFFE72E』|r")
              SendDtimeMsgAll(13.3, "|cFFFF0000『|r|cFFFF0C02但|r|cFFFF1705你|r|cFFFF2307却|r|cFFFF2E09永|r|cFFFF3A0C远|r|cFFFF460E无|r|cFFFF5110法|r|cFFFF5D13达|r|cFFFF6815到|r|cFFFF7417实|r|cFFFF801A际|r|cFFFF8B1C会|r|cFFFF971E发|r|cFFFFA220生|r|cFFFFAE23的|r|cFFFFB925「|r|cFFFFC527真|r|cFFFFD12A实|r|cFFFFDC2C」|r|cFFFFE82E』|r")
              SendDtimeMsgAll(19.2, "|cFFFF0000『|r|cFFFF0902不|r|cFFFF1304管|r|cFFFF1C06你|r|cFFFF2608拥|r|cFFFF2F09有|r|cFFFF390B什|r|cFFFF420D么|r|cFFFF4C0F能|r|cFFFF5511力|r|cFFFF5E13只|r|cFFFF6815要|r|cFFFF7117在|r|cFFFF7B19我|r|cFFFF841A面|r|cFFFF8E1C前|r|cFFFF971E就|r|cFFFFA120绝|r|cFFFFAA22对|r|cFFFFB324不|r|cFFFFBD26可|r|cFFFFC628能|r|cFFFFD02A实|r|cFFFFD92B现|r|cFFFFE32D！|r|cFFFFEC2F』|r")
              SendDtimeMsgAll(26.2, "|cFFFF0000『|r|cFFFF2006这|r|cFFFF400D就|r|cFFFF6013是|r|cFFFF801A—|r|cFFFF9F20—|r|cFFFFBF26』|r")
              SendDtimeMsgAll(27.2, "|cFFFF0000「|r|cFFFF0902P|r|cFFFF1204l|r|cFFFF1A05a|r|cFFFF2307s|r|cFFFF2C09t|r|cFFFF350Bi|r|cFFFF3E0Cc|r|cFFFF460E |r|cFFFF4F10E|r|cFFFF5812x|r|cFFFF6113p|r|cFFFF6A15e|r|cFFFF7217r|r|cFFFF7B19i|r|cFFFF841Ae|r|cFFFF8D1Cn|r|cFFFF951Ec|r|cFFFF9E20e|r|cFFFFA721 |r|cFFFFB023R|r|cFFFFB925e|r|cFFFFC127q|r|cFFFFCA28u|r|cFFFFD32Ai|r|cFFFFDC2Ce|r|cFFFFE52Em|r|cFFFFED2F」|r")
              SendDtimeMsgAll(30.3, "|cFFFF0000『|r|cFFFF0B02这|r|cFFFF1504件|r|cFFFF2006事|r|cFFFF2A08就|r|cFFFF350B连|r|cFFFF400D操|r|cFFFF4A0F纵|r|cFFFF5511我|r|cFFFF6013的|r|cFFFF6A15乔|r|cFFFF7517鲁|r|cFFFF801A诺|r|cFFFF8A1C·|r|cFFFF951E乔|r|cFFFF9F20巴|r|cFFFFAA22纳|r|cFFFFB524都|r|cFFFFBF26不|r|cFFFFCA28知|r|cFFFFD42A道|r|cFFFFDF2D！|r|cFFFFEA2F』|r")
              ac.wait(37000, function()
                PlayGlobalSound(BGM_RR_100)
                ForGroupLuaNew(Group_DeathHero, function(xq)
                  local xq2 = xq
                  xq2:sendmessage("你已复活")
                  HeroRelive(xq2.handle, x, y, 5)
                end)
              end)
            end)
            ac.wait(4000, function()
              CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 0.0, 0.0, 0.0, 0.0)
              EffectcreateArgs({
                effect = "war3mapImported\\tx_rongrong_juguang2.mdx",
                x = x,
                y = y,
                time = 0.5,
                size = 2,
                height = 10,
                zxz = jd,
                animespeed = 10
              })
            end)
            local tx = EffectcreateArgs({
              effect = "war3mapImported\\tx_rongrong_juguang3.mdx",
              x = x,
              y = y,
              time = 0.1,
              size = 1,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            local cs1 = 0
            ac.loop(10, function(t1)
              cs1 = cs1 + 1
              if 0 < cs1 and cs1 <= 100 then
                japi.EXSetEffectSize(tx, cs1 / 4)
              end
              if 150 < cs1 and cs1 <= 200 then
                japi.EXSetEffectSize(tx, cs1 / 2)
              end
              if 199 < cs1 and cs1 <= 200 then
                japi.EXSetEffectSize(tx, -cs1)
              end
              if 200 <= cs1 then
                t1:remove()
              end
            end)
          end
          if 10 <= cs then
            p:setcamera(x, y, 0)
            t:remove()
          end
        end)
      end)
      PlayBGM({
        bgm = 0,
        time = 347,
        ID = 199,
        unit = u.handle
      })
      u:changedata("闪避值", 20)
      ChangeValue(Hero_Tili_Huifu, sy, 0.2)
      ChangeValue(DamageSystem_Baoji, sy, 20)
      ChangeValue(DamageSystem_Baoshang, sy, 0.2)
      ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
      local dskill = S2ID("A0GB")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local tg = getunit(args.target)
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 1500 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过1500|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            MovieAct["木大木大"](u, tg)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local cs = 0
      local add = 0
      ac.loop(3000, function()
        cs = cs + 1
        if cs == 20 then
          cs = 0
          local add2 = u:getdata("光明变异数量") + u:getdata("替身使者变异数量") + u:getdata("黄金精神变异数量")
          u:addallstats(add2)
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.01 * u:getlevel() + 0.002 * u:getallattri()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(str, "决死效果", function(args)
        if args.dt and not u:hasdata("茸茸-决死冷却") then
          args.dt = false
          u:sendmessage("|cFFFFCC00「黄金体验」|r")
          u:settimedata("茸茸-决死冷却", 300)
          u:buffset(u.handle, 3, "无敌")
          u:playsound(Sound_Touma_01)
          local yxz = {
            Sound_Rongrong_N02,
            Sound_Rongrong_N06,
            Sound_Rongrong_N08,
            Sound_Rongrong_N12
          }
          u:playsound(yxz[GetRandomInt(1, #yxz)])
          ac.timer(1000, 10, function()
            u:curehp(u.handle, 0, 10, 2)
          end)
        end
      end)
      u:uivar_change({
        keyname = "流氓巨星",
        keytype = "传奇栏",
        text = "|cFFFF0000Gold Experience Requiem|r\n|cFFFFCC00『|r|cFFFFBD00没|r|cFFFFAF00有|r|cFFFFA000终|r|cFFFF9200结|r|cFFFF8300，|r|cFFFF7500才|r|cFFFF6600是|r|cFFFF5700真|r|cFFFF4900正|r|cFFFF3A00的|r|cFFFF2C00终|r|cFFFF1D00结|r\n|cFFFFCC00这|r|cFFFF9900就|r|cFFFF6600是|r\n        |cFFFF0000「黄金体验镇魂曲」|r\n                                     |cFFFF6600』|r",
        icon = "Ewl_Rongrong_01",
        ishasphoto = true,
        jbtext = function()
          UIYNameCount = 2
          UIYName[1] = {
            method = 1,
            name = "Gold Experience Requiem",
            colors = {
              "FFCC00",
              "FF0000",
              "FF0000",
              "FF0000",
              "FFCC00"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.25,
            extratext = "\n" .. "|cFFFFCC00『|r|cFFFFBD00没|r|cFFFFAF00有|r|cFFFFA000终|r|cFFFF9200结|r|cFFFF8300，|r|cFFFF7500才|r|cFFFF6600是|r|cFFFF5700真|r|cFFFF4900正|r|cFFFF3A00的|r|cFFFF2C00终|r|cFFFF1D00结|r" .. "\n|cFFFFCC00这|r|cFFFF9900就|r|cFFFF6600是|r\n        "
          }
          UIYName[2] = {
            method = 1,
            name = "「黄金体验镇魂曲」",
            colors = {
              "FFCC00",
              "FF0000",
              "FF0000",
              "FF0000",
              "FFCC00"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.5,
            extratext = "\n                                     |cFFFF6600』|r"
          }
        end
      })
    end
  end,
  ["朱雀院椿禁忌"] = function(u)
    local sy = u.ownerid
    local str = "朱雀院椿-禁忌化"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      NameID[sy] = "|cFFFFCCFF绊き|r|cFFFFA3CCらめ|r|cFFFF7A99く恋い|r|cFFFF5266ろは|r"
      u:setplayername(NameID[sy])
      flashphoto({
        photo = "war3mapImported\\Chun_Jjh_01.tga",
        timeout = 0.5,
        timehold = 2,
        timein = 1
      })
      PlayGlobalSound(Sound_Chun_23)
      SendDtimeMsgAll(0, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFFCCFF『对不起，不能如你所愿。』|r")
      SendDtimeMsgAll(5.8, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFFA3CC『因为如果我就这样输了的话，有人会伤心的！』|r")
      SendDtimeMsgAll(11.8, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF7A99『我会让你看看，我能把这火焰化作我的力量飞舞起来！』|r")
      SendDtimeMsgAll(19.2, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF5266『像朱雀一样，用赤红色的翅膀振翅高飞！』|r")
      PlayBGM({
        bgm = 0,
        time = 240,
        ID = 110,
        unit = u.handle
      })
      ac.wait(900, function()
        PlayGlobalSound(BGM_Chun_01)
        SetSoundVolume(BGM_Chun_01, 0)
        songtext({
          text = {
            {
              starttime = 15.3,
              str = "争奇斗艳  椿色恋歌  承载着思念"
            },
            {
              starttime = 21.7,
              str = "寄托于你 向着未知的未来张开翅膀",
              time = 6.3
            },
            {
              starttime = 32.1,
              str = "因为 如今听到了你的声音"
            },
            {
              starttime = 38.5,
              str = "不再 迷惘不前 相信着你 直到永远"
            },
            {
              starttime = 44.9,
              str = "背负朱雀的十字架 唤起宿命的鼓动"
            },
            {
              starttime = 51.6,
              str = "打开不为人知的 我的过去"
            },
            {
              starttime = 58.3,
              str = "朱红灵魂的羁绊"
            },
            {
              starttime = 64.5,
              str = "光芒闪耀 染上真红的羽翼披风斩月",
              time = 8.5
            },
            {
              starttime = 74.7,
              str = "争奇斗艳 椿色恋歌 向着春风"
            },
            {
              starttime = 81.1,
              str = "金铁交鸣  灵魂上的攻防 如今我不会退缩"
            },
            {
              starttime = 87.8,
              str = "争奇斗艳 椿色恋歌 承载着思念"
            },
            {
              starttime = 94.5,
              str = "寄托于你 向着未知的未来张开翅膀"
            },
            {
              starttime = 101,
              str = "The Biggest Love"
            },
            {
              starttime = 104.4,
              str = "To Be Loved Ever"
            },
            {
              starttime = 107.7,
              str = "The Biggest Love"
            },
            {
              starttime = 111,
              str = "To Be Loved Ever",
              time = 3
            }
          },
          color = "FFFF7A99"
        })
      end)
      ac.wait(32000, function()
        SetSoundVolume(BGM_Chun_01, 127)
      end)
      u:deldata("椿-里幻剑惩罚")
      u:adddivinity(2)
      u:addskill("S07M")
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.95, 1)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      u:changedata("全属性增幅", 0.015 * u:getstate("战士变异"))
      u:changedata("闪避值", 15)
      ChangeValue(HeroMenu_Sbxs, sy, 0.1)
      ac.wait(240000, function()
        if u:getdata("椿-里幻剑复活限制") == 0 and u:hasdata("椿-里幻剑复活限制") then
          ac.wait(100, function()
            StopSoundBJ(BGM_Chun_02, false)
            local x, y = u:getxy()
            local tx = Effectcreate("0Tx\\0Tx_Chun (15).mdl", x, y)
            u:effectadd("war3mapImported\\[ake]war3ake.com - 7346841038772226188179609.mdx", "origin", -1)
            u:shanmo(70)
          end)
        end
      end)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") then
          if u:hasdata("椿-火之迦具土命") then
            u:deldata("椿-火之迦具土命")
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            local angle = AngleXY(x, y, x2, y2)
            local dis = DistanceXY(x, y, x2, y2)
            if 1000 <= dis then
              dis = 1000
            end
            u:playsound(Sound_Katana_20)
            local txsh = 88 * u:getallattri()
            Effectcreate("AATX\\[AATxNew]Katana19.mdl", x, y, 0, 1.25, 0, 0, angle)
            u:buffset(u.handle, 0.15, "绝对闪避")
            local g = CreateGroupLua()
            unitmove({
              unit = u.handle,
              time = 0.15,
              distance = dis,
              angle = angle,
              loops = {
                {
                  looptime = 0.015,
                  func = function(dx, dy)
                    Effectcreate("AATX\\[AATxNew]Fire23.mdl", dx, dy)
                    Effectcreate("war3mapImported\\blackblink.mdx", dx, dy)
                    local dx2, dy2 = PolarXY(dx, dy, GetRandomReal(0, 150), GetRandomAngle())
                    Effectcreate("AATX\\[AATxNew]Red40.mdl", dx2, dy2)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 250):is_enemy(u.handle):isnotingroup(g):ipairs() do
                      xq = getunit(xq)
                      xq:groupadd(g)
                      DamageUnit({
                        bj = "椿-火之迦具土命",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "灵力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "火"
                      })
                      xq:buffset(u.handle, 0.5, "眩晕")
                      xq:effectadd("AATX\\[AATxNew]Fire20.mdl", "chest")
                      xq:effectadd("war3mapImported\\texiao_xuebao.mdx", "chest")
                    end
                  end
                }
              },
              endfunc = function()
                u:playsound(Sound_Katana_02)
                u:playsound(Sound_Katana_18)
              end
            })
            modelchange({
              unit = u.handle,
              model = "Hero\\Hero_Chun.mdl",
              modelsize = 1.03,
              modelact = 11,
              modelactspeed = 1,
              time = 0.15,
              sfunc = function(mj)
                local dx, dy = mj:getxy()
                Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              end,
              efunc = function(mj)
                local dx, dy = mj:getxy()
                Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              end
            })
          end
          if u:hasdata("椿-浴火鸟位移") then
            u:deldata("椿-浴火鸟位移")
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            local angle = AngleXY(x, y, x2, y2)
            local dis = DistanceXY(x, y, x2, y2)
            if 800 <= dis then
              dis = 800
            end
            local dx, dy = PolarXY(x, y, dis, angle)
            u:playsound(Sound_Katana_16)
            u:buffset(u.handle, 0.15, "绝对闪避")
            u:curetili(-0.5)
            local txsh = 88 * u:getallattri()
            Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
            Effectcreate("ATX\\[ATxNew]Black_01.mdl", dx, dy)
            Effectcreate("effect\\Chun_11.mdl", dx, dy, 0.5, 2)
            Effectcreate("effect\\Chun_10.mdl", dx, dy)
            u:setxy(dx, dy)
            for _, xq in ac.selector():in_rangexy(dx, dy, 450):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "椿-浴火鸟位移",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "灵力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "火"
              })
              xq:buffset(u.handle, 0.5, "眩晕")
              xq:effectadd("AATX\\[AATxNew]Fire20.mdl", "chest")
            end
          end
        end
      end)
      u:uivar_change({
        keyname = "刀仕禰宜",
        keytype = "传奇栏",
        text = "|cFFFFCCFF绊き|r|cFFFFA3CCらめ|r|cFFFF7A99く恋い|r|cFFFF5266ろは|r\n|cFFFF5266神性 3\n刀仕襧宜|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266神速|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266幻剑|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266黄泉凤凰|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266火之迦具土命|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266浴火鸟|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266真*里炎姬|r\n|cFFFFCCFF[数据删除]|r",
        icon = "war3mapImported\\PASBTNEwl_Chun_05",
        cd = 60,
        clickfunc = function(u, button)
          if not u:hasdata("朱雀院椿-BOSS战") and BossBattle and u:isalive() and Group_Counts(Group_Xingcunzu) <= 1 and u:isexist() then
            StopSoundBJ(BGM, true)
            ac.wait(3000, function()
              BGM = BGM_Chun_03
              PlayBGM({
                bgm = BGM,
                time = 0,
                ID = 111,
                unit = u.handle
              })
            end)
            u:setdata("朱雀院椿-BOSS战")
            local tz = getunit(NPC_TIANZI)
            tz:setdata("环境变更")
            tz:setdata("椿天气切换")
            ChangeValue(DamageSystem_Shjc, sy, 0.02)
            ChangeValue(DamageSystem_Shjc, sy, 0.02)
            ChangeValue(DamageSystem_Shjc, sy, 0.02)
            PlayGlobalSound(Sound_Chun_35)
            SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『这里啊是我的领域』|r")
            flashphoto({
              photo = "war3mapImported\\Chun_Lzz_1.tga",
              timeout = 1,
              timehold = 3.5,
              timein = 4
            })
            ac.wait(4000, function()
              flashphoto({
                photo = "war3mapImported\\Chun_Lzz_2.tga",
                timeout = 0,
                timehold = 4.5,
                timein = 4
              })
              PlayGlobalSound(Sound_Chun_34)
              SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『无论是谁只要靠近,我都会毫不留情的将其切成碎片』|r")
            end)
            ac.wait(9000, function()
              flashphoto({
                photo = "war3mapImported\\Chun_Lzz_3.tga",
                timeout = 0,
                timehold = 1.2,
                timein = 4
              })
              SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『为了使其无法再次反抗我，彻底的』|r")
            end)
            ac.wait(10700, function()
              flashphoto({
                photo = "war3mapImported\\Chun_Lzz_4.tga",
                timeout = 0,
                timehold = 1.5,
                timein = 2
              })
            end)
          end
        end
      })
    end
  end,
  ["队长禁忌"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-队长禁忌"
    if not u:hasdata(str) then
      u:setdata(str)
      NameID[sy] = "|cFFFFCC00基尔什塔利亚·沃戴姆|r"
      u:setplayername(NameID[sy])
      local wp = u:getitem("I0EF")
      ChangeItemCount(wp, -600)
      local data = {
        {
          text = "|cFFFFCC00基尔什塔利亚·沃戴姆：『我的目的很单纯。既然现在的人类无法做到的话，那我就将其变革。』|r",
          time = 0.7
        },
        {
          text = "|cFFFFCC00基尔什塔利亚·沃戴姆：『没错，从现在开始，生活在这地球上的所有的人类都将获得新生。』|r",
          time = 10
        },
        {
          text = "|cFFFFCC00基尔什塔利亚·沃戴姆：『这就是我的计划，开拓崭新的神代世界，任何人都能成为与神同等的存在。』|r",
          time = 19.5
        },
        {
          text = "|cFFFFCC00基尔什塔利亚·沃戴姆：『消除所有的不平等，终有一天孕育出可以抵达世界根源的知性个体。』|r",
          time = 30.6
        },
        {
          text = "|cFFFFCC00基尔什塔利亚·沃戴姆：『人类在这一天击溃神明这一概念！』|r",
          time = 40.9
        }
      }
      NPCChat({
        name = "|cFFFFCC00基尔什塔利亚·沃戴姆",
        chaticon = "Chat_Duizhang.blp",
        chattext = {
          {
            time = 47.9,
            text = "|cFFFFCC00这就是我的冠位指定，穷极我的一生也必须实现的梦想。"
          },
          {
            time = 57.3,
            text = "|cFFFFCC00如果要否定的话，请务必真心回答我。"
          },
          {
            time = 64.7,
            text = "|cFFFFCC00我是基尔什塔利亚·沃戴姆"
          },
          {
            time = 69,
            text = "|cFFFFCC00作为|r|cFFFFFF66隐匿者，|r|cFFFFCC00否定泛人类史之人"
          },
          {
            time = 74.5,
            text = "|cFFFFCC00是你们|r|cFF3366FF迦勒底|r|cFFFFCC00的|r|cFFFF0000敌人|r"
          },
          {
            time = 77.7,
            text = "|cFFFFCC00也是为守护|r|cFF9999FF人理|r|cFFFFCC00而战的"
          },
          {
            time = 81,
            text = "|cFFFFCC00A组的队长"
          }
        }
      })
      for index, value in ipairs(data) do
        SendDtimeMsgAll(value.time, value.text, 30)
      end
      PlayGlobalSound(Sound_Duizhang_05)
      ac.wait(47700.0, function()
        PlayGlobalSound(Sound_Duizhang_06)
        ac.wait(35400, function()
          NameID[sy] = "|cFFFFCC00Kirschtaria Wodime|r"
          u:setplayername(NameID[sy])
          PlayGlobalSound(BGM_Duizhang_02)
          songtext({
            text = {
              {
                starttime = 1.8,
                str = "如果说获得是胜利的话"
              },
              {
                starttime = 6.4,
                str = "那放手就意味着失败吗"
              },
              {
                starttime = 11.2,
                str = "谁也不会受伤的世界"
              },
              {
                starttime = 15.8,
                str = "或许只是一句漂亮话"
              },
              {
                starttime = 18.7,
                str = "即使如此 我仍想放手一搏",
                time = 3.1
              },
              {
                starttime = 39.7,
                str = "刚好是在这样的月夜"
              },
              {
                starttime = 43.8,
                str = "钟声响起 宣告时间"
              },
              {
                starttime = 48.5,
                str = "残响 仿佛把空壳般的我"
              },
              {
                starttime = 53.2,
                str = "完全看透了一般"
              },
              {
                starttime = 57.8,
                str = "愤怒与哀叹 仅一瞬间"
              },
              {
                starttime = 62.6,
                str = "便在人与人之间传递"
              },
              {
                starttime = 67.2,
                str = "是否制造出不存在的敌人"
              },
              {
                starttime = 72.3,
                str = "便能让战火奋勇燃起呢"
              },
              {
                starttime = 76.6,
                str = "奔跑下去的理由"
              },
              {
                starttime = 81.3,
                str = "无论有多么荒诞 也没关系"
              },
              {
                starttime = 83.7,
                str = "炽热的 快速的 回响着的心跳"
              },
              {
                starttime = 90,
                str = "唯有这毫无虚假的跃动"
              },
              {
                starttime = 94,
                str = "请侧耳倾听吧",
                time = 6
              },
              {
                starttime = 114.9,
                str = "绝对的正义"
              },
              {
                starttime = 117,
                str = "不曾动摇的法则"
              },
              {
                starttime = 119.9,
                str = "被人们称作命运"
              },
              {
                starttime = 121.5,
                str = "这一连串的偶然"
              },
              {
                starttime = 124.5,
                str = "还要相信到什么时候才好呢"
              },
              {
                starttime = 129.1,
                str = "或许早已经遭到背叛"
              },
              {
                starttime = 131.2,
                str = "虽然我并不这样觉得"
              },
              {
                starttime = 135.1,
                str = "用手指描摹着天球仪"
              },
              {
                starttime = 137.1,
                str = "曾触碰过多次的星座"
              },
              {
                starttime = 142.3,
                str = "将会在候鸟起飞之时"
              },
              {
                starttime = 147.4,
                str = "升上拂晓的赤红天空"
              },
              {
                starttime = 154,
                str = "未来无限接近自由"
              },
              {
                starttime = 158.6,
                str = "同时又面对着束缚"
              },
              {
                starttime = 163.3,
                str = "如果放弃了抉择"
              },
              {
                starttime = 168.5,
                str = "就再也无法回头"
              },
              {
                starttime = 170,
                str = "请侧耳倾听 那宣告时间的钟声吧",
                time = 7.16
              },
              {
                starttime = 191.3,
                str = "越是反抗 越会遭到束缚"
              },
              {
                starttime = 196.1,
                str = "越是渴望 越会被人剥夺"
              },
              {
                starttime = 200.85,
                str = "谁都能得到原谅的世界"
              },
              {
                starttime = 205.5,
                str = "或许只是一句漂亮话吧"
              },
              {
                starttime = 208.3,
                str = "即使如此 我仍然不想放弃"
              },
              {
                starttime = 210,
                str = "奔跑下去的理由"
              },
              {
                starttime = 214.88,
                str = "无论有多么荒诞 也没关系"
              },
              {
                starttime = 219.4,
                str = "炽热的 快速的 回响着的心跳"
              },
              {
                starttime = 223.98,
                str = "只要相信这毫无虚假的跃动"
              },
              {
                starttime = 230,
                str = "侧耳倾听"
              },
              {
                starttime = 231.3,
                str = "那宣告时间的钟声吧",
                time = 8
              }
            },
            color = {"FFFFCC00"}
          })
        end)
      end)
      ac.wait(64700, function()
        flashphoto({
          photo = "war3mapImported\\Ph_Duizhang_01.tga",
          timeout = 5,
          timehold = 8,
          timein = 5
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 18, "绝对闪避")
        end)
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.24)
      ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
      ChangeValue(Hero_Tili_Huifu, sy, 0.25)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1)
      ChangeValue(Revise_PoisonResist, sy, 1)
      PlayBGM({
        bgm = 0,
        time = 334,
        ID = 129,
        unit = u.handle
      })
      local dskill = S2ID("A1NR")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local tg = getunit(args.target)
          local dis = DistanceBetweenUnits(u.handle, tg.handle)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if not BossBattle then
            b = false
            u:sendmessage("|cFF7DBEF1不存在BOSS|r")
          end
          if b then
            ewl:delskill("A1NR")
            MovieAct["队长宝具"](u)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "隐匿者",
        keytype = "传奇栏",
        text = "|cFF3366FF「天不旋」\n[人理保障]|r\n|cFFFF6600「地不动」\n[人理保障]|r\n|cFFFFCC00「人理填充」\n我的目的早已宣告，我们积累了太多的错误，这就是我的回答。|r",
        icon = "war3mapImported\\PASBTNEwl_Duizhang_03"
      })
    end
  end,
  ["忍野忍禁忌（光）"] = function(u)
    local sy = u.ownerid
    local str = OshinoTaboo.LIGHT_FLAG
    if not u:hasdata(str) then
      u:setdata(str)
      set_oshino_color_name(u, "☆忍☆野☆忍☆", {
        "FDF2B6",
        "FEC65B",
        "CC0000",
        "FEC65B",
        "FDF2B6"
      })
      start_oshino_element_panel_bonus(u, Damage_Element_Light)
      u:adddivinity(1)
      u:changedata("人类变异数量", 1)
      ChangeValue(DamageSystem_Baoji, sy, 100)
      u:setdata("忍野忍-甜腻层数上限", OshinoTaboo.SWEET_STACK_CAP)
      u:setdata("忍野忍-禁忌终局复活次数", OshinoTaboo.initial_final_revives(u:getdata("忍野忍-甜食值")))
      if u:getlevel() >= 75 then
        u:setdata("忍野忍-禁忌光等级重置")
        u:setlevel(1)
      end
      PlayBGM({
        bgm = BGM_Ryr_Jinji_Guang,
        time = 275,
        ID = 271,
        unit = u.handle
      })
      musiccolortext({
        mode = "slope_rise",
        showtexttime = 0.8,
        showtime = 0.9,
        enter_interval_ms = 35,
        staytime = 4.4,
        fadetime = 2.6,
        fade_interval_ms = 35,
        sy_ranges = {
          {min = 720, max = 750}
        },
        str_spacing = 40,
        slope_ranges = {
          {-1, -0.5},
          {0.5, 1}
        },
        rise_y = 90,
        spread_x = 7,
        float_y = 50,
        translation_offset_y = 55,
        translation_spacing = 42,
        translation_center = true,
        color = {
          "00A9D8FF",
          "FFA9D8FF",
          "FFFFD27A"
        },
        translation_color = {
          "00FFD27A",
          "FFA9D8FF",
          "FFFFD27A"
        },
        strz = {
          {
            starttime = 14.94,
            str = "昨日なんて 通り過ぎた後は",
            translation = "昨天的事情 在经过之后"
          },
          {
            starttime = 22.12,
            str = "そう すぺてが 些細なことになる",
            translation = "没错 所有的一切 便都成了琐碎的小事"
          },
          {
            starttime = 29.5,
            str = "今も残る いつかの 傷あとの",
            translation = "至今依旧残留着 曾经的伤痕"
          },
          {
            starttime = 36.74,
            str = "痛みさえ もう 忘れてしまってた",
            translation = "那份疼痛 我也早已忘却"
          },
          {
            starttime = 43.46,
            str = "ねえ 君に出逢った瞬間に",
            translation = "呐 与你相遇的瞬间"
          },
          {
            starttime = 47.079,
            str = "運命は 塗り替えられちゃって",
            translation = "我的命运 仿佛涂上全新的色彩"
          },
          {
            starttime = 50.779,
            str = "こわいものなど もう びとつだけ",
            translation = "害怕的事情 只剩下那么一个"
          },
          {
            starttime = 56.659,
            str = "私の 全部を ひきかえにしても",
            translation = "这是我第一次"
          },
          {
            starttime = 64.149,
            str = "守りたいと思ったのは",
            translation = "不惜牺牲我的全部"
          },
          {
            starttime = 68.209,
            str = "はじめてなんだ",
            translation = "去将一个人守护"
          },
          {
            starttime = 71.239,
            str = "この世に 生まれた 理由はなくても",
            translation = "就算没有诞生在这个世界的理由"
          },
          {
            starttime = 78.798,
            str = "でも 確かに 生きてる 意味",
            translation = "但是 确实活在当下的意义"
          },
          {
            starttime = 83.418,
            str = "私は もう みつけたらから",
            translation = "我已经找到了"
          },
          {
            starttime = 104.698,
            str = "悴む空 どんな季節よりも",
            translation = "冰冷的天空 却比任何季节"
          },
          {
            starttime = 111.908,
            str = "輝いてる あの星たちのように",
            translation = "都还要闪耀的星辰"
          },
          {
            starttime = 119.258,
            str = "冬の凛と はりつめた空気に",
            translation = "在冬夜遍布凛然的空气里"
          },
          {
            starttime = 126.568,
            str = "研ぎ澄まされたこころが囁く",
            translation = "洗涤后的心灵 细声呢喃"
          },
          {
            starttime = 133.228,
            str = "想い通りに ならないのなら",
            translation = "如果无法如我所愿"
          },
          {
            starttime = 136.697,
            str = "運命を 変えちゃえばいいから",
            translation = "那把命运扭转就好"
          },
          {
            starttime = 140.537,
            str = "だいじなものは そう ひとつだけ",
            translation = "重要的事物 只有一个"
          },
          {
            starttime = 146.367,
            str = "私の 全部を ひきかえにしても",
            translation = "这是我第一次"
          },
          {
            starttime = 153.897,
            str = "守りたいと思ったのは",
            translation = "不惜牺牲我的全部"
          },
          {
            starttime = 157.977,
            str = "はじめてなんだ",
            translation = "去将一个人守护"
          },
          {
            starttime = 160.957,
            str = "この世に 生まれた 理由はなくても",
            translation = "就算没有诞生在这个世界的理由"
          },
          {
            starttime = 168.507,
            str = "でも 確かに 生きてる 意味",
            translation = "但是 确实活在当下的意义"
          },
          {
            starttime = 173.547,
            str = "私は もう みつけたから",
            translation = "我已经找到了"
          },
          {
            starttime = 205.147,
            str = "私の 全部を ひきかえにしても",
            translation = "这是我第一次"
          },
          {
            starttime = 212.577,
            str = "守りたいと思ったのは",
            translation = "不惜牺牲我的全部"
          },
          {
            starttime = 216.637,
            str = "はじめてなんだ",
            translation = "去将一个人守护"
          },
          {
            starttime = 219.607,
            str = "この世に 生まれた 理由はなくても",
            translation = "就算没有诞生在这个世界的理由"
          },
          {
            starttime = 227.157,
            str = "でも 確かに 生きてる 意味",
            translation = "但是 确实活在当下的意义"
          },
          {
            starttime = 231.977,
            str = "私は もう みつけたから",
            translation = "我已经找到了"
          },
          {
            starttime = 238.127,
            str = "私の 全部を ひきかえにしても",
            translation = "这是我第一次"
          },
          {
            starttime = 245.647,
            str = "守りたいと思ったのは",
            translation = "不惜牺牲我的全部"
          },
          {
            starttime = 249.537,
            str = "はじめてなんだ",
            translation = "去将一个人守护"
          },
          {
            starttime = 252.737,
            str = "この世に 生まれた 理由はなくても",
            translation = "就算没有诞生在这个世界的理由"
          },
          {
            starttime = 260.237,
            str = "でも 確かに 生きてる 意味",
            translation = "但是 确实活在当下的意义"
          },
          {
            starttime = 264.767,
            str = "私は もう みつけたから",
            translation = "我已经找到了"
          }
        }
      })
      u:removeitem(OshinoTaboo.DONUT_GIFT_BOX_ITEM)
      for _, entry in ipairs(Pools_food) do
        if entry.item == OshinoTaboo.DONUT_GIFT_BOX_ITEM then
          ac.loop(OshinoTaboo.FINE_DONUT_INTERVAL_MILLISECONDS, function()
            entry.effect(entry, u)
          end)
          break
        end
      end
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        if not u:hasdata(str .. "-光抹除附伤冷却") then
          u:settimedata(str .. "-光抹除附伤冷却", OshinoTaboo.LIGHT_ATTACHMENT_COOLDOWN)
          DamageUnit({
            bj = "忍野忍禁忌光附伤",
            unit = tg.handle,
            source = u.handle,
            damage = OshinoTaboo.light_attachment_damage(u:getallattri()),
            level = 1,
            type = "物理",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "光",
            extradata = {
              "系统-本次伤害无视伤害抗性"
            }
          })
        end
      end)
      u:uivar_change({
        keyname = "忍野忍",
        keytype = "传奇栏",
        text = "|cFFFDF2B6☆忍|r|cFFFEDC88☆野|r|cFFFEC65B☆忍☆|r\n|cFFFDF2B6『万缕金发垂素雪，眸中漾碎流金。』|r\n|cFFFDF2B6『轻裙曳影伴幽岑。』|r\n|cffff8757『口衔甜饵在，娇靥带憨深。』|r\n|cffff8928『曾作暗夜君王客，沧桑锁入童心。』|r\n|cffd82d27『浮生羁绊系知音。』|r\n|cffb41b1b『千年寥落意，都付一糖斟。』|r",
        icon = "Ryr_Jinji_Guang",
        isclearclick = true,
        ishasphoto = true,
        jbtext = function()
          UIYNameCount = 2
          UIYName[1] = {
            method = 1,
            name = "☆忍☆野☆忍☆",
            colors = {
              "FDF2B6",
              "FEC65B",
              "CC0000",
              "FEC65B",
              "FDF2B6"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.25,
            extratext = "\n"
          }
          UIYName[2] = {
            method = 1,
            name = "『万缕金发垂素雪，眸中漾碎流金。』\n『轻裙曳影伴幽岑。』\n『口衔甜饵在，娇靥带憨深。』\n『曾作暗夜君王客，沧桑锁入童心。』\n『浮生羁绊系知音。』\n『千年寥落意，都付一糖斟。』",
            colors = {
              "FDF2B6",
              "FEC65B",
              "CC0000",
              "FEC65B",
              "FDF2B6"
            },
            length = 5,
            lengthcd = 100,
            math = 1,
            offsetspeed = 2,
            extratext = ""
          }
        end
      })
      add_fine_donut_uivar(u)
    end
  end,
  ["忍野忍禁忌（暗）"] = function(u)
    local str = OshinoTaboo.DARK_FLAG
    if not u:hasdata(str) then
      u:setdata(str)
      set_oshino_color_name(u, "★姬丝秀忒·雅赛劳拉莉昂·刃下心★", {
        "990000",
        "6C5959",
        "FFCC33",
        "6C5959",
        "990000"
      })
      start_oshino_element_panel_bonus(u, Damage_Element_Dark)
      u:adddivinity(1)
      u:getgoddessforce(3, true)
      Boolean_Ryr_TabooNight = true
      u:addstexiao(str, "伤害格挡效果", function(args)
        if args.u ~= u or args.b then
          return
        end
        if u:getgedangrandom(OshinoTaboo.dark_block_chance(u:getdata("忍野忍-甜食值"))) then
          args.b = true
          u:sendmessage("|cFF990000[姬丝秀忒]伤害格挡")
        end
      end)
      u:removeitem(OshinoTaboo.DONUT_GIFT_BOX_ITEM)
      for _, entry in ipairs(Pools_food) do
        if entry.item == OshinoTaboo.DONUT_GIFT_BOX_ITEM then
          ac.loop(OshinoTaboo.FINE_DONUT_INTERVAL_MILLISECONDS, function()
            entry.effect(entry, u)
          end)
          break
        end
      end
      PlayBGM({
        bgm = BGM_Ryr_Jinji_An01,
        time = 415,
        ID = 272,
        unit = u.handle
      })
      NPCChat({
        name = "|cFFCC0000姬|r|cFFB81414丝|r|cFFA32929秀|r|cFF8F3D3D忒|r",
        chaticon = "Chat_Ryr_Daren.tga",
        chattext = {
          {
            text = "|cff971313我也是正想要成为这样的怪物|r",
            time = 1
          },
          {
            text = "|cff971313想变的和你一样|r",
            time = 6
          },
          {
            text = "|cff971313和你一样，冷酷，坚强，温柔而美丽的吸血鬼|r",
            time = 8
          },
          {
            text = "|cff971313你的话一定可以的，雅赛劳拉公主|r",
            time = 18
          },
          {
            text = "|cff971313姬丝秀忒·雅赛劳拉莉昂·刃下心|r",
            time = 24
          },
          {
            text = "|cff971313这就是你的名字，姬丝秀忒|r",
            time = 28
          },
          {
            text = "|cff971313像是亲吻一般，吃下那些为你而死的人们吧|r",
            time = 32
          },
          {
            text = "|cff971313获得了永恒的生命，一直活下去的话，说不定还能遇到你命中注定的王子殿下|r",
            time = 38
          },
          {
            text = "|cff971313姬丝秀忒·雅赛劳拉莉昂·刃下心，我很中意，殊杀尊主，迪斯托比亚·威尔图奥佐·殊杀尊主|r",
            time = 46
          },
          {
            text = "|cff971313太棒了，我非常开心。为了不给您，以及您赋予的这个名字蒙羞而努力的努力的吸血鬼，小女子会努力的|r",
            time = 61
          },
          {
            text = "|cff971313你就努力上进吧|r",
            time = 73
          },
          {
            text = "|cff971313对了，对了 说到上进教你最后一课，非常高兴地时候要这样笑|r",
            time = 76
          },
          {
            text = "|cff971313哈|r",
            time = 83.6
          },
          {
            text = "|cff971313哈哈|r",
            time = 85
          },
          {
            text = "|cff971313哈哈哈|r",
            time = 86.6
          },
          {
            text = "|cff971313哈哈哈哈|r",
            time = 88.2
          },
          {
            text = "|cff971313啊哈|r",
            time = 89.7
          },
          {
            text = "|cff971313哈哈哈哈哈|r",
            time = 90.6
          },
          {
            text = "|cff971313啊哈哈|r",
            time = 92.3
          },
          {
            text = "|cff971313呼哈哈哈哈哈|r",
            time = 94
          },
          {
            text = "|cff971313嗯哈哈|r",
            time = 96
          },
          {
            text = "|cff971313啊哈哈哈哈哈|r",
            time = 97
          },
          {
            text = "|cff971313啊哈哈……|r",
            time = 99.2
          },
          {
            text = "|cff971313哈哈哈哈|r",
            time = 100.4
          },
          {
            text = "|cff971313啊哈哈哈哈|r",
            time = 101.8
          },
          {
            text = "|cff971313呼哈哈哈哈哈|r",
            time = 103.4
          },
          {
            text = "|cff971313啊哈哈----|r",
            time = 104.3
          },
          {
            text = "|cff971313呼哈哈哈哈哈哈……|r",
            time = 106.8
          },
          {
            text = "|cff971313哼哈哈哈……|r",
            time = 108.9
          },
          {
            text = "|cff971313哈哈……|r",
            time = 110.3
          },
          {
            text = "|cff971313请您慢用|r",
            time = 116
          },
          {
            text = "|cff971313没什么大不了的，杀死后吃下，杀死并爱上，吃与爱是同一种意思|r",
            time = 131
          }
        }
      })
      ac.wait(143000, function()
        PlayGlobalSound(BGM_Ryr_Jinji_An02)
        musiccolortext({
          mode = "slope_shake",
          strz = {
            {
              starttime = 13.744,
              str = "黒い闇の中",
              translation = "在黑暗中"
            },
            {
              starttime = 19.924,
              str = "そっと咲いてた",
              translation = "悄悄绽放的"
            },
            {
              starttime = 25.764,
              str = "はじめての心",
              translation = "初次的心意"
            },
            {
              starttime = 31.114,
              str = "君はきっと知らない",
              translation = "你一定毫不知情"
            },
            {
              starttime = 36.804,
              str = "差し伸べてくれた手を",
              translation = "你伸出的手"
            },
            {
              starttime = 42.714,
              str = "つかめずにいる私は",
              translation = "没能握住 这样的我"
            },
            {
              starttime = 48.734,
              str = "あと少しもう少し",
              translation = "还要再一点点 一点点"
            },
            {
              starttime = 54.594,
              str = "君にもっと求めている",
              translation = "再继续追逐你"
            },
            {
              starttime = 60.734,
              str = "それはひとすじの光",
              translation = "那是黑暗中的一束光芒"
            },
            {
              starttime = 70.944,
              str = "心の行方を",
              translation = "而心的去向"
            },
            {
              starttime = 75.454,
              str = "今は まだ知りたくない",
              translation = "现在我还不想知道",
              staytime = 4
            },
            {
              starttime = 107.153,
              str = "黒い闇の中",
              translation = "在黑暗中"
            },
            {
              starttime = 112.623,
              str = "そっと咲いてた",
              translation = "悄悄绽放的"
            },
            {
              starttime = 118.503,
              str = "はじめての心",
              translation = "初次的心意"
            },
            {
              starttime = 123.773,
              str = "今日も云えないままで",
              translation = "此时此刻也未说出口"
            },
            {
              starttime = 130.032,
              str = "あきらめたふりをして",
              translation = "假装死心的样子"
            },
            {
              starttime = 135.932,
              str = "期待してしまっている",
              translation = "却暗暗期待着"
            },
            {
              starttime = 141.572,
              str = "君になら君となら",
              translation = "正因为是你 正因在你身边"
            },
            {
              starttime = 147.822,
              str = "だからこそ怯えている",
              translation = "正因为如此才会害怕"
            },
            {
              starttime = 153.612,
              str = "それは あたたかな光",
              translation = "那才是温暖的光"
            },
            {
              starttime = 164.242,
              str = "多分今はまだ",
              translation = "大概现在"
            },
            {
              starttime = 170.012,
              str = "きっと夜明け前",
              translation = "还没到黎明前"
            },
            {
              starttime = 176.311,
              str = "君のとなり微睡みながら",
              translation = "我要在你的身边闭上眼睛"
            },
            {
              starttime = 183.481,
              str = "明日を待ってる",
              translation = "一直到明天",
              staytime = 4
            },
            {
              starttime = 211.07,
              str = "差し伸べてくれた手を",
              translation = "你伸出的手"
            },
            {
              starttime = 216.77,
              str = "つかめずにいる私は",
              translation = "没能握住 这样的我"
            },
            {
              starttime = 223.04,
              str = "あと少しもう少し",
              translation = "还要再一点点 一点点"
            },
            {
              starttime = 228.81,
              str = "君にばかり求めている",
              translation = "再继续追逐你"
            },
            {
              starttime = 234.829,
              str = "それはひとすじの光",
              translation = "那是黑暗中的一束光芒"
            },
            {
              starttime = 244.899,
              str = "はじめての心",
              translation = "初次的心意"
            },
            {
              starttime = 249.949,
              str = "君に 気付いてほしくて",
              translation = "希望你能感知到"
            }
          },
          color = {"FFFFE96A", "FFA01212"},
          translation_color = {"FF811414", "FF811414"},
          sy = 680,
          sy_ranges = {
            {min = 440, max = 660}
          },
          str_spacing = 42,
          slope_ranges = {
            {min = -1.2, max = -0.8},
            {min = 0.8, max = 1.2}
          },
          left_offset_x = {min = 200, max = 400},
          right_offset_x = {min = 200, max = 400},
          str_shake = 1,
          translation_shake = 1,
          float_y = 35,
          translation_offset_y = 48,
          translation_spacing = 42,
          translation_center = true
        })
      end)
      u:uivar_change({
        keyname = "忍野忍",
        keytype = "传奇栏",
        text = "|cFF990000★姬|r|cFF960606丝|r|cFF930D0D秀|r|cFF8F1313忒|r|cFF8C1A1A·|r|cFF892020雅|r|cFF862626赛|r|cFF832D2D劳|r|cFF803333拉|r|cFF7C3939莉|r|cFF794040昂|r|cFF764646·|r|cFF734C4C刃|r|cFF705353下|r|cFF6C5959心★|r\n|cFF990000『日无光，月无华。』|r\n|cFF901111『吾已降临，天地失色，』|r\n|cFF882222『风月悄然静默，万物尽仰仙颜。』|r\n|cFF803333『朝夕停轮，星河敛影，』|r\n|cFF774444『此间天地，唯我独存。』|r",
        icon = "Ryr_Jinji_An",
        isclearclick = true,
        ishasphoto = true,
        jbtext = function()
          UIYNameCount = 2
          UIYName[1] = {
            method = 1,
            name = "★姬丝秀忒·雅赛劳拉莉昂·刃下心★",
            colors = {
              "990000",
              "6C5959",
              "FFCC33",
              "6C5959",
              "990000"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.25,
            extratext = "\n"
          }
          UIYName[2] = {
            method = 1,
            name = "『日无光，月无华。』\n『吾已降临，天地失色，』\n『风月悄然静默，万物尽仰仙颜。』\n『朝夕停轮，星河敛影，』\n『此间天地，唯我独存。』",
            colors = {
              "990000",
              "6C5959",
              "FFCC33",
              "6C5959",
              "990000"
            },
            length = 5,
            lengthcd = 100,
            math = 1,
            offsetspeed = 2,
            extratext = ""
          }
        end
      })
      add_fine_donut_uivar(u)
    end
  end
})
