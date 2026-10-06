-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local dptt = CIUC
local M = {
  {id = "斯卡蒂"},
  {id = "幽灵鲨"},
  {
    id = "雷之律者",
    etfunc = function(u, sy)
      if dptt[sy] ~= "-2105600062" then
        u:setdata("判定-雷律概率2")
      end
    end,
    etendfunc = function(u, sy)
      if dptt[sy] ~= "-2105600062" then
        u:deldata("判定-雷律概率2")
      end
    end
  },
  {id = "露娜"},
  {id = "老魔杖"},
  {
    id = "吉普利露"
  },
  {
    id = "薄暝",
    etfunc = function(u, sy)
      if dptt[sy] == "4641059" then
        u:setdata("判定-薄暝高概率")
      end
    end,
    etendfunc = function(u, sy)
      if dptt[sy] == "4641059" then
        u:deldata("判定-薄暝高概率")
      end
    end
  },
  {id = "安吉拉"},
  {
    id = "忍野忍",
    etfunc = function(u, sy)
      if not u:hasdata("忍野忍-注册") then
        u:setdata("忍野忍-注册")
        
        local function chattrg(args)
          if args.chat == "-ryr598" and not u:hasdata("忍野忍-注册判定") then
            u:setdata("忍野忍-注册判定")
            local bb = getunit(Beibao[sy])
            if u:ishasitem("I08X") and (u:ishasitem("I0C0") or u:ishasitem("I0H6")) then
              u:setdata("忍野忍-获取判定")
            end
          end
        end
        
        u:addtrgevent("玩家-聊天", function(args)
          chattrg(args)
        end)
      end
    end,
    etendfunc = function(u, sy)
    end
  },
  {
    id = "玉藻前",
    etfunc = function(u, sy)
      u:setdata("玉藻前-杀生界额外伤害")
    end,
    etendfunc = function(u, sy)
      u:deldata("玉藻前-杀生界额外伤害")
    end
  },
  {
    id = "古明地恋"
  },
  {id = "队长"},
  {
    id = "克萝蒂亚"
  },
  {id = "纳西妲"},
  {
    id = "智慧树的枝条"
  },
  {id = "阿米娅"},
  {
    id = "星神之嗣"
  },
  {id = "百百"},
  {id = "雪菜"},
  {id = "窥星"},
  {id = "缠魇丸"},
  {
    id = "朝武芳乃"
  },
  {
    id = "千子村正"
  },
  {
    id = "早苗",
    etfunc = function(u, sy)
      if dptt[sy] == "1932310753" or dptt[sy] == "241989033" or dptt[sy] == "644398561" then
        u:setdata("判定-早苗高概率")
      end
    end,
    etendfunc = function(u, sy)
      if dptt[sy] == "1932310753" or dptt[sy] == "241989033" or dptt[sy] == "644398561" then
        u:deldata("判定-早苗高概率")
      end
    end
  },
  {id = "桔梗"},
  {
    id = "朱雀院红叶"
  },
  {id = "八云紫"},
  {id = "祢豆子"},
  {
    id = "卫宫士郎"
  },
  {id = "忴"},
  {id = "鹿目圆"},
  {id = "狂乱者"},
  {id = "伊蕾娜"},
  {id = "祸灵梦"},
  {id = "暗之书"},
  {
    id = "鬼灭权限",
    etfunc = function(u, sy)
      if dptt[sy] == "-779232133" then
        u:setdata("判定-鬼灭之刃本人")
      end
      if dptt[sy] == "-779232133" or dptt[sy] == "-1691194058" then
        u:setdata("判定-鬼灭之刃可锻造")
      end
    end,
    etendfunc = function(u, sy)
      if dptt[sy] == "-779232133" then
        u:deldata("判定-鬼灭之刃本人")
      end
      if dptt[sy] == "-779232133" or dptt[sy] == "-1691194058" then
        u:deldata("判定-鬼灭之刃可锻造")
      end
    end
  },
  {
    id = "黑龙",
    etfunc = function(u, sy)
      if dptt[sy] == "4641059" or dptt[sy] == "-1429600477" then
        u:setdata("判定-黑龙高概率")
      end
    end,
    etendfunc = function(u, sy)
      if dptt[sy] == "4641059" or dptt[sy] == "-1429600477" then
        u:deldata("判定-黑龙高概率")
      end
    end
  },
  {
    id = "大阿阇黎特殊权限"
  },
  {id = "小天子"},
  {id = "大天子"},
  {
    id = "猫头鹰因子"
  },
  {id = "间桐樱"},
  {id = "虹猫"},

  {
    id = "狂战士之铠"
  },
  {id = "椿"},
  {id = "小死神"},
  {id = "特里诺"},
  {
    id = "破碎的梦"
  },
  {id = "茸茸"},
  {id = "夜夜"},
  {id = "愚者"},
  {id = "老男人"},
  {id = "礼奈"},
  {id = "王女"},
  {id = "拟态"},
  {id = "利姆露"},
  {
    id = "暗影大人"
  }
}
return M
