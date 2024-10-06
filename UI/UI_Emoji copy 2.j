call DzTriggerRegisterKeyEventByCode(null,84,1,false,function BNu)
T키 이벤트 등록
call DzFrameSetUpdateCallbackByCode(function BNv)
마우스 좌표 감정표현 등록 및 마우스 최근 좌표 위치 등록 
call DzTriggerRegisterKeyEventByCode(null,84,0,false,function BNw)
최근 좌표 위치에 따른 감정표현 재생

function BNu takes nothing returns nothing
    if not LoadBoolean(QL,LoadInteger(Ui,$8A6FA691,$2A5D9A31),$BD4989EA) then
        call SavePlayerHandle(Ui,$8A6FA691,$A59BB4C6,DzGetTriggerKeyPlayer())
        call SaveStr(Ui,$8A6FA691,ExpressionPicID+1,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)),ExpressionPicID_UP))
        call SaveStr(Ui,$8A6FA691,ExpressionPicID+2,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)),ExpressionPicID_LEFT))
        call SaveStr(Ui,$8A6FA691,ExpressionPicID+3,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)),ExpressionPicID_DOWN))
        call SaveStr(Ui, $8A6FA691, ExpressionPicID+4, LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)), ExpressionPicID_RIGHT))
        call SaveReal(Ui, $8A6FA691, $A99320FA, I2R(DzGetMouseX()-DzGetWindowX())/(I2R(DzGetWindowWidth())/.8)+0)
        call SaveReal(Ui,$8A6FA691,$FDF65382,I2R(DzGetWindowHeight()+DzGetWindowY()-DzGetMouseY())/(I2R(DzGetWindowHeight())/.6)+0)
        call SaveReal(QL,LoadInteger(Ui,$8A6FA691,$2A5D9A31),$A99320FA,LoadReal(Ui,$8A6FA691,$A99320FA))
        call SaveReal(QL,LoadInteger(Ui,$8A6FA691,$2A5D9A31),$FDF65382,LoadReal(Ui,$8A6FA691,$FDF65382))
        call SaveBoolean(QL,LoadInteger(Ui,$8A6FA691,$2A5D9A31),$BD4989EA,true)
        call DzFrameClearAllPoints(LoadInteger(Ui,$8A6FA691,$2A5D9A31))
        call DzFrameSetAbsolutePoint(LoadInteger(Ui,$8A6FA691,$2A5D9A31),4,LoadReal(Ui,$8A6FA691,$A99320FA),LoadReal(Ui,$8A6FA691,$FDF65382))
        call DzFrameSetTexture(YK[1],"Expression_Up.blp",0)
        call DzFrameSetTexture(YK[2],"Expression_Left.blp",0)
        call DzFrameSetTexture(YK[3],"Expression_Down.blp",0)
        call DzFrameSetTexture(YK[4],"Expression_Right.blp",0)
        call DzFrameSetTexture(YK[5],LoadStr(Ui,$8A6FA691,ExpressionPicID+LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)),$93019576)),0)
        call DzFrameSetTexture(YK[6],LoadStr(Ui,$8A6FA691,ExpressionPicID+LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)),$1A25C950)),0)
        call DzFrameSetTexture(YK[7],LoadStr(Ui,$8A6FA691,ExpressionPicID+LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)),$73B6285E)),0)
        call DzFrameSetTexture(YK[8],LoadStr(Ui,$8A6FA691,ExpressionPicID+LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$8A6FA691,$A59BB4C6)),$DE33BF0F)),0)
        call DzFrameShow(LoadInteger(Ui,$8A6FA691,$2A5D9A31),true)
    endif
