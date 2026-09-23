-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local w, h = 88, 68
local dx = 0.35
local chatmsg = {}
local chatmsgnowuse = {}
local chatmsgnowusecount = 0

local function createnewchatmsg()
  local chatpanel = class.panel:builder({
    x = 1490,
    y = 730,
    w = 100,
    h = 10,
    normal_image = "UI_Chat_Black.tga"
  })
  chatpanel:hide()
  chatpanel:set_level(3)
  local chatdicon = class.panel:builder({
    parent = chatpanel,
    x = -w * dx * 2,
    w = w * dx * 2,
    h = h * dx,
    normal_image = "ChatIcon (17).tga"
  })
  chatdicon:hide()
  chatdicon:set_level(3)
  local chaticontext = class.text:builder({
    parent = chatdicon,
    x = w * dx * 2,
    y = 0.5 * h * dx - 10,
    w = 1,
    h = 1,
    text = "",
    font_size = 10
  })
  chaticontext:hide()
  chaticontext:set_level(4)
  chatpanel.showtext = chaticontext
  chatpanel.showicon = chatdicon
  table.insert(chatmsg, chatpanel)
end

local function showsoundmsg(args)
  local u = args.u
  local sy = u.ownerid or 7
  local time = args.time or 3
  local originstr = args.originstr or args.str
  local str = args.str or args.originstr
  local isrun = args.isrun or false
  local image = args.image
  if isrun == false then
    return
  end
  local dh, dw = textjisuan(originstr)
  local chatpanel
  if #chatmsg == 0 then
    createnewchatmsg()
  end
  chatpanel = table.remove(chatmsg, 1)
  chatpanel.showtext:set_control_size(math.max(1, dw + 5), math.max(20, dh + 5))
  japi.FrameSetSize(chatpanel.showtext._id, math.max(1, dw + 5) / 1920 * 0.8, math.max(20, dh + 5) / 1080 * 0.6)
  chatpanel.showtext:set_text(str)
  chatpanel.showicon:set_normal_image(image or ChatIcon[sy] or "ChatIcon (17).tga")
  chatpanel.showtext:show()
  chatpanel.showicon:show()
  chatpanel:show()
  chatpanel:set_alpha(200)
  chatpanel:set_height(dh + 5)
  chatpanel:set_width(dw + 5)
  chatpanel.dw = dw
  chatpanel.dh = dh
  local x2 = 1890 - dw
  local y2 = 725 - dh - chatmsgnowusecount * 35
  chatpanel:set_position(x2, y2)
  chatmsgnowusecount = chatmsgnowusecount + 1
  table.insert(chatmsgnowuse, chatpanel)
  ac.wait(time * 1000, function()
    chatpanel:hide()
    table.insert(chatmsg, table.remove(chatmsgnowuse, 1))
    chatmsgnowusecount = chatmsgnowusecount - 1
    if 0 < #chatmsgnowuse then
      for i = 1, #chatmsgnowuse do
        local x2 = 1890 - chatmsgnowuse[i].dw
        local y2 = 725 - chatmsgnowuse[i].dh - (i - 1) * 35
        chatmsgnowuse[i]:set_position(x2, y2)
      end
    end
  end)
end

local unit = require("jh.ac.unit")
local cd = false

function unit:playsndmsg(args)
  local u = self
  local str = require("hera_korean").translate(type(args.str) == "string" and args.str or "")
  local snd = args.snd
  local time = args.time or 3
  local sndsize = 100
  local isrun = true
  local isselfonly = args.isselfonly or false
  local isignorecd = args.isignorecd or false
  local isallpeople = args.isallpeople or false
  local isneedseen = args.isneedseen or false
  local isignoredeath = args.isignoredeath or false
  local isnotrun = args.isnotrun or false
  local colors = args.colors or {"7DBEF1"}
  local image = args.image
  if not u:isalive() and not isignoredeath then
    return
  end
  if not isallpeople then
    if isneedseen and not u:isbeseenlocal() then
      isrun = false
    end
    local localid = LocalPlayerID
    if Hero[localid] and Hero[localid] ~= 0 then
      local dis = DistanceBetweenUnits(u.handle, Hero[localid])
      if 3500 <= dis then
        isrun = false
      elseif 2000 <= dis then
        sndsize = 25 + 75 * (3500 - dis) / 1500
      end
    end
  end
  if cd and not isignorecd then
    isrun = false
  end
  if not isselfonly or u:islocal() then
  else
    isrun = false
  end
  if snd then
    PlayGlobalSound(snd, math.floor(sndsize * 1.27))
  end
  if isnotrun then
    isrun = false
  end
  if isrun and not cd then
    cd = true
    ac.wait((time + 1.5) * 1000, function()
      cd = false
    end)
  end
  local chars = {}
  for char, length in utf8Iter(str) do
    table.insert(chars, char)
  end
  local dtext = ""
  local count = 0
  for index, value in ipairs(chars) do
    count = count + 1
    dtext = dtext .. value
    if count == 10 then
      count = 0
      dtext = dtext .. "\n"
    end
  end
  str = dtext
  showsoundmsg({
    u = u,
    originstr = str,
    str = ColorfulMsg(str, colors),
    time = time + 1,
    isrun = isrun,
    image = image
  })
end
