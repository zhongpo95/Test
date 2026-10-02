-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local M = {}

function M.load_foundation_modules()
  require("gameplay.bootstrap.system_dependencies").install()
  require("system.init")
  require("jh.init")
  require("gameplay.unit_extensions.config").install()
end

function M.load_state_modules()
  require("gameplay.state.buff.init")
end

function M.load_combat_modules()
  require("gameplay.combat.handlers").install()
  require("combat.init")
end

function M.load_runtime_modules()
  require("gameplay.runtime.unify.init")
end

function M.load_feature_modules()
  require("gameplay.feature.weapons.init")
  require("gameplay.feature.gun.init")
  require("gameplay.feature.item.init")
end

function M.load_startup_modules()
  DebugText = false
  require("gameplay.state.random")
  require("gameplay.permission.permission_hero_unlock")
  require("gameplay.state.stats")
  require("gameplay.feature.yisi")
  require("gameplay.hero.registry")
  require("gameplay.start.initial_scene")
  require("gameplay.feature.movie.init")
  require("hera_korean").install_movie_text()
  require("gameplay.start.difficulty.after_difficulty")
  require("gameplay.hero.hidepro.random_pool")
  require("gameplay.start.hero_select.init")
  require("gameplay.runtime.systemArealimit")
  require("gameplay.runtime.stamina")
  require("gameplay.state.hpgroup.init")
  require("gameplay.feature.planet.init")
  require("gameplay.feature.keyan.init")
end

function M.load_local_input_modules()
  require("gameplay.runtime.moveskill.init")
  require("gameplay.feature.shot.set")
  require("gameplay.feature.shot.act")
end

function M.load_game_modules()
  M.load_foundation_modules()
  M.load_state_modules()
  M.load_combat_modules()
  M.load_runtime_modules()
  M.load_feature_modules()
  M.load_startup_modules()
  M.load_local_input_modules()
end

return M
