-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local gun_upgrade = require("gameplay.feature.gun.upgrade")

local function apple(args)
  local u = args.u
  local sy = u.ownerid
  local hero = getunit(Hero[sy])
  local w = {}
  w[1] = "I0AH"
  w[2] = "I0AG"
  w[3] = "I0AF"
  w[4] = "I0AI"
  w[5] = "I0ED"
  local z
  if hero:hasdata("隐藏职业-神树之实") then
    if GetRandom100(50) then
      z = 1
    elseif GetRandom100(92) then
      z = 2
    else
      z = 3
      if not Boolean_Pg_Jinguo and GetRandom100(5) then
        z = 4
        Boolean_Pg_Jinguo = true
        if not hero:hasdata("隐藏职业-神树之实已揭露") then
          u:additem("I0ED")
          hero:setdata("隐藏职业-神树之实已揭露")
          hideproshow(hero.handle)
        end
      end
    end
  elseif GetRandom100(75) then
    z = 1
  elseif GetRandom100(92) then
    z = 2
  else
    z = 3
    if not Boolean_Pg_Jinguo and GetRandom100(2.5) then
      z = 4
      Boolean_Pg_Jinguo = true
    end
  end
  u:additem(w[z])
  if hero:hasdata("判定-智慧树的枝条") and 5 >= Time_M and not hero:hasdata("智慧树的枝条-持有") and not hero:hasdata("智慧树的枝条-摘苹果获取") then
    for index, value in ipairs(Pools_Spe) do
      if value.name == "智慧树的枝条" then
        if not value.hasbeenget then
          hero:setdata("智慧树的枝条-摘苹果获取")
          hero:additem("I0EW")
          value.hasbeenget = true
          hero:sendmessage("|cfffdd963你摘苹果的时候被一根落下的枝条砸中|r")
        end
        break
      end
    end
  end
  if Danwei_Baoming ~= 0 and Danwei_Baoming == hero.handle and hero:ishasitem("I0A2") and hero:getdata("瞳变异数量") == 0 and GetTimeOfDay() <= 1.3 and not Boolean_BaomingIng and not Boolean_BaomingTip[2] then
    AdvanceGet["终末鸟-大鸟事件"](hero)
  end
end

local removezuzhou = {
  "髑髅饥",
  "胧车面",
  "天狗相",
  "土蛛毒",
  "妖狐咒",
  "憎恶荆棘",
  "血武士",
  "虚无咒文",
  "王家诅咒",
  "雾隐恶魔",
  "技能抽取",
  "血之刻印",
  "破坏欲"
}
local bkqs = require("gameplay.feature.npc.pools_bkqs")
local wzcz250 = {
  "I01I",
  "I00E",
  "I000",
  "I003",
  "I00T"
}
local wzcz200 = {
  "I0HM",
  "I0I1",
  "I0I0",
  "I0I2",
  "I0HN",
  "I0HZ",
  "I0HY"
}
local wzcz500 = {
  "I033",
  "I032",
  "I037",
  "I0H8",
  "I05G",
  "I034",
  "I019",
  "I00N",
  "I009",
  "I00C",
  "I00L"
}
local wzcz1000 = {
  "I00V",
  "I001",
  "I00W",
  "I004",
  "I01H",
  "I017",
  "I005",
  "I00K",
  "I00U",
  "I00S",
  "I00P",
  "I00Q",
  "I018",
  "I00R",
  "I002",
  "I00H",
  "I027",
  "I062",
  "I060",
  "I061",
  "I00O",
  "I00D",
  "I00M",
  "I00A",
  "I063"
}
local wzcz = {
  {typeid = "I0IB", xh = 400},
  {typeid = "I0IG", xh = 400},
  {typeid = "I0IC", xh = 10000}
}

local function tuzhitupo(u, tuzhi)
  local inventory = {}
  for i = 1, 6 do
    local item = u:getcountitem(i)
    local itemtype = GetItemTypeId(item)
    local count = GetItemCharges(item)
    inventory[itemtype] = {count = count, item = item}
  end
  local requiredMaterials = tuzhi.requiredMaterials
  for _, recipe in ipairs(requiredMaterials) do
    local allMatched = true
    local returnValue = recipe.returnValue or 1
    local returnCgl = recipe.returnCgl or 1
    for _, material in ipairs(recipe.items) do
      local item, quantity = material[1], material[2]
      if not inventory[item] or quantity > inventory[item].count then
        allMatched = false
        break
      end
    end
    if allMatched then
      for _, material in ipairs(recipe.items) do
        local item, quantity = material[1], material[2]
        inventory[item].count = inventory[item].count - quantity
        ChangeItemCount(inventory[item].item, -quantity)
      end
      return {value = returnValue, cgl = returnCgl}
    end
  end
  return {value = 0, cgl = 0}
end

MATERIALS = {
  {name = "石头"},
  {name = "铁矿"},
  {name = "煤炭"},
  {
    name = "源石原矿"
  },
  {name = "蓝晶石"},
  {name = "铜矿"},
  {name = "银矿"},
  {name = "金矿"},
  {name = "稀金矿"},
  {name = "钨矿"},
  {name = "钛矿"},
  {name = "钻石"},
  {name = "铀矿"},
  {name = "沙子"},
  {name = "石英矿"}
}
PRODUCTS = {
  {name = "铁锭"},
  {name = "源石锭"},
  {name = "铜锭"},
  {name = "银锭"},
  {name = "金锭"},
  {
    name = "稀有金属"
  },
  {name = "钨锭"},
  {name = "钛锭"},
  {name = "硅"},
  {name = "电路板"},
  {
    name = "高级电路板"
  }
}
local JGMATERIALS = {
  [1] = {
    name = "铁矿",
    need = 1,
    out = "铁锭",
    out_each = 1
  },
  [2] = {
    name = "铜矿",
    need = 1,
    out = "铜锭",
    out_each = 1
  },
  [3] = {
    name = "银矿",
    need = 1,
    out = "银锭",
    out_each = 1
  },
  [4] = {
    name = "金矿",
    need = 1,
    out = "金锭",
    out_each = 1
  },
  [5] = {
    name = "稀金矿",
    need = 1,
    out = "稀有金属",
    out_each = 1
  },
  [6] = {
    name = "钨矿",
    need = 1,
    out = "钨锭",
    out_each = 1
  },
  [7] = {
    name = "钛矿",
    need = 1,
    out = "钛锭",
    out_each = 1
  },
  [8] = {
    name = "沙子",
    need = 3,
    out = "硅",
    out_each = 1
  },
  [9] = {
    name = "石英矿",
    need = 1,
    out = "硅",
    out_each = 1
  }
}

local function _jgm_to_multi()
  local t = {}
  for i, cfg in ipairs(JGMATERIALS) do
    t[i] = {
      inputs = {
        {
          name = cfg.name,
          need = cfg.need
        }
      },
      outputs = {
        {
          name = cfg.out,
          qty = cfg.out_each or 1,
          mode = "mat"
        }
      }
    }
  end
  return t
end

local STATIONS = {
  ["先驱工厂"] = {
    cap = 10,
    energy = 10,
    recipes = _jgm_to_multi()
  },
  ["工作台"] = {
    cap = 1,
    energy = 2,
    recipes = {
      {
        inputs = {
          {name = "硅", need = 2},
          {name = "铜锭", need = 1}
        },
        outputs = {
          {
            name = "电路板",
            qty = 3,
            mode = "mat"
          }
        }
      },
      {
        inputs = {
          {name = "电路板", need = 1},
          {name = "金锭", need = 1}
        },
        outputs = {
          {
            name = "高级电路板",
            qty = 1,
            mode = "mat"
          }
        }
      },
      {
        inputs = {
          {name = "石头", need = 3}
        },
        outputs = {
          {
            name = "工作台(组装建筑)",
            qty = 1,
            mode = "item",
            itemid = "I0LR"
          }
        }
      },
      {
        inputs = {
          {name = "铁锭", need = 10},
          {name = "电路板", need = 3}
        },
        outputs = {
          {
            name = "制作台(组装建筑)",
            qty = 1,
            mode = "item",
            itemid = "I0LU"
          }
        }
      },
      {
        inputs = {
          {name = "铁锭", need = 10},
          {name = "电路板", need = 5}
        },
        outputs = {
          {
            name = "基础钻机(挖掘素材)",
            qty = 1,
            mode = "item",
            itemid = "I0LV"
          }
        }
      },
      {
        inputs = {
          {name = "铁锭", need = 10},
          {name = "电路板", need = 5}
        },
        outputs = {
          {
            name = "火力发电机(生产能量)",
            qty = 1,
            mode = "item",
            itemid = "I0LW"
          }
        }
      }
    }
  },
  ["制作台"] = {
    cap = 1,
    energy = 2,
    recipes = {
      {
        inputs = {
          {name = "硅", need = 2},
          {name = "铜锭", need = 1}
        },
        outputs = {
          {
            name = "电路板",
            qty = 3,
            mode = "mat"
          }
        }
      },
      {
        inputs = {
          {name = "电路板", need = 1},
          {name = "金锭", need = 1}
        },
        outputs = {
          {
            name = "高级电路板",
            qty = 1,
            mode = "mat"
          }
        }
      },
      {
        inputs = {
          {name = "钨锭", need = 15},
          {
            name = "高级电路板",
            need = 5
          }
        },
        outputs = {
          {
            name = "装配台(组装建筑)",
            qty = 1,
            mode = "item",
            itemid = "I0LY"
          }
        }
      },
      {
        inputs = {
          {name = "源石锭", need = 10},
          {
            name = "高级电路板",
            need = 5
          }
        },
        outputs = {
          {
            name = "源石发电机(生产能量)",
            qty = 1,
            mode = "item",
            itemid = "I0LX"
          }
        }
      },
      {
        inputs = {
          {name = "铁锭", need = 15},
          {name = "钨锭", need = 5},
          {
            name = "高级电路板",
            need = 5
          }
        },
        outputs = {
          {
            name = "进阶钻机(挖掘素材)",
            qty = 1,
            mode = "item",
            itemid = "I0LZ"
          }
        }
      }
    }
  },
  ["装配台"] = {
    cap = 1,
    energy = 2,
    recipes = {
      {
        inputs = {
          {name = "硅", need = 2},
          {name = "铜锭", need = 1}
        },
        outputs = {
          {
            name = "电路板",
            qty = 3,
            mode = "mat"
          }
        }
      },
      {
        inputs = {
          {name = "电路板", need = 1},
          {name = "金锭", need = 1}
        },
        outputs = {
          {
            name = "高级电路板",
            qty = 1,
            mode = "mat"
          }
        }
      },
      {
        inputs = {
          {
            name = "高级电路板",
            need = 1
          },
          {
            name = "稀有金属",
            need = 1
          }
        },
        outputs = {
          {
            name = "量子电路板",
            qty = 1,
            mode = "mat"
          }
        }
      }
    }
  },
  ["装备制造台"] = {
    cap = 1,
    energy = 2,
    recipes = {
      {
        inputs = {
          {name = "铁锭", need = 3}
        },
        outputs = {
          {
            name = "铁镐(物品)",
            qty = 1,
            mode = "item",
            itemid = "I0LS"
          }
        }
      },
      {
        inputs = {
          {name = "钻石", need = 1}
        },
        outputs = {
          {
            name = "钻石镐(物品)",
            qty = 1,
            mode = "item",
            itemid = "I0LT"
          }
        }
      },
      {
        inputs = {
          {name = "铁锭", need = 10}
        },
        outputs = {
          {
            name = "通用武器盒(物品)",
            qty = 1,
            mode = "item",
            itemid = "I0M0"
          }
        }
      },
      {
        inputs = {
          {name = "铁锭", need = 10}
        },
        outputs = {
          {
            name = "通用枪械盒(物品)",
            qty = 1,
            mode = "item",
            itemid = "I0M1"
          }
        }
      }
    }
  }
}

local function _recipe_disallow_input_names(r)
  local inputs = r.inputs or {}
  if 2 < #inputs then
    return true
  end
  for _, ot in ipairs(r.outputs or {}) do
    if (ot.mode or "mat") ~= "mat" then
      return true
    end
  end
  return false
end

local STATION_INDEX = {}
for station_key, st in pairs(STATIONS) do
  local map = {}
  for i, r in ipairs(st.recipes) do
    map[tostring(i)] = i
    for _, ot in ipairs(r.outputs or {}) do
      map[ot.name] = map[ot.name] or i
    end
    if not _recipe_disallow_input_names(r) then
      for _, it in ipairs(r.inputs or {}) do
        map[it.name] = map[it.name] or i
      end
    end
  end
  STATION_INDEX[station_key] = map
end

local function _parse_index_for_station(chat, station_key)
  if not chat or chat == "" then
    return nil
  end
  local s = chat:gsub("^%s+", ""):gsub("%s+$", "")
  local map = STATION_INDEX[station_key]
  if not map then
    return nil
  end
  if map[s] then return map[s] end
  for name, index in pairs(map) do
    if require("hera_korean").translate(name) == s then return index end
  end
  return nil
end

local function ProcessStationOnce(u, station_key, index)
  local st = STATIONS[station_key]
  if not st then
    u:sendmessage("|cffff6666未知站点：" .. tostring(station_key) .. "|r")
    return
  end
  local r = st.recipes[index]
  if not r then
    u:sendmessage("|cffff6666无效配方序号：" .. tostring(index) .. "|r")
    return
  end
  local energy_need = st.energy or 10
  local energy = Huanjing_Lingli or 0
  if energy_need > energy then
    u:sendmessage("|cffff6666能量不足，本次未加工|r")
    return
  end
  local npc = getunit(NPC_Wuzicangku)
  local max_by_inputs = math.huge
  for _, it in ipairs(r.inputs or {}) do
    local have = npc:getdata("素材数量-" .. it.name) or 0
    local can = math.floor(have / (it.need or 1))
    if max_by_inputs > can then
      max_by_inputs = can
    end
  end
  if max_by_inputs == math.huge then
    max_by_inputs = 0
  end
  if max_by_inputs <= 0 then
    for _, it in ipairs(r.inputs or {}) do
      local have = npc:getdata("素材数量-" .. it.name) or 0
      if have < (it.need or 1) then
        u:sendmessage((require("hera_korean").translate("|cffffaa00原料不足：%s（需要%d，当前%d）|r")):format(require("hera_korean").translate(it.name), it.need or 1, have))
        return
      end
    end
    u:sendmessage("|cffffaa00原料不足|r")
    return
  end
  local has_non_mat_output = false
  for _, ot in ipairs(r.outputs or {}) do
    if (ot.mode or "mat") ~= "mat" then
      has_non_mat_output = true
      break
    end
  end
  local cap = st.cap or 10
  if has_non_mat_output then
    cap = 1
  end
  local to_make = math.min(cap, max_by_inputs)
  if to_make <= 0 then
    u:sendmessage("|cffffaa00原料不足，本次未加工|r")
    return
  end
  for _, it in ipairs(r.inputs or {}) do
    local key = "素材数量-" .. it.name
    local have = npc:getdata(key) or 0
    npc:setdata(key, have - to_make * (it.need or 1))
  end
  local out_msgs = {}
  for _, ot in ipairs(r.outputs or {}) do
    local add = to_make * (ot.qty or 1)
    local mode = ot.mode or "mat"
    if mode == "mat" then
      local key = "素材数量-" .. ot.name
      local have = npc:getdata(key) or 0
      npc:setdata(key, have + add)
    elseif mode == "item" then
      if not ot.itemid then
        u:sendmessage("|cffff6666配置缺少 itemid：" .. tostring(ot.name) .. "|r")
      else
        for i = 1, add do
          u:additem(ot.itemid)
        end
      end
    elseif mode == "unit" then
      u:sendmessage("|cffffaa00未启用的输出模式 unit，请改用 item（可放置物品）|r")
    end
    table.insert(out_msgs, require("hera_korean").translate(ot.name) .. "×" .. tostring(add))
  end
  Huanjing_Lingli = energy - energy_need
  local in_msgs = {}
  for _, it in ipairs(r.inputs or {}) do
    table.insert(in_msgs, require("hera_korean").translate(it.name) .. "×" .. tostring(to_make * (it.need or 1)))
  end
  u:sendmessage((require("hera_korean").translate("|cff80ff80[%s] 完成：%s → %s；能量消耗%d|r")):format(require("hera_korean").translate(station_key), table.concat(in_msgs, "，"), table.concat(out_msgs, "，"), energy_need))
