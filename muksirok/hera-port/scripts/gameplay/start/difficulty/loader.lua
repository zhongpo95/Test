-- 저장 서버 없이 원본 난이도 선택 UI를 열고 헤라 버튼 입력을 연결한다.
ac.wait(1, function()
  local boot = require("hera_boot")
  boot.run_stage("difficulty UI", function()
    local player = require("jh.ac.player")
    for i = 1, 6 do
      if player[i]:isplayer() then
        SeletPlayerID = i
        break
      end
    end
    assert(SeletPlayerID, "HERA_DIFFICULTY_NO_PLAYER")
    require("hera_startup_trace").start_flush()
    require("gameplay.start.difficulty.ui")
    local count = require("hera_difficulty_input").bind()
    boot.note("DIFFICULTY UI ready; native buttons=" .. count .. "; selecting player=" .. SeletPlayerID)
    boot.note("WORLD HOVER adapter ready; inspect hover unit/item/empty counts in diagnostic panel")
  end)
end)