endfunction

    function BNv takes nothing returns nothing
    if LoadBoolean(QL,LoadInteger(Ui,$CE400D0C,$2A5D9A31),$BD4989EA) then
        call SaveReal(Ui,$CE400D0C,$A99320FA,I2R(DzGetMouseX()-DzGetWindowX())/(I2R(DzGetWindowWidth())/.8)+0)
        call SaveReal(Ui,$CE400D0C,$FDF65382,I2R(DzGetWindowHeight()+DzGetWindowY()-DzGetMouseY())/(I2R(DzGetWindowHeight())/.6)+0)
        if RAbsBJ(LoadReal(Ui,$CE400D0C,$A99320FA)-LoadReal(QL,LoadInteger(Ui,$CE400D0C,$2A5D9A31),$A99320FA))>=.01 or RAbsBJ(LoadReal(Ui,$CE400D0C,$FDF65382)-LoadReal(QL,LoadInteger(Ui,$CE400D0C,$2A5D9A31),$FDF65382))>=.01 then
            call SaveReal(Ui,$CE400D0C,$A1614B4D,Atan2BJ(LoadReal(Ui,$CE400D0C,$FDF65382)-LoadReal(QL,LoadInteger(Ui,$CE400D0C,$2A5D9A31),$FDF65382),LoadReal(Ui,$CE400D0C,$A99320FA)-LoadReal(QL,LoadInteger(Ui,$CE400D0C,$2A5D9A31),$A99320FA)))
            call SaveReal(Ui,$CE400D0C,$A1614B4D,ModuloReal(LoadReal(Ui,$CE400D0C,$A1614B4D)+315.,360.))
            call SaveInteger(Ui,$CE400D0C,$6F96F2D2,R2I(LoadReal(Ui,$CE400D0C,$A1614B4D)/90.)+1)
        else
            call SaveInteger(Ui,$CE400D0C,$6F96F2D2,0)
        endif
        if LoadInteger(QL,LoadInteger(Ui,$CE400D0C,$E3FCDFB0),$6F96F2D2)!=LoadInteger(Ui,$CE400D0C,$6F96F2D2) then
            call SaveInteger(QL,LoadInteger(Ui,$CE400D0C,$2A5D9A31),$6F96F2D2,LoadInteger(Ui,$CE400D0C,$6F96F2D2))
            call DzFrameSetTexture(YK[1],"Expression_Up.blp",0)
            call DzFrameSetTexture(YK[2],"Expression_Left.blp",0)
            call DzFrameSetTexture(YK[3],"Expression_Down.blp",0)
            call DzFrameSetTexture(YK[4],"Expression_Right.blp",0)
            if LoadInteger(Ui,$CE400D0C,$6F96F2D2)!=0 then
                call DzFrameSetTexture(YK[LoadInteger(Ui,$CE400D0C,$6F96F2D2)],LoadStr(Ui,$CE400D0C,ExpressionPicID+LoadInteger(Ui,$CE400D0C,$6F96F2D2)),0)
            endif
        endif
    endif
