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
        
    private struct SkillFx
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
        local SkillFx fx = t.data
       
        //반디필터
        set fx.i = fx.i + 1
        if fx.i+29 < 10 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ (0"+I2S(fx.i)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            if GetLocalPlayer() == GetOwningPlayer(fx.caster)  then
                call DzFrameSetTexture(BanAden,"war3mapImported\\BandiZ (0"+I2S(fx.i+29)+").blp",0)
                call DzFrameShow(BanAden, true)
            endif
        elseif fx.i+29 < 86 then
            //call CinematicFilter2(GetTriggerPlayer(), BLEND_MODE_BLEND , "war3mapImported\\BandiZ ("+I2S(fx.i)+").blp" , 100, 100, 100, 100, 100, 100, 100, 25)
            if GetLocalPlayer() == GetOwningPlayer(fx.caster)  then
                call DzFrameSetTexture(BanAden,"war3mapImported\\BandiZ ("+I2S(fx.i+29)+").blp",0)
                call DzFrameShow(BanAden, true)
            endif
        endif
        
        if fx.i+29 == 31 then
            //call Sound3D(MainUnit[0],'A066')
            call Sound3D(MainUnit[0],'A067')
        elseif fx.i+29 == 85 then
            call Sound3D(MainUnit[0],'A068')
        endif


        if fx.i+29 < 86 then
            call t.start( 0.02, false, function EffectFunction ) 
        else
            call DzFrameShow(BanAden, false)
        endif


    endfunction
        
    private function Main takes nothing returns nothing
        local integer pid
        local tick t
        local SkillFx fx
        
        if GetSpellAbilityId() == 'A06M' then
            set t = tick.create(0) 
            set fx = SkillFx.Create()
            set fx.caster = GetTriggerUnit()
            set fx.i = 0
            set pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                
            call Sound3D(fx.caster,'A01P')
            call CooldownFIX(fx.caster,'A06M', 5.0)
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
            call IssuePointOrder( MainUnit[pid], "autodispel", x, y )
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

    library HeroBandiZ2

    globals
        integer array BanBisul
        real zchecker = 0
    endglobals

    function BanBisulPlus takes integer pid, integer i returns nothing
        loop
            if BanBisul[pid] == 5 then
                set BanBisul[pid] = 0
            endif
        exitwhen i <= 0
            if GetLocalPlayer() == Player(pid) then
                if BanBisul[pid] == 0 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden1.blp",0)
                    call DzFrameSetAbsolutePoint(BanAdens2[0],JN_FRAMEPOINT_BOTTOMLEFT,0.374,0.040)
                    call BJDebugMsg(R2S(zchecker))
                    call DzFrameSetModel(BanAdens2[0], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 1 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden2.blp",0)
                    call DzFrameSetAbsolutePoint(BanAdens2[1],JN_FRAMEPOINT_BOTTOMLEFT,0.379,0.048)
                    call BJDebugMsg(R2S(zchecker))
                    call DzFrameSetModel(BanAdens2[1], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 2 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden3.blp",0)
                    call DzFrameSetAbsolutePoint(BanAdens2[2],JN_FRAMEPOINT_BOTTOMLEFT,0.387,0.055)
                    call BJDebugMsg(R2S(zchecker))
                    call DzFrameSetModel(BanAdens2[2], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 3 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden4.blp",0)
                    call DzFrameSetAbsolutePoint(BanAdens2[3],JN_FRAMEPOINT_BOTTOMLEFT,0.396,0.060)
                    call BJDebugMsg(R2S(zchecker))
                    call DzFrameSetModel(BanAdens2[3], "Bandi_Aden.mdx", 0, 0)
                elseif BanBisul[pid] == 4 then
                    call DzFrameSetTexture(BanAdens[0],"Bandi_Aden5.blp",0)
                    call DzFrameSetAbsolutePoint(BanAdens2[4],JN_FRAMEPOINT_BOTTOMLEFT,0.406,0.060)
                    call BJDebugMsg(R2S(zchecker))
                    call DzFrameSetModel(BanAdens2[4], "Bandi_Aden.mdx", 0, 0)
                endif
            endif
    
            if BanBisul[pid] == 5 then
                set BanBisul[pid] = 4
            endif
    
            set i = i - 1
            set BanBisul[pid] = BanBisul[pid] + 1
        endloop
    endfunction
    
    function BanBisulUse takes integer pid, boolean b returns integer
        if BanBisul[pid] == 0 then
            set BanBisul[pid] = 0
            return 0
        elseif BanBisul[pid] == 1 then
            set BanBisul[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(BanAdens[0], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 1
        elseif BanBisul[pid] == 2 then
            set BanBisul[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(BanAdens[0], false)
                call DzFrameShow(BanAdens[1], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 2
        elseif BanBisul[pid] == 3 then
            set BanBisul[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(BanAdens[0], false)
                call DzFrameShow(BanAdens[1], false)
                call DzFrameShow(BanAdens[2], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 3
        elseif BanBisul[pid] == 4 then
            set BanBisul[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(BanAdens[0], false)
                call DzFrameShow(BanAdens[1], false)
                call DzFrameShow(BanAdens[2], false)
                call DzFrameShow(BanAdens[3], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 4
        elseif BanBisul[pid] == 5 then
            set BanBisul[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(BanAdens[0], false)
                call DzFrameShow(BanAdens[1], false)
                call DzFrameShow(BanAdens[2], false)
                call DzFrameShow(BanAdens[3], false)
                call DzFrameShow(BanAdens[4], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 5
        elseif BanBisul[pid] == 6 then
            set BanBisul[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(BanAdens[0], false)
                call DzFrameShow(BanAdens[1], false)
                call DzFrameShow(BanAdens[2], false)
                call DzFrameShow(BanAdens[3], false)
                call DzFrameShow(BanAdens[4], false)
                call DzFrameShow(BanAdens[5], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[5], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(BanAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(BanAdens2[5], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 6
        endif
        
        return 0
    endfunction


endlibrary