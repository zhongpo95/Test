call DzTriggerRegisterKeyEventByCode(null,84,1,false,function BNu)
T키 이벤트 등록
call DzFrameSetUpdateCallbackByCode(function BNv)
마우스 좌표 감정표현 등록 및 마우스 최근 좌표 위치 등록 
call DzTriggerRegisterKeyEventByCode(null,84,0,false,function BNw)
최근 좌표 위치에 따른 감정표현 재생

function BNu takes nothing returns nothing
    if not LoadBoolean(QL,Ui[A][B],C) then
        call SavePlayerHandle(Ui,A,D,DzGetTriggerKeyPlayer())
        set Ui[A][ExpressionPicID+1] = LoadStr(QL,Ui[A][D],ExpressionPicID_UP
        set Ui[A][ExpressionPicID+2] = LoadStr(QL,Ui[A][D],ExpressionPicID_LEFT
        set Ui[A][ExpressionPicID+3] = LoadStr(QL,Ui[A][D],ExpressionPicID_DOWN
        set Ui[A][ExpressionPicID+4] = LoadStr(QL,Ui[A][D],xpressionPicID_RIGHT
        set Ui[A][E] = I2R(DzGetMouseX()-DzGetWindowX())/(I2R(DzGetWindowWidth())/.8)+0)
        set Ui[A][F] = I2R(DzGetWindowHeight()+DzGetWindowY()-DzGetMouseY())/(I2R(DzGetWindowHeight())/.6)+0)
        set QL[Ui[A][B]][E] = Ui[A][E]
        set QL[Ui[A][B]][F] = Ui[A][F]
        set QL[Ui[A][B]][C] = true
        call DzFrameClearAllPoints(Ui[A][B])
        call DzFrameSetAbsolutePoint(Ui[A][B],4,Ui[A][E],Ui[A][F])
        call DzFrameSetTexture(YK[1],"Expression_Up.blp",0)
        call DzFrameSetTexture(YK[2],"Expression_Left.blp",0)
        call DzFrameSetTexture(YK[3],"Expression_Down.blp",0)
        call DzFrameSetTexture(YK[4],"Expression_Right.blp",0)
        call DzFrameSetTexture(YK[5],LoadStr(Ui[A][ExpressionPicID]+QL[Ui[A][D]][G]),0)
        call DzFrameSetTexture(YK[6],LoadStr(Ui[A][ExpressionPicID]+QL[Ui[A][D]][H]),0)
        call DzFrameSetTexture(YK[7],LoadStr(Ui[A][ExpressionPicID+QL[Ui[A][D]][I]),0)
        call DzFrameSetTexture(YK[8],LoadStr(Ui[A][ExpressionPicID+QL[Ui[A][D]][J]),0)
        call DzFrameShow(Ui[A][B],true)
    endif
endfunction





    function BNv takes nothing returns nothing
    if LoadBoolean(QL,LoadInteger(UiKB),C) then
        set UiKE = I2R(DzGetMouseX()-DzGetWindowX())/(I2R(DzGetWindowWidth())/.8)+0
        set UiKF = I2R(DzGetWindowHeight()+DzGetWindowY()-DzGetMouseY())/(I2R(DzGetWindowHeight())/.6)+0
        if RAbsBJ(X,NowX)>=.01 or RAbsBJ(Y,NowY)>=.01 then
            set UiKL,Atan2BJ(LoadReal(UiKF)-LoadReal(QL,LoadInteger(UiKB),F),LoadReal(UiKE)-LoadReal(QL,LoadInteger(UiKB),E)))
            set UiKL,ModuloReal(LoadReal(UiKL)+315.,360.))
            set UiKM,R2I(LoadReal(UiKL)/90.)+1)
        else
            set UiKM = 0
        endif
        if LoadInteger(QL,LoadInteger(Ui,K,$E3FCDFB0),M)!=LoadInteger(UiKM) then
            set QL,LoadInteger(UiKB),M,LoadInteger(UiKM))
            call DzFrameSetTexture(YK[1],"Expression_Up.blp",0)
            call DzFrameSetTexture(YK[2],"Expression_Left.blp",0)
            call DzFrameSetTexture(YK[3],"Expression_Down.blp",0)
            call DzFrameSetTexture(YK[4],"Expression_Right.blp",0)
            if LoadInteger(UiKM)!=0 then
                call DzFrameSetTexture(YK[LoadInteger(UiKM)],LoadStr(UiKExpressionPicID+LoadInteger(UiKM)),0)
            endif
        endif
    endif
