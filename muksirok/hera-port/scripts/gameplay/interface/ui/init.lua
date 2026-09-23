-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
require("gameplay.interface.ui.uifunc")
require("gameplay.interface.ui.songtext")
require("gameplay.interface.ui.herostate")
require("gameplay.interface.ui.varskill")
require("gameplay.interface.ui.bqb")
require("gameplay.interface.ui.dyd")
require("gameplay.interface.ui.musictext")
require("hera_korean").install_music_text()
require("gameplay.interface.ui.uichatsnd")
require("gameplay.interface.ui.gbbook")
require("gameplay.interface.ui.shop")
require("gameplay.interface.ui.rlc")
require("gameplay.interface.ui.player_name_head")
require("gameplay.interface.ui.player_image_head")
require("gameplay.interface.ui.chat_tool")
BuffUI = require("gameplay.interface.ui.buff")
require("gameplay.interface.ui.buffset")
local damagemonster009 = require("combat.monster.re009")
local damagemonster011 = require("combat.monster.re011")
local ddx = 1900
local ddy = 55
if EnableCustomUI then
  ddx = 1705
  ddy = 18
end
UI_jiance = class.text:builder({
  x = ddx,
  y = ddy,
  w = 1,
  h = 1,
  text = "",
  align = "right",
  font_size = 8
})
UI_jiance:set_color("FFA9C4FF")
ac.loop(1000, function()
  ForGroupLuaNew(Group_PlayHero, function(u)
    u:setdata("系统-伤害修正显示计算")
    local x, y = u:getxy()
    local sy = u.ownerid
    local damageinfo = {
      u = u,
      soc = u,
      hero = u,
      x = x,
      y = y,
      x2 = x,
      y2 = u,
      sy = sy,
      sy2 = sy,
      damage = 1,
      yssh = 1,
      element = "无",
      damagetype = "物理",
      level = 1,
      iscrit = false,
      distance = 0,
      isvestdamage = false,
      ismeleedamage = false
    }
    damagemonster009(damageinfo)
    damagemonster011(damageinfo)
    damagesystemre004(u.handle, u.handle, 0, 1, 0)
    damagesystemre005(u.handle, u.handle, 0, 1, 0, "无", 0)
    u:deldata("系统-伤害修正显示计算")
    flashstate(u.ownerid)
  end)
end)
local shouce_text
Shouce_Button = class.button:builder({
  x = 1455,
  y = 18,
  w = 48.400000000000006,
  h = 37.400000000000006,
  showtext = "|cFF6633FF帕|r|cFF8044FF秋|r|cFF9955FF莉|r|cFFB266FF手|r|cFFCC77FF册|r\n|cFFCC99FF查看游戏指令/合成列表|r",
  normal_image = "UI_Shouce.blp",
  on_button_clicked = function(self)
    self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
    ac.wait(100, function()
      self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
    end)
    self:set_alpha(255)
    if shouce_text:get_is_show() then
      shouce_text:hide()
    else
      shouce_text:show()
    end
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(150)
    if self.showtext then
      uiy_show_text(self.showtext)
    end
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(255)
    if self.showtext then
      uiy_hide()
    end
  end,
  on_button_update_drag = function(self, icon, x, y)
    self:set_position(x, y)
  end
})
Shouce_Button:hide()
Shouce_Button:set_enable_drag(true)
shouce_text = class.panel:builder({
  x = 500,
  y = 125,
  w = 1000,
  h = 650,
  normal_image = "war3mapImported\\Black.blp"
})
shouce_text:hide()
shouce_text:set_level(3)
shouce_text:set_alpha(150)
local shouce_text_show = class.text:builder({
  parent = shouce_text,
  x = 8,
  y = 38,
  w = 1,
  h = 1,
  text = "",
  align = "topleft",
  font_size = 12
})
shouce_text_show:set_color("FFCCCCFF")
shouce_text_show:set_size(1, "Fonts\\NanumGothic-Regular.ttf")
shouce_text_show:set_control_size(975, 600)
japi.FrameSetSize(shouce_text_show._id, 975 / 1920 * 0.8, 600 / 1080 * 0.6)
-- 번역된 안내의 실제 글자 영역과 줄바꿈을 같은 폭으로 맞춘다.
function shouce_text_show:set_text(text)
  local metrics = require("hera_text_width")
  local font = "Fonts\\NanumGothic-Regular.ttf"
  local wrapped = metrics.wrap(text, 12, font, 960)
  local height = math.max(24, metrics.height(wrapped, 12, font))
  self:set_control_size(975, height)
  japi.FrameSetSize(self._id, 975 / 1920 * 0.8, height / 1080 * 0.6)
  class.text.set_text(self, wrapped)
