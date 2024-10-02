library BuffData requires Struct2Buff, StatsSet
    //무적
    struct BuffNoDM
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
            call UnitAddAbility(.Target, 'A01V')
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
            call UnitRemoveAbility(.Target, 'A01V')
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct

    //스턴 면역
    struct BuffNoST
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
            call UnitAddAbility(.Target, 'A00Q')
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
            call UnitRemoveAbility(.Target, 'A00Q')
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
    
    //넉백 면역
    struct BuffNoNB
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
            call UnitAddAbility(.Target, 'A00R')
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
            call UnitRemoveAbility(.Target, 'A00R')
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
    
    //모미지이속버프
    struct BuffMomiz00
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
            set Hero_BuffMoveSpeed[GetPlayerId(GetOwningPlayer(.Target))] = Hero_BuffMoveSpeed[GetPlayerId(GetOwningPlayer(.Target))] + 50.0
            call ItemUIStatsSet(GetPlayerId(GetOwningPlayer(.Target)))
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
            set Hero_BuffMoveSpeed[GetPlayerId(GetOwningPlayer(.Target))] = Hero_BuffMoveSpeed[GetPlayerId(GetOwningPlayer(.Target))] - 50.0
            call ItemUIStatsSet(GetPlayerId(GetOwningPlayer(.Target)))
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
    
    //시너지 치확증가
    struct DeBuffCri
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
    
    //시너지 방깎
    struct DeBuffMArm
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
    
    //시너지 백추뎀
    struct DeBuffMBackHead
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
    
    //모미지발도버프
    struct BuffMomiz01
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
    
    
    //나루메아 전환버프
    struct BuffNar00
        effect Effect
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
            local integer pid = GetPlayerId(GetOwningPlayer(.Target))
            set .Effect = AddSpecialEffectTarget("VFX_Pepsislash_Thin.mdl",.Target,"hand left")
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
            call DestroyEffect(.Effect)
            set .Effect = null
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct

    //챈 공증버프
    struct BuffChen00
        effect Effect
        real Velue
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
            local integer pid = GetPlayerId(GetOwningPlayer(.Target))
            set .Effect = AddSpecialEffectTarget("Buff_Attack.mdl",.Target,"overhead")
            set .Velue = R2I( Equip_Damage[pid] ) * ( I2R(.Argument) / 1000 )
            set Hero_Damage[pid] = Hero_Damage[pid] + .Velue
            call ItemUIStatsSet(pid)
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
            call DestroyEffect(.Effect)
            set .Effect = null
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
            local integer pid = GetPlayerId(GetOwningPlayer(.Target))
            set Hero_Damage[pid] = Hero_Damage[pid] - .Velue
            call ItemUIStatsSet(pid)
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct

    
    //나루메아 공증버프
    struct BuffNar01
        effect Effect
        real Velue
        /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
        method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
            return .Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
        endmethod
        /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
        method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
            set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
            set .Duration = dur
            set .Argument = arg
        endmethod
        /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
        method OnApply takes nothing returns nothing
            local integer pid = GetPlayerId(GetOwningPlayer(.Target))
            set .Effect = AddSpecialEffectTarget("LivingArmor.mdl",.Target,"origin")
            set .Velue = R2I( Equip_Damage[pid] ) * ( I2R(.Argument) / 1000 )
            set Hero_Damage[pid] = Hero_Damage[pid] + .Velue
            call ItemUIStatsSet(pid)
        endmethod
        /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
        method OnRemove takes nothing returns nothing
            call DestroyEffect(.Effect)
            set .Effect = null
        endmethod
        /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
        method OnDuration takes nothing returns nothing
            local integer pid = GetPlayerId(GetOwningPlayer(.Target))
            set Hero_Damage[pid] = Hero_Damage[pid] - .Velue
            call ItemUIStatsSet(pid)
        endmethod
        /* struct를 Buff로 만듦 */
        //! runtextmacro Struct2Buff("-1.0") /* 틱 사용안함 = 틱 발동형 버프가 아님 */
    endstruct
endlibrary