endfunction

    function BNw takes nothing returns nothing
        call DzFrameShow(LoadInteger(Ui,$B9801AE9,$2A5D9A31),false)
        call SaveBoolean(QL,LoadInteger(Ui,$B9801AE9,$2A5D9A31),$BD4989EA,false)
        call SavePlayerHandle(Ui,$B9801AE9,$A59BB4C6,DzGetTriggerKeyPlayer())
        call SaveInteger(Ui,$B9801AE9,$6F96F2D2,LoadInteger(QL,LoadInteger(Ui,$B9801AE9,$2A5D9A31),$6F96F2D2))
        if LoadInteger(Ui,$B9801AE9,$6F96F2D2)!=0 then
            if LoadInteger(Ui,$B9801AE9,$6F96F2D2)==1 then
                call SaveInteger(Ui,$B9801AE9,$6F96F2D2,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$B9801AE9,$A59BB4C6)),$93019576))
            endif
            if LoadInteger(Ui,$B9801AE9,$6F96F2D2)==2 then
                call SaveInteger(Ui,$B9801AE9,$6F96F2D2,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$B9801AE9,$A59BB4C6)),$1A25C950))
            endif
            if LoadInteger(Ui,$B9801AE9,$6F96F2D2)==3 then
                call SaveInteger(Ui,$B9801AE9,$6F96F2D2,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$B9801AE9,$A59BB4C6)),$73B6285E))
            endif
            if LoadInteger(Ui,$B9801AE9,$6F96F2D2)==4 then
                call SaveInteger(Ui,$B9801AE9,$6F96F2D2,LoadInteger(QL,GetHandleId(LoadPlayerHandle(Ui,$B9801AE9,$A59BB4C6)),$DE33BF0F))
            endif
            call SaveStr(Ui,$B9801AE9,$2D297D87,I2S(GetConvertedPlayerId(LoadPlayerHandle(Ui,$B9801AE9,$A59BB4C6)))+I2S(LoadInteger(Ui,$B9801AE9,$6F96F2D2)))
            call DzSyncData("Img",LoadStr(Ui,$B9801AE9,$2D297D87))
        endif
    endfunction
    function BNx takes nothing returns nothing
    if LoadReal(Ui,GetHandleId(GetExpiredTimer()),$6B54C545)>0. and LoadTimerHandle(QL,GetHandleId(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),$B6A6EBAA)),$5F17FEDE)==GetExpiredTimer() then
    call SaveReal(Ui,GetHandleId(GetExpiredTimer()),$6B54C545,LoadReal(Ui,GetHandleId(GetExpiredTimer()),$6B54C545)-.03)
    call MoveLocation(LoadLocationHandle(Ui,GetHandleId(GetExpiredTimer()),$5E83114F),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),$B6A6EBAA)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),$B6A6EBAA)))
    call EXSetEffectXY(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),$F8F856EA),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),$B6A6EBAA)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),$B6A6EBAA)))
    call EXSetEffectZ(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),$F8F856EA),GetLocationZ(LoadLocationHandle(Ui,GetHandleId(GetExpiredTimer()),$5E83114F))+(GetUnitFlyHeight(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),$B6A6EBAA))+256.))
    else
    if LoadTimerHandle(QL,GetHandleId(LoadUnitHandle(Ui,GetHandleId(GetExpiredTimer()),$B6A6EBAA)),$5F17FEDE)!=GetExpiredTimer() then
    call EXSetEffectZ(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),$F8F856EA),9999.)
    endif
    call DestroyEffect(LoadEffectHandle(Ui,GetHandleId(GetExpiredTimer()),$F8F856EA))
    call BIr(GetExpiredTimer())
    call FlushChildHashtable(Ui,GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    endif
    endfunction
    function BNy takes nothing returns nothing
    local timer X3
    call SaveStr(Ui,GetHandleId(GetTriggeringTrigger()),$2D297D87,DzGetTriggerSyncData())
    call SavePlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$A59BB4C6,ConvertedPlayer(S2I(SubStringBJ(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),$2D297D87),1,1))))
    call SaveStr(Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+1,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$A59BB4C6)),ExpressionPic_UP))
    call SaveStr(Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+2,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$A59BB4C6)),ExpressionPic_LEFT))
    call SaveStr(Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+3,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$A59BB4C6)),ExpressionPic_DOWN))
    call SaveStr(Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+4,LoadStr(QL,GetHandleId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$A59BB4C6)),ExpressionPic_RIGHT))
    call SaveInteger(Ui,GetHandleId(GetTriggeringTrigger()),$6F96F2D2,S2I(SubStringBJ(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),$2D297D87),2,StringLength(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),$2D297D87)))))
    call SaveUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA,Xb[GetConvertedPlayerId(LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$A59BB4C6))])
    call SaveTimerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$1CA61CEC,CreateTimer())
    call SaveTimerHandle(QL,GetHandleId(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA)),$5F17FEDE,LoadTimerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$1CA61CEC))
    call MoveLocation(LoadLocationHandle(Ui,GetHandleId(GetTriggeringTrigger()),$5E83114F),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA)))
    call SaveEffectHandle(Ui,GetHandleId(GetTriggeringTrigger()),$F8F856EA,AddSpecialEffect(LoadStr(Ui,GetHandleId(GetTriggeringTrigger()),ExpressionPicID+LoadInteger(Ui,GetHandleId(GetTriggeringTrigger()),$6F96F2D2)),GetWidgetX(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA)),GetWidgetY(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA))))
    call EXSetEffectZ(LoadEffectHandle(Ui,GetHandleId(GetTriggeringTrigger()),$F8F856EA),GetLocationZ(LoadLocationHandle(Ui,GetHandleId(GetTriggeringTrigger()),$5E83114F))+(GetUnitFlyHeight(LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA))+256.))
    set X3=LoadTimerHandle(Ui,GetHandleId(GetTriggeringTrigger()),$1CA61CEC)
    call SaveReal(Ui,GetHandleId(X3),$6B54C545,5.)
    call SaveEffectHandle(Ui,GetHandleId(X3),$F8F856EA,LoadEffectHandle(Ui,GetHandleId(GetTriggeringTrigger()),$F8F856EA))
    call SaveLocationHandle(Ui,GetHandleId(X3),$5E83114F,LoadLocationHandle(Ui,GetHandleId(GetTriggeringTrigger()),$5E83114F))
    call SaveUnitHandle(Ui,GetHandleId(X3),$B6A6EBAA,LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger()),$B6A6EBAA))
    call TimerStart(X3,.03,true,function BNx)
    call BIp(X3,.03,true," function Trig_bqb_004Func035Func016T","bqb-004")
    set X3=null
    endfunction
    
    function BIp takes timer R7,real X6,boolean X7,string X8,string X9 returns nothing
        call SaveTimerHandle(i,X4,0,R7)
        call SaveInteger(i,GetHandleId(R7),0,X4)
        call SaveReal(i,GetHandleId(R7),1,X6)
        call SaveBoolean(i,GetHandleId(R7),2,X7)
        call SaveStr(i,GetHandleId(R7),3,X8)
        call SaveStr(i,GetHandleId(R7),4,X9)
        set X4=X4+1
        endfunction

    function BNz takes nothing returns nothing
        local integer Xa
        local integer YJ
        local trigger Xz
        local integer XZ=LoadInteger(Ui,GetHandleId(GetTriggeringTrigger()),$CFDE6C76)
        set XZ=XZ+3
        call SaveInteger(Ui,GetHandleId(GetTriggeringTrigger()),$CFDE6C76,XZ)
        call SaveInteger(Ui,GetHandleId(GetTriggeringTrigger()),$ECE825E7,XZ)
        call SaveInteger(QL,GetHandleId(GetLocalPlayer()),$93019576,1)
        call SaveInteger(QL,GetHandleId(GetLocalPlayer()),$1A25C950,2)
        call SaveInteger(QL,GetHandleId(GetLocalPlayer()),$73B6285E,3)
        call SaveInteger(QL,GetHandleId(GetLocalPlayer()),$DE33BF0F,4)
        set Xa=1
        loop
            exitwhen Xa>5
            call SaveInteger(QL,GetHandleId(ConvertedPlayer(Xa)),$93019576,1)
            call SaveInteger(QL,GetHandleId(ConvertedPlayer(Xa)),$1A25C950,2)
            call SaveInteger(QL,GetHandleId(ConvertedPlayer(Xa)),$73B6285E,3)
            call SaveInteger(QL,GetHandleId(ConvertedPlayer(Xa)),$DE33BF0F,4)
            set Xa=Xa+1
        endloop
        call SaveInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31,DzCreateFrameByTagName("BACKDROP","name",DzGetGameUI(),"template",0))
        call DzFrameSetTexture(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),"Expression_Point.blp",0)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),.065,.065)
        call DzFrameShow(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),false)
        set YJ=1
        loop
            exitwhen YJ>4
            call SaveInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+YJ,DzCreateFrameByTagName("BACKDROP","name",LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),"template",0))
            set YK[YJ]=LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+YJ)
            set YJ=YJ+1
        endloop
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+1),7,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),1,0,-.0325)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+1),.14,.07)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+2),5,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),3,.0325,0)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+2),.07,.14)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+3),1,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),7,0,.0325)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+3),.14,.07)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+4),3,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),5,-.0325,0.)
        call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+4),.07,.14)
        set YJ=5
        loop
            exitwhen YJ>8
            call SaveInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+YJ,DzCreateFrameByTagName("BACKDROP","name",LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),"template",0))
            call DzFrameSetSize(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+YJ),.05,.05)
            set YK[YJ]=LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+YJ)
            set YJ=YJ+1
        endloop
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+5),7,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),1,0,-.015)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+6),5,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),3,.015,0)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+7),1,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),7,0,.015)
        call DzFrameSetPoint(LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$82340862+8),3,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31),5,-.015,0.)
        call SaveInteger(Ui,$8A6FA691,$2A5D9A31,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31))
        call SavePlayerHandle(Ui,$8A6FA691,$A59BB4C6,LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$A59BB4C6))
        call SaveReal(Ui,$8A6FA691,$A99320FA,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$A99320FA))
        call SaveReal(Ui,$8A6FA691,$FDF65382,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$FDF65382))
        if GetLocalPlayer()==GetLocalPlayer() then
            call DzTriggerRegisterKeyEventByCode(null,84,1,false,function BNu)
        endif
        call SaveStr(Ui,$CE400D0C,ExpressionPicID+1,TransText("Expression_Up_Select.blp"))
        call SaveStr(Ui,$CE400D0C,ExpressionPicID+2,TransText("Expression_Left_Select.blp"))
        call SaveStr(Ui,$CE400D0C,ExpressionPicID+3,TransText("Expression_Down_Select.blp"))
        call SaveStr(Ui,$CE400D0C,ExpressionPicID+4,TransText("Expression_Right_Select.blp"))
        call SaveInteger(Ui,$CE400D0C,$6F96F2D2,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$6F96F2D2))
        call SaveInteger(Ui,$CE400D0C,$2A5D9A31,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31))
        call SaveInteger(Ui,$CE400D0C,$E3FCDFB0,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$E3FCDFB0))
        call SaveReal(Ui,$CE400D0C,$A1614B4D,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$A1614B4D))
        call SaveReal(Ui,$CE400D0C,$A99320FA,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$A99320FA))
        call SaveReal(Ui,$CE400D0C,$FDF65382,LoadReal(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$FDF65382))
        if GetLocalPlayer()==GetLocalPlayer() then
            call DzFrameSetUpdateCallbackByCode(function BNv)
        endif
        call SaveInteger(Ui,$B9801AE9,$6F96F2D2,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$6F96F2D2))
        call SaveInteger(Ui,$B9801AE9,$2A5D9A31,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2A5D9A31))
        call SavePlayerHandle(Ui,$B9801AE9,$A59BB4C6,LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$A59BB4C6))
        call SaveStr(Ui,$B9801AE9,$2D297D87,LoadStr(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2D297D87))
        if GetLocalPlayer()==GetLocalPlayer() then
            call DzTriggerRegisterKeyEventByCode(null,84,0,false,function BNw)
        endif
        set Xz=CreateTrigger()
        call SaveLocationHandle(Ui,GetHandleId(Xz),$5E83114F,Location(0.,0.))
        call SaveEffectHandle(Ui,GetHandleId(Xz),$F8F856EA,LoadEffectHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$F8F856EA))
        call SaveInteger(Ui,GetHandleId(Xz),$6F96F2D2,LoadInteger(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$6F96F2D2))
        call SavePlayerHandle(Ui,GetHandleId(Xz),$A59BB4C6,LoadPlayerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$A59BB4C6))
        call SaveStr(Ui,GetHandleId(Xz),$2D297D87,LoadStr(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$2D297D87))
        call SaveTimerHandle(Ui,GetHandleId(Xz),$1CA61CEC,LoadTimerHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$1CA61CEC))
        call SaveUnitHandle(Ui,GetHandleId(Xz),$B6A6EBAA,LoadUnitHandle(Ui,GetHandleId(GetTriggeringTrigger())*XZ,$B6A6EBAA))
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