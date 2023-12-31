/********************************************************************************/
/*
    Struct2Buff by 동동주(escaco)
        Version 0.93
        
    [업데이트]
    
    - 2020.06.16 : 0.93
    
        # UnitAlive AI 함수 할당
            ** 이제 쉽게쉽게 사망체크하세요~
    
    
    [개요]
    1. 나만의 버프 만드는 방법
    
        struct 버프이름
            * this.Caster = 버프 건 유닛
            * this.Target = 버프 걸린 유닛
            * this.Handle = 버프 걸린 유닛 핸들값
            * this.Argument = 버프 커스텀 데이터(정수)
            * this.Timeout = 버프 틱 간격(초)
            * this.Duration = 버프 지속 시간(초)
            * this.Remaining = 버프 남은 지속 시간(초)
            * this.Elapsed = 버프 지나간 지속 시간(초)
            
            * private method OnApply takes nothing returns nothing
                ** 버프가 최초 적용될 때 발동
            
            * private method OnBeforeStack takes unit caster, real timeout, real duration, integer argument
                returns boolean
                ** caster   : 버프 건 유닛
                ** timeout  : 새로 적용될 틱 간격
                ** duration : 새로 적용될 지속 시간
                ** argument : 새로 적용될 커스텀 데이터
                ** 버프 중첩을 '시도'하면 발동
                    >> true : 중첩 판정
                    >> false : 중첩 안함
        
            * private method OnAfterStack takes unit caster, real timeout, real duration, integer argument
                returns nothing
                ** caster   : 버프 건 유닛
                ** timeout  : 새로 적용될 틱 간격
                ** duration : 새로 적용될 지속 시간
                ** argument : 새로 적용될 커스텀 데이터
                ** 버프 중첩 시 발동
                
            * private method OnTimeout takes nothing returns boolean
                ** 버프가 걸려있을 때, 매 틱마다 발동
                    >> true : 버프 유지
                    >> false : 버프 강제 종료
            
            * private method OnDuration takes nothing returns nothing
                ** 버프의 지속 시간이 만료되면 발동
            
            * private method OnRemove takes nothing returns nothing
                ** 버프가 소멸(어떤 방법으로든)하면 발동
        
            //! runtextmacro Struct2Buff("기본 틱 간격<초>")
        endstruct
        
        
    2. 만든 버프를 유닛에게 적용하는 방법
    
        call 버프이름.Apply( 대상 유닛, 지속 시간, 커스텀 데이터 )
            * 지속 시간 : 0초보다 작으면 '영구 지속' 버프
            * 커스텀 데이터 : 아무 정수. 버프 레벨로 응용하거나, 구조체를 넘길 수도 있음
        
            예시) call MySampleBuff.Apply( GetTriggerUnit(), 3.0, 0 )
            
        call 버프이름.ApplyEx( 버프를 건 유닛, 버프 걸릴 유닛, 지시간, 커스텀 속 데이터 )
            * 지속 시간 : 0초보다 작으면 '영구 지속' 버프
            * 커스텀 데이터 : 아무 정수. 버프 레벨로 응용하거나, 구조체를 넘길 수도 있음
        
            예시) call MySampleBuff.Apply( GetSpellAbilityUnit(), GetSpellTargetUnit(), 3.0, 0 )
            
            
    3. 유닛에게 버프가 걸려있는지 확인하는 방법
    
        local boolean 걸려있음? = 버프이름.Exists( 검사 대상 유닛 )
        
            예시) if MySampleBuff.Exists( GetTriggerUnit() ) then
            
            
    4. 과부하 확인하는 방법
        
        local integer 버프총량 = Struct2Buff.Count
        call BJDebugMsg( "현존하는 버프 총량 : " + I2S(버프총량) )
        
        ** 특정 버프가 과부하 의심될 때 **
            local integer 특정버프총량 = 버프이름.Count
            call BJDebugMsg( "[버프이름] 총량 : " + I2S(특정버프총량) )
            
            
*/
/********************************************************************************/
native UnitAlive takes unit id returns boolean
    /********************************************************************************/
    library Struct2Buff
        globals
            hashtable TABLE_CBUFF = InitHashtable()
            integer TABLE_CBUFF_COUNT = 0
        endglobals
        struct Struct2Buff extends array
            static method operator Count takes nothing returns integer
                return TABLE_CBUFF_COUNT
            endmethod
        endstruct
    endlibrary
    /********************************************************************************/
    //! textmacro Struct2Buff takes TIMEOUT
    private static key BUFF_KEY
    private static integer BUFF_COUNT = 0
    private static trigger BUFF_ALLOC = CreateTrigger()
    private static unit BUFF_CAS = null
    private static unit BUFF_SRC = null
    private static real BUFF_DUR = 0.0
    private static real BUFF_TOUT = 0.0
    private static integer BUFF_ARG = 0
    private unit Target
    private unit Caster
    private integer Handle
    private integer Argument
    private real Timeout
    private real Duration
    private timer T_TIMEOUT
    private timer T_DURATION
    private method operator Remaining takes nothing returns real
        return TimerGetRemaining(.T_DURATION)
    endmethod
    private method operator Elapsed takes nothing returns real
        return TimerGetElapsed(.T_DURATION)
    endmethod
    private method AtRemoval takes nothing returns nothing
        static if thistype.OnRemove.exists then
            call this.OnRemove()
        endif
        
        set .Caster = null
        set .Target = null
        call RemoveSavedInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(.T_DURATION))
        call DestroyTimer(.T_DURATION)
        set .T_DURATION = null
        call RemoveSavedInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(.T_TIMEOUT))
        call DestroyTimer(.T_TIMEOUT)
        set .T_TIMEOUT = null
        /* DeAllocated! */
        call RemoveSavedInteger(TABLE_CBUFF,BUFF_KEY,.Handle)
        
        call deallocate()
        set BUFF_COUNT = BUFF_COUNT - 1
        set TABLE_CBUFF_COUNT = TABLE_CBUFF_COUNT - 1
    endmethod
    private static method AtDuration takes nothing returns nothing
        local thistype this = LoadInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(GetExpiredTimer()))
        local boolean result = true
        static if thistype.OnDuration.exists then
            call this.OnDuration()
        endif
        call this.AtRemoval()
    endmethod
    private static method AtTimeout takes nothing returns nothing
        local thistype this = LoadInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(GetExpiredTimer()))
        local boolean result = true
        static if thistype.OnTimeout.exists then
            if GetUnitTypeId(.Target) != 0 then
                set result = this.OnTimeout()
            else
                set result = false
            endif
        else
            if GetUnitTypeId(.Target) == 0 then
                set result = false
            endif
        endif
        if not result then
            call this.AtRemoval()
            return
        endif
        if .Timeout > 0 then
            call TimerStart(.T_TIMEOUT,.Timeout,false,function thistype.AtTimeout)
        endif
    endmethod
    private static method AtAlloc takes nothing returns boolean
        local unit cas = BUFF_CAS
        local unit src = BUFF_SRC
        local real dur = BUFF_DUR
        local real tout = BUFF_TOUT
        local integer arg = BUFF_ARG
        local integer hnd = GetHandleId(src)
        local thistype this = LoadInteger(TABLE_CBUFF,BUFF_KEY,hnd)
        if this == 0 then
            set TABLE_CBUFF_COUNT = TABLE_CBUFF_COUNT + 1
            set BUFF_COUNT = BUFF_COUNT + 1
            set this = allocate()
            set .Handle = hnd
            set .Caster = cas
            set .Target = src
            set .Argument = arg
            set .Duration = dur
            set .Timeout = tout
            set .T_DURATION = CreateTimer()
            call SaveInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(.T_DURATION),this)
            set .T_TIMEOUT = CreateTimer()
            call SaveInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(.T_TIMEOUT),this)
            /* Allocated! */
            call SaveInteger(TABLE_CBUFF,BUFF_KEY,hnd,this)
            
            static if thistype.OnApply.exists then
                call this.OnApply()
            endif
            
            if .Duration > 0 then
                call TimerStart(.T_DURATION,.Duration,false,function thistype.AtDuration)
            endif
            if .Timeout > 0 then
                call TimerStart(.T_TIMEOUT,.Timeout,false,function thistype.AtTimeout)
            endif
        else
            static if thistype.OnBeforeStack.exists then
                if this.OnBeforeStack(cas,tout, dur, arg) then
                    call this.OnAfterStack(cas,tout, dur, arg)
                    if .Duration > 0 then
                        call TimerStart(.T_DURATION,.Duration,false,function thistype.AtDuration)
                    else
                        call PauseTimer(.T_DURATION)
                    endif
                    if .Timeout > 0 then
                        call TimerStart(.T_TIMEOUT,.Timeout,false,function thistype.AtTimeout)
                    else
                        call PauseTimer(.T_TIMEOUT)
                    endif
                endif
            endif
        endif
        set cas = null
        set src = null
        return false
    endmethod
    private static method Alloc takes unit cas, unit src, real dur, real tout, integer arg returns nothing
        set BUFF_CAS = cas
        set BUFF_SRC = src
        set BUFF_DUR = dur
        set BUFF_TOUT = tout
        set BUFF_ARG = arg
        call TriggerEvaluate(BUFF_ALLOC)
        set BUFF_CAS = null
        set BUFF_SRC = null
    endmethod
    static method Count takes nothing returns integer
        return BUFF_COUNT
    endmethod
    static method Exists takes unit src returns boolean
        return HaveSavedInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(src))
    endmethod
    static method Apply takes unit src, real dur, integer arg returns boolean
        if GetUnitTypeId(src) == 0 then
            return false
        endif
        call Alloc(null,src,dur,$TIMEOUT$,arg)
        return true
    endmethod
    static method Stop takes unit src returns nothing
        local thistype this
        local boolean result
        if GetUnitTypeId(src) == 0 then
            return
        endif
        set this = LoadInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(src))
        set result = true
        static if thistype.OnDuration.exists then
            call this.OnDuration()
        endif
        call this.AtRemoval()
    endmethod
    static method Dur takes unit src returns real
        local thistype this
        if GetUnitTypeId(src) == 0 then
            return 0.0
        endif
        set this = LoadInteger(TABLE_CBUFF,BUFF_KEY,GetHandleId(src))
        return TimerGetRemaining(.T_DURATION)
    endmethod
    static method ApplyEx takes unit cas, unit src, real dur, integer arg returns boolean
        if GetUnitTypeId(src) == 0 then
            return false
        endif
        call Alloc(cas,src,dur,$TIMEOUT$,arg)
        return true
    endmethod
    static method create takes nothing returns thistype
        call BJDebugMsg("<Buff>: " + create.name + " 사용 금지!")
        return 0
    endmethod
    method destroy takes nothing returns nothing
        call BJDebugMsg("<Buff>: " + destroy.name + " 사용 금지!")
    endmethod
    private static method onInit takes nothing returns nothing
        call TriggerAddCondition(BUFF_ALLOC,Condition(function thistype.AtAlloc))
        static if thistype.OnMapLoad.exists then
        call thistype.OnMapLoad()
        endif
    endmethod
    //! endtextmacro
    /********************************************************************************/