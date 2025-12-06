library UIBossHP initializer init requires FrameCount, DataUnit, FX
    globals
        // UI 프레임 배열 (최대 9개)
        private integer array BHPBar
        // 보스 UI 업데이트 용 임시 변수
        private unit MyBossUnit
        // 모니터링할 플레이어 ID
        private integer g_PlayerId = -1
    endglobals
        
    private struct FxEffect
        unit caster
        integer index
        integer BHPx         // 체력바 줄 수
        real BHPxV           // 한 줄당 체력량
        integer BHPxN        // 현재 체력바 개수
        real BHPxNN          // 현재 줄의 나머지 퍼센트 (0~100)
        real BHPxNNP         // 이전 퍼센트 (애니메이션용)
        integer BHPxN2       // 이전 체력바 개수
        integer BHPxL        // 마지막 자리 수 (0~9)
        integer playerId     // 플레이어 ID
        
        method OnStop takes nothing returns nothing
            set caster = null
        endmethod
        //! runtextmacro 연출()
    endstruct

    function PlayersBossBarShow takes player p, boolean state returns nothing
        if state then
            set g_PlayerId = GetPlayerId(p)
        else
            set g_PlayerId = -1
        endif
    endfunction
    /*
    function SELECTEDBOSS takes player p, unit u returns nothing
        set MyBossUnit = u
        call BOSSHPSTART(u, GetPlayerId(p))
    endfunction
    */
    private function MyBarCreate takes nothing returns nothing
        set BHPBar[0]=DzCreateFrameByTagName("BACKDROP", "frame00", DzGetGameUI(), "frame", FrameCount())
        call DzFrameSetPoint(BHPBar[0], 0, DzGetGameUI(), 6, ( 318.00 / 1280.00 ), ( 730.00 / 1280.00 ))
        call DzFrameSetSize(BHPBar[0], ( 388.00 / 1280.00 ), ( 100.00 / 1280.00 ))
        call DzFrameSetTexture(BHPBar[0], "war3mapImported\\DGXT.tga", 0)
        call DzFrameShow(BHPBar[0], false)
        set BHPBar[5]=DzCreateFrameByTagName("BACKDROP", "frame05", BHPBar[0], "frame", FrameCount())
        call DzFrameSetPoint(BHPBar[5], 0, DzGetGameUI(), 6, ( 322 / 1280.00 ), ( 705.00 / 1280.00 ))
        call DzFrameSetSize(BHPBar[5], ( 380.00 / 1280.00 ), ( 35.00 / 1280.00 ))
        set BHPBar[1]=DzCreateFrameByTagName("BACKDROP", "frame01", BHPBar[0], "frame", FrameCount())
        call DzFrameSetPoint(BHPBar[1], 3, BHPBar[5], 3, 0.00, 0.00)
        call DzFrameSetSize(BHPBar[1], ( 380.00 / 1280.00 ), ( 35.00 / 1280.00 ))
        call DzFrameSetTexture(BHPBar[1], "war3mapImported\\UIX.tga", 0)
        set BHPBar[2]=DzCreateFrameByTagName("BACKDROP", "frame02", BHPBar[1], "frame", FrameCount())
        call DzFrameSetPoint(BHPBar[2], 0, DzGetGameUI(), 6, ( 322 / 1280.00 ), ( 705.00 / 1280.00 ))
        call DzFrameSetSize(BHPBar[2], ( 380.00 / 1280.00 ), ( 35.00 / 1280.00 ))
        call DzFrameSetTexture(BHPBar[2], "war3mapImported\\ZT-[BOSS]-B0.blp", 0)
        set BHPBar[4]=DzCreateFrameByTagName("TEXT", "", BHPBar[0], "template", FrameCount())
        call DzFrameSetFont(BHPBar[4], "Fonts\\DFHeiMd.ttf", 0.011, 0)
        call DzFrameSetSize(BHPBar[4], ( 80.00 / 1280.00 ), ( 25.00 / 1280.00 ))
        call DzFrameSetPoint(BHPBar[4], 2, DzGetGameUI(), 6, ( 725.00 / 1280.00 ), ( 697.50 / 1280.00 ))
        set BHPBar[6]=DzCreateFrameByTagName("BACKDROP", "frame06", BHPBar[0], "frame", FrameCount())
        call DzFrameSetPoint(BHPBar[6], 0, DzGetGameUI(), 6, ( 361.5 / 1280.00 ), ( 668.00 / 1280.00 ))
        call DzFrameSetSize(BHPBar[6], ( 450.00 / 1280.00 ), ( 300.00 / 1280.00 ))
        call DzFrameSetTexture(BHPBar[6], "war3mapImported\\ZT-[BOSS]-B0.blp", 0)
        set BHPBar[8]=DzCreateFrameByTagName("BACKDROP", "frame08", BHPBar[0], "frame", FrameCount())
        call DzFrameSetPoint(BHPBar[8], 4, BHPBar[0], 4, 0.00, 0.00)
        call DzFrameSetSize(BHPBar[8], ( 388.00 / 1280.00 ), ( 100.00 / 1280.00 ))
        call DzFrameSetTexture(BHPBar[8], "war3mapImported\\DGXT.tga", 0)
        call DzFrameShow(BHPBar[8], true)
        set BHPBar[7]=DzCreateFrameByTagName("TEXT", "", BHPBar[0], "template", FrameCount())
        call DzFrameSetFont(BHPBar[7], "Fonts\\DFHeiMd.ttf", 0.011, 0)
        call DzFrameSetSize(BHPBar[7], ( 300.00 / 1280.00 ), ( 25.00 / 1280.00 ))
        call DzFrameSetPoint(BHPBar[7], 0, DzGetGameUI(), 6, ( 487.50 / 1280.00 ), ( 655.00 / 1280.00 ))
    endfunction

    function yaojingGN24 takes string f1, string f2, integer z1 returns string
        local integer x1 = 1
        local integer x2 = StringLength(f1)
        local integer f2Len = StringLength(f2)
        
        loop
            exitwhen x1 > x2
            if SubStringBJ(f1, x1, x1 + f2Len - 1) == f2 then
                exitwhen true
            endif
            set x1 = x1 + 1
        endloop
        
        if z1 == 1 then
            return SubStringBJ(f1, 1, x1 - 1)
        else
            return SubStringBJ(f1, x1 + f2Len, x2)
        endif
    endfunction

    //0x57D9DCA8 체력바줄수 BHPx i
    //0xEFA6E3AD 한줄당체력 BHPxV r
    //0x6729787C 체력바갯수 BHPxN i
    //0xE5B3307E 나머지퍼센트 BHPxNN r
    //0x749BAE3E 갱신체력바퍼샌트 BHPxNNP r
    
    // 프레임 표시 헬퍼 함수
    private function ShowFrames takes player p, boolean state returns nothing
        if GetLocalPlayer() == p then
            call DzFrameShow(BHPBar[0], state)
            call DzFrameShow(BHPBar[8], state)
        endif
    endfunction
    
    // 텍스처 업데이트 헬퍼 함수
    private function UpdateTexture takes player p, integer frameIndex, string texturePath returns nothing
        if GetLocalPlayer() == p then
            call DzFrameSetTexture(frameIndex, texturePath, 0)
        endif
    endfunction
    
    // 프레임 위치 업데이트 헬퍼 함수
    private function UpdateFramePosition takes player p, integer frameIndex, integer anchorPoint, integer anchorFrame, real offsetX, real offsetY returns nothing
        if GetLocalPlayer() == p then
            call DzFrameSetPoint(frameIndex, anchorPoint, anchorFrame, anchorPoint, offsetX, offsetY)
        endif
    endfunction

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
        local real r
        local real shieldPercent
        local real hpPercent
        local string texturePath
        local player p
        local boolean isLocalPlayer
        
        if not UnitAlive(fx.caster) or fx.BHPxNNP <= 0.00 then
            if not UnitAlive(fx.caster) then
                set p = Player(fx.playerId)
                if GetLocalPlayer() == p then
                    call DzFrameShow(BHPBar[0], false)
                    call DzFrameShow(BHPBar[8], false)
                endif
            endif
            call fx.Stop()
            call t.destroy()
            return
        endif
        
        set p = Player(fx.playerId)
        set isLocalPlayer = (GetLocalPlayer() == p)
        
        // 보스 이름 업데이트
        if isLocalPlayer then
            call DzFrameShow(BHPBar[0], true)
            call DzFrameSetText(BHPBar[7], GetUnitName(fx.caster))
        endif
        
        // 현재 체력바 개수 계산
        set fx.BHPxN = R2I(UnitHP[fx.index] / fx.BHPxV)
        set r = ModuloReal(UnitHP[fx.index], fx.BHPxV)
        
        // 나머지 퍼센트 계산
        if r == 0.00 then
            set fx.BHPxNN = 0.00
        else
            set fx.BHPxNN = 100.00 * r / fx.BHPxV
        endif
        
        // 최소값 보정 (1% 이상)
        if fx.BHPxNN > 0.00 and fx.BHPxNN < 1.00 then
            set fx.BHPxNN = 1.00
        endif
        
        // 마지막 자리 수 추출
        set fx.BHPxL = fx.BHPxN - (fx.BHPxN / 10) * 10
        
        // 체력바 개수 텍스트 업데이트
        if isLocalPlayer then
            call DzFrameSetText(BHPBar[4], "×" + I2S(fx.BHPxN))
        endif
        
        // 현재 체력바 텍스처 업데이트
        if isLocalPlayer then
            set texturePath = "war3mapImported\\ZT-[BOSS]-B" + I2S(fx.BHPxL) + ".blp"
            call DzFrameSetTexture(BHPBar[2], texturePath, 0)
        endif
        
        // 보호막 게이지 업데이트
        set shieldPercent = 3.00 * UnitSD[fx.index] / UnitSDMAX[fx.index] * 100 / 1280.00
        if shieldPercent < 0.001 then
            set shieldPercent = 1.00 / 1280.00
        endif
        call DzFrameSetSize(BHPBar[6], shieldPercent, 5.00 / 1280.00)
        
        // 다음 체력바 표시
        if fx.BHPxN > 0 then
            if isLocalPlayer then
                call DzFrameShow(BHPBar[5], true)
            endif
            
            if fx.BHPxL == 0 then
                set texturePath = "war3mapImported\\ZT-[BOSS]-B9.blp"
            else
                set texturePath = "war3mapImported\\ZT-[BOSS]-B" + I2S(fx.BHPxL - 1) + ".blp"
            endif
            if isLocalPlayer then
                call DzFrameSetTexture(BHPBar[5], texturePath, 0)
            endif
        else
            if isLocalPlayer then
                call DzFrameShow(BHPBar[5], false)
            endif
        endif
        
        // 체력바 줄 수 변경 감지
        if fx.BHPxN2 > fx.BHPxN then
            // 한 줄 이상 깎임 - 새로운 애니메이션 시작
            set fx.BHPxNNP = 100.00
            if isLocalPlayer then
                call DzFrameSetPoint(BHPBar[1], 5, BHPBar[5], 3, 0.277 * fx.BHPxNNP * 0.01, 0)
            endif
        elseif fx.BHPxN2 < fx.BHPxN then
            // 회복됨 - 즉시 업데이트
            set fx.BHPxNNP = fx.BHPxNN
            if isLocalPlayer then
                call DzFrameSetPoint(BHPBar[1], 5, BHPBar[5], 3, 0.277 * fx.BHPxNN * 0.01, 0)
            endif
        endif
        
        set fx.BHPxN2 = fx.BHPxN
        
        // 나머지가 없으면 100으로 설정
        if fx.BHPxNN == 0.00 then
            set fx.BHPxNN = 100.00
        endif
        
        // 부드러운 감소 애니메이션
        if fx.BHPxNNP > fx.BHPxNN then
            set fx.BHPxNNP = fx.BHPxNNP - 1.00
            if isLocalPlayer then
                call DzFrameSetPoint(BHPBar[1], 5, BHPBar[5], 3, 0.277 * fx.BHPxNNP * 0.01, 0)
            endif
        endif
        
        // 현재 체력바 길이 조정
        if isLocalPlayer then
            call DzFrameSetSize(BHPBar[2], 3.8 * fx.BHPxNN / 1280.00, 35.00 / 1280.00)
            call DzFrameShow(BHPBar[8], true)
        endif
        
        // HP 퍼센트 기반 게이지
        set hpPercent = 3.00 * UnitHP[fx.index] / UnitHPMAX[fx.index] * 100 / 1280.00
        if hpPercent < 0.001 then
            set hpPercent = 1.00 / 1280.00
        endif
        call DzFrameSetSize(BHPBar[6], hpPercent, 5.00 / 1280.00)
    endfunction
    
    function BOSSHPSTART takes unit u, integer id returns nothing
        local tick t
        local FxEffect fx
        local integer index = GetUnitIndex(u)
        
        if index == 0 then
            call VJDebugMsg("BOSSHPSTART 인덱싱 오류")
            return
        endif
        
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = u
        set fx.index = index
        set fx.BHPx = UnitSetHPx[DataUnitIndex(u)]
        set fx.BHPxV = I2R(R2I(UnitHPMAX[index] / fx.BHPx))
        set fx.BHPxN = fx.BHPx
        set fx.BHPxN2 = fx.BHPx
        set fx.BHPxNN = 100
        set fx.BHPxNNP = 100
        set fx.BHPxL = 0
        set fx.playerId = id
        set t.data = fx
        
        call t.start(0.03, true, function EffectFunction)
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction( t, function MyBarCreate )
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        set t = null
    endfunction
endlibrary