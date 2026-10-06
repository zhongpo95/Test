-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
require("gameplay.permission.state")
local PermissionRead = require("gameplay.permission.permission_read")
local PermissionGroups = require("gameplay.permission.permission_groups")
local fun = require("gameplay.permission.permission_dama")
local PermissionDefaultEffects = require("gameplay.permission.permission_default_effects")
local PermissionStore = require("gameplay.permission.permission_store")
local a = {
  "权力之刃",
  "权力之冠",
  "破戒刀",
  "残暴心",
  "日轮竹",
  "孤狼",
  "高频村雨刀",
  "大阿阇黎",
  "只狼",
  "鬼灭之刃",
  "窥星",
  "千矢",
  "空之律者",
  "潮汐",
  "塞壬公主",
  "白银城主",
  "芙兰酱",
  "朱红之瑰",
  "猎龙盔甲",
  "雷霆长枪",
  "狮子戒指",
  "炎之呼吸",
  "德丽莎观星",
  "儿童节棒棒糖",
  "粽子精",
  "卡兹戴尔纹章",
  "玉月",
  "无暇之钥",
  "吸血剑鬼",
  "爱丽丝之馆",
  "圣诞尼禄",
  "巴蛇之影",
  "儿童节雪糕",
  "布丁背包",
  "轮椅水门",
  "赛马娘",
  "新年权限",
  "哈密瓜雪糕",
  "幻想杀手"
}
local M = {}

