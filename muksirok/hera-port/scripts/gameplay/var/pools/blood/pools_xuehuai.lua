-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local AdvanceHelpers = require("gameplay.var.advance.helpers")
local get_konglv = false
local get_leilv = false
local leilv_caidan = false
local leilv

local function leilvcaidan()
  local u = leilv
  local idyayi = u:getplayername()
  local idjx = "|cFF8A2BE2九|r|cFF9C36C5霄|r"
  local idqyn = "|cFFFFFFFF琪|r|cFFE2CAF8亚|r|cFFC495F0娜|r"
  local kl = false
  local t = 30
  if u:hasdata("特殊判定-雷律初始") then
    t = 290
  else
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq.handle ~= u.handle and xq:hasdata("变异判定-空之律者") then
        kl = true
        idqyn = xq:getplayername()
      end
    end)
  end
  PlayBGM({
    bgm = 0,
    time = t,
    ID = 168,
    unit = u.handle
  })
  PlayGlobalSound(Sound_Leilv_Caidan)
  SendDtimeMsgAll(0, idyayi .. "|cFF6699FF：『琪|r|cFF658EF6亚|r|cFF6383ED娜|r|cFF6278E4，|r|cFF616DDB我|r|cFF5F62D2…|r|cFF5E57C9…|r|cFF5C4DBF我|r|cFF5B42B6是|r|cFF5A37AD律|r|cFF582CA4者|r|cFF57219B…|r|cFF561692…』|r")
  SendDtimeMsgAll(5.4, idyayi .. "|cFF6699FF：|r|cFF6590F8『|r|cFF6487F0我|r|cFF637EE9曾|r|cFF6275E1经|r|cFF606CDA想|r|cFF5F63D2要|r|cFF5E5ACB毁|r|cFF5D51C3灭|r|cFF5C48BC这|r|cFF5B3FB4个|r|cFF5A36AD世|r|cFF592DA5界|r|cFF57249E…|r|cFF561B96…|r|cFF55128F』|r")
  SendDtimeMsgAll(8.5, idyayi .. "|cFF6699FF：|r|cFF6590F8『|r|cFF6487F0即|r|cFF637EE9使|r|cFF6275E1这|r|cFF606CDA样|r|cFF5F63D2，|r|cFF5E5ACB我|r|cFF5D51C3也|r|cFF5C48BC算|r|cFF5B3FB4是|r|cFF5A36AD人|r|cFF592DA5类|r|cFF57249E吗|r|cFF561B96？|r|cFF55128F』|r")
  SendDtimeMsgAll(12.6, idjx .. "|cFFAA4B81：|r|cFFA14481『|r|cFF993C81哼|r|cFF903481哼|r|cFF872D81，|r|cFF7F2681安|r|cFF761E80心|r|cFF6D1680吧|r|cFF640F80』|r")
  SendDtimeMsgAll(15.5, idjx .. "|cFFAA4B81：|r|cFFA74881『|r|cFFA34581我|r|cFFA04281可|r|cFF9D3F81以|r|cFF993D81负|r|cFF963A81责|r|cFF933781地|r|cFF8F3481告|r|cFF8C3181诉|r|cFF892E81你|r|cFF852B81，|r|cFF822881九|r|cFF7F2580霄|r|cFF7B2380大|r|cFF782080人|r|cFF741D80认|r|cFF711A80可|r|cFF6E1780了|r|cFF6A1480你|r|cFF671180的|r|cFF640E80灵|r|cFF600C80魂|r|cFF5D0980！|r|cFF5A0680』|r")
  SendDtimeMsgAll(21, idjx .. "|cFFAA4B81：|r|cFFA74981『|r|cFFA54681在|r|cFFA24481九|r|cFF9F4281霄|r|cFF9C3F81大|r|cFF9A3D81人|r|cFF973B81的|r|cFF943881指|r|cFF923681引|r|cFF8F3481下|r|cFF8C3181，|r|cFF892F81你|r|cFF872D81也|r|cFF842A81没|r|cFF812881有|r|cFF7E2680做|r|cFF7C2380出|r|cFF792180毁|r|cFF761E80灭|r|cFF741C80世|r|cFF711A80界|r|cFF6E1780的|r|cFF6B1580妄|r|cFF691380举|r|cFF661080，|r|cFF630E80不|r|cFF610C80是|r|cFF5E0980吗|r|cFF5B0780！|r|cFF580580』|r")
  if not kl then
    SendDtimeMsgAll(30, idqyn .. "|cFFFFFFFF：|r|cFFFAF7FE『|r|cFFF6EEFD虽|r|cFFF1E6FC然|r|cFFECDDFA这|r|cFFE8D5F9个|r|cFFE3CCF8家|r|cFFDEC4F7伙|r|cFFDABBF6说|r|cFFD5B3F5话|r|cFFD0AAF3神|r|cFFCCA2F2神|r|cFFC799F1叨|r|cFFC291F0叨|r|cFFBD88EF的|r|cFFB980EE，|r|cFFB477EC但|r|cFFAF6FEB是|r|cFFAB66EA她|r|cFFA65EE9意|r|cFFA155E8思|r|cFF9D4DE7没|r|cFF9844E5错|r|cFF933CE4』|r")
    SendDtimeMsgAll(34.4, idqyn .. "|cFFFFFFFF：|r|cFFFBF8FE『|r|cFFF7F1FD如|r|cFFF4EAFC果|r|cFFF0E4FB我|r|cFFECDDFA说|r|cFFE8D6F9学|r|cFFE5CFF8姐|r|cFFE1C8F8是|r|cFFDDC1F7人|r|cFFD9BBF6类|r|cFFD5B4F5的|r|cFFD2ADF4话|r|cFFCEA6F3，|r|cFFCA9FF2那|r|cFFC698F1就|r|cFFC392F0没|r|cFFBF8BEF有|r|cFFBB84EE任|r|cFFB77DED何|r|cFFB476EC人|r|cFFB06FEB能|r|cFFAC69EA够|r|cFFA862E9改|r|cFFA45BE9变|r|cFFA154E8我|r|cFF9D4DE7的|r|cFF9946E6想|r|cFF9540E5法|r|cFF9239E4』|r")
  else
    SendDtimeMsgAll(30, idqyn .. "|cFFC2733E：|r|cFFC4763F『|r|cFFC67941虽|r|cFFC77D42然|r|cFFC98043这|r|cFFCB8345个|r|cFFCD8646家|r|cFFCE8A47伙|r|cFFD08D49说|r|cFFD2904A话|r|cFFD4934B神|r|cFFD5974D神|r|cFFD79A4E叨|r|cFFD99D4F叨|r|cFFDBA050的|r|cFFDCA452，|r|cFFDEA753但|r|cFFE0AA54是|r|cFFE2AD56她|r|cFFE3B157意|r|cFFE5B458思|r|cFFE7B75A没|r|cFFE9BA5B错|r|cFFEABE5C』|r")
    SendDtimeMsgAll(34.4, idqyn .. "|cFFC2733E：|r|cFFC3763F『|r|cFFC57840如|r|cFFC67B41果|r|cFFC87D42我|r|cFFC98043说|r|cFFCB8344学|r|cFFCC8545姐|r|cFFCD8847是|r|cFFCF8B48人|r|cFFD08D49类|r|cFFD2904A的|r|cFFD3924B话|r|cFFD4954C，|r|cFFD6984D那|r|cFFD79A4E就|r|cFFD99D4F没|r|cFFDA9F50有|r|cFFDCA251任|r|cFFDDA552何|r|cFFDEA753人|r|cFFE0AA54能|r|cFFE1AC55够|r|cFFE3AF56改|r|cFFE4B258变|r|cFFE5B459我|r|cFFE7B75A的|r|cFFE8BA5B想|r|cFFEABC5C法|r|cFFEBBF5D』|r")
  end
  ac.wait(30000, function()
    flashphoto({
      photo = "Ph_Leilv.tga",
      timeout = 2,
      timehold = 4,
      timein = 2
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 8, "绝对闪避")
    end)
  end)
  if u:hasdata("特殊判定-雷律初始") then
    ac.wait(26000, function()
      PlayGlobalSound(BGM_Leilv_Caidan)
      SetSoundVolumeBJ(BGM_Leilv_Caidan, 80.0)
      songtext({
        text = {
          {
            starttime = 14.4,
            str = "不安的心 藏匿羽翼"
          },
          {
            starttime = 19.3,
            str = "透过残破的躯体呼喊着奇迹"
          },
          {
            starttime = 24.5,
            str = "汇集这世界渺茫的回音"
          },
          {
            starttime = 27.1,
            str = "抵抗一场致命的黑暗侵袭",
            time = 6.7
          },
          {
            starttime = 34.6,
            str = "神明之意 终将唤醒"
          },
          {
            starttime = 39.9,
            str = "沉睡的救世者逃离虚妄梦境"
          },
          {
            starttime = 44.5,
            str = "汇集这世界散落的光影"
          },
          {
            starttime = 47.5,
            str = "揭示未知的命运 挣脱封印",
            time = 7.5
          },
          {
            starttime = 55.7,
            str = "In this endless night"
          },
          {
            starttime = 57.3,
            str = "There are bodies whose souls are manipulated by evil overflowing"
          },
          {
            starttime = 62,
            str = "The lonely Savior"
          },
          {
            starttime = 64,
            str = "Try to enlighten the dark with proverbs"
          },
          {starttime = 67, str = "Wake up"},
          {
            starttime = 68,
            str = "Resonate with your heart that yearns for the light"
          },
          {
            starttime = 71,
            str = "Recognizing your true long-cherished wish"
          },
          {
            starttime = 74.5,
            str = "跟随着光芒的指引"
          },
          {
            starttime = 76.8,
            str = "召唤我沉寂的宿命"
          },
          {
            starttime = 79.3,
            str = "描绘着救世的真理"
          },
          {
            starttime = 82,
            str = "穿越虚幻迷境"
          },
          {
            starttime = 84.4,
            str = "梦魇里灰白的神域"
          },
          {
            starttime = 86.8,
            str = "迎接未来照进此刻的那一道闪耀曙光"
          },
          {
            starttime = 92.8,
            str = "Find the way"
          },
          {
            starttime = 93.8,
            str = "You never give up",
            time = 3.5
          },
          {
            starttime = 100,
            str = "希望之型  幻化为力"
          },
          {
            starttime = 105,
            str = "找寻心中被尘埃掩埋的勇气"
          },
          {
            starttime = 109.8,
            str = "错乱的结局 宣读着 你我的命运"
          },
          {
            starttime = 119.8,
            str = "神明之意  已经唤醒"
          },
          {
            starttime = 124.3,
            str = "执着的救世者将这力量倾尽"
          },
          {
            starttime = 129.6,
            str = "冥冥之中 有光 是连接未来的魂引"
          },
          {
            starttime = 138.3,
            str = "跟随这光芒的指引"
          },
          {
            starttime = 141.4,
            str = "召唤我专属的宿命"
          },
          {
            starttime = 143.8,
            str = "遵循着救世的真理"
          },
          {
            starttime = 146.3,
            str = "穿越虚幻迷境"
          },
          {
            starttime = 148.7,
            str = "梦魇里灰白的神域"
          },
          {
            starttime = 151.2,
            str = "迎接未来照进此刻的那一道闪耀曙光"
          },
          {
            starttime = 157,
            str = "Find the way"
          },
          {
            starttime = 158,
            str = "You never give up"
          },
          {
            starttime = 161.2,
            str = "The Savior of light"
          },
          {starttime = 168.6, str = "迎着光"},
          {
            starttime = 170,
            str = "走向你的未来"
          },
          {
            starttime = 179.6,
            str = "终于不再畏惧"
          },
          {
            starttime = 182.3,
            str = "完成我的使命"
          },
          {
            starttime = 184.7,
            str = "夜空里的残星"
          },
          {
            starttime = 187.2,
            str = "把黎明 都唤醒"
          },
          {
            starttime = 189.8,
            str = "终于不再迟疑"
          },
          {
            starttime = 192.2,
            str = "完成神的约定"
          },
          {
            starttime = 194.6,
            str = "夜空里的残星"
          },
          {
            starttime = 197,
            str = "把黎明 都唤醒"
          },
          {
            starttime = 198.9,
            str = "跟随这光芒的指引"
          },
          {
            starttime = 200.6,
            str = "召唤我专属的宿命"
          },
          {
            starttime = 203.3,
            str = "遵循着救世的真理"
          },
          {
            starttime = 205.7,
            str = "穿越虚幻迷境"
          },
          {
            starttime = 208.2,
            str = "梦魇里灰白的神域"
          },
          {
            starttime = 210.7,
            str = "迎接未来照进此刻的那一道闪耀曙光"
          },
          {
            starttime = 216.5,
            str = "Find the way"
          },
          {
            starttime = 217.5,
            str = "You never give up"
          },
          {
            starttime = 220.5,
            str = "The Savior of light"
          },
          {starttime = 228, str = "迎着光"},
          {
            starttime = 230.3,
            str = "走向你的未来",
            time = 9.7
          }
        },
        color = {"FFFF0000", "FF0000FF"},
        isjbcolor = true
      })
    end)
  end
