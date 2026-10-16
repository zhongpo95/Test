-- 기본 버튼의 실제 배치와 같은 좌표를 툴팁 마우스 검사에 전달한다.
local native_frames = {}
local tooltip_input = require("hera_native_tooltip")
local frame_parent = japi.DzFrameGetParent(japi.DzFrameGetPortrait())
local frame_definitions = {
  {
    x = 758,
    y = 425,
    width = 168.63934426229508,
    height = 127,
    texture = "UI_Y_Skill.tga"
  },
  {
    x = 464,
    y = 425,
    width = 76.54794520547945,
    height = 127,
    texture = "UI_Y_Item.tga"
  },
  {
    x = 19,
    y = 425,
    width = 294.7051282051282,
    height = 127,
    texture = "UI_Y_Hpmp.tga"
  },
  {
    x = -448,
    y = 425,
    width = 94.43589743589743,
    height = 127,
    texture = "UI_Y_HeroPor.tga"
  },
  {
    x = -771,
    y = 425,
    width = 175.84615384615384,
    height = 127,
    texture = "UI_Y_Liukong.tga"
  },
  {
    x = -608,
    y = 450.8,
    width = 39.4,
    height = 98.5,
    texture = "UI_Y_State.tga"
  },
  {
    x = -841,
    y = 449,
    width = 101.61290322580645,
    height = 100,
    texture = "UI_Y_Minmap.tga"
  }
}
for index, definition in ipairs(frame_definitions) do
  local frame = japi.DzCreateFrameByTagName("BACKDROP", "name", frame_parent, "template", 0)
  native_frames[index] = frame
  japi.DzFrameSetPoint(frame, 4, japi.DzGetGameUI(), 4, definition.x / 1920 * 0.8, -definition.y / 1080 * 0.6)
  japi.DzFrameSetSize(frame, definition.width * 0.001, definition.height * 0.001)
  japi.DzFrameSetTexture(frame, definition.texture, 0)
  japi.DzFrameSetAlpha(frame, UITransparency * 255)
end
do
  local start_x = 1106.5
  local start_y = -912.5
  local size = 55
  for slot = 0, 5 do
    local column = slot % 2
    local row = math.floor(slot / 2)
    local button = japi.DzFrameGetItemBarButton(slot)
    japi.FrameShow(button, true)
    japi.FrameClearAllPoints(button)
    japi.FrameSetSize(button, size / 1920, size / 1800)
    japi.FrameSetPoint(button, 4, japi.GetGameUI(), 0, (start_x + column * (size + 12)) / 1920, (start_y - row * (size + 10)) / 1800)
    tooltip_input.layout(button, (start_x + column * (size + 12)) / 0.8, -start_y + row * (size + 10), size / 0.8, size)
  end
end
do
  local size = 67
  local start_x = 1261.5
  local start_y = -897
  for row = 0, 2 do
    for column = 0, 3 do
      local button = japi.FrameGetCommandBarButton(row, column)
      japi.FrameShow(button, true)
      japi.FrameClearAllPoints(button)
      japi.FrameSetSize(button, size / 1920, size / 1800)
      japi.FrameSetPoint(button, 4, japi.GetGameUI(), 0, (start_x + column * (size + 8.5)) / 1920, (start_y - row * (size + 4.6)) / 1800)
      tooltip_input.layout(button, (start_x + column * (size + 8.5)) / 0.8, -start_y + row * (size + 4.6), size / 0.8, size)
    end
  end
end
return native_frames
