function Unit_Skill_Action takes unit Actor, unit Target, group LocalGroup, unit FilterUnit returns nothing
    call GroupEnumUnitsInRange(LocalGroup, GetWidgetX(Target), GetWidgetY(Target), 800., null)
    loop
        set FilterUnit = FirstOfGroup(LocalGroup)
        exitwhen FilterUnit == null
        call GroupRemoveUnit(LocalGroup, FilterUnit)
        call UnitDamageTarget(Actor, FilterUnit, 200., false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_UNKNOWN)
    endloop
    call DestroyGroup(LocalGroup)
  endfunction
  
  function Unit_Skill_Action_Proxy takes nothing returns nothing
    call Unit_Skill_Action(GetTriggerUnit(), GetSpellTargetUnit(), CreateGroup(), null)
  endfunction