end
local shouce_text_b1 = class.button:builder({
  parent = shouce_text,
  x = 5,
  y = 5,
  w = 150,
  h = 28,
  normal_image = "UI_Chat_Black.tga",
  on_button_clicked = function(self)
    shouce_text_show:set_text("+숫자 카메라 높이 올리기\n-숫자 카메라 높이 내리기\n+cam숫자 카메라 강제 올리기\n-move 4초 뒤 맵의 무작위 위치로 이동\n-awsl 자살\n-fly 환몽 난이도의 추가 이동 속도·비행 전환\n-spshot 총기 빠른 사격 켜기\n-ewys 추가 이동 속도 적용 전환\n-give X X번 플레이어에게 잔기 1개 전달(혼돈 제외)\nbgm on/off 배경 음악 켜기/끄기\n-show 남은 몬스터 수 표시 전환\n-xz 내 능력 보정 확인(-zx도 사용 가능)\n-xz2 변이 관련 누적 수치 확인(-zx2도 사용 가능)\n-xz4 특성·속성 확인\n-uid UID 관련 코드 확인\n-roll숫자 1부터 해당 숫자까지 주사위(기본 100)\n-clear 지면의 대부분 아이템 정리(방장)\n-next 전원 준비 완료 처리(방장)")
  end
})
local shouce_text_b1_show = class.text:builder({
  parent = shouce_text_b1,
  x = 5,
  y = 5,
  w = 1,
  h = 1,
  text = "【일반 명령어】",
  align = "topleft",
  font_size = 10
})
shouce_text_b1_show:set_color("FFCCCCFF")
shouce_text_b1_show:set_size(1, "Fonts\\NanumGothic-Regular.ttf")
shouce_text_b1_show:set_control_size(145, 22)
shouce_text_b1_show:set_size(math.min(1, 145 / math.max(1, shouce_text_b1_show:get_width())), "Fonts\\NanumGothic-Regular.ttf")
japi.FrameSetSize(shouce_text_b1_show._id, 145 / 1920 * 0.8, 22 / 1080 * 0.6)
local shouce_text_b2 = class.button:builder({
  parent = shouce_text,
  x = 165,
  y = 5,
  w = 150,
  h = 28,
  normal_image = "UI_Chat_Black.tga",
  on_button_clicked = function(self)
    shouce_text_show:set_text("-relive 영체화 사망 후 영력 덩어리가 없을 때 복구\n-verfix 무한 기절 복구\n-sd 카이스 상점 구매 상태 복구\n-debug4 게임 종료 판정 실행\n-movie 연출 모드에 갇힌 상태 복구\n-live 버추얼 스트리머 외형 복구\n-model 변신 모델 복구\n-mfsx 음수가 된 마법 한도 복구")
  end
})
local shouce_text_b2_show = class.text:builder({
  parent = shouce_text_b2,
  x = 5,
  y = 5,
  w = 1,
  h = 1,
  text = "【복구 명령어】",
  align = "topleft",
  font_size = 10
})
shouce_text_b2_show:set_color("FFCCCCFF")
shouce_text_b2_show:set_size(1, "Fonts\\NanumGothic-Regular.ttf")
shouce_text_b2_show:set_control_size(145, 22)
shouce_text_b2_show:set_size(math.min(1, 145 / math.max(1, shouce_text_b2_show:get_width())), "Fonts\\NanumGothic-Regular.ttf")
japi.FrameSetSize(shouce_text_b2_show._id, 145 / 1920 * 0.8, 22 / 1080 * 0.6)
local shouce_text_b3 = class.button:builder({
  parent = shouce_text,
  x = 325,
  y = 5,
  w = 150,
  h = 28,
  normal_image = "UI_Chat_Black.tga",
  on_button_clicked = function(self)
    shouce_text_show:set_text("-qx 이번 게임의 드롭 권한 확인\n-rr 오른쪽 더블클릭 아이템 전달 끄기\n-ar 변경된 AR 스킬 고정\n-fx 변경된 F 스킬 고정\n-summon 소환수 피해 끄기\n-chat 대사 텍스트 켜기\n-shutup 일부 변이 음성 끄기(소유자 입력)\n-nophotic 총의 악토 화면 깜빡임 끄기\n-noshock 모든 카메라 흔들림 끄기\n-tt 이모티콘 끄기\n-dxd 속성 주사위 판정 표시\n-font 채팅 글꼴 전환\n-dps DPS 통계 확인\n-clearmemory(-qchc) 게임 캐시 정리(팀 전체 적용)\n-recam 카메라 초기화\n-filtered 명령어 채팅 표시만 숨기기/보이기\nbqbc 이모티콘 음성 끄기\n-jp/-cn 일부 변이 음성의 언어 전환\n你已经死了 체력이 가득 찬 보스에게 마왕 특성 부여")
  end
})
local shouce_text_b3_show = class.text:builder({
  parent = shouce_text_b3,
  x = 5,
  y = 5,
  w = 1,
  h = 1,
  text = "【기타 명령어】",
  align = "topleft",
  font_size = 10
})
shouce_text_b3_show:set_color("FFCCCCFF")
shouce_text_b3_show:set_size(1, "Fonts\\NanumGothic-Regular.ttf")
shouce_text_b3_show:set_control_size(145, 22)
shouce_text_b3_show:set_size(math.min(1, 145 / math.max(1, shouce_text_b3_show:get_width())), "Fonts\\NanumGothic-Regular.ttf")
japi.FrameSetSize(shouce_text_b3_show._id, 145 / 1920 * 0.8, 22 / 1080 * 0.6)
local shouce_text_b4 = class.button:builder({
  parent = shouce_text,
  x = 485,
  y = 5,
  w = 150,
  h = 28,
  normal_image = "UI_Chat_Black.tga",
  on_button_clicked = function(self)
    local u = getunit(Hero[LocalPlayerID])
    local str = "|cFFCCCCFF이 캐릭터의 전용 명령어가 없습니다"
    if u.type == HeroType["八重樱"] then
      str = "【야에 사쿠라】\n-cd 비염지옥 남은 재사용 시간\n-cq 순영잔 사용 시 정지 명령 여부 전환"
    end
    if u.type == HeroType["两仪式"] then
      str = "【료우기 시키】\n-handmode 수동 콤보 모드\n-lock 스킬 카메라 고정 끄기\n-zgs 강제 콤보 중단 켜기\n-shockcam 스킬 카메라 흔들림 끄기\n-aeav AEAV 마우스 방향 추적 켜기\n-eeav EEAV 마우스 방향 추적 켜기\n-icon 고해상도 아이콘 끄기"
    end
    if u.type == HeroType["史尔特尔"] then
      str = "【스르트】\n-cdshow 밧줄벌레 재사용 시간 표시 끄기\n-tfs 스킬트리 전환\n-ccd 숨겨진 음성 끄기\n-wd 기술 무적 방식 전환\n-icon 고해상도 아이콘 끄기"
    end
    if u.type == HeroType["妖梦"] then
      str = "【콘파쿠 요우무】\n-cd 기술 재사용 시간 확인\n-ss 영격을 S 한 번으로 사용하도록 전환\n-ex1 스킨 전환·외형 복구\n-ace 생사유전참 첫 타의 밀치기 전환\n-zs1 화면 연출 전환\n-zs2 스킨 화면 연출 전환\n-fc 또는 -facechange 기본 검술 A의 방향 보정 전환"
    end
    if u.type == HeroType["志贵"] then
      str = "【시키】\n-cd 극사 나나야·십칠분할 재사용 시간\n-handmode 수동 콤보 모드\n-handmode2 수동 모드 AEEV 선딜레이 제거\n-facechange 콤보 방향 보정\n-lock 스킬 카메라 고정\n-lockall 모든 스킬 카메라 고정\n-lockhero 카메라를 영웅에게 고정\n-zgs 강제 콤보 중단 켜기\n-icon 고해상도 아이콘 끄기"
    end
    if u.type == HeroType["千咲"] then
      str = "【쿠치하 치사】\n-ajd 일반 공격(A) 마우스 방향 추적\n-ejd 톱날 고리(E) 마우스 방향 추적\n-fjd F 마우스 방향 추적\n-rjd 강공격(R) 마우스 방향 추적\n-alljd 위 방향 추적을 모두 전환\n-zgs 강제 콤보 중단 켜기\n-wd 기술의 의사 무적 켜기\n-zj 탈것 소환 끄기\n-camlock 공중 카메라 고정\n-tfs 스킬트리 전환\n-icon 고해상도 아이콘 끄기"
    end
    shouce_text_show:set_text(str)
  end
})
local shouce_text_b4_show = class.text:builder({
  parent = shouce_text_b4,
  x = 5,
  y = 5,
  w = 1,
  h = 1,
  text = "【캐릭터 명령어】",
  align = "topleft",
  font_size = 10
})
shouce_text_b4_show:set_color("FFCCCCFF")
shouce_text_b4_show:set_size(1, "Fonts\\NanumGothic-Regular.ttf")
shouce_text_b4_show:set_control_size(145, 22)
shouce_text_b4_show:set_size(math.min(1, 145 / math.max(1, shouce_text_b4_show:get_width())), "Fonts\\NanumGothic-Regular.ttf")
japi.FrameSetSize(shouce_text_b4_show._id, 145 / 1920 * 0.8, 22 / 1080 * 0.6)
local shouce_text_b6 = class.button:builder({
  parent = shouce_text,
  x = 645,
  y = 5,
  w = 150,
  h = 28,
  normal_image = "UI_Chat_Black.tga",
  on_button_clicked = function(self)
    shouce_text_show:set_text("玩家群：713194097\n玩家群2：1125292576\n玩家群3：926041792\n养老群：197182230\n\n【制作组】\n作者:星辰渝水&小河坂芽爱\n动作&模型：逗耀&苔丝\nUI：安乐冈花火\n感谢可爱的群友们的建议和支持\n\n【本图归属模型】\n博丽灵梦、爱丽丝、圣白莲、秦心\n真红、丹花伊吹、艾露猫、翁斯坦")
  end
})
local shouce_text_b6_show = class.text:builder({
  parent = shouce_text_b6,
  x = 5,
  y = 5,
  w = 1,
  h = 1,
  text = "【제작진·커뮤니티】",
  align = "topleft",
  font_size = 9
})
shouce_text_b6_show:set_color("FFCCCCFF")
shouce_text_b6_show:set_size(1, "Fonts\\NanumGothic-Regular.ttf")
shouce_text_b6_show:set_control_size(145, 22)
shouce_text_b6_show:set_size(math.min(1, 145 / math.max(1, shouce_text_b6_show:get_width())), "Fonts\\NanumGothic-Regular.ttf")
japi.FrameSetSize(shouce_text_b6_show._id, 145 / 1920 * 0.8, 22 / 1080 * 0.6)
