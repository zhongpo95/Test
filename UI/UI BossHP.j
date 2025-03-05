library UIBossHP initializer init requires FrameCount, DataUnit
    globals
        private integer BHPBarBorder
        private integer BSDBarBorder
        private integer array BHPBar
        private integer BSDBar
        private integer BHPTextFrame
        private integer BSDTextFrame
        private unit MyBossUnit
        private real BossHP
        private real BossSD
        private boolean array BHPxVshow
    endglobals
        
    private struct FxEffect
        unit caster
        integer index
        integer BHPx //체력바줄수 BHPx i
        real BHPxV //한줄당체력 BHPxV r
        integer BHPxN //체력바갯수 BHPxN i
        real BHPxNN //나머지퍼센트 BHPxNN r
        real BHPxNNP //갱신체력바퍼샌트
        integer BHPxN2
        integer BHPxL
        integer id //플레이어 아이디
        
        method OnStop takes nothing returns nothing
            set caster = null
            set index = 0
            set BHPx = 0
            set BHPxV = 0
            set BHPxN = 0
            set BHPxNN = 0
            set BHPxNNP = 0
            set BHPxN2 = 0
            set BHPxL = 0
            set id = 0
        endmethod
        //! runtextmacro 연출()
    endstruct

    function PlayersBossBarShow takes player p , boolean state returns nothing
    endfunction
    
    function SELECTEDBOSS takes player p, unit u returns nothing
    endfunction

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

    function yaojingGN24 takes string f1,string f2,integer z1 returns string
        local integer x1= 1
        local integer x2= StringLength(f1)
        loop
            exitwhen x1 > x2
            if ( ( SubStringBJ(f1, x1, ( ( x1 - 1 ) + StringLength(f2) )) == f2 ) ) then
                exitwhen true
            endif
            set x1=x1 + 1
        endloop
        if z1 == 1 then
         return SubStringBJ(f1, 1, ( x1 - 1 ))
        else
         return SubStringBJ(f1, ( x1 + StringLength(f2) ), x2)
        endif
        
    endfunction

    //0x57D9DCA8 체력바줄수 BHPx i
    //0xEFA6E3AD 한줄당체력 BHPxV r
    //0x6729787C 체력바갯수 BHPxN i
    //0xE5B3307E 나머지퍼센트 BHPxNN r
    //0x749BAE3E 갱신체력바퍼샌트 BHPxNNP r

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local FxEffect fx = t.data
        local real r
        
        if  UnitAlive(fx.caster) and (fx.BHPxNNP > 0.00 ) then
            if GetLocalPlayer() == Player(fx.id) then
            call DzFrameShow(BHPBar[0], true)
            endif
            //보스이름
            if GetLocalPlayer() == Player(fx.id) then
            call DzFrameSetText( BHPBar[7], GetUnitName(fx.caster) )
            endif
            set fx.BHPxN = R2I( UnitHP[fx.index] / fx.BHPxV )
            set r = ModuloReal( UnitHP[fx.index], fx.BHPxV )
            if r == 0 then
                set fx.BHPxNN = 0
            else
                set fx.BHPxNN = 100 / (fx.BHPxV / r)
            endif
            
            //나머지보정
            if 1.00 > fx.BHPxNN and fx.BHPxNN > 0 then
                set fx.BHPxNN = 1.00
            endif
            
            //체력바 갯수
            if GetLocalPlayer() == Player(fx.id) then
            call DzFrameSetText(BHPBar[4], ( "×" + I2S(fx.BHPxN) ))
            endif
            
            //체력바 갯수 마지막자리 표시
            set fx.BHPxL = S2I( SubString( I2S(fx.BHPxN), StringLength(I2S(fx.BHPxN)) - 1, StringLength(I2S(fx.BHPxN)) ) )
            
            //지금체력바
            if GetLocalPlayer() == Player(fx.id) then
            call DzFrameSetTexture(BHPBar[2], ( ( "war3mapImported\\ZT-[BOSS]-B" ) + ( I2S(fx.BHPxL) ) + ( ".blp" ) ), 0)
            endif
            
            //빨간체력바 쉴드게이지
            if ((3.00 * (UnitSD[fx.index] / UnitSDMAX[fx.index]) * 100) / 1280.00) == 0 then
                if GetLocalPlayer() == Player(fx.id) then
                call DzFrameSetSize(BHPBar[6],  (1.00) / 1280.00 , 5.00 / 1280.00 )
                endif
            else
                if GetLocalPlayer() == Player(fx.id) then
                call DzFrameSetSize(BHPBar[6],  (3.00 * (UnitSD[fx.index] / UnitSDMAX[fx.index]) * 100) / 1280.00 , 5.00 / 1280.00 )
                endif
            endif
        
            //체력바 갯수가 0개
            if fx.BHPxN > 0  then
                //5보이게
                if GetLocalPlayer() == Player(fx.id) then
                call DzFrameShow(BHPBar[5], true)
                endif
                //5 다음체력바 설정
                if fx.BHPxL == 0 then
                    if GetLocalPlayer() == Player(fx.id) then
                    call DzFrameSetTexture(BHPBar[5], ( "war3mapImported\\ZT-[BOSS]-B" ) + I2S( 9 ) + ( ".blp" ), 0)
                    endif
                else
                    if GetLocalPlayer() == Player(fx.id) then
                    call DzFrameSetTexture(BHPBar[5], ( "war3mapImported\\ZT-[BOSS]-B" ) + I2S( fx.BHPxL - 1 ) + ( ".blp" ), 0)
                    endif
                endif
            else
                //5안보이게
                if GetLocalPlayer() == Player(fx.id) then
                call DzFrameShow(BHPBar[5], false)
                endif
            endif
            
            //보스의 체력바갯수가 , 갱신된 체력바갯수보다 많음 = 1줄이상 깎았음
            if fx.BHPxN2 > fx.BHPxN then
                //갱신체력바퍼샌트
                set fx.BHPxNNP = 100.00
                if GetLocalPlayer() == Player(fx.id) then
                call DzFrameSetPoint(BHPBar[1], 5, BHPBar[5], 3, 0.277 * (fx.BHPxNNP * ( 0.01 )), 0)
                endif
            else
            endif
            
            if GetLocalPlayer() == Player(fx.id) then
            call DzFrameShow(BHPBar[0], true)
            call DzFrameShow(BHPBar[8], true)
            endif
            
            //보스의 체력바갯수가 , 갱신된 체력바갯수보다 많음 = ??회복된건가??
            if fx.BHPxN2 < fx.BHPxN then
                if GetLocalPlayer() == Player(fx.id) then
                call DzFrameSetPoint(BHPBar[1], 5, BHPBar[5], 3, 0.277 * (fx.BHPxNN * ( 0.01 )), 0)
                endif
                set fx.BHPxNNP = fx.BHPxNN
            else
            endif
            
            //보스의 체력바갯수 갱신
            set fx.BHPxN2 = fx.BHPxN
            
            //나머지가 없음 = 한줄을 다깎음 0=100
            if 0.00 == fx.BHPxNN then
                set fx.BHPxNN = 100.00
            endif
                
            //보스의 갱신되기전 체력바의 퍼센트(현재체력바퍼센트) > 나머지퍼센트(현재체력바퍼센트)  =  피가까였음
            //0.03초마다 -1로 피까임 표시
            if fx.BHPxNNP > fx.BHPxNN then
                //보스의 갱신되기전 체력바의 퍼센트(현재체력바퍼센트) - 1
                set fx.BHPxNNP = fx.BHPxNNP - 1.00
                if GetLocalPlayer() == Player(fx.id) then
                    call DzFrameSetPoint(BHPBar[1], 5, BHPBar[5], 3, 0.277 * (fx.BHPxNNP * ( 0.01 )), 0)
                endif
            else
            endif
            //지금체력바 길이조정
            if GetLocalPlayer() == Player(fx.id) then
                call DzFrameSetSize(BHPBar[2], ( 3.8 * fx.BHPxNN ) / 1280.00, 35.00 / 1280.00 )
            endif
            
            
            //빨간체력바 쉴드게이지
            //if ((3.00 * (UnitSD[fx.index] / UnitSDMAX[fx.index]) * 100) / 1280.00) == 0 then
                //call DzFrameSetSize(BHPBar[6],  (1.00) / 1280.00 , 5.00 / 1280.00 )
            //else
                //call DzFrameSetSize(BHPBar[6],  (3.00 * (UnitSD[fx.index] / UnitSDMAX[fx.index]) * 100) / 1280.00 , 5.00 / 1280.00 )
            //endif
            
        else
            //뒤지면 UI숨김
            if UnitAlive(fx.caster) == false then
                if GetLocalPlayer() == Player(fx.id) then
                call DzFrameShow(BHPBar[0], false)
                call DzFrameShow(BHPBar[8], false)
                endif
                call fx.Stop()
                call t.destroy()
            else
            endif
        endif
    endfunction
    
    function BOSSHPSTART takes unit u, integer id returns nothing
        local tick t
        local FxEffect fx
        local integer Index = DataUnitIndex(u)
        
        set t = tick.create(0)
        set fx = FxEffect.Create()
        set fx.caster = u
        set fx.index = GetUnitIndex(u)
        set fx.BHPx = UnitSetHPx[Index]
        set fx.BHPxV = I2R(R2I(UnitHPMAX[fx.index]/fx.BHPx))
        set fx.BHPxN = fx.BHPx
        set fx.BHPxN2 = fx.BHPxN
        set fx.BHPxNN = 100
        set fx.BHPxNNP = 100
        set fx.BHPxL = 0
        set t.data = fx
        set fx.id = id
        if fx.index != 0 then
            call t.start( 0.03, true, function EffectFunction )
        else
            call VJDebugMsg("이 메세지가 보이면 BOSSHPSTART 인덱싱 오류")
        endif
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction( t, function MyBarCreate )
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        set t = null
    endfunction
endlibrary