end

local function _fmt_io_list(list, key_name, key_qty, color)
  local parts = {}
  for _, e in ipairs(list or {}) do
    local nm = require("hera_korean").translate(e[key_name])
    local qty = e[key_qty] or 1
    if qty ~= 1 then
      table.insert(parts, (color or "") .. nm .. "×" .. qty .. "|r")
    else
      table.insert(parts, (color or "") .. nm .. "|r")
    end
  end
  return table.concat(parts, " + ")
end

local function _build_prompt(station_key)
  local st = STATIONS[station_key]
  if not st then
    return ""
  end
  local lines = {}
  local base_cap = st.cap
  local base_energy = st.energy
  table.insert(lines, (require("hera_korean").translate("|cFF7DBEF1—%s—|处理数量:%d 能量/次:%d|r")):format(require("hera_korean").translate(station_key), base_cap, base_energy))
  table.insert(lines, "|cFF7DBEF1— 可用配方列表(输入序号或名称) —|r")
  for i, r in ipairs(st.recipes) do
    local out_txt = _fmt_io_list(r.outputs, "name", "qty", "|cFF80FF80")
    local in_txt = _fmt_io_list(r.inputs, "name", "need", "|cFFB0B0B0")
    local line = ("|cFFAAD7FF[%d]|r %s |cFF7DBEF1←|r %s"):format(i, out_txt, in_txt)
    table.insert(lines, line)
  end
  return "\n" .. table.concat(lines, "\n")
end

local function AttachStationChat(u, station_key)
  local flag_key = "加工判定-" .. station_key
  local reg_key = "加工注册-" .. station_key
  u:sendmessage(_build_prompt(station_key))
  for sk, _ in pairs(STATIONS) do
    local fk = "加工判定-" .. sk
    if u:hasdata(fk) then
      u:deldata(fk)
    end
  end
  u:setdata(flag_key)
  if not u:hasdata(reg_key) then
    u:setdata(reg_key)
    u:addtrgevent("玩家-聊天", function(args)
      if u:hasdata(flag_key) then
        u:deldata(flag_key)
        local idx = _parse_index_for_station(args.chat, station_key)
        if idx then
          ProcessStationOnce(u, station_key, idx)
        else
          u:sendmessage("|cffffaa00无效输入，请重新输入序号或名称|r")
        end
      end
    end)
  end
end

local ENERGY_CAP = 10
local ENERGY_RECIPES = {
  [1] = {name = "煤炭", energy_per = 10},
  [2] = {name = "蓝晶石", energy_per = 25},
  [3] = {
    name = "源石原矿",
    energy_per = 20
  },
  [4] = {name = "源石锭", energy_per = 25},
  [5] = {name = "铀矿", energy_per = 400}
}

local function _build_energy_prompt()
  local lines = {}
  table.insert(lines, (require("hera_korean").translate("|cFF7DBEF1— 能源转换台 —|r  | 每次最多消耗: %d|r")):format(ENERGY_CAP))
  table.insert(lines, "|cFFAAAAAA输入序号进行转换|r")
  for i, r in ipairs(ENERGY_RECIPES) do
    local line = (require("hera_korean").translate("|cFFAAD7FF[%d]|r |cFF80FF80+%d 能源|r |cFF7DBEF1←|r |cFFB0B0B0%s×1|r")):format(i, r.energy_per, require("hera_korean").translate(r.name))
    table.insert(lines, line)
  end
  return "\n" .. table.concat(lines, "\n")
end

local function ProcessEnergyOnce(u, index)
  local r = ENERGY_RECIPES[index]
  if not r then
    u:sendmessage("|cffff6666无效序号|r")
    return
  end
  local npc = getunit(NPC_Wuzicangku)
  if not npc then
    u:sendmessage("|cffff6666未找到物资仓库|r")
    return
  end
  local key = "素材数量-" .. r.name
  local have = npc:getdata(key) or 0
  if have <= 0 then
    u:sendmessage((require("hera_korean").translate("|cffffaa00原料不足：%s 当前0|r")):format(require("hera_korean").translate(r.name)))
    return
  end
  local to_burn = math.min(ENERGY_CAP, have)
  if to_burn <= 0 then
    u:sendmessage("|cffffaa00原料不足，本次未转换|r")
    return
  end
  npc:setdata(key, have - to_burn)
  local gain = to_burn * (r.energy_per or 0)
  Huanjing_Lingli = (Huanjing_Lingli or 0) + gain
  local remain = npc:getdata(key) or 0
  u:sendmessage((require("hera_korean").translate("|cff80ff80能源转换完成：消耗 %s×%.0f  → 能量 +%.0f；剩余%s：%.0f；当前能量：%.0f|r")):format(require("hera_korean").translate(r.name), to_burn, gain, require("hera_korean").translate(r.name), remain, Huanjing_Lingli or 0))
end

local function _parse_energy_index(chat)
  if not chat or chat == "" then
    return nil
  end
  local num = tonumber(chat:match("^%s*(%d+)%s*$"))
  if num and ENERGY_RECIPES[num] then
    return num
  end
  return nil
end

local function AttachEnergyChat(u)
  local flag_key = "能源判定-燃料转换"
  local reg_key = "能源注册-燃料转换"
  if u:hasdata(flag_key) then
    u:deldata(flag_key)
  end
  u:sendmessage(_build_energy_prompt())
  u:setdata(flag_key)
  if not u:hasdata(reg_key) then
    u:setdata(reg_key)
    u:addtrgevent("玩家-聊天", function(args)
      if u:hasdata(flag_key) then
        u:deldata(flag_key)
        local idx = _parse_energy_index(args.chat)
        if idx then
          ProcessEnergyOnce(u, idx)
        else
          u:sendmessage("|cffffaa00无效输入，请输入序号（例如：1）|r")
        end
      end
    end)
  end
end