function M.heroselect6(u)
  local sy = u.ownerid
  local uidc = CIUC[sy]
  local id3 = TID[sy]
  local p = sen[sy]
  if p then
    if p.uid == "0" then
      return
    end
    if p.CORID then
      if type(p.CORID) == "function" then
        p.CORID(u, sy)
      else
        NameID[sy] = p.CORID
        u:setplayername(NameID[sy])
      end
    end
    if p.PEM and #p.PEM > 0 then
      for _, value in ipairs(p.PEM) do
        u:setdata("权限-" .. value)
        if PermissionDefaultEffects[value] then
          PermissionDefaultEffects[value](u, sy)
        end
        if value == "DALL" then
          for _, value2 in ipairs(a) do
            u:setdata("权限-" .. value2)
            if PermissionDefaultEffects[value2] then
              PermissionDefaultEffects[value2](u, sy)
            end
          end
        end
      end
    end
  end
  PermissionRead.Itema(u)
  local store_bzzyy = PermissionStore.has_permission_group(u.owner, "皮肤权限-白洲梓语音")
  if store_bzzyy and u.type == HeroType["白洲梓"] then
    u:setdata("语音-白洲梓")
  end
  for index, value in ipairs(PermissionGroups.bzzyy) do
    if store_bzzyy then
      break
    end
    if CIUC[sy] == value then
      if u.type == HeroType["白洲梓"] then
        u:setdata("语音-白洲梓")
      end
      break
    end
  end
  local store_umpf = PermissionStore.has_permission_group(u.owner, "皮肤权限-渎白之渊")
  if store_umpf then
    u:setdata("皮肤权限-妖梦渎白之渊")
  end
  for index, value in ipairs(PermissionGroups.umpf) do
    if store_umpf then
      break
    end
    if CIUC[sy] == value then
      if u.type == HeroType["妖梦"] then
        u:setdata("皮肤权限-妖梦渎白之渊")
      end
      break
    end
  end
  local store_mzpf = PermissionStore.has_permission_group(u.owner, "皮肤权限-常陆茉子")
  if store_mzpf then
    u:setdata("皮肤权限-青水茉子")
  end
  for index, value in ipairs(PermissionGroups.mzpf) do
    if store_mzpf then
      break
    end
    if CIUC[sy] == value then
      if u.type == HeroType["波风水门"] then
        u:setdata("皮肤权限-青水茉子")
      end
      break
    end
  end
  do
    local store_ls = PermissionStore.has_permission_group(u.owner, "变异权限-幽灵鲨")
    if store_ls then
      fun["幽灵鲨"](u, sy)
    end
    for index, value in ipairs(PermissionGroups.dsmyls) do
      if store_ls then
        break
      end
      if CIUC[sy] == value then
        fun["幽灵鲨"](u, sy)
        break
      end
    end
    local store_skd = PermissionStore.has_permission_group(u.owner, "变异权限-斯卡蒂")
    if store_skd then
      fun["斯卡蒂"](u, sy)
    end
    for index, value in ipairs(PermissionGroups.dsmskd) do
      if store_skd then
        break
      end
      if CIUC[sy] == value then
        fun["斯卡蒂"](u, sy)
        break
      end
    end
    local id = {
      "-403273771",
      "728051655",
      "-1057999030",
      "-1895700092",
      "-1413566993",
      "30918512",
      "290886525",
      "-1765756934",
      "-1329896005",
      "-1691194058",
      "-373487042",
      "-1413566993",
      "-58375553",
      "1496861602",
      "1862820213"
    }
    if TableContains(id, uidc) then
      fun["小天子"](u, sy)
    end
    local id = {
      "1023030663",
      "1613553417",
      "666489845",
      "-653418414",
      "1787153005",
      "-484534089",
      "-1678000098",
      "-1403970922",
      "123995761",
      "-822407662",
      "1364150447",
      "1310008887",
      "-2023168823",
      "-1429600477"
    }
    if TableContains(id, uidc) then
      fun["猫头鹰因子"](u, sy)
    end
    local id = {
      "1787153005",
      "123995761",
      "-671962942",
      "-808583347",
      "-194465786",
      "912737881",
      "-1128044213",
      "-1800543239",
      "2106781655",
      "1694565419",
      "1932310753",
      "-787709145",
      "-1236056174"
    }
    if TableContains(id, uidc) then
      fun["夜夜"](u, sy)
    end
    local id = {
      "-109585099",
      "-587063853",
      "-1691194058",
      "241989033",
      "-808583347",
      "1932310753"
    }
    if TableContains(id, uidc) then
      fun["利姆露"](u, sy)
    end
    local id = {
      "-787709145",
      "-671962942",
      "-184681976",
      "241989033",
      "-1236056174",
      "764480012",
      "1155201793",
      "-936649973",
      "-786200340",
      "-327470687",
      "1932310753",
      "1887206979",
      "1974422401",
      "-1013633388"
    }
    if TableContains(id, uidc) then
      fun["礼奈"](u, sy)
    end
    local id = {
      "-1691194058",
      "1194862749",
      "-484534089",
      "123995761",
      "2088880290",
      "371553968",
      "-193381640",
      "-779232133",
      "-1530089653",
      "-1429600477",
      "1787153005",
      "-464531394",
      "-695728144",
      "-1202313139"
    }
    if TableContains(id, uidc) then
      fun["鬼灭权限"](u, sy)
    end
    local id = {
      "-373487042",
      "-933485982",
      "4641059"
    }
    if TableContains(id, uidc) then
      fun["鹿目圆"](u, sy)
    end
    local id = {
      "1023030663",
      "-2086535450",
      "-1429600477",
      "4641059"
    }
    if TableContains(id, uidc) then
      fun["黑龙"](u, sy)
    end
    local id = {
      "-1681447971"
    }
    if TableContains(id, uidc) then
      fun["窥星"](u, sy)
    end
    local id = {
      "2011283003",
      "-327470687",
      "807112835",
      "848356535",
      "-31222358",
      "-1730738540",
      "-1201977636",
      "873810818",
      "1932310753",
      "1636942944",
      "-671962942",
      "-1588123416"
    }
    if TableContains(id, uidc) then
      fun["暗之书"](u, sy)
    end
    local id = {
      "324554023",
      "-1202313139",
      "4641059",
      "1932310753"
    }
    if TableContains(id, uidc) then
      fun["八云紫"](u, sy)
    end
    local id = {
      "-1202313139",
      "123995761",
      "1449469018",
      "1787153005",
      "-484534089",
      "-1413566993",
      "-1429600477",
      "-1152126013",
      "1457930646",
      "-1379169678",
      "954255946",
      "1039830281",
      "1658557193",
      "-373487042",
      "4641059",
      "-642537551",
      "1458959657",
      "324554023",
      "807112835",
      "-695728144"
    }
    if TableContains(id, uidc) then
      fun["忴"](u, sy)
    end
    local id = {
      "-779232133",
      "2118197695",
      "1155201793",
      "123995761",
      "-1202313139",
      "1787153005",
      "4641059",
      "1457930646",
      "807112835"
    }
    if TableContains(id, uidc) then
      fun["祢豆子"](u, sy)
    end
    local shadow_ids = {"-48256776"}
    if TableContains(shadow_ids, uidc) then
      fun["暗影大人"](u, sy)
    end
  end
  itemc(u)
end

return M
