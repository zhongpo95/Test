scope HeroBandiZ
     globals
        private constant real SD = 109.00
        
        //쉐클시간
        private constant real Time = 0.60
        //스킬이펙트 시간
        private constant real Time2 = 0.20
        //스킬이펙트 시간2
        private constant real Time3 = 0.20
        //이동거리
        private constant real Dist = 450
    
        private constant real scale = 500
        private constant real distance = 200
    endglobals
        
    private struct FxEffect
        unit caster
        unit dummy
        real TargetX
        real TargetY
        real speed
        integer i
        private method OnStop takes nothing returns nothing
            set caster = null
            set dummy = null
            set i = 0
               set speed = 0
               set TargetX = 0
                set TargetY = 0
            endmethod
            //! runtextmacro 연출()
        endstruct
        
    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
       
        set fx.i = fx.i + 1
        
        if BBB == 0 then
            set BBBF = DzCreateFrameByTagName("BACKDROP", "", NarAden, "", 0)
            call DzFrameSetTexture(BBBF,"Narmaya_blue.blp",0)
            call DzFrameSetAbsolutePoint(BBBF,JN_FRAMEPOINT_CENTER,0.4,0.3)
            call DzFrameSetSize(BBBF,0.8,0.6)
            call DzFrameShow(BBBF, false)
        endif

        //반디필터
        set BBB = BBB + 1
        if BBB+29 < 10 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ (0"+I2S(BBB)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            call DzFrameSetTexture(BBBF,"war3mapImported\\BandiZ (0"+I2S(BBB+29)+").blp",0)
            call DzFrameShow(BBBF, true)
        elseif BBB+29 < 86 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ ("+I2S(BBB)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            call DzFrameSetTexture(BBBF,"war3mapImported\\BandiZ ("+I2S(BBB+29)+").blp",0)
            call DzFrameShow(BBBF, true)
        endif
        
        if BBB+29 == 31 then
            //call Sound3D(MainUnit[0],'A066')
            call Sound3D(MainUnit[0],'A067')
        elseif BBB+29 == 85 then
            call Sound3D(MainUnit[0],'A068')
        endif


        call TriggerSleepActionByTimer(0.02)


        if BBB+29 < 86 then
            call ESCAction()
        else
            call DzFrameShow(BBBF, false)
            call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "BANDI.blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            set BBB = 1
        endif


    endfunction
        
    private function Main takes nothing returns nothing
        local integer pid
        local tick t
        local SkillFx fx
        
        if GetSpellAbilityId() == 'A019' then
            set t = tick.create(0) 
            set fx = SkillFx.Create()
            set fx.caster = GetTriggerUnit()
            set fx.i = 0
            set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                
            call Sound3D(fx.caster,'A01P')
            call CooldownFIX(fx.caster,'A019',HeroSkillCD2[4])
            call DummyMagicleash(fx.caster, Time)

            call AnimationStart3(fx.caster,17, 1.00)

            set t.data = fx
            call t.start( Time2, false, function EffectFunction ) 
         endif
    endfunction

    private function ZSyncData takes nothing returns nothing
        local player p=(DzGetTriggerSyncPlayer())
        local string data=(DzGetTriggerSyncData())
        local integer pid
        local integer dataLen=StringLength(data)
        local integer valueLen
        local real x
        local real y
        local real angle
    
        set pid=GetPlayerId(p)
            
        if GetUnitAbilityLevel(MainUnit[pid],'B000') < 1 and EXGetAbilityState(EXGetUnitAbility(MainUnit[pid], HeroSkillID2[DataUnitIndex(MainUnit[pid])]), ABILITY_STATE_COOLDOWN) == 0 then
            set x=S2R(data)
            set valueLen=StringLength(R2S(x))
            set data=SubString(data,valueLen+1,dataLen)
            set dataLen=dataLen-(valueLen+1)
            set y=S2R(data)
            set pid=GetPlayerId(p)
            set angle = AngleWBP(MainUnit[pid],x,y)
            call SetUnitFacing(MainUnit[pid],angle)
            call EXSetUnitFacing(MainUnit[pid],angle)
            call IssuePointOrder( MainUnit[pid], "ambush", x, y )
        endif
            
        set p=null
    endfunction

    //! runtextmacro 이벤트_N초가_지나면_발동("B","2.0")
        local trigger t
        
        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function Main)
            
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("BandiZ"),(false))
        call TriggerAddAction(t,function ZSyncData)
    
        set t = null
    //! runtextmacro 이벤트_끝()

endscope