local b_biexibo_BGM = false
local pools = {
  {
    name = "启动",
    typeid = "h05L",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      npc:groupadd(Group_Yunxingshebei)
      u:sendmessage("|cFF7DBEF1设备开启|r")
    end
  },
  {
    name = "关闭",
    typeid = "h05M",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      npc:groupremove(Group_Yunxingshebei)
      u:sendmessage("|cFF7DBEF1设备关闭|r")
    end
  },
  {
    name = "充能",
    typeid = "h05J",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      AttachEnergyChat(u)
    end
  },
  {
    name = "打包",
    typeid = "h05K",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local x, y = npc:getxy()
      local itemtype = "I0LR"
      if npc:hasdata("建筑-工作台") then
        itemtype = "I0LR"
      end
      if npc:hasdata("建筑-制作台") then
        itemtype = "I0LU"
      end
      if npc:hasdata("建筑-装配台") then
        itemtype = "I0LY"
      end
      if npc:hasdata("建筑-装备制造台") then
        itemtype = "I0M3"
      end
      if npc:hasdata("建筑-进阶钻机") then
        itemtype = "I0LZ"
      end
      if npc:hasdata("建筑-破损的先驱挖掘装置") then
        itemtype = "I0M2"
      end
      if npc:hasdata("建筑-进阶钻机") then
        itemtype = "I0LZ"
      end
      if npc:hasdata("建筑-火力发电机") then
        itemtype = "I0LW"
      end
      if npc:hasdata("建筑-源石发电机") then
        itemtype = "I0LX"
      end
      npc:groupremove(Group_Yunxingshebei)
      npc:remove()
      CreateItemLua(itemtype, x, y)
    end
  },
  {
    name = "加工",
    typeid = "h05I",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local str = "工作台"
      if npc.type == S2ID("n00Z") then
        str = "先驱工厂"
      end
      AttachStationChat(u, str)
    end
  },
  {
    name = "真红-光之翼",
    typeid = "h036",
    func = function(self, args)
      local u = args.u
      if Stage < 3 and not Boolean_ZhenhongBiding then
        local npc = getunit(NPC_ZHENHONG)
        npc:playseensound(BOSS_Zhenhong_Chuansong)
        local dx, dy = npc:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
          x = dx,
          y = dy
        })
        ShowUnit(NPC_ZHENHONG, false)
        u:sendmessage("|cFFFFFF33你|r|cFFFFEE30告|r|cFFFFDD2C诉|r|cFFFFCC29了|r|cFFFFBB25少|r|cFFFFAA22女|r|cFFFF991F现|r|cFFFF881B在|r|cFFFF7718这|r|cFFFF6614样|r|cFFFF5511就|r|cFFFF440E可|r|cFFFF330A以|r|cFFFF2207了|r")
        Boolean_Zhenhong = false
      end
    end
  },
  {
    name = "真红-世界的命运",
    typeid = "h037",
    func = function(self, args)
      local u = args.u
      if Stage < 3 then
        local b = true
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy = xq.ownerid
          if Hero_Shenhua_Now[sy] > 0 then
            b = false
          end
        end)
        if b then
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy = xq.ownerid
            ChangeValue(Hero_Shenhua_Left, sy, -1)
          end)
          local npc = getunit(NPC_ZHENHONG)
          npc:playseensound(BOSS_Zhenhong_Chuansong)
          local dx, dy = npc:getxy()
          EffectcreateArgs({
            effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
            x = dx,
            y = dy
          })
          ShowUnit(NPC_ZHENHONG, false)
          SendMsgAll(u:getplayername() .. "|cFFFFFF33告|r|cFFFFEE30诉|r|cFFFFDD2C少|r|cFFFFCC29女|r|cFFFFBB25，|r|cFFFFAA22她|r|cFFFF991F遗|r|cFFFF881B忘|r|cFFFF7718了|r|cFFFF6614重|r|cFFFF5511要|r|cFFFF440E的|r|cFFFF330A记|r|cFFFF2207忆|r")
          Boolean_ZhenhongBiding = true
        else
          u:sendmessage("|cFFFFFF33你|r|cFFFFF230正|r|cFFFFE62E在|r|cFFFFD92B被|r|cFFFFCC29凝|r|cFFFFBF26视|r|cFFFFB224(|r|cFFFFA621任|r|cFFFF991F意|r|cFFFF8C1C英|r|cFFFF801A雄|r|cFFFF7317已|r|cFFFF6614拥|r|cFFFF5912有|r|cFFFF4C0F神|r|cFFFF400D化|r|cFFFF330A力|r|cFFFF2608量|r|cFFFF1A05)|r")
        end
      end
    end
  },
  {
    name = "尼禄-唱歌",
    typeid = "h04W",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      PlayBGM({
        bgm = BGM_Padoru,
        time = 165,
        ID = 185
      })
      ac.wait(165000, function()
        StopSoundBJ(BGM_Padoru, true)
      end)
    end
  },
  {
    name = "尼禄-Padoru",
    typeid = "h04X",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      PlayGlobalSound(Sound_Padoru)
    end
  },
  {
    name = "尼禄-背包皮肤",
    typeid = "h04Y",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local sy = u.ownerid
      local bb = getunit(Beibao[sy])
      japi.SetUnitModel(bb.handle, "padoru.mdx")
      bb:setsize(0.35)
    end
  },
  {
    name = "源石处理设施-技术项目暂时取消",
    typeid = "h04S",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      if npc:hasdata("技术突破-当前图纸") then
        local x, y = u:getxy()
        local wp = CreateItemLua(npc:getdata("技术突破-当前图纸物品类型"), x, y)
        SetData(wp, "图纸-对应内容", npc:getdata("技术突破-当前图纸"))
        SetData(wp, "图纸-破解进度", npc:getdata("技术突破-当前破解进度"))
        npc:deldata("技术突破-当前图纸")
        npc:deldata("技术突破-当前图纸物品类型")
        npc:deldata("技术突破-当前破解进度")
        u:sendmessage("|cFF7DBEF1取消当前技术突破项目|r")
        npc:setskilldatastring("A08R", "提示", "|cFF7DBEF1当前技术研究项目:[无]|r")
        npc:setskilldatastring("A08R", "提示拓展", "|cFF7DBEF1等待图纸添加|r")
        npc:setskilldatastring("A08R", "图标", "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
      else
        u:sendmessage("|cFF7DBEF1当前没有技术突破项目|r")
      end
    end
  },
  {
    name = "源石处理设施-技术项目研究推进",
    typeid = "h04R",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      if args.isbbbuy then
        u = args.bb
      end
      if npc:hasdata("技术突破-当前图纸") then
        local tuzhi = npc:getdata("技术突破-当前图纸")
        for index, value in ipairs(Tuzhi_All) do
          if value.name == tuzhi then
            tuzhi = value
          end
        end
        local rb = tuzhitupo(u, tuzhi)
        if rb.value ~= 0 then
          local add = GetRandomReal(tuzhi.add1, tuzhi.add2)
          local gl = tuzhi.cgl * rb.cgl
          if GetRandom100(gl) then
            if GetRandom100(5) then
              add = add * 2
              SendMsgAll(u:getplayername() .. "|cFF7DBEF1在技术突破时触发灵光一闪|r")
              u:sendmessage("|cFF6699FF[灵光一闪]|r|cFF7DBEF1,进度迅速推进,进度改变:" .. string.format("%.1f", add) .. "%|r")
            else
              u:sendmessage("|cFF1BE6B8成功|r|cFF7DBEF1,进度改变:" .. string.format("%.1f", add) .. "%|r")
            end
          elseif GetRandom100(5) then
            SendMsgAll(u:getplayername() .. "|cFF7DBEF1在技术突破时触发灵光一闪|r")
            u:sendmessage("|cFFCC0000[灵光一闪]|r|cFF7DBEF1,失败补救回来了,进度改变:" .. string.format("%.1f", add) .. "%|r")
          else
            add = add * tuzhi.addfail
            u:sendmessage("|cFFCC0000失败|r|cFF7DBEF1,进度改变:" .. string.format("%.1f", add) .. "%|r")
          end
          npc:changedata("技术突破-当前破解进度", add)
          if npc:getdata("技术突破-当前破解进度") >= 100 then
            npc:setdata("技术突破-当前破解进度", 100)
          end
          u:sendmessage("|cFF7DBEF1当前进度:" .. string.format("%.1f", npc:getdata("技术突破-当前破解进度")) .. "%|r")
          if npc:getdata("技术突破-当前破解进度") >= 100 then
            PlayGlobalSound(Sound_Keyanwancheng)
            SendMsgAll("|cFF1BE6B8技术突破项研究完毕:[" .. tuzhi.name .. "]|r", 60)
            SendMsgAll(tuzhi.outcometext, 60)
            tuzhi:outcome(u)
            npc:deldata("技术突破-当前图纸")
            npc:deldata("技术突破-当前破解进度")
            npc:setskilldatastring("A08R", "提示", "|cFF7DBEF1当前技术研究项目:[无]|r")
            npc:setskilldatastring("A08R", "提示拓展", "|cFF7DBEF1等待图纸添加|r")
            npc:setskilldatastring("A08R", "图标", "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
          end
        else
          u:sendmessage("|cFF7DBEF1资源不足|r")
        end
      else
        u:sendmessage("|cFF7DBEF1当前没有技术突破项目|r")
      end
    end
  },
  {
    name = "先驱加工厂-清空储存区",
    typeid = "h04Q",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      for i = 1, 6 do
        local wp = npc:getcountitem(i)
        if wp ~= 0 then
          u:addspeitem(wp)
        end
      end
    end
  },
  {
    name = "先驱加工厂-微型物质重组仪",
    typeid = "h04P",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local wp = npc:getcountitem(1)
      if wp == 0 then
        u:sendmessage("|cFFFFCC33加工厂第一格未放置物品|r")
        return
      end
      local typeid = GetItemTypeId(wp)
      local fzid
      local xh = 0
      for index, value in ipairs(wzcz200) do
        if typeid == S2ID(value) then
          fzid = value
          xh = 200
        end
      end
      for index, value in ipairs(wzcz250) do
        if typeid == S2ID(value) then
          fzid = value
          xh = 250
        end
      end
      for index, value in ipairs(wzcz500) do
        if typeid == S2ID(value) then
          fzid = value
          xh = 500
        end
      end
      for index, value in ipairs(wzcz1000) do
        if typeid == S2ID(value) then
          fzid = value
          xh = 1000
        end
      end
      for index, value in ipairs(wzcz) do
        if typeid == S2ID(value.typeid) then
          fzid = value.typeid
          xh = value.xh
        end
      end
      if xh ~= 0 then
        if xh <= npc:getmp() then
          npc:curemp(-1 * xh)
          u:sendmessage("|cFFFFCC33复制成功|r")
          local x, y = u:getxy()
          CreateItemLua(fzid, x, y)
        else
          u:sendmessage("|cFFFFCC33能源不足,所需能源:" .. xh .. "|r")
        end
      else
        u:sendmessage("|cFF6699FF这件物品无法复制|r")
      end
    end
  },
  {
    name = "先驱加工厂-重新启动工厂",
    typeid = "h04N",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local b = false
      if npc:getmp() >= 1000 then
        b = true
      end
      npc:curemp(-1000)
      if b then
        local x, y = npc:getxy()
        local mp = npc:getmp()
        npc:remove()
        local newnpc = getunit(NPC_Xianqujiagongchang)
        newnpc:setxy(x, y)
        newnpc:setmp(mp)
        ShowUnit(newnpc.handle, false)
        ShowUnit(newnpc.handle, true)
        SendMsgAll("|cFFFFCC33先驱加工厂成功启动了|r")
      else
        u:sendmessage("|cFF6699FF启动失败，能源不足|r")
      end
    end
  },
  {
    name = "先驱加工厂-能源装填",
    typeid = "h04O",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local add = 0
      for i = 1, 6 do
        local wp = npc:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        if wptype == S2ID("I0I2") then
          add = add + GetItemCharges(wp) * 10
          RemoveItemLua(wp)
        end
        if wptype == S2ID("I0IG") or wptype == S2ID("I0IB") then
          add = add + GetItemCharges(wp) * 100
          RemoveItemLua(wp)
        end
        if wptype == S2ID("I0IC") then
          add = add + GetItemCharges(wp) * 5000
          RemoveItemLua(wp)
        end
      end
      npc:curemp(add)
      if 0 < add then
        u:sendmessage("|cFF6699FF填充了" .. add .. "单位的能源|r")
      else
        u:sendmessage("|cFF6699FF没有可以用作能源的材料|r")
      end
    end
  },
  {
    name = "源石处理设施-源石加工",
    typeid = "h04L",
    func = function(self, args)
      local u = args.u
      local hero = u
      local npc = args.npc
      if args.isbbbuy then
        u = args.bb
      end
      local b = false
      b = itemcompund({
        unit = u.handle,
        item1 = "I0I1",
        count1 = 1,
        item2 = "I0IB",
        count2 = 1,
        item3 = "I02E",
        count3 = 1,
        coitem = "I0ID"
      })
      b = itemcompund({
        unit = u.handle,
        item1 = "I0I1",
        count1 = 2,
        item2 = "I0IB",
        count2 = 4,
        item3 = "I02F",
        count3 = 2,
        coitem = "I0IE"
      })
      b = itemcompund({
        unit = u.handle,
        item1 = "I0I1",
        count1 = 2,
        item2 = "I0IB",
        count2 = 4,
        item3 = "I030",
        count3 = 1,
        coitem = "I0IE"
      })
      b = itemcompund({
        unit = u.handle,
        item1 = "I0IG",
        count1 = 10,
        item2 = "I0IB",
        count2 = 10,
        coitem = "I0IC"
      })
      b = itemcompund({
        unit = u.handle,
        item1 = "I0I1",
        count1 = 3,
        item2 = "I08E",
        count2 = 1,
        item3 = "I0IC",
        count3 = 1,
        coitem = "I0IF"
      })
      if hero:getdata("龙血浓度") > 0 then
        b = itemcompund({
          unit = u.handle,
          item1 = "I0IC",
          count1 = 1,
          item2 = "I011",
          count2 = 4,
          coitem = "I0IT"
        })
      end
      if u:ishasitem("I0IC") and u:ishasitem("I0GR") then
        local wp = u:getitem("I0GR")
        local lb = false
        local cf
        for index, value in ipairs(Vars_Blood) do
          if value.name == GetData(wp, "血晶-定向") then
            cf = value.bloodkey
            break
          end
        end
        if cf then
          for index, value in ipairs(cf) do
            if value == "龙" then
              lb = true
            end
          end
        end
        if lb then
          ChangeItemCount(u:getitem("I0IC"), -1)
          RemoveItemLua(wp)
          u:additem("I0IT")
          u:sendmessage("|cFF7DBEF1加工成功|r")
          return
        end
      end
      if npc:hasdata("技术突破-晶体复制") then
        b = itemcompund({
          unit = u.handle,
          item1 = "I0I1",
          count1 = 1,
          item2 = "I0IG",
          count2 = 1,
          coitem = "I08C"
        })
        b = itemcompund({
          unit = u.handle,
          item1 = "I0I1",
          count1 = 1,
          item2 = "I0IB",
          count2 = 1,
          coitem = "I08C"
        })
      end
      if npc:hasdata("技术突破-幻海培育") then
        b = itemcompund({
          unit = u.handle,
          item1 = "I0IH",
          count1 = 1,
          coitem = "I035"
        })
      end
      if b then
        u:sendmessage("|cFF7DBEF1加工成功|r")
      else
        u:sendmessage("|cFF7DBEF1无可加工物品|r")
      end
    end
  },
  {
    name = "源石处理设施-血液检测",
    typeid = "h04M",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      u:losshp(u, 100)
      local nd = u:getdata("系统-血液源石结晶密度")
      local text = "无症状阶段"
      if 100 <= nd then
        text = "轻微症状阶段"
      end
      if 300 <= nd then
        text = "严重阶段"
      end
      if 400 <= nd then
        text = "非常严重阶段"
      end
      if 500 <= nd then
        text = "无法抑制阶段"
      end
      if 800 <= nd then
        text = "致死阶段"
      end
      u:sendmessage("|cFFFF9900血液源石结晶密度:[" .. text .. "]" .. string.format("%.1f", nd) .. "u/ml|r")
    end
  },
  {
    name = "纳西妲-植株回收",
    typeid = "h04J",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      if args.isbbbuy then
        u = args.bb
      end
      local b = false
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        if wptype == S2ID("I07D") or wptype == S2ID("I0GW") or wptype == S2ID("I0A2") or wptype == S2ID("I0A3") or wptype == S2ID("I08C") then
          local add = GetItemCharges(wp) * 90
          u:addgold(add)
          RemoveItemLua(wp)
          b = true
        end
      end
      if b then
        u:sendmessage("|cFFFF9966回收成功|r")
      else
        u:sendmessage("|cFFFF9966没有可回收植株|r")
      end
    end
  },
  {
    name = "老吴-农夫三拳",
    typeid = "h061",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local b = false
      if u:hasdata("英雄-志贵") then
        b = true
      end
      if b then
        local sj = GetRandomInt(1, 3)
        if sj == 1 then
          u:setdata("志贵-远野模型", "units\\human\\Peasant\\Peasant.mdx")
          u:setdata("志贵-远野模型大小", 1.85)
          u:setdata("志贵-七夜模型", "units\\orc\\Peon\\Peon.mdx")
          u:setdata("志贵-七夜模型大小", 1.85)
        end
        if sj == 2 then
          u:setdata("志贵-远野模型", "units\\orc\\Peon\\Peon.mdx")
          u:setdata("志贵-远野模型大小", 1.85)
          u:setdata("志贵-七夜模型", "units\\demon\\ChaosPeon\\ChaosPeon.mdx")
          u:setdata("志贵-七夜模型大小", 1.85)
        end
        if sj == 3 then
          u:setdata("志贵-远野模型", "units\\human\\Peasant\\Peasant.mdx")
          u:setdata("志贵-远野模型大小", 1.85)
          u:setdata("志贵-七夜模型", "units\\critters\\HighElfPeasant\\HighElfPeasant")
          u:setdata("志贵-七夜模型大小", 1.85)
        end
        u:sendmessage("|cFFFF9966下次切换形态变更模型|r")
      else
        u:sendmessage("|cFFFF9966你不是我要找的人,你走吧|r")
      end
    end
  },
  {
    name = "老吴-遗物回收",
    typeid = "h04K",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      if args.isbbbuy then
        u = args.bb
      end
      local b = false
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        local lx = GetItemType(wp)
        if lx == ITEM_TYPE_CAMPAIGN and HasData(wp, "遗物品质") then
          local str = GetData(wp, "遗物品质")
          if str == "普通" then
            b = true
            u:addgold(100)
          end
          if str == "稀有" then
            b = true
            u:addgold(200)
          end
          if str == "魔法" then
            b = true
            u:addgold(400)
          end
          if str == "传奇" then
            b = true
            u:addgold(800)
          end
          RemoveItemLua(wp)
        end
      end
      if b then
        u:sendmessage("|cFFFF9966回收成功|r")
      else
        u:sendmessage("|cFFFF9966没有可回收遗物|r")
      end
    end
  },
  {
    name = "老吴-材料回收",
    typeid = "h04I",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      if args.isbbbuy then
        u = args.bb
      end
      local b = false
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        if wptype == S2ID("I0I2") or wptype == S2ID("I0HL") or wptype == S2ID("I0HM") or wptype == S2ID("I0I0") then
          local add = GetItemCharges(wp) * 20
          u:addgold(add)
          RemoveItemLua(wp)
          b = true
        end
      end
      if b then
        u:sendmessage("|cFFFF9966回收成功|r")
      else
        u:sendmessage("|cFFFF9966没有可回收材料|r")
      end
    end
  },
  {
    name = "老吴-兑换洛阳稿",
    typeid = "h04T",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        if wptype == S2ID("I0HL") and GetItemCharges(wp) >= 30 then
          ChangeItemCount(wp, -30)
          u:additem("I0HW")
          break
        end
      end
    end
  },
  {
    name = "老吴-洛阳稿",
    typeid = "h04H",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      u:additem("I0HW")
    end
  },
  {
    name = "伊丝-问答药剂",
    typeid = "h04U",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      local count = u:getdata("伊丝-问答药剂购买次数")
      local xh = 100 * 2 ^ count
      if xh <= u:getgold() then
        u:sendmessage("|cFF7DBEF1兑换成功")
        u:additem("I0J9")
        u:addgold(-xh)
        u:changedata("伊丝-问答药剂购买次数", 1)
      else
        u:sendmessage("|cFF7DBEF1所需积分：" .. math.floor(xh))
      end
    end
  },
  {
    name = "伊丝-百科全书",
    typeid = "h04G",
    func = function(self, args)
      local u = args.u
      local npc = args.npc
      if args.isbbbuy then
        u = args.bb
      end
      local wp = u:getcountitem(1)
      if wp ~= 0 then
        local wplx = GetItemTypeId(wp)
        local text = "|cFF949596未录入|r"
        for index, value in ipairs(bkqs) do
          if S2ID(value.typeid) == wplx then
            text = value.text
            break
          end
        end
        u:sendmessage(text)
        if wplx == S2ID("I0JR") and not Boolean_Shijietanzhen then
          Boolean_Shijietanzhen = true
          SendMsgAll("|cFF6699FF现在点击信标时将会消耗并建立联系通道|r|cFF990000(不可逆)|r")
        end
      else
        u:sendmessage("|cFF949596第一格没有物品|r")
      end
    end
  },
  {
    name = "无极-挑战无极",
    typeid = "h04D",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = getunit(NPC_WUJI)
      local x, y = npc:getxy()
      if BossBattle and Boolean_TestMode then
        u:sendmessage("|cFF990000存在其他BOSS|r")
        return
      end
      if Mode_Dabamoshi then
        return
      end
      if u:getdata("系统-累积升级") < 40 and not u:hasdata("吞世之殿-无限之蛇次数") and not npc:hasdata("无极-已解锁条件") then
        u:sendmessage("|cFF990000等级不足|r")
        return
      end
      if npc:hasdata("无极-反应训练中") then
        u:sendmessage("|cFF990000无极老师正在进行反应训练|r")
        return
      end
      if not IsBOSSDead and not ModeSelect_Infinite and not npc:hasdata("无极-已解锁条件") then
        u:sendmessage("|cFF990000未击败BOSS|r")
        return
      end
      npc:setdata("无极-已解锁条件")
      ShowUnit(npc.handle, false)
      BOSS_Wj = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), "u05E", x, y, -90)
      boss_wj(BOSS_Wj)
    end
  },
  {
    name = "无极-武道指导",
    typeid = "h04B",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if not u:hasdata("无极-武道指导") then
        u:addstexiao("无极-武道指导", "终结伤害计算效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if u:hasdata("无极-武道指导") then
            info.enddown = info.enddown * 0.2
          end
        end)
        u:settimedata("无极-武道指导", 240)
        u:sendmessage("|cFF990000接受武道指导|r")
        ac.wait(240000, function()
          u:sendmessage("|cFF990000武道指导结束|r")
        end)
      end
    end
  },
  {
    name = "无极-反应训练",
    typeid = "h04C",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = getunit(NPC_WUJI)
      if npc:hasdata("无极-反应训练中") then
        u:sendmessage("|cFF990000无极老师正在指导别人|r")
        return
      end
      if u:hasdata("无极-反应训练冷却") then
        u:sendmessage("|cFF990000过段时间再来训练吧|r")
        return
      end
      npc:setdata("无极-反应训练中")
      u:settimedata("无极-反应训练冷却", 180)
      u:sendmessage("|cFF9900003秒后开始|r")
      local t2 = GetRandomReal(0.7, 1.1)
      u:sendmessage("|cFF990000第一刀将在倒计时结束" .. string.format("%.1f", t2) .. "秒后开始|r")
      ac.wait(1000, function()
        u:sendmessage("|cFF9900003……|r")
      end)
      ac.wait(2000, function()
        u:sendmessage("|cFF9900002……|r")
      end)
      ac.wait(3000, function()
        u:sendmessage("|cFF9900001……|r")
      end)
      ac.wait(4000, function()
        u:sendmessage("|cFF990000训练开始|r")
        local cs = 0
        local t = 0
        u:setdata("无极-反应训练命中次数", 0)
        local t3 = GetRandomReal(0.9, 1.3)
        ac.loop(25, function(timer)
          t = t + 0.025
          if t >= t2 then
            t = 0
            t2 = t3
            cs = cs + 1
            local zjsj2 = 0.35
            ac.wait(100, function()
              u:playselfsound(wj_yxws)
            end)
            u:playselfsound(SE050)
            u:effectadd("war3mapImported\\blink_1.mdx", "overhead")
            local x4, y4 = u:getxy()
            npc:animeact("attack")
            ac.wait(zjsj2 * 1000, function()
              u:playselfsound(Wj_Yx1)
              u:playselfsound(Wj_Yx3)
              x4, y4 = u:getxy()
              Effectcreate("war3mapImported\\176.mdl", x4, y4, 7, 3, 100, GetRandomAngle())
              ac.wait(50, function()
                DamageUnit({
                  unit = u.handle,
                  source = BOSS_DEATH,
                  damage = 100,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无"
                })
                if u:getdata("绝对闪避时间") == 0 then
                  u:changedata("无极-反应训练命中次数", 1)
                  u:sendmessage("|cFF990000命中次数：" .. math.floor(u:getdata("无极-反应训练命中次数")) .. "|r")
                end
              end)
            end)
          end
          if 10 <= cs then
            ac.wait(1000, function()
              local count = 10 - u:getdata("无极-反应训练命中次数")
              if u:getdata("角色基础伤害") > 0 then
                u:changedata("无极-武道指导提升伤害", 50 * count)
              else
                ChangeValue(Correction_Jzsh, sy, 0.1 * (0.01 * count))
              end
              if count == 10 then
                u:setdata("无极-完美通过训练")
                SendMsgAll(u:getplayername() .. "|cFF990000完美通过了无极老师的训练|r")
                if u:getdata("角色基础伤害") > 0 then
                  u:changedata("无极-武道指导提升伤害", 1000)
                else
                  ChangeValue(Correction_Jzsh, sy, 0.020000000000000004)
                end
              else
                u:sendmessage("|cFF990000训练完成,总计命中次数：" .. math.floor(u:getdata("无极-反应训练命中次数")) .. "|r")
              end
              npc:animeact("stand")
              npc:deldata("无极-反应训练中")
              u:deldata("无极-反应训练命中次数")
            end)
            timer:remove()
          end
        end)
      end)
    end
  },
  {
    name = "八云紫-诅咒祛除",
    typeid = "h023",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local lv = u:getlevel()
      local xf = 100 + u:getdata("祛除诅咒次数") * 500
      if xf > u:getgold() then
        u:sendmessage("积分不足 所需积分：" .. math.floor(xf))
        return
      end
      local zu = {}
      for index, value in ipairs(removezuzhou) do
        if u:hasdata("变异判定-" .. value) then
          table.insert(zu, value)
        end
      end
      if #zu == 0 then
        u:sendmessage("不存在诅咒")
        return
      end
      local quchu = zu[GetRandomInt(1, #zu)]
      u:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl")
      u:changedata("祛除诅咒次数", 1)
      u:sendmessage("成功祛除了诅咒")
      u:addgold(-1 * xf)
      u:deldata("变异判定-" .. quchu)
      u:uivar_remove(quchu, "疾病栏")
    end
  },
  {
    name = "八云紫-职业进阶",
    typeid = "h01Y",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local lv = u:getlevel()
      local xf = 0
      if not u:hasdata("职业判定-已选择") then
        u:sendmessage("未选择初始职业")
        return
      end
      if u:hasdata("职业进阶-一转") then
        u:sendmessage("已完成一转")
        return
      end
      if lv < 5 then
        u:sendmessage("等级不足")
        return
      end
      if lv <= 15 then
        xf = 250 * (15 - lv)
      end
      if xf > u:getgold() then
        u:sendmessage("|cFF7DBEF1积分不足 所需积分：" .. math.floor(xf))
        return
      end
      u:effectadd("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl")
      u:setdata("职业进阶-一转")
      ProJinjie(u)
      u:addgold(-1 * xf)
    end
  },
  {
    name = "村正-神兵",
    typeid = "h028",
    func = function(self, args)
      local u = args.u
      local npc = getunit(NPC_CUNZHENG)
      if npc:hasdata("锻造中武器") then
        local targetitem = npc:getdata("锻造中武器")
        local itemtype = targetitem.itemtype
        if not targetitem.hasbeenget then
          u:sendmessage("|cFF7DBEF1目前锻造中武器：|r" .. slk.item[ID2S(itemtype)].Name)
          u:addgold(400)
          return
        end
      end
      local x, y = u:getxy()
      local mj = u:createunit("h02A", x, y)
      mj:registertrgevent("单位-发动技能")
      mj:registertrgevent("单位-被取消选择")
      local skill = {}
      local selskill = {}
      skill[1] = S2ID("A1RS")
      skill[2] = S2ID("A1RT")
      skill[3] = S2ID("A1RU")
      selskill[1] = S2ID("A1RV")
      selskill[2] = S2ID("A1RW")
      selskill[3] = S2ID("A1RX")
      
      local function skillfunc(args)
        if args.skill == selskill[1] or args.skill == selskill[2] or args.skill == selskill[3] then
          local sy = mj.ownerid
          u:select()
          local targetitem
          if args.skill == selskill[1] then
            targetitem = mj:getdata("绑定锻造1")
          end
          if args.skill == selskill[2] then
            targetitem = mj:getdata("绑定锻造2")
          end
          if args.skill == selskill[3] then
            targetitem = mj:getdata("绑定锻造3")
          end
          mj:remove()
          if targetitem == 0 then
            return
          end
          local itemtype = targetitem.itemtype
          if npc:hasdata("锻造中武器") and not targetitem.hasbeenget then
            u:sendmessage("|cFF7DBEF1目前锻造中武器：|r" .. slk.item[itemtype].Name)
            return
          end
          npc:setdata("锻造武器数量", u:getdata("锻造武器数量"))
          npc:setdata("锻造者", u)
          local xf
          if npc:getdata("锻造武器数量") == 0 then
            xf = 1000
          else
            xf = 1500 + 1000 * npc:getdata("锻造武器数量")
          end
          xf = 400
          if GameStage_BOSS1End then
            xf = xf * 2
          end
          if Weiyi_Dz[25] then
            xf = xf * 0.7
          end
          local shadow_discount = math.min(0.95, u:getdata("伊塔-锻造消耗降低"))
          xf = xf * (1 - shadow_discount)
          if xf <= u:getgold() then
            if u:hasdata("卡斯特-圣剑基型") then
              local x, y = u:getxy()
              u:sendmessage("|cFFFFCC00圣剑的基型|r")
              u:deldata("卡斯特-圣剑基型")
              targetitem.hasbeenget = true
              local wp = u:additem(itemtype)
              SetItemPosition(wp, x, y)
              System_Count_Weapon = System_Count_Weapon + 1
              SetData(wp, "物品判定-神兵")
              SetData(wp, "神兵-锻造")
            else
              u:addgold(-1 * xf)
              npc:setdata("锻造中武器", targetitem)
              u:sendmessage("|cFF7DBEF1目前锻造中武器：|r" .. slk.item[itemtype].Name)
              u:playsound(BlacksmithWhat1)
            end
          else
            u:sendmessage("|cFF7DBEF1所需积分：" .. math.floor(xf))
          end
        end
      end
      
      mj:addtrgevent("单位-发动技能", function(args)
        skillfunc(args)
      end)
      mj:addtrgevent("单位-被取消选择", function(args)
        mj:remove()
      end)
      mj:setdata("绑定锻造1", 0)
      mj:setdata("绑定锻造2", 0)
      mj:setdata("绑定锻造3", 0)
      for i = 1, 3 do
        local b = false
        local b2 = false
        for max = 1, 25 do
          local pools = {
            Pools_SpeWeapon,
            Pools_SpeDzWeapon,
            Pools_SpeNormalWeapon,
            Pools_DuanzaoSpeWeapon
          }
          u:setdata("只返回值")
          local targetitem = herogetitem(u.handle, pools, x, y)
          u:deldata("只返回值")
          if not targetitem then
            break
          end
          local itemtype = targetitem.itemtype
          for index, value in ipairs(Duanzaopools) do
            if value.itemtype == itemtype then
              b = true
              local b3 = true
              for j = 1, 3 do
                if mj:getdata("绑定锻造" .. j) == targetitem then
                  b3 = false
                end
              end
              if b3 and value.condition and value.condition(u) and not targetitem.nocanforging then
                b2 = true
                mj:setdata("绑定锻造" .. i, targetitem)
                if u:islocal() then
                  u:setskilldatastring(skill[i], "图标", slk.item[itemtype].Art)
                  u:setskilldatastring(skill[i], "提示", slk.item[itemtype].Name)
                  local str = slk.item[itemtype].Ubertip
                  local targetString = ",DataA1"
                  local startIndex, endIndex = string.find(str, targetString)
                  if startIndex then
                    str = string.sub(str, 1, startIndex - 1)
                  end
                  u:setskilldatastring(skill[i], "提示拓展", str)
                end
                break
              end
            end
          end
          if b2 then
            break
          end
          if not b then
            local b3 = true
            for j = 1, 3 do
              if mj:getdata("绑定锻造" .. j) == targetitem then
                b3 = false
              end
            end
            if b3 and not targetitem.nocanforging then
              mj:setdata("绑定锻造" .. i, targetitem)
              if u:islocal() then
                u:setskilldatastring(skill[i], "图标", slk.item[itemtype].Art)
                u:setskilldatastring(skill[i], "提示", slk.item[itemtype].Name)
                local str = slk.item[itemtype].Ubertip
                local targetString = ",DataA1"
                local startIndex, endIndex = string.find(str, targetString)
                if startIndex then
                  str = string.sub(str, 1, startIndex - 1)
                end
                u:setskilldatastring(skill[i], "提示拓展", str)
              end
              break
            end
          end
        end
      end
      for i = 1, 3 do
        if mj:getdata("绑定锻造" .. i) == 0 then
          u:setskilldatastring(skill[i], "图标", "war3mapImported\\btncommand_stop.blp")
          u:setskilldatastring(skill[i], "提示", "无")
          u:setskilldatastring(skill[i], "提示拓展", "无")
        end
      end
      u:select(mj)
    end
  },
  {
    name = "村正-锻造",
    typeid = "h029",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = getunit(NPC_CUNZHENG)
      if not npc:hasdata("锻造中武器") then
        u:sendmessage("|cFF7DBEF1未选择锻造武器|r")
        return
      end
      local targetitem = npc:getdata("锻造中武器")
      if targetitem.hasbeenget then
        u:sendmessage("|cFF7DBEF1无法继续锻造该武器|r")
        npc:deldata("锻造中武器")
        npc:setdata("锻造武器次数", 0)
        return
      end
      local xf
      npc:setdata("锻造武器数量", u:getdata("锻造武器数量"))
      if npc:getdata("锻造武器数量") == 0 then
        xf = 250
      else
        xf = 250 + 750 * npc:getdata("锻造武器数量")
      end
      xf = 250
      if GameStage_BOSS1End then
        xf = xf * 2
      end
      if Weiyi_Dz[25] then
        xf = xf * 0.85
      end
      local shadow_discount = math.min(0.95, u:getdata("伊塔-锻造消耗降低"))
      xf = xf * (1 - shadow_discount)
      if xf <= u:getgold() then
        u:addgold(-1 * xf)
        if u:hasdata("神化判定-千子村正") then
          local sj = GetRandomInt(3, 9)
          u:addallstats(sj)
          u:sendmessage("|cFF9900FF提升了" .. math.floor(sj) .. "点全属性")
          local sj2 = GetRandomReal(0.03, 0.05)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * sj2)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * sj2)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * sj2)
        end
      else
        u:sendmessage("|cFF7DBEF1所需积分：" .. math.floor(xf))
        return
      end
      local angle = npc:getface()
      local x, y = npc:getxy()
      local x2, y2 = PolarXY(x, y, 500, angle)
      local jl = 50 + 10 * npc:getdata("锻造武器次数")
      if Weiyi_Dz[25] then
        jl = jl * 1.25
      end
      u:sendmessage("|cFF7DBEF1当前成功率：" .. math.floor(jl) .. "%")
      u:playsound(BlacksmithWhat1)
      local yx = {}
      yx[1] = Sound_Senji_Rc_01
      yx[2] = Sound_Senji_Rc_02
      yx[3] = Sound_Senji_Rc_03
      yx[4] = Sound_Senji_Rc_04
      for i = 1, 4 do
        StopSoundBJ(yx[i], false)
      end
      local txmj = npc:createunit("u09P", x2, y2)
      txmj:timetoremove(6)
      Effectcreate("ATX\\[ATxNew]Animated_16.mdl", x2, y2, 6, 3, 50)
      Effectcreate("ATX\\[ATxNew]Fire_01.mdl", x2, y2, 6, 3, 50)
      Effectcreate("ATX\\[ATxNew]Fire_12.mdl", x2, y2)
      npc:animeact(22)
      ac.wait(5000, function()
        npc:animeact(12)
      end)
      local dyx = {}
      dyx[1] = Sound_Senji_Dz_02_Start
      dyx[2] = Sound_Senji_Dz_04_Start
      dyx[3] = Sound_Senji_Dz_06_Start
      npc:playsound(dyx[GetRandomInt(1, 3)])
      local cs = 0
      ac.loop(250, function(timer)
        cs = cs + 1
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 1, 0, GetRandomReal(0, 360))
        if cs == 20 then
          Effectcreate("war3mapImported\\bbb.mdx", x, y, 0, 5)
          timer:remove()
        end
      end)
      ac.wait(3000, function()
        local dyx2 = {}
        dyx2[1] = Sound_Senji_Dz_01_End
        dyx2[2] = Sound_Senji_Dz_03_End
        dyx2[3] = Sound_Senji_Dz_05_End
        npc:playsound(dyx2[GetRandomInt(1, 3)])
      end)
      ac.wait(6000, function()
        u:playsound(ThunderClapCaster)
        Effectcreate("ATX\\[ATxNew]Fire_08.mdl", x2, y2, 0, 3)
        Effectcreate("ATX\\[ATxNew]ShockBoom_29.mdl", x2, y2, 0, 2)
        if GetRandom100(jl) and not targetitem.hasbeenget then
          System_Count_Weapon = System_Count_Weapon + 1
          if npc:hasdata("真红-任务中") then
            local boss = npc:getdata("真红-任务中")
            boss:changedata("千子村正打造武器次数", 1)
          end
          targetitem.hasbeenget = true
          local wp = u:additem(targetitem.itemtype)
          SetItemPosition(wp, x2, y2)
          SetData(wp, "物品判定-神兵")
          npc:deldata("锻造中武器")
          npc:setdata("锻造武器次数", 0)
          npc:getdata("锻造者"):changedata("锻造武器数量", 1)
          if GetRandom100(50) then
            npc:playsound(Sound_Senji_Succeed_01)
          end
          Effectcreate("ATX\\[ATxNew]Fire_03.mdl", x2, y2, 0, 3)
          Effectcreate("ATX\\[ATxNew]Fire_10.mdl", x2, y2, 10, 2)
        else
          npc:changedata("锻造武器次数", 1)
          PlayGlobalSound(boom1)
          if GetRandom100(50) then
            npc:playsound(Sound_Senji_Fail_01)
          end
          for _, xq in ac.selector():in_rangexy(x2, y2, 1200):ipairs() do
            xq = getunit(xq)
            xq:animeact("death")
            xq:buffset(npc.handle, 5, "眩晕")
            if xq:isboss() then
              xq:losshp(npc, 0, 2)
            else
              xq:losshp(npc, 0, 50)
            end
          end
          Effectcreate("ATX\\[ATxNew]ShockBoom_15.mdl", x2, y2, 0, 10)
          Effectcreate("ATX\\[ATxNew]ShockBoom_13.mdl", x2, y2, 0, 3)
          Effectcreate("ATX\\[ATxNew]ShockBoom_16.mdl", x2, y2, 0, 3)
          ac.wait(1000, function()
            npc:animeact("death")
          end)
        end
      end)
      ac.wait(9000, function()
        ResetUnitAnimation(npc.handle)
      end)
    end
  },
  {
    name = "魔力节点-灵体重构",
    typeid = "h00C",
    func = function(self, args)
      local u = args.u
      local npc = getunit(NPC_Molijiedian)
      local b = false
      local buy = GetUnitTypeId(getunit(args.buy))
      if Keyan_Posuilingyu then
        u:sendmessage("|cFF7DBEF1[科研模式]破碎领域阻止|r")
        return
      end
      if buy == S2ID("e000") then
        u:sendmessage("|cFF7DBEF1灵魂状态无法交互|r")
        RemoveUnitFromStockBJ(S2ID("h00C"), NPC_Molijiedian)
        ac.wait(10, function()
          AddUnitToStockBJ(S2ID("h00C"), NPC_Molijiedian, 1, 1)
        end)
        return
      end
      local g = CreateGroupLua()
      ForGroupLuaNew(Group_DeathHero, function(xq)
        if not xq:hasdata("变异判定-Bloo") and not xq:hasdata("变异判定-歼灭天使") and not xq:hasdata("阿卡多-死河限制") then
          xq:groupadd(g)
        end
      end)
      if Group_Counts(g) > 0 then
        b = true
      else
        u:sendmessage("目前没有死亡队友")
      end
      if u:ishasskill("A0OI") or u:ishasskill("A0QP") then
        b = false
      end
      if Caidan_Jiancilang_2 then
        b = false
        u:sendmessage("ん？")
      end
      if u:hasdata("Bloo-了结你") then
        b = false
        u:sendmessage("你一个人就够了")
      end
      if getunit(BOSS):hasdata("真红-金色翎羽") then
        b = false
      end
      if b then
        if u:ishasskill("A0QJ") then
          u:addstr(1)
        end
        if u:hasdata("星座-摩羯座激活") and GetRandom100(12) then
          u:addallstats(GetRandomInt(1, 12))
        end
        if u:hasdata("钢铁之躯-愉悦") and not u:hasdata("愉悦冷却") then
          u:settimedata("愉悦冷却", 100)
          u:changedata("愉悦时间", 9)
          u:playsound(Yuyue_4)
        end
        local hero = Group_Randomunit(g)
        if Youxianfuhuo ~= 0 and getunit(Youxianfuhuo):isingroup(Group_DeathHero) then
          hero = getunit(Youxianfuhuo)
          Youxianfuhuo = 0
          local str = u:getdata("复活台词")
          if str == "胜利的法则已然确定" then
            PlayGlobalSound(Fuhuo_Shenglide)
          end
          if str == "现在我的手中抓住了未来" then
            PlayGlobalSound(Fuhuo_Xianzai)
          end
          if str == "来细数你的罪恶吧" then
            PlayGlobalSound(Fuhuo_Salaixishu)
          end
          if str == "神说我还不能死在这里" then
            PlayGlobalSound(Fuhuo_Shenshuo)
          end
          if str == "我也要加把劲啊" then
            PlayGlobalSound(Fuhuo_Woyeyaojiabajina)
          end
          u:chat(u:getdata("复活台词"))
          u:deldata("复活台词")
        end
        hero:sendmessage("你已经复活")
        local x, y = npc:getxy()
        HeroRelive(hero.handle, x, y, 5)
      else
        RemoveUnitFromStockBJ(S2ID("h00C"), NPC_Molijiedian)
        ac.wait(10, function()
          AddUnitToStockBJ(S2ID("h00C"), NPC_Molijiedian, 1, 1)
        end)
      end
    end
  },
  {
    name = "魔力节点-灵体重构 神兆",
    typeid = "u0EF",
    func = function(self, args)
      local u = args.u
      local npc = getunit(NPC_Molijiedian)
      local b = false
      local buy = GetUnitTypeId(getunit(args.buy))
      if Keyan_Posuilingyu then
        u:sendmessage("|cFF7DBEF1[科研模式]破碎领域阻止|r")
        return
      end
      if buy == S2ID("e000") then
        u:sendmessage("|cFF7DBEF1灵魂状态无法交互|r")
        RemoveUnitFromStockBJ(S2ID("u0EF"), NPC_Molijiedian)
        ac.wait(10, function()
          AddUnitToStockBJ(S2ID("u0EF"), NPC_Molijiedian, 1, 1)
        end)
        return
      end
      local g = CreateGroupLua()
      ForGroupLuaNew(Group_DeathHero, function(xq)
        if not xq:hasdata("变异判定-Bloo") and not xq:hasdata("变异判定-歼灭天使") and not xq:hasdata("阿卡多-死河限制") then
          xq:groupadd(g)
        end
      end)
      if Group_Counts(g) > 0 then
        b = true
      else
        u:sendmessage("目前没有死亡队友")
      end
      if u:ishasskill("A0OI") or u:ishasskill("A0QP") then
        b = false
      end
      if Caidan_Jiancilang_2 then
        b = false
        u:sendmessage("ん？")
      end
      if u:hasdata("Bloo-了结你") then
        b = false
        u:sendmessage("你一个人就够了")
      end
      if getunit(BOSS):hasdata("真红-金色翎羽") then
        b = false
      end
      if b then
        if Huanjing_Lingli >= 500 then
          Huanjing_Lingli = Huanjing_Lingli - 500
        else
          b = false
          u:sendmessage("灵力值不足")
        end
      end
      if b then
        if u:ishasskill("A0QJ") then
          u:addstr(1)
        end
        if u:hasdata("星座-摩羯座激活") and GetRandom100(12) then
          u:addallstats(GetRandomInt(1, 12))
        end
        if u:hasdata("钢铁之躯-愉悦") and not u:hasdata("愉悦冷却") then
          u:settimedata("愉悦冷却", 100)
          u:changedata("愉悦时间", 9)
          u:playsound(Yuyue_4)
        end
        local hero = Group_Randomunit(g)
        if Youxianfuhuo ~= 0 and getunit(Youxianfuhuo):isingroup(Group_DeathHero) then
          hero = getunit(Youxianfuhuo)
          Youxianfuhuo = 0
          local str = u:getdata("复活台词")
          if str == "胜利的法则已然确定" then
            PlayGlobalSound(Fuhuo_Shenglide)
          end
          if str == "现在我的手中抓住了未来" then
            PlayGlobalSound(Fuhuo_Xianzai)
          end
          if str == "来细数你的罪恶吧" then
            PlayGlobalSound(Fuhuo_Salaixishu)
          end
          if str == "神说我还不能死在这里" then
            PlayGlobalSound(Fuhuo_Shenshuo)
          end
          if str == "我也要加把劲啊" then
            PlayGlobalSound(Fuhuo_Woyeyaojiabajina)
          end
          u:chat(u:getdata("复活台词"))
          u:deldata("复活台词")
        end
        hero:sendmessage("你已经复活")
        local x, y = npc:getxy()
        HeroRelive(hero.handle, x, y, 5)
      else
        RemoveUnitFromStockBJ(S2ID("u0EF"), NPC_Molijiedian)
        ac.wait(10, function()
          AddUnitToStockBJ(S2ID("u0EF"), NPC_Molijiedian, 1, 1)
        end)
      end
    end
  },
  {
    name = "伊甸-箱庭污染",
    typeid = "h05A",
    func = function(self, args)
      local npc = getunit(NPC_YIDIAN)
      local u = args.u
      local sy = u.ownerid
      local hero = getunit(Hero[sy])
      if not npc:hasdata("伊甸-箱庭污染已开启") then
        if Nandu_Choose < 4 then
          u:sendmessage("|cFFCC0000游戏难度不满足(非难度4及以上)|r")
          return
        end
        SendMsgAll("|cFF9966CC所有区域出现了星域污染|r", 10)
        npc:setdata("伊甸-箱庭污染已开启")
        local rectg = {
          RECT_Huangwu,
          RECT_Feichengqu,
          RECT_Feichezhan,
          RECT_Jiaoqu,
          RECT_Haian,
          RECT_Feichangqu
        }
        local mj2
        local ng = CreateGroupLua()
        npc:setdata("伊甸-箱庭污染区域组", rectg)
        npc:setdata("伊甸-深空污染组", ng)
        
        local function set(mj)
          mj:setdata("免疫生命损耗")
          mj:setdata("免疫击退效果")
          mj:setdata("免疫生命修改")
          mj:setdata("免疫抑制恢复")
          mj:setdata("免疫负面效果")
          mj:setdata("暗神-星渊核心单位")
          mj:setdata("系统-单次受伤1")
          mj:setdata("免疫即死效果")
          mj:setdata("免疫混乱改变所属")
          local ax, ay = mj:getxy()
          mj:setdata("保存坐标X", ax)
          mj:setdata("保存坐标Y", ay)
          SetUnitState(mj.handle, UNIT_STATE_MAX_LIFE, 10000)
          mj:setmaxhp(100)
          mj:groupadd(ng)
          mj:groupadd(HellGroup)
          local ax, ay = mj:getxy()
          local txmj = EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_heiwu2.mdx",
            x = ax,
            y = ay,
            time = -1,
            size = 4,
            height = 25,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          mj:setdata("星渊核心特效", txmj)
          PingMinimapEx(ax, ay, 10, 153, 102, 204, false)
          TriggerRegisterUnitEvent(DamageSystemTrg, mj.handle, EVENT_UNIT_DAMAGED)
          SetUnitMoveSpeed(mj.handle, 0)
          mj:addstexiao("暗神-星域污染", "伤害显示后效果", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if info.damage >= tg:gethp() or tg:hasdata("暗神永恒") then
              info.damage = 0
              if not tg:hasdata("暗神永恒") then
                tg:setdata("暗神永恒")
                SetUnitInvulnerable(tg.handle, true)
                tg:buffset(u.handle, 3600, "无敌")
                SendMsgAll("|cFF9966CC星域污染降低……|r")
                mj2:changedata("剩余生命次数", -1)
                mj2:sethp(mj2:gethp() - 100)
              end
            end
          end)
        end
        
        local boss = getunit(BOSS_DEATH)
        for index, value in ipairs(rectg) do
          local x, y = GetRectCenterX(value), GetRectCenterY(value)
          local mj = boss:createunit("u046", x + 450, y)
          set(mj)
          mj:changeowner(Player(9))
          mj:setdata("箱庭污染对应区域", value)
        end
        local npc2 = getunit(NPC_Molijiedian)
        local x, y = npc2:getxy()
        mj2 = boss:createunit("u046", x, y + 450)
        set(mj2)
        mj2:setdata("模型-名字", "|cFF6633FF噬|r|cFF7340F2界|r|cFF804CE6树|r")
        japi.SetUnitModel(mj2.handle, "Boss_Anshen_Shijieshu.mdx")
        japi.SetUnitName(mj2.handle, mj2:getdata("模型-名字"))
        mj2:setsize(1.5)
        mj2:changeowner(Player(9))
        mj2:setmaxhp(2500)
        mj2:setdata("箱庭污染对应区域", RECT_Guangchang)
        mj2:setdata("中央星域星渊核心")
        mj2:setdata("剩余生命次数", 25)
        mj2:setdata("暗神永恒")
        table.insert(rectg, RECT_Guangchang)
        AddAllSTexiao("箱庭污染", "暴击系统触发效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if u:hasdata("暗神-深空污染等级") then
            local bs = 0.1 * u:getdata("暗神-深空污染等级")
            info.bjsh = 1.25 + (info.bjsh - 1.25) * (1 - bs)
          end
        end)
        AddAllSTexiao("箱庭污染", "伤害判定后效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if u:hasdata("暗神-深空污染等级") then
            local level = u:getdata("暗神-深空污染等级") or 0
            local base = 1 - 0.1 * level
            local down = tg:getdata("深空污染减伤值") or 0
            local effective = math.max(0, base + down)
            if 1 <= effective then
              effective = 1
            end
            info.damage = info.damage * effective
            tg:changetimedata("深空污染减伤值", 0.01, 2)
          end
        end)
        AddAllSTexiao("箱庭污染", "受伤后效果", function(args)
          local u = args.u
          local tg = args.tg
          local info = args.damageinfo
          if u:hasdata("暗神-深空污染等级") then
            local dlv = u:getdata("暗神-深空污染等级")
            if tg:gethp() < tg:getmaxhp() then
              info.damage = info.damage * (1 + 0.2 * dlv)
            end
            u:curetili(-0.25 * dlv)
            if not u:hasdata("深空污染时间") then
              local xh = 0.05 * dlv
              ac.loop(100, function(timer)
                u:changedata("深空污染时间", -0.1)
                u:losshp(tg, 0, 0, xh)
                if 0 >= u:getdata("深空污染时间") then
                  u:deldata("深空污染时间")
                  if u:islocal() then
                    BuffUI.remove("深空污染损耗")
                  end
                  timer:remove()
                end
              end)
            end
            u:setdata("深空污染时间", 3)
            if u:islocal() then
              BuffUI.apply({
                id = "深空污染损耗",
                duration = 3
              })
            end
          end
        end)
        local cs = 0
        local lv = 1
        local time = 7
        local st = Stage
        ac.loop(1000, function(timer)
          mj2:buffset(mj2.handle, 2, "无敌")
          if st ~= Stage then
            st = Stage
            lv = lv + 1
            SendMsgAll("|cFF9966CC星域污染等级提升,当前等级:" .. lv .. "|r")
            mj2:changedata("剩余生命次数", -1)
            mj2:sethp(mj2:gethp() - 100)
            ForGroupLuaNew(ng, function(xq)
              local ax = xq:getdata("保存坐标X")
              local ay = xq:getdata("保存坐标Y")
              xq:setxy(ax, ay)
              PingMinimapEx(ax, ay, 10, 153, 102, 204, false)
              if not xq:hasdata("中央星域星渊核心") then
                xq:deldata("暗神永恒")
                xq:clearbuff("无敌")
                xq:sethp(100, true)
              end
            end)
          end
          local rg = {}
          ForGroupLuaNew(ng, function(xq2)
            if xq2:hasdata("中央星域星渊核心") or not xq2:hasdata("暗神永恒") then
              table.insert(rg, xq2:getdata("箱庭污染对应区域"))
            end
          end)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              local sy2 = xq.ownerid
              local x, y = xq:getxy()
              local buffb = false
              for index, value in ipairs(rg) do
                if IsXYinRect(x, y, value) then
                  buffb = true
                end
              end
              if buffb then
                if not xq:hasdata("暗神-深空污染等级") then
                  xq:setdata("暗神-深空污染等级", lv)
                  ChangeValue(DamageSystem_Txgl, sy2, -10 * lv)
                  if xq:islocal() then
                    BuffUI.apply({
                      id = "深空污染",
                      duration = 99999
                    })
                  end
                end
              elseif xq:hasdata("暗神-深空污染等级") then
                local dlv = xq:getdata("暗神-深空污染等级")
                ChangeValue(DamageSystem_Txgl, sy2, 10 * dlv)
                xq:deldata("暗神-深空污染等级")
                if xq:islocal() then
                  BuffUI.remove("深空污染")
                end
              end
            elseif xq:hasdata("暗神-深空污染等级") then
              xq:deldata("暗神-深空污染等级")
              if xq:islocal() then
                BuffUI.remove("深空污染")
              end
            end
          end)
          if 1 >= mj2:getdata("剩余生命次数") then
            SendMsgAll("|cFF9966CC星域污染已经清除完毕|r")
            ForGroupLuaNew(ng, function(xq)
              local dx, dy = xq:getxy()
              DestroyEffectLua(xq:getdata("星渊核心特效"))
              if xq:hasdata("中央星域星渊核心") then
                xq:deldata("中央星域星渊核心")
                CreateItemLua("I0LF", dx, dy)
              end
              xq:remove()
            end)
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if xq:hasdata("暗神-深空污染等级") then
                local sy2 = xq.ownerid
                local dlv = xq:getdata("暗神-深空污染等级")
                ChangeValue(DamageSystem_Txgl, sy2, 10 * dlv)
                xq:deldata("暗神-深空污染等级")
                if xq:islocal() then
                  BuffUI.remove("深空污染")
                end
              end
            end)
            timer:remove()
          end
        end)
      end
    end
  },
  {
    name = "伊甸-摘取苹果",
    typeid = "h02O",
    func = function(self, args)
      apple(args)
    end
  },
  {
    name = "伊甸-摘取苹果-赫萝",
    typeid = "h02P",
    func = function(self, args)
      apple(args)
    end
  },
  {
    name = "纳西妲-妈妈的小测验",
    typeid = "h043",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      if not u:hasdata("纳西妲-已聊天") then
        u:setdata("纳西妲-已聊天")
        local data = {
          banner = "event_02.tga",
          desc = "你遇到了一名萝莉体型的美少女，她正在盯着你看。你决定……",
          options = {
            {
              text = "1) 大概是什么问题儿童吧",
              func = function(u)
              end
            },
            {
              text = "2) \"请和我交往吧！\" (|cFFCC0000被眩晕3秒并损耗50%生命值|r)",
              func = function(u)
                u:buffset(u.handle, 3, "眩晕")
                u:losshp(u, 0, 0, 50)
                PlayBGM({
                  bgm = BGM_Nxd_01,
                  time = 280,
                  ID = 162,
                  unit = u.handle
                })
                if GetRandom100(50) then
                  u:sendmessage("|cFF33FF66是|r|cFF4AFF77不|r|cFF60FF88听|r|cFF77FF99话|r|cFF8EFFAA的|r|cFFA4FFBB孩|r|cFFBBFFCC子|r|cFFD2FFDD！|r")
                else
                  u:sendmessage("|cFF33FF66是|r|cFF55FF80坏|r|cFF77FF99孩|r|cFF99FFB2子|r|cFFBBFFCC！|r")
                end
                u:effectadd("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl")
                SendMsgAll("|cFF66FF99BGM：粛清!! ロリ神レクイエム☆|r")
                local data = {
                  banner = "event_02_2.tga",
                  desc = "你看到她涨红着脸给了你一拳，你被打飞了",
                  options = {
                    {
                      text = "1) 离开",
                      func = function(u)
                      end
                    }
                  }
                }
                RLChoose(u, data, "list")
              end
            },
            {
              text = "3) \"妈妈！\" (获得|cFF1FBF00棒棒糖|r)",
              func = function(u)
                local x, y = u:getxy()
                u:additem("I08X", GetRandomInt(1, 10))
                local wp = u:additem("I0C0")
                SetData(wp, "棒棒糖-所有者", u.owner)
                local data = {
                  banner = "event_02_2.tga",
                  desc = "你看到她瞬间涨红了脸，她没有说什么扔给你一袋糖果飞走了",
                  options = {
                    {
                      text = "1) 离开",
                      func = function(u)
                      end
                    }
                  }
                }
                RLChoose(u, data, "list")
              end
            }
          }
        }
        RLChoose(u, data, "list")
      else
        local data = {
          banner = "event_02.tga",
          desc = "你再次尝试搭话，眼前的美少女直接跑开了",
          options = {
            {
              text = "1) 离开",
              func = function(u)
              end
            }
          }
        }
        RLChoose(u, data, "list")
      end
    end
  },
  {
    name = "阎魔爱-药剂兑换",
    typeid = "h03T",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if KillCount[sy] >= 75 then
        ChangeValue(KillCount, sy, -75)
        u:sendmessage("|cFF7DBEF1兑换成功|r")
        RandomNormalMedcine(u.handle)
      else
        u:sendmessage("|cFF7DBEF1杀敌数不足|r")
      end
    end
  },
  {
    name = "阎魔爱-杀戮祝福",
    typeid = "h03U",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      local gold = u:getgold()
      local xf = 100 + 50 * u:getdata("杀戮祝福-购买次数")
      if gold >= xf then
        u:sendmessage("购买成功 当前消耗积分：" .. math.floor(xf))
        u:changedata("杀戮祝福-购买次数", 1)
        u:addgold(-xf)
        ac.timer(1, 25, function()
          KillCount[sy] = KillCount[sy] + 1
          monsterrewardget1(u.handle, BOSS_DEATH)
          monsterrewardget2(u.handle, BOSS_DEATH)
        end)
      else
        u:sendmessage("积分不足 所需积分：" .. math.floor(xf))
      end
    end
  },
  {
    name = "阎魔爱-次元凝聚",
    typeid = "h03V",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      if KillCount[sy] >= 100 then
        ChangeValue(KillCount, sy, -100)
        u:sendmessage("|cFF7DBEF1兑换成功|r")
        u:additem("I00X")
      else
        u:sendmessage("|cFF7DBEF1杀敌数不足|r")
      end
    end
  },
  {
    name = "白洲梓-枪械升级",
    typeid = "h03S",
    func = function(self, args)
      local u = args.u
      local gun = gun_upgrade.get_equipped_gun(u)
      if not gun_upgrade.is_valid_gun(gun) then
        u:sendmessage("没有可强化枪支")
        return
      end
      local cost = 400
      if cost > u:getgold() then
        u:sendmessage("积分不足 所需积分：" .. cost)
        return
      end
      u:addgold(-cost)
      local result = gun_upgrade.apply(gun, u)
      gun_upgrade.send_success_message(u, result, "|cFF6699FF")
    end
  },
  {
    name = "白洲梓-特殊弹药兑换",
    typeid = "h035",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      if System_Jungong[sy] >= 2500 then
        ChangeValue(System_Jungong, sy, -2500)
        local x, y = u:getxy()
        u:setdata("物品-X", x)
        u:setdata("物品-Y", y)
        u:additem("I0DV")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "白洲梓-军火箱兑换",
    typeid = "h03Q",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      if System_Jungong[sy] >= 1000 then
        ChangeValue(System_Jungong, sy, -1000)
        local x, y = u:getxy()
        u:setdata("物品-X", x)
        u:setdata("物品-Y", y)
        u:additem("I008")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "白洲梓-模块兑换",
    typeid = "h03R",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      if System_Jungong[sy] >= 750 then
        ChangeValue(System_Jungong, sy, -750)
        local x, y = u:getxy()
        u:setdata("物品-X", x)
        u:setdata("物品-Y", y)
        u:additem("I0EB")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "白洲梓-药剂回收",
    typeid = "h046",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      local b = false
      local med = {
        {id = "I02E", value = 500},
        {id = "I02F", value = 500},
        {id = "I02H", value = 500},
        {id = "I0EV", value = 250},
        {id = "I00J", value = 250},
        {id = "I011", value = 750},
        {id = "I030", value = 1000}
      }
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        for index, value in ipairs(med) do
          if S2ID(value.id) == wptype then
            local add = GetItemCharges(wp) * value.value * Correction_Jungong[sy]
            ChangeValue(System_Jungong, sy, add)
            RemoveItemLua(wp)
            b = true
          end
        end
      end
      if b then
        u:sendmessage("|cFFFF9966回收成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966没有可回收药水|r")
      end
    end
  },
  {
    name = "白洲梓-军功兑换",
    typeid = "h047",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if u:getgold() >= 2000 then
        u:addgold(-2000)
        local add = 1000 * Correction_Jungong[sy]
        ChangeValue(System_Jungong, sy, add)
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966积分不足|r")
      end
    end
  },
  {
    name = "FNC-遗物栏拓展",
    typeid = "h033",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      u = getunit(Hero[sy])
      if u:getdata("遗物栏-拓展次数") < 5 then
        if Hero_Shenhua_Left[sy] > 0 then
          u:changedata("遗物栏-拓展次数", 1)
          local pid = sy * System_YiwulanCount - (3 - u:getdata("遗物栏-拓展次数"))
          for i = 1, 6 do
            RemoveItemLua(getunit(System_Yiwulan[pid]):getcountitem(i))
          end
          u:sendmessage("|cFFFF9900遗物栏解锁|r")
          ChangeValue(Hero_Shenhua_Left, sy, -1)
        else
          u:sendmessage("|cFFFF9900神化位不足|r")
        end
      else
        u:sendmessage("|cFFFF9900遗物栏拓展已达上限|r")
      end
    end
  },
  {
    name = "FNC-注册公司",
    typeid = "h070",
    func = function(self, args)
      local u = args.u
      if u:hasdata("变异判定-格里芬安全承包商") then
        u:sendmessage("|cFFFF9900已经拥有格里芬公司，无法重复注册|r")
        return
      end
      u:addqiankuan(800)
      local result = herogetvar(u.handle, {
        Vars_Mwx
      }, "冥王星", "格里芬安全承包商")
      if result == "失败" or not result then
        u:changedata("系统-贷款", -800)
        u:sendmessage("|cFFFF0000格里芬公司注册失败，贷款已退回|r")
        return
      end
      u:sendmessage("|cFFFF9900注册公司成功，增加800贷款，获得冥王启动[格里芬公司]|r")
    end
  },
  {
    name = "FNC-心动大冒险",
    typeid = "h02T",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local b = false
      u = getunit(Hero[sy])
      if System_Jungong[sy] >= 500 then
        b = true
        ChangeValue(System_Jungong, sy, -500)
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
      if b then
        if GetRandom100(10) then
          local zs = GetRandomInt(1, 3)
          if zs == 1 then
            u:sendmessage("|cFFFF99661000军功|r")
            local add = 1000 * Correction_Jungong[sy]
            ChangeValue(System_Jungong, sy, add)
          end
          if zs == 2 then
            u:sendmessage("|cFFFF9966特殊弹药箱|r")
            u:additem("I0DV")
          end
          if zs == 3 then
            u:sendmessage("|cFFFF9966一盒糖果|r")
            u:additem("I08X", 12)
          end
        else
          local zs = GetRandomInt(1, 5)
          if zs == 1 then
            u:sendmessage("|cFFFF9966600军功|r")
            local add = 600 * Correction_Jungong[sy]
            ChangeValue(System_Jungong, sy, add)
          end
          if zs == 2 then
            u:sendmessage("|cFFFF9966补给箱|r")
            u:additem("I007")
          end
          if zs == 3 then
            u:sendmessage("|cFFFF9966饱含FNC心意的一颗糖果！|r")
            u:additem("I08X", 1)
          end
          if zs == 4 then
            u:sendmessage("|cFFFF9966弹药箱|r")
            u:additem("I068")
          end
          if zs == 5 then
            u:sendmessage("|cFFFF9966军火！|r")
            u:additem("I008")
          end
        end
      end
    end
  },
  {
    name = "FNC-子弹回收",
    typeid = "h02U",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if args.isbbbuy then
        u = args.bb
      end
      local b = false
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        local fenlei = GetItemType(wp)
        if fenlei == ITEM_TYPE_ARTIFACT and not HasData(wp, "不可回收") then
          local lx = GetData(wptype, "子弹类型")
          if 1 <= lx and lx <= 6 or lx == 12 then
            local add = GetData(wptype, "价值比重")
            add = GetItemCharges(wp) * add
            ChangeValue(System_Jungong, sy, add)
            RemoveItemLua(wp)
            b = true
          end
        end
      end
      if b then
        u:sendmessage("|cFFFF9966回收成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966没有可回收子弹|r")
      end
    end
  },
  {
    name = "FNC-枪械回收",
    typeid = "h02V",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if args.isbbbuy then
        u = args.bb
      end
      local b = false
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        local fenlei = GetItemType(wp)
        if fenlei == ITEM_TYPE_PERMANENT and not HasData(wp, "不可回收") and wptype ~= S2ID("I01F") and not HasData(wp, "枪械-枪械等级") and not HasData(wp, "枪械模块-弹匣") and not HasData(wp, "枪械模块-极速") then
          local lx = GetData(wptype, "枪械类型")
          if 1 <= lx and lx <= 6 then
            local add
            if lx == 1 then
              add = 500
            else
              add = 750
            end
            if wptype == S2ID("I00K") and wptype == S2ID("I004") then
              add = 1000
            end
            if wptype == S2ID("I01H") then
              add = 1500
            end
            ChangeValue(System_Jungong, sy, add)
            RemoveItemLua(wp)
            b = true
          end
        end
      end
      if b then
        u:sendmessage("|cFFFF9966回收成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966没有可回收枪械|r")
      end
    end
  },
  {
    name = "FNC-黑科弹兑换",
    typeid = "h02W",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if System_Jungong[sy] >= 500 then
        ChangeValue(System_Jungong, sy, -500)
        u:additem("I000")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "FNC-黑科弹II兑换",
    typeid = "h02X",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if System_Jungong[sy] >= 500 then
        ChangeValue(System_Jungong, sy, -500)
        u:additem("I00E")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "FNC-瓦尔特弹兑换",
    typeid = "h02Z",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if System_Jungong[sy] >= 500 then
        ChangeValue(System_Jungong, sy, -500)
        u:additem("I00T")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "FNC-伯奈利军弹兑换",
    typeid = "h02Y",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if System_Jungong[sy] >= 500 then
        ChangeValue(System_Jungong, sy, -500)
        u:additem("I003")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "FNC-贯彻弹兑换",
    typeid = "h03P",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      if System_Jungong[sy] >= 1000 then
        ChangeValue(System_Jungong, sy, -1000)
        u:additem("I01I")
        u:sendmessage("|cFFFF9966兑换成功 剩余军功：" .. math.floor(System_Jungong[sy]))
      else
        u:sendmessage("|cFFFF9966军功不足 当前军功：" .. math.floor(System_Jungong[sy]))
      end
    end
  },
  {
    name = "天子-环境切换",
    typeid = "h00P",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = getunit(NPC_TIANZI)
      local xf
      if u:getdata("环境结束次数") == 0 then
        xf = 0
      else
        xf = 300 + 100 * u:getdata("环境结束次数")
      end
      if Nandu_Choose <= 3 then
        xf = 300
      end
      local gold = u:getgold()
      if npc:hasdata("环境变更") then
        u:sendmessage("无法使用")
        return
      end
      local b = false
      local b1 = false
      if not b then
        for i = 1, 6 do
          local wp = u:getcountitem(i)
          local wptype = GetItemTypeId(wp)
          if wptype == S2ID("I0C2") then
            b = true
            b1 = true
            ChangeItemCount(wp, -1)
            break
          end
        end
      end
      if not b then
        if xf <= gold then
          b = true
          u:addgold(-1 * xf)
        else
          u:sendmessage("积分不足 所需积分：" .. math.floor(xf))
        end
      end
      if b then
        npc:setdata("环境变更")
        if not b1 then
          u:changedata("环境结束次数", 1)
          u:sendmessage("消耗积分：" .. math.floor(xf))
        end
      end
    end
  },
  {
    name = "天子-暗夜行舟",
    typeid = "h02R",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = getunit(NPC_TIANZI)
      local b1 = false
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        if wptype == S2ID("I0C2") then
          b1 = true
          ChangeItemCount(wp, -1)
          break
        end
      end
      if b1 then
        SendMsgAll("|cFF99CCFF暗|r|cFF85A3EB夜|r|cFF707AD6行|r|cFF5C52C2舟|r")
        PlayGlobalSound(Fu)
        if IsTimeDay() then
          SetTimeOfDay(0)
        else
          SetTimeOfDay(12)
        end
      else
        u:sendmessage("|cFFFF99FF没有桃子|r")
        RemoveUnitFromStockBJ(S2ID("h02R"), npc.handle)
        ac.wait(1, function()
          AddUnitToStockBJ(S2ID("h02R"), npc.handle, 1, 1)
        end)
      end
    end
  },
  {
    name = "天子-大地操纵",
    typeid = "h02S",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = getunit(NPC_TIANZI)
      local b1 = false
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wptype = GetItemTypeId(wp)
        if wptype == S2ID("I0C2") then
          b1 = true
          ChangeItemCount(wp, -1)
          break
        end
      end
      if b1 then
        SendMsgAll("|cFFFF9900大|r|cFFE08F14地|r|cFFC28529操|r|cFFA37A3D纵|r")
        PlayGlobalSound(Fu)
        supplybornciyuan()
        ForGroupLuaNew(Group_Monster, function(xq)
          xq:delskill("S00G")
          xq:buffset(npc.handle, 10, "眩晕")
        end)
      else
        u:sendmessage("|cFFFF99FF没有桃子|r")
        RemoveUnitFromStockBJ(S2ID("h02S"), npc.handle)
        ac.wait(1, function()
          AddUnitToStockBJ(S2ID("h02S"), npc.handle, 1, 1)
        end)
      end
    end
  }
}
local GL_BUCKETS = {
  {
    bound = 2,
    name = require("hera_korean").translate("几乎不可能")
  },
  {
    bound = 5,
    name = require("hera_korean").translate("非常困难")
  },
  {bound = 10, name = require("hera_korean").translate("困难")},
  {bound = 20, name = require("hera_korean").translate("普通")},
  {bound = 50, name = require("hera_korean").translate("简单")},
  {
    bound = math.huge,
    name = require("hera_korean").translate("非常简单")
  }
}