endfunction

    function BNw takes nothing returns nothing
        call DzFrameShow(LoadInteger(Ui,N,B),false)
        call SaveBoolean(QL,LoadInteger(Ui,N,B),C,false)
        call SavePlayerHandle(Ui,N,D,DzGetTriggerKeyPlayer())
        set Ui,N,M,LoadInteger(QL,LoadInteger(Ui,N,B),M))
        if LoadInteger(Ui,N,M)!=0 then
            if LoadInteger(Ui,N,M)==1 then
                set Ui,N,M,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,N,D)),G))
            endif
            if LoadInteger(Ui,N,M)==2 then
                set Ui,N,M,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,N,D)),H))
            endif
            if LoadInteger(Ui,N,M)==3 then
                set Ui,N,M,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,N,D)),I))
            endif
            if LoadInteger(Ui,N,M)==4 then
                set Ui,N,M,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,N,D)),J))
            endif
            set Ui,N,O,I2S(GetConvertedPlayerId(LoadPlayerHandle(Ui,N,D)))+I2S(LoadInteger(Ui,N,M)))
            call DzSyncData("Img",LoadStr(Ui,N,O))
        endif
    endfunction

    function BNx takes nothing returns nothing
    if LoadReal(Ui,GetHandleId(GetExpiredTimer()),P)>0. and LoadTimerHandle(QL,GetHandleId(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),S)),T)==GetExpiredTimer() then
    set Ui,GetHandleId(GetExpiredTimer()),P,LoadReal(Ui,GetHandleId(GetExpiredTimer()),P)-.03)
    call MoveLocation(LoadLocationHandle(Ui,GetHandleId(GetExpiredTimer()),U),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),S)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),S)))
    call EXSetEffectXY(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),Q),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),S)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),S)))
    call EXSetEffectZ(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),Q),GetLocationZ(LoadLocationHandle(Ui,GetHandleId(GetExpiredTimer()),U))+(GetUnitFlyHeight(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),S))+256.))
    else
    if LoadTimerHandle(QL,GetHandleId(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),S)),T)!=GetExpiredTimer() then
    call EXSetEffectZ(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),Q),9999.)
    endif
    call DestroyEffect(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),Q))
    call BIr(GetExpiredTimer())
    call FlushChildHashtable(Ui,GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    endif
    endfunction

    function BNy takes nothing returns nothing
    local timer X3
    set Ui,GetHandleId(GetTriggeringTrigger()),O,DzGetTriggerSyncData())
    call SavePlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),D,ConvertedPlayer(S2I(SubStringBJ(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),O),1,1))))
    set Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+1,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),D)),ExpressionPic_UP))
    set Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+2,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),D)),ExpressionPic_LEFT))
    set Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+3,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),D)),ExpressionPic_DOWN))
    set Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+4,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),D)),ExpressionPic_RIGHT))
    set Ui,GetHandleId(GetTriggeringTrigger()),M,S2I(SubStringBJ(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),O),2,StringLength(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),O)))))
    call SaveUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S,Xb[GetConvertedPlayerId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),D))])
    call SaveTimerHandle(Ui,GetHandleId(GetTriggeringTrigger()),R,CreateTimer())
    call SaveTimerHandle(QL,GetHandleId(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S)),T,LoadTimerHandle(Ui,GetHandleId(GetTriggeringTrigger()),R))
    call MoveLocation(LoadLocationHandle(Ui,GetHandleId(GetTriggeringTrigger()),U),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S)))
    call SaveEffectHandle(Ui,GetHandleId(GetTriggeringTrigger()),Q,AddSpecialEffect(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+LoadInteger(Ui,GetHandleId(GetTriggeringTrigger()),M)),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S))))
    call EXSetEffectZ(LoadEffectHandle(Ui,GetHandleId(GetTriggeringTrigger()),Q),GetLocationZ(LoadLocationHandle(Ui,GetHandleId(GetTriggeringTrigger()),U))+(GetUnitFlyHeight(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S))+256.))
    set X3=LoadTimerHandle(Ui,GetHandleId(GetTriggeringTrigger()),R)
    set Ui,GetHandleId(X3),P,5.)
    call SaveEffectHandle(Ui,GetHandleId(X3),Q,LoadEffectHandle(Ui,GetHandleId(GetTriggeringTrigger()),Q))
    call SaveLocationHandle(Ui,GetHandleId(X3),U,LoadLocationHandle(Ui,GetHandleId(GetTriggeringTrigger()),U))
    call SaveUnitHandle(Ui,GetHandleId(X3),S,LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),S))
    call TimerStart(X3,.03,true,function BNx)
    call BIp(X3,.03,true," function Trig_bqb_004Func035Func016T","bqb-004")
    set X3=null
    endfunction

    function BIp takes timer R7,real X6,boolean X7,string X8,string X9 returns nothing
        call SaveTimerHandle(i,X4,0,R7)
        set i,GetHandleId(R7),0,X4)
        set i,GetHandleId(R7),1,X6)
        call SaveBoolean(i,GetHandleId(R7),2,X7)
        set i,GetHandleId(R7),3,X8)
        set i,GetHandleId(R7),4,X9)
        set X4=X4+1
    endfunction

    function BNz takes nothing returns nothing
        local integer Xa
        local integer YJ
        local trigger Xz
        local integer XZ=LoadInteger(Ui,GetHandleId(GetTriggeringTrigger()),V)
        set XZ=XZ+3
        set Ui,GetHandleId(GetTriggeringTrigger()),V,XZ)
        set Ui,GetHandleId(GetTriggeringTrigger()),$ECE825E7,XZ)
        set QL,GetHandleId(GetLocalPlayer()),G,1)
        set QL,GetHandleId(GetLocalPlayer()),H,2)
        set QL,GetHandleId(GetLocalPlayer()),I,3)
        set QL,GetHandleId(GetLocalPlayer()),J,4)
        set Xa=1
        loop
            exitwhen Xa>5
            set QL,GetHandleId(ConvertedPlayer(Xa)),G,1)
            set QL,GetHandleId(ConvertedPlayer(Xa)),H,2)
            set QL,GetHandleId(ConvertedPlayer(Xa)),I,3)
            set QL,GetHandleId(ConvertedPlayer(Xa)),J,4)
            set Xa=Xa+1
        endloop
        set Ui,GetHandleId(GetTriggeringTrigger())*XZ,B,DzCreateFrameByTagName("BACKDROP","name",DzGetGameUI(),"template", FrameCount()))
        call DzFrameSetTexture(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),"Expression_Point.blp",0)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),.065,.065)
        call DzFrameShow(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),false)
        set YJ=1
        loop
            exitwhen YJ>4
            set Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+YJ,DzCreateFrameByTagName("BACKDROP","name",LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),"template", FrameCount()))
            set YK[YJ]=LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+YJ)
            set YJ=YJ+1
        endloop
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+1),7,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),1,0,-.0325)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+1),.14,.07)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+2),5,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),3,.0325,0)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+2),.07,.14)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+3),1,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),7,0,.0325)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+3),.14,.07)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+4),3,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),5,-.0325,0.)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+4),.07,.14)
        set YJ=5
        loop
            exitwhen YJ>8
            set Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+YJ,DzCreateFrameByTagName("BACKDROP","name",LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),"template", FrameCount()))
            call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+YJ),.05,.05)
            set YK[YJ]=LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+YJ)
            set YJ=YJ+1
        endloop
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+5),7,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),1,0,-.015)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+6),5,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),3,.015,0)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+7),1,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),7,0,.015)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,X+8),3,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B),5,-.015,0.)
        set Ui[A][B],LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B))
        call SavePlayerHandle(Ui[A][D],LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,D))
        set Ui[A]E,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,E))
        set Ui[A]F,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,F))
        if GetLocalPlayer()==GetLocalPlayer() then
            call DzTriggerRegisterKeyEventByCode(null,84,1,false,function BNu)
        endif
        set UiKExpressionPicID+1,TransText("Expression_Up_Select.blp"))
        set UiKExpressionPicID+2,TransText("Expression_Left_Select.blp"))
        set UiKExpressionPicID+3,TransText("Expression_Down_Select.blp"))
        set UiKExpressionPicID+4,TransText("Expression_Right_Select.blp"))
        set UiKM,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,M))
        set UiKB,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B))
        set Ui,K,$E3FCDFB0,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$E3FCDFB0))
        set UiKL,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,L))
        set UiKE,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,E))
        set UiKF,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,F))
        if GetLocalPlayer()==GetLocalPlayer() then
            call DzFrameSetUpdateCallbackByCode(function BNv)
        endif
        set Ui,N,M,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,M))
        set Ui,N,B,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,B))
        call SavePlayerHandle(Ui,N,D,LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,D))
        set Ui,N,O,LoadStr(Ui,GetHandleId(GetTriggeringTrigger())*XZ,O))
        if GetLocalPlayer()==GetLocalPlayer() then
            call DzTriggerRegisterKeyEventByCode(null,84,0,false,function BNw)
        endif
        set Xz=CreateTrigger()
        call SaveLocationHandle(Ui,GetHandleId(Xz),U,Location(0.,0.))
        call SaveEffectHandle(Ui,GetHandleId(Xz),Q,LoadEffectHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,Q))
        set Ui,GetHandleId(Xz),M,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,M))
        call SavePlayerHandle(Ui,GetHandleId(Xz),D,LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,D))
        set Ui,GetHandleId(Xz),O,LoadStr(Ui,GetHandleId(GetTriggeringTrigger())*XZ,O))
        call SaveTimerHandle(Ui,GetHandleId(Xz),R,LoadTimerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,R))
        call SaveUnitHandle(Ui,GetHandleId(Xz),S,LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,S))
        call DzTriggerRegisterSyncData(Xz,"Img",false)
        call TriggerAddCondition(Xz,Condition(function BNy))
        call FlushChildHashtable(Ui,GetHandleId(GetTriggeringTrigger())*XZ)
        set Xz=null
    endfunction

    function BN0 takes nothing returns nothing
    set YI=CreateTrigger()
    call TriggerRegisterTimerEventSingle(YI,0.)
    call TriggerAddAction(YI,function BNz)
    endfunction