end

Vars_Xuehuai = {
  {
    name = "黑龙",
    weight = 100,
    key = {
      "唯一",
      "龙",
      "黑暗",
      "炎"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:hasdata("黑龙-获取中判定") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      SendMsgAll("|cFFCC0000传|r|cFFA30000说|r|cFF7A0000降|r|cFF520000临|r")
      u:setdata("血坏血统")
      u:setdata("黑龙血统阶级", 1)
      u:changedata("龙血浓度", 20)
      u:effectadd("effect\\623_2324 (1).mdx", "origin", -1)
      u:effectadd("effect\\623_2324 (2).mdx", "origin", -1)
      PlayBGM({
        bgm = BGM_Heilong_01,
        time = 125,
        ID = 48,
        unit = u.handle
      })
      ChangeValue(Correction_Exp, sy, 0.3)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("灾厄使者残废") then
          info.endup = info.endup + 0.2
        end
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addallstats(6)
      end)
      u:addstexiao(var.name, "伤害判定后特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 1.5)
          local txsh = 200000 * u:getdata("黑龙血统阶级")
          tg:effectadd("war3mapImported\\[TXNew]020.mdl", "origin")
          DamageUnit({
            bj = "黑龙附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {"龙属性"}
          })
        end
        if u:hasdata("黑龙-灾厄使者") and not u:hasdata(var.name .. "-特效3冷却") then
          u:settimedata(var.name .. "-特效3冷却", 1.5)
          local txsh = 200000 * u:getdata("黑龙血统阶级")
          tg:effectadd("war3mapImported\\[TX] (985).mdl", "origin")
          DamageUnit({
            bj = "黑龙灾厄使者附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {"龙属性"}
          })
        end
      end)
      if u:getdata("瞳变异数量") == 0 then
        u:changedata("瞳变异数量", 1)
        u:setdata("变异判定-诅咒的魔神瞳")
        u:changedata("黑暗变异数量", 1)
        u:addskill("S06Z")
        local zs = 0
        ac.loop(3000, function()
          ChangeValue(DamageSystem_Shjc, sy, -zs)
          zs = 0.5 * u:getdata("黑龙血统阶级")
          ChangeValue(DamageSystem_Shjc, sy, zs)
        end)
        u:addstexiao("诅咒的魔神瞳", "决死效果触发后", function(args)
          u:addallstats(2)
        end)
        u:addstexiao("诅咒的魔神瞳", "抗性破坏阶段", function(args)
          local u = args.u
          local tg = args.tg
          local info = args.damageinfo
          info.pk_benyuan = true
        end)
        u:addstexiao("诅咒的魔神瞳", "近战伤害效果", function(args)
          local tg = args.tg
          if not tg:hasdata("魔神瞳-减甲") then
            local down = -1.5 * u:getlevel()
            tg:settimedata("魔神瞳-减甲", 1)
            tg:changetimearmor(down, 1)
          end
        end)
        u:uivar_add({
          keyname = "诅咒的魔神瞳",
          keytype = "传奇栏",
          text = "|cFF990000诅咒的魔神眼|r\n|cFF990000黑暗\n目|r\n|cFF666666无视本源\n视野范围扩大至全图|r\n|cFF990000漆黑|r\n|cFF666666提升[50%*阶级]伤害加成|r\n|cFF990000龙威|r\n|cFF666666降低自身周围1800范围除自身外所有单位50%移速与攻速,并使额外移速失效|r\n|cFF990000无尽怒焰|r\n|cFF666666近战伤害降低目标[1.5*等级]护甲,持续1秒,无法叠加\n触发决死类效果或死亡时永久提升自身2点全属性|r",
          icon = "war3mapImported\\BTNEwl_Gulong_4.blp"
        })
      end
      u:uivar_add({
        keyname = "古龙的净浓血",
        keytype = "以太栏",
        text = "|cFF990000古龙的净浓血|r\n|cFF990000[数据删除]|r",
        icon = "war3mapImported\\PASBTNEwl_Gulong_10"
      })
      local cs = 0
      ac.loop(1000, function()
        if u:isalive() then
          if u:getdata("黑龙血统阶级") >= 5 then
            u:curehp(u.handle, 0, GetRandomReal(0.33, 1), 1)
          end
          cs = cs + 1
          if cs == 60 then
            cs = 0
            u:clearbuff()
          end
        end
      end)
      ARskillreplace({
        unit = u.handle,
        level = 2,
        skill_A = "A0UA",
        skill_R = "A0UB",
        isforce = false,
        efunc = function()
          gunban(u.handle)
          ac.loop(3000, function()
            gunban(u.handle)
          end)
          
          local function skill(args)
            if args.skill == S2ID("A0UA") then
              local sy = u.ownerid
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local yxz = {
                DragonYes2,
                DragonYesAttack1,
                DragonYesAttack201,
                DragonYesAttack3
              }
              u:playsound(yxz[GetRandomInt(1, 4)])
              u:playsound(bac230)
              u:playsound(bac313)
              local txsh = 50 * u:getstate("龙变异") * u:getallattri()
              Effectcreate("AATX\\[AATxNew]Dust17.mdl", x, y)
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
              unifycreate({
                owner = u.handle,
                model = "AATX\\[AATxNew]Tile11.mdl",
                modelname = "黑龙-吐息",
                modelsize = 2,
                height = 90,
                damage = 0,
                damagetype = 1,
                x = x,
                y = y,
                range = dis,
                speed = 1800,
                volume = 100,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 1,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                startfunc = function(mj)
                  mj:setdata("循环计数", 0)
                end,
                loopfunc = function(mj)
                  mj:changedata("循环计数", UnifyDT)
                  if mj:getdata("循环计数") >= 0.03 then
                    mj:setdata("循环计数", 0)
                  end
                end,
                hitfunc = function(mj, damage)
                  return damage
                end,
                hitbeforefunc = function(mj, xq, damage2)
                end,
                hitafterfunc = function(mj, xq, damage2)
                end,
                endfunc = function(mj)
                  local dx, dy = mj:getxy()
                  Effectcreate("ATX\\[ATxNew]Fire_14.mdl", dx, dy)
                  Effectcreate("ATX\\[ATxNew]Fire_04.mdl", dx, dy, 0, 3)
                  Effectcreate("AATX\\[AATxNew]Fire32.mdl", dx, dy, 0, 5)
                  u:playsound(BuildingDeathLargeHuman)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    u:changedata("世界之门-伤害加成", 4)
                    DamageUnit({
                      bj = "黑龙吐息",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "火",
                      extradata = {"龙属性"}
                    })
                    u:changedata("世界之门-伤害加成", -4)
                  end
                  ac.timer(250, 12, function()
                    for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      u:changedata("世界之门-伤害加成", 4)
                      DamageUnit({
                        bj = "黑龙吐息",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "魔力",
                        isvest = false,
                        isattack = false,
                        isnoarmor = false,
                        element = "火",
                        extradata = {"龙属性"}
                      })
                      u:changedata("世界之门-伤害加成", -4)
                    end
                  end)
                end
              })
              AdvanceHelpers.dragon_breath(u)
            end
            if args.skill == S2ID("A0UB") then
              local sy = u.ownerid
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local yxz = {
                DragonYes2,
                DragonYesAttack1,
                DragonYesAttack201,
                DragonYesAttack3
              }
              u:playsound(yxz[GetRandomInt(1, 4)])
              local txsh = 250 * u:getstate("龙变异") * (u:getallattri() + u:getstr())
              Effectcreate("AATX\\[AATxNew]Black19.mdl", x, y, 2, 5)
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
              Effectcreate("AATX\\[AATxNew]Black15.mdl", x, y, 0, 3)
              u:playsound(bac133)
              u:buffset(u.handle, 0.8, "暂停")
              u:buffset(u.handle, 1, "绝对闪避")
              for _, xq in ac.selector():in_rangexy(x, y, 3000):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 1, "僵直")
              end
              ac.wait(800, function()
                u:playsound(bac240)
                Effectcreate("AATX\\[AATxNew]Purple10.mdl", x, y, 1, 8)
                unifycreate({
                  owner = u.handle,
                  model = "units\\creeps\\BlackDragon\\BlackDragon.mdl",
                  modelname = "黑龙-R",
                  modelsize = 8,
                  height = 300,
                  damage = 0,
                  damagetype = 1,
                  x = x,
                  y = y,
                  range = dis,
                  speed = 2000,
                  volume = 10,
                  angle = angle,
                  angleoffset = 0,
                  attenua = 1,
                  attenuacount = 999,
                  life = 10,
                  isbullet = false,
                  isvest = false,
                  isignorearmor = false,
                  startfunc = function(mj)
                    mj:setdata("循环计数", 0)
                    mj:setcolor(255, 255, 255, 150)
                  end,
                  loopfunc = function(mj)
                    mj:changedata("循环计数", UnifyDT)
                    if mj:getdata("循环计数") >= 0.03 then
                      mj:setdata("循环计数", 0)
                    end
                  end,
                  hitfunc = function(mj, damage)
                    return damage
                  end,
                  hitbeforefunc = function(mj, xq, damage2)
                  end,
                  hitafterfunc = function(mj, xq, damage2)
                  end,
                  endfunc = function(mj)
                    mj:setcolor(255, 255, 255, 255)
                    local dx, dy = mj:getxy()
                    Effectcreate("AATX\\[AATxNew]Black26.mdl", dx, dy, 0, 8)
                    Effectcreate("AATX\\[AATxNew]Fire07.mdl", dx, dy, 0, 3)
                    u:playsound(bac301)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 900):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      DamageUnit({
                        bj = "黑龙咆哮",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "魔力",
                        isvest = false,
                        isattack = false,
                        isnoarmor = false,
                        element = "暗",
                        extradata = {"龙属性"}
                      })
                      xq:buffset(u.handle, 1.5, "眩晕")
                    end
                  end
                })
                AdvanceHelpers.dragon_breath(u)
              end)
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
    end,
    effectname = "|cFF990000ミラ|r|cFF730000ボレ|r|cFF4C0000アス|r",
    effecttext = "|cFF990000黑暗 龙 炎\n它是传说中的灾厄\n将会毁灭我们与大地\n它带着愤怒，来吞噬我们\n米拉波雷亚斯，万物臣服于他\n米拉波雷亚斯，万物恐惧于他\n米拉波雷亚斯，将会毁灭一切\n王城已化为废墟\n它已被人们称为恶魔\n万物都在毁灭之际向它哭诉\n万物恐惧于它|r",
    effectart = "war3mapImported\\BTNEwl_Gulong_1.blp"
  },
  {
    name = "塞壬公主",
    weight = 100,
    key = {
      "唯一",
      "魔导",
      "水",
      "同奏",
      "歌姬",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      SendMsgAll("|cFF99CCFF请|r|cFF91C4FF停|r|cFF89BCFF下|r|cFF81B4FF来|r|cFF7AADFF，|r|cFF72A5FF倾|r|cFF6A9DFF听|r|cFF6295FF我|r|cFF5A8DFF的|r|cFF5285FF歌|r|cFF4B7EFF声|r|cFF4376FF！|r")
      u:setdata("血坏血统")
      u:adddivinity(2)
      PlayBGM({
        bgm = BGM_Sairen_01,
        time = 180,
        ID = 74,
        unit = u.handle
      })
      u:addskill("S014")
      Danwei_Sairengongzhu = u.handle
      u:changedata("水变异补正", 100)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("睡眠") then
          info.end2 = info.end2 + 0.5
        end
      end)
      u:addstexiao(var.name, "被施加Buff时效果-僵直", function(args)
        local u = args.u
        local soc = args.soc
        if soc.handle ~= u.handle and not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        local zs = u:getstate("水变异")
        local jc = 0.1 * zs
        local sx = 10 * zs
        ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
        ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
        ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
        xq:addallstats(sx)
        local zs2 = zs
        ac.loop(3000, function()
          zs = u:getstate("水变异")
          if zs2 ~= zs then
            jc = 0.1 * zs
            sx = 10 * zs
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
            xq:addallstats(sx)
            jc = -0.1 * zs2
            sx = -10 * zs2
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * jc)
            xq:addallstats(sx)
            zs2 = zs
          end
        end)
      end)
      u:addskill("S00T")
      u:addskill("S06X")
      local g = CreateGroupLua()
      ac.loop(1000, function()
        if u:isalive() then
          local x, y = u:getxy()
          GroupClearLua(g)
          for _, xq in ac.selector():in_rangexy(x, y, 5000):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
          end
          ForGroupLuaNew(Group_Randomunits(g, 10), function(xq)
            if u:getluckrandom(13) then
              xq:buffset(u.handle, 3, "混乱")
            elseif u:getluckrandom(15) then
              xq:buffset(u.handle, 10, "睡眠")
            elseif u:getluckrandom(18) then
              local xs
              if xq:isnormal() then
                xs = 0.5
              elseif xq:iselite() then
                xs = 0.1
              else
                xs = 0.01
              end
              LossHpUnit({
                u = u,
                tg = xq,
                damage = xs * xq:gethp(),
                perhp = 0,
                maxhp = 0,
                bj = "[生命损耗]塞壬之歌"
              })
              u:curehp(u.handle, 0, 1, 2)
            end
          end)
        end
      end)
      u:addtrgevent("单位-被攻击", function(args)
        local soc = args.soc
        local u = args.u
        local jl
        if soc:isnormal() then
          jl = 33
        else
          jl = 9
        end
        if u:getluckrandom(jl) then
          if GetRandom100(50) then
            soc:buffset(u.handle, 3, "混乱")
          else
            soc:buffset(u.handle, 10, "睡眠")
          end
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:ishasbuff("B0A8") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 45 * u:getallattri()
          local x2, y2 = tg:getxy()
          Effectcreate("0Tx\\0Tx_Sairen_03.mdl", x2, y2)
          Effectcreate("war3mapImported\\[ake]war3ake.com - 1709800651073528605518801.mdl", x2, y2)
          for _, xq in ac.selector():in_rangexy(x2, y2, 325):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "塞壬公主附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "水"
            })
          end
        end
      end)
    end,
    effectname = "|cFF6699FF塞|r|cFF527AFF壬|r|cFF3D5CFF公|r|cFF293DFF主|r",
    effecttext = "|cFF4466FF神性 2\n魔导 水 同奏 歌姬\n海洋王权|r\n|cFF6699FF提升100%水变异补正\n所有英雄每水变异提供10全属性与10%基础、实际与追加修正|r\n|cFF4466FF塞壬之歌|r\n|cFF6699FF5000范围内视为水域且降低10%攻速\n每秒影响周围5000范围内10名敌军\n13%混乱3秒 13%陷入沉睡 13%汲取50(10/1)%当前生命值并恢复自身1%MHP|r\n|cFF4466FF艳色绝世|r\n|cFF6699FF无视处于塞壬之歌影响下单位的伤害抗性与减伤抗性\n妄图攻击自身的单位33%(9%)陷入混乱3秒或沉睡|r\n|cFF4466FF水之公主|r\n|cFF6699FF自身处在水域时提升25%论外减伤且单次受伤不会超过50%MHP\n处在水域时极限移速无视地形免疫僵直,死亡时复活随机移动,冷却360秒\n每有单位水域中死亡时提升1~3点魔力值且3%提升1点智力\n血统补正享受水补正|r\n|cFF4466FF惑心|r\n|cFF6699FF睡眠加成效果提升至100%|r\n|cFF4466FF深渊回响|r\n|cFF6699FF直接伤害10%附带325范围[全属性*45]水魔力伤害",
    effectart = "war3mapimported\\PASBTNXuetong_4_Sairengongzhu.blp"
  },
  {
    name = "雷之律者",
    weight = 100,
    key = {
      "唯一",
      "念力",
      "战士",
      "雷",
      "外域"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:playselfsound(Sound_Mei_03)
      SendMsgAll("|cFF6699FF雷|r|cFF628DF7之|r|cFF5E81EF律|r|cFF5A76E7者|r|cFF566AE0,|r|cFF525ED8愿|r|cFF4E52D0成|r|cFF4B47C8为|r|cFF473BC0你|r|cFF432FB8的|r|cFF3F23B1力|r|cFF3B18A9量|r")
      leilv = u
      get_leilv = true
      if not leilv_caidan and (get_konglv and get_leilv or u:hasdata("特殊判定-雷律初始")) then
        leilv_caidan = true
        ac.wait(30000, function()
          leilvcaidan()
        end)
      end
      if u:hasdata("特殊判定-雷律初始") then
        for index, value in ipairs(Pools_SpeDzWeapon) do
          if value.name == "涤罪七雷" and not value.hasbeenget then
            value.hasbeenget = true
            local bb = getunit(Beibao[sy])
            bb:additem("I0DZ")
            break
          end
        end
      end
      if u:hasdata("隐藏职业-律者") then
        u:setdata("律者-崩坏成长")
        u:addallstats(GetRandomInt(50, 100))
        hideproshow(u.handle)
      end
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        info.lw = info.lw + 0.03 * tg:getdata("雷律-鸣神层数")
        if u:hasdata("特殊判定-律者形态") then
          info.gl = info.gl + 0.4
        end
        if tg:getdata("雷律-鸣神层数") > 0 then
          info.gl = info.gl + 0.1
        end
      end)
      u:addskill("S06B")
      u:adddivinity(3)
      u:setdata("血坏血统")
      u:become("噩梦具现化")
      u:getgoddessforce(3, true)
      u:setdata("特殊判定-律者")
      u:addskill("S06C")
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("雷律-幻光世") and not u:hasdata("雷律-幻光世冷却") then
          u:settimedata("雷律-幻光世", 1)
        end
      end)
      local g = CreateGroupLua()
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("雷律-幻光世") then
          u:deldata("雷律-幻光世")
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          if 1000 <= dis then
            dis = 1000
          end
          u:playsound(LightningBolt)
          local txsh = 2 * u:getdata("当前额外移速")
          local txg = {
            "ATX\\[ATxNew]Thunder_15.mdl",
            "ATX\\[ATxNew]Thunder_16.mdl",
            "ATX\\[ATxNew]Thunder_17.mdl"
          }
          u:buffset(u.handle, 0.15, "绝对闪避")
          unitmove({
            unit = u.handle,
            time = 0.15,
            distance = dis,
            angle = angle,
            loops = {
              {
                looptime = 0.015,
                func = function(dx, dy)
                  Effectcreate(txg[GetRandomInt(1, 3)], dx, dy)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):isnotingroup(g):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g)
                    DamageUnit({
                      bj = "雷之律者附伤",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = true,
                      isattack = false,
                      isnoarmor = false,
                      element = "雷"
                    })
                    xq:buffset(u.handle, 1, "僵直")
                  end
                end
              }
            },
            endfunc = function()
              GroupClearLua(g)
            end
          })
        end
      end)
      AddAllSTexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        local u = args.u
        if u:ishasbuff("B09M") then
          info.zj = info.zj + 0.08 * u:getstate("雷变异") + 0.04 * u:getstate("外域变异")
        end
      end)
      ChangeValue(Damage_Element_Thunder, sy, 0.15)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(DamageSystem_Shjc, sy2, 0.014)
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:getdata("雷律-鸣神层数") > 0 then
          info.endup = info.endup + 0.1
        end
      end)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      local lw = 0
      local cs = 0
      local addg = 0
      local weaadd = 0
      ac.loop(3000, function()
        cs = cs + 1
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
        u:changedata("固定伤害", 0.1 * (-1 * addg))
        addg = 20 * u:getdata("当前额外移速")
        lw = 0.1 * u:getstate("雷变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
        u:changedata("固定伤害", 0.1 * (1 * addg))
        if u:isinmaxvar("雷") then
          if not u:hasdata("雷之律者-建御雷强化") then
            u:setdata("雷之律者-建御雷强化")
            ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
            ChangeValue(DamageSplit_CountJzHit, sy, 1)
          end
        elseif u:hasdata("雷之律者-建御雷强化") then
          u:deldata("雷之律者-建御雷强化")
          ChangeValue(DamageSplit_CountJzMax, sy, -0.25)
          ChangeValue(DamageSplit_CountJzHit, sy, -1)
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * weaadd))
        ChangeValue(Damage_Element_Thunder, sy, -0.05 * weaadd)
        local zs = 0
        for i = 1, 6 do
          local wptype = GetItemTypeId(u:getcountitem(i))
          if wptype == Weapons["天殛之钥"] or wptype == Weapons["天殛之镜.裁决"] or wptype == Weapons["布都御魂"] or wptype == Weapons["童子切安纲"] or wptype == Weapons["雷霆长枪"] or wptype == Weapons["涤罪七雷"] then
            zs = zs + 1
          end
        end
        if Hero_Equip_WeaponType[sy] == Weapons["布都御魂"] or Hero_Equip_WeaponType[sy] == Weapons["童子切安纲"] or Hero_Equip_WeaponType[sy] == Weapons["雷霆长枪"] or Hero_Equip_WeaponType[sy] == Weapons["涤罪七雷"] then
          zs = zs + 1
        end
        weaadd = zs * 0.2
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * weaadd))
        ChangeValue(Damage_Element_Thunder, sy, 0.05 * weaadd)
        if cs == 200 then
          cs = 0
          local ml = 5 * u:getlevel()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:hasdata("特殊判定-律者") then
              xq:changedata("魔力值", ml * 2)
            else
              xq:changedata("魔力值", ml)
            end
          end)
        end
      end)
      
      local function leilvmingshen(xq)
        local x, y = xq:getxy()
        xq:changedata("雷律-鸣神层数", 1)
        xq:effectadd("Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl", "origin")
        if xq:getdata("雷律-鸣神层数") >= 25 then
          Effectcreate("ATx\\[ATxNew]Thunder_03.mdl", x, y, 0, 2, 0, GetRandomAngle())
          local txsh = (5000 + u:getdata("魔力值")) * (u:getshenxing() * 2 + xq:getdata("雷律-鸣神层数") + u:getlevel() / 2) * 0.2
          if u:hasdata("武器判定-鸣雷见") then
            xq:changedata("雷律-鸣神层数", -1 * math.floor(u:getdata("雷律-鸣神层数") / 2))
          else
            xq:deldata("雷律-鸣神层数")
          end
          DamageUnit({
            bj = "雷之律者附伤",
            unit = xq.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "雷"
          })
        end
      end
      
      u:setdata("雷之律者-雷鸣触发", leilvmingshen)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local txsh = 0.6 * info.yssh
          DamageUnit({
            bj = "雷之律者附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "雷"
          })
          u:settimedata(var.name .. "-特效冷却", 0.25)
        end
        if not u:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(20) then
          local x2, y2 = tg:getxy()
          Effectcreate("ATX\\[ATxNew]Thunder_09.mdl", x2, y2, 0, 1.25)
          Effectcreate("ATX\\[ATxNew]Thunder_04.mdl", x2, y2, 0, 2)
          local txsh = 5000 + 500 * u:getlevel() + u:getdata("魔力值") * 2
          for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "雷之律者附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "雷"
            })
            leilvmingshen(xq)
          end
          u:settimedata(var.name .. "-特效2冷却", 1)
        end
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not args.isvestdamage and not u:hasdata(var.name .. "-特效3冷却") then
          u:settimedata(var.name .. "-特效3冷却", 0.5)
          local txsh = 0.8 * info.yssh
          DamageUnit({
            bj = "雷之律者附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "雷"
          })
          leilvmingshen(tg)
        end
      end)
      local dskill = S2ID("A15J")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 4000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过4000|r")
          end
          if not u:hasdata("特殊判定-律者形态") then
            b = false
            u:sendmessage("|cFF7DBEF1非律者形态|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            u:buffset(u.handle, 6, "暂停")
            u:buffset(u.handle, 6, "永恒")
            u:buffset(u.handle, 8, "无敌")
            u:buffset(u.handle, 8, "绝对闪避")
            ac.timer(1000, 6, function()
              ForGroupLuaNew(Group_Monster, function(xq)
                xq:buffset(u.handle, 3, "僵直")
                xq:buffset(u.handle, 2, "沉默")
                if xq:isboss() then
                  xq:buffset(u.handle, 6.5, "锁定")
                end
              end)
            end)
            u:setface(angle)
            PlayGlobalSound(Sound_Thunder_02)
            PlayGlobalSound(Sound_Thunder_05)
            u:playsound(Sound_Katana_19)
            PlayGlobalSound(Sound_Mei_01)
            u:setplayername("|cFF3399FF雷|r|cFF337AEB之|r|cFF335CD6律|r|cFF333DC2者|r")
            u:chat("怒吼吧")
            u:chat("俱利伽罗！", 1.4)
            u:chat("一刀——", 5.3)
            u:chat("了断！", 6.2)
            ac.wait(5100, function()
              u:playsound(Sound_Katana_10)
            end)
            local mj = u:createunit("u096", x, y)
            local cs2 = 0
            local dx = 0.1
            ac.loop(100, function(timer)
              cs2 = cs2 + 1
              if cs2 <= 40 then
                dx = dx + 0.05
                mj:setsize(dx)
              end
              if cs2 == 60 then
                mj:remove()
                timer:remove()
              end
            end)
            for i = 1, 2 do
              local dx2 = 0
              ac.timer(100, 60, function()
                dx2 = dx2 + 0.05
                Effectcreate("ATx\\[ATxNew]Thunder_14.mdl", x, y, 0, 0.1 + dx2)
              end)
            end
            ac.wait(1000, function()
              ac.timer(100, 50, function()
                Effectcreate("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl", x, y, 1, 2, 0, GetRandomAngle())
              end)
            end)
            ac.wait(3600, function()
              local dx2 = 1
              ac.timer(100, 10, function()
                dx2 = dx2 + 0.25
                Effectcreate("ATx\\[ATxNew]Light_12.mdl", x, y, 0, dx2)
              end)
            end)
            ac.wait(5300, function()
              local jl = 1000
              local xx, yy = PolarXY(x, y, jl, angle)
              Effectcreate("ATx\\[ATxNew]Daoguang_07.mdl", xx, yy, 2, 8, 150, angle)
              local jl = 200
              local jl1 = 4000
              local cs1 = jl1 / jl
              local cs = 0
              local xx, yy = x, y
              local jd2 = angle
              ac.loop(10, function(timer)
                xx, yy = PolarXY(xx, yy, jl, jd2)
                ac.wait(400, function()
                  local jl2 = GetRandomReal(300, 500)
                  local jd3 = GetRandomAngle()
                  local xx2, yy2 = PolarXY(xx, yy, jl2, jd3)
                  Effectcreate("ATx\\[ATxNew]Thunder_03.mdl", xx2, yy2, 0.9, 5, 150, angle)
                end)
                for i = 1, 3 do
                  local jl2 = GetRandomReal(300, 500)
                  local jd3 = GetRandomAngle()
                  local xx2, yy2 = PolarXY(xx, yy, jl2, jd3)
                  Effectcreate("ATx\\[ATxNew]Thunder_18.mdl", xx2, yy2, 1, GetRandomReal(1, 3))
                end
                cs = cs + 1
                if cs >= cs1 then
                  timer:remove()
                end
              end)
            end)
            ac.wait(6200, function()
              u:playsound(Sound_Weapon_08)
              local xx, yy = x, y
              local jl = 150
              local jd2 = angle
              local g2 = CreateGroupLua()
              local txsh = 44444 * u:getlevel()
              for i = 1, 27 do
                xx, yy = PolarXY(xx, yy, jl, jd2)
                for _, xq in ac.selector():in_rangexy(xx, yy, 1000):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g2)
                  u:setdata("雷之律者-一刀两断伤害")
                  DamageUnit({
                    bj = "雷之律者一刀两断",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "雷"
                  })
                end
                local jl2 = GetRandomReal(300, 500)
                local jd3 = GetRandomAngle()
                local xx2, yy2 = PolarXY(xx, yy, jl2, jd3)
                Effectcreate("ATx\\[ATxNew]ShockBoom_08.mdl", xx2, yy2, 0, GetRandomReal(1.5, 2.5))
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:banskill("A15J")
      u:setdata("雷之律者-律者化函数", function()
        local x, y = u:getxy()
        PlayGlobalSound(Sound_Mei_04)
        u:chat("让雷鸣，涤荡所有的罪孽！")
        u:adddivinity(1)
        u:setdata("特殊判定-律者形态")
        local bgm = BGM_Mei_01
        if u:hasdata("隐藏职业-坏苹果") then
          bgm = BGM_Badapple
          if not u:hasdata("隐藏职业-坏苹果揭露") then
            u:setdata("隐藏职业-坏苹果揭露")
            hideproshow(u.handle)
          end
        end
        if u:hasdata("变异判定-斯巴达之子") then
          if u:hasdata("斯巴达之子-但丁") then
            bgm = BGM_Pro_11
          else
            bgm = BGM_Pro_10
          end
        end
        ChangeBGM(bgm)
        PlayBGM({
          bgm = 0,
          time = 0,
          ID = 82,
          unit = u.handle
        })
        if Nandu_Choose >= 3 then
          Surr_Leiyu = true
          SendMsgAll("|cFF3366FF雷|r|cFF3959FF狱|r|cFF404CFF狂|r|cFF4640FF暴|r|cFF4C33FF了|r|cFF5326FF起|r|cFF591AFF来|r")
        end
        u:addskill("S025")
        u:banskill("A15J", false)
        Damage_Element_Thunder[sy] = Damage_Element_Thunder[sy] + 0.4
        local cs = 0
        ac.loop(1000, function(t)
          cs = cs + 1
          if cs == 3 then
            cs = 0
            u:playsound(LightningBolt01)
            local txsh = 30000 * HeroMenu_Shenxing[sy]
            for i = 1, 3 do
              local x2, y2 = PolarXY(x, y, GetRandomReal(0, 1800), GetRandomReal(0, 360))
              Effectcreate("ATX\\[ATxNew]Thunder_15.mdl", x2, y2, 0, 2)
              for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "雷之律者律者化",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 4,
                  type = "魔力",
                  isvest = true,
                  isnoarmor = false,
                  element = "雷"
                })
              end
            end
          end
          if not u:ishasskill("S025") then
            u:banskill("A15J")
            Damage_Element_Thunder[sy] = Damage_Element_Thunder[sy] - 0.4
            u:adddivinity(-1)
            u:deldata("特殊判定-律者形态")
            if 3 <= Nandu_Choose then
              Surr_Leiyu = false
              SendMsgAll("|cFF3366FF雷|r|cFF3A57FF狱|r|cFF4249FF重|r|cFF493AFF归|r|cFF502CFF平|r|cFF571DFF静|r")
            end
            t:remove()
          end
        end)
      end)
    end,
    effectname = "|cFF3399FF雷|r|cFF337AEB之|r|cFF335CD6律|r|cFF333DC2者|r",
    effecttext = "|cFF3399FF神性 3\n雷之理|r\n|cFF335CD6免疫僵直且极限移速\n额外移速不再生效\n提升[自身额外移速*2]固定伤害,对鸣神单位无视伤害免疫|r\n|cFF3399FF八百万神|r\n|cFF335CD6提升全队1.4%伤害加成与[雷变异数量*0.8%+外域变异数量*0.4%]伤害加成\n每600秒提升全队[5*自身等级]魔力值,律者翻倍|r\n|cFF3399FF祸隐 迦具土|r\n|cFF335CD6提升15%雷属性伤害\n绝对闪避时僵直伤害来源1秒并施加一层鸣神\n对拥有鸣神单位提升1%终结伤害与1%伤害加成\n直接伤害时20%300范围内造成魔力伤害并施加一层鸣神\n对目标提升[0.3%*鸣神层数]伤害加成,层数达到25时造成魔力抹除伤害并清空层数|r\n|cFF3399FF幻光世|r\n|cFF335CD6降低25%位移冷却,发动位移后1秒内右击地面向其瞬移(最多1000码)|r\n|cFF3399FF胧刀 建御雷|r\n|cFF335CD6直接伤害时附带[60%*伤害值]魔力纯粹伤害\n近战伤害10%附带[80%*伤害值]魔力纯粹伤害与鸣神,冷却0,25秒\n每把携带或装备的雷属性武器提升5%雷属性伤害与2%伤害加成\n近战伤害段数+1(雷灵力伤害) 近战伤害上限+25%\n主变异为雷时:\n【近战伤害段数+1(雷灵力伤害) 近战伤害上限+25%】",
    effectart = "war3mapImported\\PASBTNEwl_Mei_Xuehuai.blp"
  },
  {
    name = "空之律者",
    weight = 100,
    key = {
      "唯一",
      "念力",
      "战士",
      "影",
      "外域",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      SendMsgAll("|cFFD5B242我|r|cFFC6A642，|r|cFFB79A41就|r|cFFA78F41是|r|cFF988341崩|r|cFF897741坏|r|cFF7A6B40的|r|cFF6B5F40化|r|cFF5B5440身|r")
      get_konglv = true
      if not leilv_caidan and get_konglv and get_leilv then
        leilv_caidan = true
        ac.wait(30000, function()
          leilvcaidan()
        end)
      end
      if u:hasdata("隐藏职业-律者") then
        u:setdata("律者-崩坏成长")
        u:addallstats(GetRandomInt(50, 100))
        hideproshow(u.handle)
      end
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:getperhp() <= 50 then
          info.gl = info.gl + 0.25
        end
        if u:ishasskill("S025") then
          info.gl = info.gl + 0.25 + Group_Counts(Group_Kzlz_St)
          if tg:isboss() then
            info.gl = info.gl + 0.25
          end
        end
      end)
      ChangeValue(DamageSystem_Baoji, sy, 0.1)
      ChangeValue(DamageSystem_BaoshangBeilv, sy, 0.25)
      local glsh = 0
      local bjl = 0
      local cb = 0
      ac.loop(3000, function()
        local hx = 0
        ForGroupLuaNew(Group_Xingcunzu, function(xq)
          if xq.handle ~= u.handle then
            hx = hx + 1
          end
        end)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -glsh)
        glsh = 1.6 - 0.16 * hx
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * glsh)
        ChangeValue(DamageSystem_Baoji, sy, -bjl)
        bjl = 0.05 * u:getstate("念力变异") + 0.25 * (DamageSystem_Baoji[sy] - 1)
        ChangeValue(DamageSystem_Baoji, sy, bjl)
        ChangeValue(Correction_Cbxs, sy, -cb)
        cb = 0.01 * u:getdata("系统-累积等级")
        ChangeValue(Correction_Cbxs, sy, cb)
      end)
      u:addstexiao(var.name, "抗性破坏结算阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("虚界降临-释放中") then
          info.sb = false
          info.my = false
        end
        if tg:getperhp() <= 50 then
          info.sb = false
        end
        local pd = u:getdata("显示-暴击率")
        if u:getluckrandom(pd) then
          info.my = false
        end
      end)
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        u:changetimedata("空之律者-暴击率提升", 0.5, 5)
        u:changetimedata("空之律者-暴击伤害提升", 0.01, 5)
        info.bjl = info.bjl + u:getdata("空之律者-暴击率提升")
        info.bjsh = info.bjsh + u:getdata("空之律者-暴击伤害提升")
        if tg:getperhp() <= 50 then
          info.bjl = info.bjl + 25
        end
      end)
      u:addskill("S06B")
      u:adddivinity(3)
      u:setdata("血坏血统")
      u:become("噩梦具现化")
      u:getgoddessforce(3, true)
      u:setdata("特殊判定-律者")
      u:addskill("A0IX")
      u:addskill("A0IY")
      u:banskill("A0IX")
      u:banskill("A0IY")
      local dskill = S2ID("A0I4")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 1800 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过1800|r")
          end
          if not u:hasdata("特殊判定-律者形态") then
            b = false
            u:sendmessage("|cFF7DBEF1非律者形态|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            u:setplayername("|cFF996600空|r|cFFAD7A14之|r|cFFC28F29律|r|cFFD6A33D者|r")
            u:buffset(u.handle, 6, "暂停")
            u:buffset(u.handle, 6, "永恒")
            u:buffset(u.handle, 10, "无敌")
            u:buffset(u.handle, 6, "绝对闪避")
            u:settimedata("虚界降临-释放中", 10)
            PlayGlobalSound(Kongzhilvzhe_1)
            u:setface(angle)
            local syxzq = u:createfogcorrector(x2, y2, 4500)
            ac.wait(10000, function()
              u:removefogcorrector(syxzq)
            end)
            local mj = u:createunit("u048", x2, y2, 0)
            local cs = 0
            ac.loop(25, function(timer)
              cs = cs + 1
              if cs <= 80 then
                local dx = 1 + 0.1 * cs
                mj:setsize(dx)
              end
              if cs == 480 then
                mj:remove()
                timer:remove()
              end
            end)
            local g = CreateGroupLua()
            local cs2 = 0
            local a1 = u:getface() * -1
            ac.loop(20, function(timer)
              cs2 = cs2 + 1
              local jl = GetRandomReal(300, 900)
              local a = a1 + GetRandomReal(-90, 90)
              local x3, y3 = PolarXY(x2, y2, jl, a)
              local a2 = AngleXY(x3, y3, x2, y2)
              local mj2 = u:createunit("u047", x3, y3, a2)
              mj2:groupadd(g)
              mj2:setflyheight(GetRandomReal(800, 1400))
              if 250 <= cs2 then
                timer:remove()
              end
            end)
            ac.wait(1000, function()
              PlayGlobalSound(Kongzhilvzhe_2)
              u:chat("此刻正是，审判之时")
            end)
            ac.wait(3000, function()
              local cs3 = 0
              local txsh = 4444 * u:getlevel()
              ac.loop(20, function(timer)
                cs3 = cs3 + 1
                local mj2 = Group_Randomunit(g)
                if type(mj2) ~= "table" then
                  return
                end
                mj2:groupremove(g)
                local x4, y4 = mj2:getxy()
                local a2 = mj2:getface()
                local tx = u:createunit("u047", x4, y4, a2)
                local he = GetUnitFlyHeight(mj2.handle)
                tx:timetoremove(2)
                local jl = GetRandomReal(0, 1600)
                local a = GetRandomAngle()
                local x3, y3 = PolarXY(x2, y2, jl, a)
                local dcs = 0
                local dx = (x3 - x4) / 20
                local dy = (y3 - y4) / 20
                local dg = he / 20
                local hg = he
                ac.loop(10, function(timer2)
                  dcs = dcs + 1
                  x4 = x4 + dx
                  y4 = y4 + dy
                  hg = hg - dg
                  mj2:setxy(x4, y4)
                  mj2:setflyheight(hg)
                  if dcs == 20 then
                    mj2:kill()
                    mj2:timetoremove(2)
                    Effectcreate("war3mapImported\\[TxNew]331 (7).mdl", x4, y4)
                    Effectcreate("war3mapImported\\[TxNew]33203.mdx", x4, y4)
                    if GetRandom100(25) then
                      mj2:playsound(BuildingDeathLargeHuman)
                    end
                    for _, xq in ac.selector():in_rangexy(x4, y4, 384):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      u:setdata("空之律者-虚界降临伤害")
                      DamageUnit({
                        bj = "空之律者虚界降临",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 5,
                        type = "魔力",
                        isvest = false,
                        isattack = false,
                        isnoarmor = false,
                        element = "无"
                      })
                      xq:buffset(u.handle, 0.75, "暂停")
                    end
                    timer2:remove()
                  end
                end)
                if 250 <= cs3 then
                  timer:remove()
                end
              end)
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:banskill("A0I4")
    end,
    effectname = "|cFF996600空|r|cFFAD7A14之|r|cFFC28F29律|r|cFFD6A33D者|r",
    effecttext = "|cFFFFCC66神性 3\n战士 念力 影 外域\n提升[40%-6%*死亡友军]隔离减伤\n提升[16%-1.6%*存活友军]伤害加成\n提升[10%+5%*念力变异]暴击率\n极速|r\n|cFFCC9900虚空权能|r\n|cFFFFCC66提升[0.01*累积等级]超暴系数\n提升25%当前暴击率\n提升25%暴击伤害增加量|r\n|cFFCC9900空之律令|r\n|cFFFFCC66每次造成伤害提升1%暴击伤害与0.5%暴击率 持续5秒 分立计时|r\n|cFFCC9900审判|r\n|cFFFFCC66对50%以上生命值的敌人提升25%暴击率 对50%以下生命值的敌人提升2.5%伤害加成且无视伤害闪避|r\n|cFFCC9900能流偏移|r\n|cFFFFCC66受到的非普攻的原始伤害25%概率降低90%并损耗目标10%(1%)当前生命值|r\n|cFFCC9900歪曲|r\n|cFFFFCC66自身的伤害有相当于自身暴击率的概率无视伤害免疫\n自身的伤害无视目标[暴击率*50%]的减伤|r\n|cFF949596死吧。|r",
    effectart = "war3mapImported\\BTNEwl_Kongzhilvzhe.blp"
  }
}
