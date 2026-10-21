-- 피해 처리와 원래 이벤트 등록을 유지하며 전투 관측기를 연결한다.
require("combat.textshow")
require("combat.damageunit")
require("combat.damagehero")
local NativeDamage = require("combat.native_event")
require("combat.damagemonster")
require("combat.monster.timer")
DamageUnit = require("hera_gameplay_diagnostic").track_damage(DamageUnit)
local apply_damage = DamageUnit
NativeDamage.install(war3.CreateTrigger, apply_damage)