local function prob_label(gl)
  for _, b in ipairs(GL_BUCKETS) do
    if gl <= b.bound then
      return b.name
    end
  end
  return "未知"
end

local function qiaosuo_core(u, target, is_item)
  local sy = u.ownerid
  local x, y = u:getxy()
  if u:hasdata("系统-撬锁中") then
    return
  end
  local lv, xyd
  if is_item then
    if HasData(target, "撬锁-撬锁完毕") then
      return
    end
    lv = GetData(target, "撬锁-难度")
    xyd = GetData(target, "宝箱-稀有度")
  else
    if target:hasdata("撬锁-撬锁完毕") then
      return
    end
    lv = target:getdata("撬锁-难度")
  end
  local dtime = 0
  local runtime = 1.5
  local tx = Effectcreate("WhiteCircle.mdx", x, y, -1, 0.8, 0, 0, 0, 0, 0.25)
  u:setdata("系统-撬锁中")
  local jcgl = {
    25,
    10,
    4,
    1,
    0.25
  }
  local expget = {
    20,
    50,
    100,
    200,
    500
  }
  local stra = "徒手撬锁"
  local qsgj
  local ts = true
  local wq = Hero_Equip_WeaponType[sy]
  if u:hasdata("变异判定-戈登") and (wq == Weapons["撬棍"] or wq == Weapons["物理学圣剑"]) then
    stra = "使用撬棍"
    ts = false
  end
  local bag_tool = 0
  if GetPlayerBagLikeItem then
    bag_tool = GetPlayerBagLikeItem(u, "I0MH") or 0
  else
    local bb = getunit(Beibao[sy])
    if u:ishasitem("I0MH") then
      bag_tool = u:getitem("I0MH") or 0
    elseif bb:ishasitem("I0MH") then
      bag_tool = bb:getitem("I0MH") or 0
    end
  end
  if ts and bag_tool ~= 0 then
    stra = "使用工具"
    ts = false
    qsgj = bag_tool
  end
  local gl = jcgl[lv] or 1
  gl = gl * (1 + 0.1 * u:getdata("撬锁-累积等级"))
  if u:hasdata("撬锁-Lv15效果") then
    gl = gl * 2
  end
  if u:hasdata("英雄-魔理沙") then
    gl = gl * 2
  end
  if ts then
    gl = gl * 0.5
  end
  u:sendmessage((require("hera_korean").translate("|cFF7DBEF1[撬锁]开始撬锁(%s),成功率:%s|r")):format(stra, prob_label(gl)))
  ac.loop(100, function(timer)
    local dx, dy = u:getxy()
    local dis = DistanceXY(x, y, dx, dy)
    local done
    if is_item then
      done = HasData(target, "撬锁-撬锁完毕")
    else
      done = target:hasdata("撬锁-撬锁完毕")
    end
    if not u:isalive() or 430 < dis or done then
      DestroyEffectLua(tx)
      u:sendmessage("|cFF7DBEF1[撬锁]停止撬锁|r")
      u:deldata("系统-撬锁中")
      timer:remove()
      return
    end
    dtime = dtime + 0.1
    if dtime < runtime then
      return
    end
    dtime = 0
    local expadd = 4
    local gl1 = jcgl[lv] or 1
    gl1 = gl1 * (1 + 0.1 * u:getdata("撬锁-累积等级"))
    if u:hasdata("撬锁-Lv15效果") then
      gl1 = gl1 * 2
    end
    if ts then
      gl1 = gl1 * 0.5
    end
    local gl2
    if is_item then
      gl2 = GetData(target, "撬锁-失败概率")
    else
      gl2 = target:getdata("撬锁-失败概率")
    end
    if ts and not u:hasdata("英雄-魔理沙") then
      gl2 = gl2 * 1.5
      gl2 = gl2 + 3
    end
    if u:hasdata("撬锁-Lv5效果") then
      gl2 = gl2 * 0.5
    end
    local cg = false
    if GetRandom100(gl1) then
      cg = true
      u:sendmessage("|cFF7DBEF1[撬锁]成功|r")
      expadd = expadd + expget[lv]
      if is_item then
        SetData(target, "撬锁-撬锁完毕")
        openxiangzi(u, target, xyd)
      else
        target:setdata("撬锁-撬锁完毕")
        if target:hasdata("系统-上锁箱") then
          kaixiangzi(u, target, target:getdata("上锁箱-品质"))
        end
        if target:hasdata("系统-龙之城") then
          target:deldata("龙之城-上锁")
        end
      end
    elseif GetRandom100(gl2) then
      if is_item then
        SetData(target, "撬锁-撬锁完毕")
        u:sendmessage("|cFF7DBEF1[撬锁]撬锁时不小心损坏了箱子……|r")
        SetItemPosition(target, PX_X, PX_Y)
        DelayRemoveItemLua(target, 200)
      else
        if target:hasdata("系统-上锁箱") then
          target:setdata("撬锁-撬锁完毕")
          u:sendmessage("|cFF7DBEF1[撬锁]撬锁时不小心损坏了箱子……|r")
          target:groupremove(Group_PlanetBuild)
          KillUnit(target.handle)
          target:timetoremove(3)
        end
        if target:hasdata("系统-龙之城") then
          target:setdata("撬锁-失败概率", 0)
          u:sendmessage("|cFF7DBEF1[撬锁]撬锁时引来了守卫……|r")
          local name1 = {"龙-红"}
          local x2, y2 = target:getxy()
          local ax, ay = PolarXY(x2, y2, GetRandomReal(0, 500), GetRandomAngle())
          local sw = CreateNameMonster(name1[GetRandomInt(1, #name1)], ax, ay)
          sw:setface(GetRandomAngle())
          sw:groupadd(Group_PlanetMonster)
        end
      end
    else
      if is_item then
        ChangeData(target, "撬锁-失败概率", 0.5)
      else
        target:changedata("撬锁-失败概率", 0.5)
      end
      u:sendmessage("|cFF7DBEF1[撬锁]失败|r")
    end
    if u:hasdata("泽塔-撬锁经验翻倍") and u:getdata("撬锁-累积等级") < 8 then
      expadd = expadd * 2
    end
    u:changedata("撬锁-累积经验", expadd)
    if u:getdata("撬锁-累积经验") >= 100 then
      u:changedata("撬锁-累积等级", 1)
      u:changedata("撬锁-累积经验", -100)
      u:sendmessage("|cFF7DBEF1[撬锁]经验等级提升,当前:" .. u:getdata("撬锁-累积等级") .. "级|r")
      if not u:hasdata("撬锁-Lv5效果") and u:getdata("撬锁-累积等级") >= 5 then
        u:setdata("撬锁-Lv5效果")
        u:sendmessage("|cFF7DBEF1[撬锁]达到5级,损坏概率减半|r")
      end
      if not u:hasdata("撬锁-Lv10效果") and u:getdata("撬锁-累积等级") >= 10 then
        u:setdata("撬锁-Lv10效果")
        u:sendmessage("|cFF7DBEF1[撬锁]达到10级,撬锁工具损坏概率减半|r")
      end
      if not u:hasdata("撬锁-Lv15效果") and u:getdata("撬锁-累积等级") >= 15 then
        u:setdata("撬锁-Lv15效果")
        u:sendmessage("|cFF7DBEF1[撬锁]达到15级,基础撬锁成功率翻倍|r")
      end
    else
      flytext({
        unit = u.handle,
        text = "|cFF7DBEF1撬锁:" .. u:getdata("撬锁-累积经验") .. "/100",
        size = 10,
        time = 1.5,
        xspeed = 0,
        yspeed = 0.02
      })
    end
    if not ts and not cg and stra == "使用工具" then
      if not u:hasdata("撬锁-工具损坏概率") then
        u:setdata("撬锁-工具损坏概率", 4)
      else
        u:changedata("撬锁-工具损坏概率", 1)
      end
      local shgl = u:getdata("撬锁-工具损坏概率")
      if u:hasdata("撬锁-Lv10效果") then
        shgl = shgl * 0.5
      end
      if GetRandom100(shgl) then
        u:setdata("撬锁-工具损坏概率", 4)
        u:sendmessage("|cFF7DBEF1[撬锁]工具损坏|r")
        ChangeItemCount(qsgj, -1)
        if RefreshPlayerBagLikeItem then
          RefreshPlayerBagLikeItem(u, qsgj)
        end
        u:playsound(Sound_Qiaosuoduanlie)
      end
    end
    DestroyEffectLua(tx)
    u:deldata("系统-撬锁中")
    timer:remove()
  end)
end

function qiaosuoitem(u, item)
  qiaosuo_core(u, item, true)
end

local function qiaosuo(u, npc)
  qiaosuo_core(u, npc, false)
end

ITEM_KEY_Huang = S2ID("I0MI")
ITEM_KEY_Lan = S2ID("I0MJ")
ITEM_KEY_Hong = S2ID("I0MK")
ITEM_KEY_Lv = S2ID("I0ML")

local function souxun(u, npc)
  local buildtype = npc:getdata("搜寻点-类型")
  local dataz
  for index, value in ipairs(BuildJlcData) do
    if value.name == buildtype then
      dataz = value.data
      break
    end
  end
  if not dataz then
    return
  end
  local sum = 0
  for _, it in ipairs(dataz) do
    sum = sum + it.w
  end
  local r, acc = GetRandomReal(0, 1) * sum, 0
  for i, it in ipairs(dataz) do
    acc = acc + it.w
    if r <= acc then
      it.func(u, npc)
      return
    end
  end
end

local function souxunwanbi(u, npc)
  local buildtype = npc:getdata("搜寻点-类型")
  local dataz
  for index, value in ipairs(BuildJlcData) do
    if value.name == buildtype then
      dataz = value.enddata
      break
    end
  end
  if not dataz then
    return
  end
  local sum = 0
  for _, it in ipairs(dataz) do
    sum = sum + it.w
  end
  local r, acc = GetRandomReal(0, 1) * sum, 0
  for i, it in ipairs(dataz) do
    acc = acc + it.w
    if r <= acc then
      it.func(u, npc)
      return
    end
  end
end

local skillz = {
  "A0M1",
  "A0M4",
  "A0M7",
  "A0M8"
}

local function jiuguan(u, npc, i)
  if npc:hasdata("酒馆-可招募" .. i) then
    local var = mj:getdata("酒馆-对应变异" .. i)
    if u:getgold() < npc:getdata("酒馆-招募价格" .. i) then
      u:sendmessage("|cFF7DBEF1[酒馆]积分不足无法招募|r")
      return
    end
    if u:hasdata("变异判定-" .. var.name) then
      u:sendmessage("|cFF7DBEF1[酒馆]无法招募|r")
      return
    end
    local dpools = VarsCiyuanPools(Vars_Ciyuan_Spe, Vars_Ciyuan_Yuanshi_Spe)
    u:addgold(-1 * npc:getdata("酒馆-招募价格" .. i))
    herogetvar(u.handle, dpools, "次元", var.name)
    mj:deldata("酒馆-对应变异" .. i)
    mj:deldata("酒馆-可招募" .. i)
    mj:deldata("酒馆-招募价格" .. i)
    local dskill = skillz[i]
    mj:setskilldatastring(dskill, "提示", "|cFF7DBEF1无人的空位|r")
    mj:setskilldatastring(dskill, "图标", "ReplaceableTextures\\CommandButtons\\BTNCancel.blp")
    mj:setskilldatastring(dskill, "提示拓展", "|cFF7DBEF1空的座位|r")
  else
    u:sendmessage("|cFF7DBEF1[酒馆]无可招募目标|r")
  end
end

local function souxundanren(u, npc)
  local sy = u.ownerid
  if not u:hasdata("系统-搜寻中") and not npc:hasdata("搜寻点-搜寻完毕") then
    local x, y = u:getxy()
    local dtime = 0
    local runtime = 2
    if u:hasdata("英雄-魔理沙") then
      runtime = runtime - 1
    end
    local dismax = 322.5
    local tx = Effectcreate("WhiteCircle.mdx", x, y, -1, 0.6, 0, 0, 0, 0, 0.25)
    u:setdata("系统-搜寻中")
    local type = npc:getdata("搜寻点-类型")
    u:sendmessage(("|cFF7DBEF1[%s]开始搜寻……|r"):format(type))
    ac.loop(100, function(timer)
      local dx, dy = u:getxy()
      local dis = DistanceXY(x, y, dx, dy)
      if not u:isalive() or dis > dismax or npc:hasdata("搜寻点-搜寻完毕") then
        DestroyEffectLua(tx)
        u:sendmessage(("|cFF7DBEF1[%s]停止搜寻|r"):format(type))
        u:deldata("系统-搜寻中")
        timer:remove()
        return
      end
      dtime = dtime + 0.1
      local needtime = runtime
      if Boolean_GuoboInterval then
        needtime = needtime * 0.5
      end
      if needtime <= dtime then
        dtime = 0
        local add = npc:getdata("搜寻点-基础推进进度") + GetRandomInt(npc:getdata("搜寻点-随机推进进度下限"), npc:getdata("搜寻点-随机推进进度上限"))
        npc:changedata("搜寻点-当前进度", add)
        if npc:getdata("搜寻点-当前进度") >= 100 then
          npc:setdata("搜寻点-当前进度", 100)
          npc:setdata("搜寻点-搜寻完毕")
          souxunwanbi(u, npc)
          DestroyEffectLua(tx)
          u:deldata("系统-搜寻中")
          npc:groupremove(Group_PlanetBuild)
          KillUnit(npc.handle)
          npc:timetoremove(3)
          timer:remove()
        else
          souxun(u, npc)
          if u:hasdata("英雄-魔理沙") and GetRandom100(25) then
            souxun(u, npc)
          end
          if GetRandom100(u:getdata("伊塔-探索额外结果概率")) then
            souxun(u, npc)
          end
        end
      end
    end)
  end
end

function souxunduli(u, npc)
  local sy = u.ownerid
  local handle = npc:getdata("交互建筑-序号")
  if not u:hasdata("系统-搜寻中") and not u:hasdata("搜寻点-搜寻完毕" .. handle) then
    local x, y = u:getxy()
    local dtime = 0
    local runtime = 2
    if u:hasdata("英雄-魔理沙") then
      runtime = runtime - 1
    end
    local dismax = 322.5
    local tx = Effectcreate("WhiteCircle.mdx", x, y, -1, 0.6, 0, 0, 0, 0, 0.25)
    u:setdata("系统-搜寻中")
    local type = npc:getdata("搜寻点-类型")
    u:sendmessage(("|cFF7DBEF1[%s]开始搜寻……|r"):format(type))
    ac.loop(100, function(timer)
      local dx, dy = u:getxy()
      local dis = DistanceXY(x, y, dx, dy)
      if not u:isalive() or dis > dismax or u:hasdata("搜寻点-搜寻完毕" .. handle) then
        DestroyEffectLua(tx)
        u:sendmessage(("|cFF7DBEF1[%s]停止搜寻|r"):format(type))
        u:deldata("系统-搜寻中")
        timer:remove()
        return
      end
      dtime = dtime + 0.1
      local needtime = runtime
      if Boolean_GuoboInterval then
        needtime = needtime * 0.5
      end
      if needtime <= dtime then
        dtime = 0
        local add = npc:getdata("搜寻点-基础推进进度") + GetRandomInt(npc:getdata("搜寻点-随机推进进度下限"), npc:getdata("搜寻点-随机推进进度上限"))
        u:changedata("搜寻点-当前进度" .. handle, add)
        if u:getdata("搜寻点-当前进度" .. handle) >= 100 then
          u:setdata("搜寻点-当前进度" .. handle, 100)
          u:setdata("搜寻点-搜寻完毕" .. handle)
          souxunwanbi(u, npc)
          DestroyEffectLua(tx)
          u:deldata("系统-搜寻中")
          local h = 0
          local localhero = getunit(Hero[LocalPlayerID])
          if localhero:hasdata("搜寻点-搜寻完毕" .. handle) then
            h = 10000
          end
          npc:setflyheight(h)
          timer:remove()
        else
          souxun(u, npc)
          if u:hasdata("英雄-魔理沙") and GetRandom100(25) then
            souxun(u, npc)
          end
          if GetRandom100(u:getdata("伊塔-探索额外结果概率")) then
            souxun(u, npc)
          end
        end
      end
    end)
  end
end

local function jiaohu(u, npc)
  local sy = u.ownerid
  if npc:hasdata("系统-龙之城") and npc:hasdata("龙之城-上锁") then
    local b = false
    if not b and u:hasdata("隐藏职业-龙太子") then
      b = true
      u:sendmessage("|cFFFFCC33[龙之城]你认得这种锁型,你直接打开了|r")
    end
    local wp = 0
    if GetPlayerBagLikeItem then
      wp = GetPlayerBagLikeItem(u, ITEM_KEY_Hong) or 0
    else
      local bb = getunit(Beibao[sy])
      if u:ishasitem(ITEM_KEY_Hong) then
        wp = u:getitem(ITEM_KEY_Hong) or 0
      elseif bb:ishasitem(ITEM_KEY_Hong) then
        wp = bb:getitem(ITEM_KEY_Hong) or 0
      end
    end
    if not b and wp ~= 0 then
      b = true
      ChangeItemCount(wp, -1)
      if RefreshPlayerBagLikeItem then
        RefreshPlayerBagLikeItem(u, wp)
      end
      u:sendmessage("|cFFFFCC33[龙之城]消耗红钥匙|r")
    end
    if b then
      npc:deldata("龙之城-上锁")
    else
      u:sendmessage("|cFFFFCC33[龙之城]无法探索(上锁 - 撬锁或消耗一把红钥匙)|r")
      return
    end
  end
  if npc:hasdata("搜寻点-搜寻完毕") then
    u:sendmessage("|cFF7DBEF1[系统]已探索完毕|r")
    return
  end
  if npc:hasdata("交互建筑-独立") then
    souxunduli(u, npc)
  else
    souxundanren(u, npc)
  end
end

local jzpools = {
  {
    name = "酒馆招募-4",
    typeid = "h05V",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      local i = 4
      jiuguan(u, npc, i)
    end
  },
  {
    name = "酒馆招募-3",
    typeid = "h05U",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      local i = 3
      jiuguan(u, npc, i)
    end
  },
  {
    name = "酒馆招募-2",
    typeid = "h05T",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      local i = 2
      jiuguan(u, npc, i)
    end
  },
  {
    name = "酒馆招募-1",
    typeid = "h05S",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      local i = 1
      jiuguan(u, npc, i)
    end
  },
  {
    name = "互动-搜寻",
    typeid = "h05R",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      jiaohu(u, npc)
    end
  },
  {
    name = "神秘花园-交互",
    typeid = "h05Q",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      if not npc:hasdata("系统-神秘花园互动" .. sy) then
        u:sendmessage("|cFF7DBEF1[系统]已互动|r")
        return
      end
      npc:deldata("系统-神秘花园互动" .. sy)
      local sj = GetRandomInt(1, 6)
      local text = "|cFF7DBEF1[神秘花园]"
      if sj == 1 then
        local add = GetRandomInt(10, 250)
        u:addgold(add)
        text = text .. "获得" .. add .. "积分"
      end
      if sj == 2 then
        local add = GetRandomInt(1, 25)
        u:addwood(add)
        text = text .. "获得" .. add .. "追忆值"
      end
      if sj == 3 then
        local zu = {
          "I0E8",
          "I007",
          "I038",
          "I00X"
        }
        local x, y = u:getxy()
        u:setdata("物品-X", x)
        u:setdata("物品-Y", y)
        u:additem(zu[GetRandomInt(1, #zu)])
        text = text .. "获得补给"
      end
      if sj == 4 then
        local add = GetRandomInt(1, 25)
        u:addrandomstats(add)
        text = text .. "获得" .. add .. "属性"
      end
      if sj == 5 then
        local add = GetRandomInt(1, 25)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (add * 0.01))
        text = text .. "获得" .. string.format("%.1f", add * 0.1) .. "%伤害加成"
      end
      if sj == 6 then
        local wpid = "I085"
        if GetRandom100(0.5) then
          wpid = "I087"
        elseif GetRandom100(1) then
          wpid = "I08A"
        elseif GetRandom100(5) then
          wpid = "I086"
        else
          wpid = "I085"
        end
        u:additem(wpid)
        text = text .. "获得遗物"
      end
      u:sendmessage(text)
      u:effectadd("Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl", "origin")
      local h = 0
      if not npc:hasdata("系统-神秘花园互动" .. LocalPlayerID) then
        h = 10000
      end
      npc:setflyheight(h)
    end
  },
  {
    name = "贸易箱-交互",
    typeid = "h05N",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      local xh = npc:getdata("贸易箱-消耗积分")
      if xh > u:getgold() then
        u:sendmessage("|cFF7DBEF1[系统]积分不足|r")
        return
      end
      u:addgold(-xh)
      local xyd = npc:getdata("贸易箱-品质")
      kaixiangzi(u, npc, xyd)
      if npc:hasdata("贸易箱-标价") then
        local text = npc:getdata("贸易箱-标价")
        TimerDestroyTextTag(0, text)
        npc:deldata("贸易箱-标价")
        u:select()
      end
    end
  },
  {
    name = "交互-撬锁",
    typeid = "h05O",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      qiaosuo(u, npc)
    end
  },
  {
    name = "兴趣点-交互",
    typeid = "h05G",
    func = function(self, args)
      local u = args.u
      local sy = u.ownerid
      local npc = args.npc
      if npc:hasdata("系统-兴趣点") then
        if npc:hasdata("兴趣点-已互动" .. sy) then
          u:sendmessage("|cFF7DBEF1已经交互过该兴趣点|r")
          return
        end
        npc:setdata("兴趣点-已互动" .. sy)
        local data = npc:getdata("兴趣点-绑定事件")
        RLChoose(u, data, "list")
        local flyheight = 0
        if u:islocal() then
          flyheight = 5000
        end
        npc:setflyheight(flyheight)
      end
    end
  },
  {
    name = "降落点-降落",
    typeid = "h05E",
    func = function(self, args)
      local u = args.u
      local npc = getunit(NPC_Fanhuidian)
      local x, y = u:getxy()
      local x2, y2 = npc:getxy()
      if Boolean_IsFlying or BossBattle then
        u:sendmessage("|cFF7DBEF1目前没有停留在任何星球地表|r")
        return
      end
      if not b_biexibo_BGM and getunit(BOSS_Baoshi):isinrect(RECT_Planetuse) then
        ChangeBGM(BGM_Biexibo)
        b_biexibo_BGM = true
      end
      u:setmapxy(x2, y2)
      u:select()
      Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x, y)
      Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x2, y2)
    end
  },
  {
    name = "信标-返回",
    typeid = "h05F",
    func = function(self, args)
      local u = args.u
      local npc = getunit(NPC_Jiangluodian)
      local x, y = u:getxy()
      local x2, y2 = npc:getxy()
      u:setmapxy(x2, y2)
      u:select()
      Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x, y)
      Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x2, y2)
    end
  }
}
for index, value in ipairs(jzpools) do
  table.insert(pools, value)
end
return pools
