library HeroLuciaZ initializer init requires FrameCount

globals
    integer array LuciaForm
    boolean array LuciaBooleanD
    unit array LuciaFormUnit
    unit array LuciaD
    unit array LuciaR
    unit array LuciaF
    integer array LuciaStack
    unit array LuciaFormG
    unit array LuciaFormC
    integer array LuciaMu
endglobals

    globals
        integer LuciaAdenBorder
        integer LuciaAden
        integer LuciaAdenBorder2
        integer LuciaAden2
        integer LuciaAdenTextFrame
        integer array LuciaVelue
    endglobals
    

    //LuciaAdenShow(플레이어,소태도1대태도2, 보임여부)
    function LuciaAdenShow takes player p, integer state, boolean state2 returns nothing
        if p == GetLocalPlayer() then
            if state2 then
                if state == 1 then
                    call DzFrameShow(LuciaAdenTextFrame,true)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_TOPLEFT,.330,.1000)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.470,.0800)
                    call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_TOPLEFT,.330,.1000)
                    call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_BOTTOMRIGHT,.470,.0800)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                    call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                    call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                elseif state == 2 then
                    call DzFrameShow(LuciaAdenTextFrame,true)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_TOPLEFT,.300,.1080)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_BOTTOMRIGHT,.500,.0720)
                    call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_TOPLEFT,.300,.1080)
                    call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_BOTTOMRIGHT,.500,.0720)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                    call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                    call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                    call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                endif
            else
                call DzFrameShow(LuciaAdenTextFrame,false)
                call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
                call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_TOPLEFT,-1,-1)
                call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
            endif
        endif
    endfunction
    
    private function MyBarCreate takes nothing returns nothing
        //소태도
        set LuciaAdenBorder=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"", FrameCount())
        call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_TOPLEFT,.320,.1800)
        call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.1700)
        call DzFrameSetTexture(LuciaAdenBorder,"LuciaAden0.blp",0)
        call DzFrameSetMinMaxValue(LuciaAdenBorder,0,'d')
        call DzFrameSetValue(LuciaAdenBorder,'d')
        set LuciaAden=DzCreateFrameByTagName("SIMPLESTATUSBAR","",LuciaAdenBorder,"", FrameCount())
        call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_TOPLEFT,.320,.1800)
        call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.1700)
        call DzFrameSetTexture(LuciaAden,"LuciaAden1.blp",0)
        call DzFrameSetMinMaxValue(LuciaAden,0, 25.00)
        call DzFrameSetValue(LuciaAden,0)

        //대태도
        set LuciaAdenBorder2=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"", FrameCount())
        call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_TOPLEFT,.320,.1800)
        call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.1700)
        call DzFrameSetTexture(LuciaAdenBorder2,"LuciaAden2.blp",0)
        call DzFrameSetMinMaxValue(LuciaAdenBorder2,0,'d')
        call DzFrameSetValue(LuciaAdenBorder2,'d')
        set LuciaAden2=DzCreateFrameByTagName("SIMPLESTATUSBAR","",LuciaAdenBorder2,"", FrameCount())
        call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_TOPLEFT,.320,.1800)
        call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_BOTTOMRIGHT,.480,.1700)
        call DzFrameSetTexture(LuciaAden2,"LuciaAden3.blp",0)
        call DzFrameSetMinMaxValue(LuciaAden2,0, 25.00)
        call DzFrameSetValue(LuciaAden2,0)

        set LuciaAdenTextFrame=DzCreateFrameByTagName("TEXT","",DzGetGameUI(),"", FrameCount())
        call DzFrameSetAbsolutePoint(LuciaAdenTextFrame,JN_FRAMEPOINT_CENTER,.400,.1200)
        call DzFrameSetFont(LuciaAdenTextFrame, "Fonts\\DFHeiMd.ttf", 0.012, 0)
        call DzFrameSetText(LuciaAdenTextFrame,"0")
        call DzFrameShow(LuciaAdenTextFrame,false)
        
        call DzFrameShow(LuciaAdenTextFrame,false)
        call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_TOPLEFT,-1,-1)
        call DzFrameSetAbsolutePoint(LuciaAdenBorder,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
        call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_TOPLEFT,-1,-1)
        call DzFrameSetAbsolutePoint(LuciaAden,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
        call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_TOPLEFT,-1,-1)
        call DzFrameSetAbsolutePoint(LuciaAdenBorder2,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
        call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_TOPLEFT,-1,-1)
        call DzFrameSetAbsolutePoint(LuciaAden2,JN_FRAMEPOINT_BOTTOMRIGHT,-1,-1)
        set LuciaVelue[0] = 0
        set LuciaVelue[1] = 0
        set LuciaVelue[2] = 0
        set LuciaVelue[3] = 0
        set LuciaVelue[4] = 0
        set LuciaVelue[5] = 0
        set LuciaVelue[6] = 0
    endfunction

    
    private function init takes nothing returns nothing
        local trigger t
        set t = CreateTrigger()
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function MyBarCreate )
        set t = null
    endfunction



function LuciaMuPlus takes integer pid, integer i returns nothing
    set LuciaMu[pid] = LuciaMu[pid] + i
    if LuciaMu[pid] > 300 then
        set LuciaMu[pid] = 300
    endif
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetText(LuciaAdenTextFrame,I2S(LuciaMu[pid]))
    endif
endfunction

function LuciaMuUse takes integer pid, boolean b returns integer
    if b == true then
        if GetRandomInt(0,1) == 1 then
            if LuciaMu[pid] == 0 then
                return 0
            elseif LuciaMu[pid] == 1 then
                if GetLocalPlayer() == Player(pid) then
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 1
            elseif LuciaMu[pid] == 2 then
                if GetLocalPlayer() == Player(pid) then
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 2
            elseif LuciaMu[pid] == 3 then
                if GetLocalPlayer() == Player(pid) then
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 3
            elseif LuciaMu[pid] == 4 then
                if GetLocalPlayer() == Player(pid) then
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 4
            elseif LuciaMu[pid] == 5 then
                if GetLocalPlayer() == Player(pid) then
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 5
            elseif LuciaMu[pid] == 6 then
                if GetLocalPlayer() == Player(pid) then
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[5], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[5], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 6
            endif
        else
            if LuciaMu[pid] == 0 then
                set LuciaMu[pid] = 0
                return 0
            elseif LuciaMu[pid] == 1 then
                set LuciaMu[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 1
            elseif LuciaMu[pid] == 2 then
                set LuciaMu[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 2
            elseif LuciaMu[pid] == 3 then
                set LuciaMu[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 3
            elseif LuciaMu[pid] == 4 then
                set LuciaMu[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameShow(NarAdens[3], false)
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 4
            elseif LuciaMu[pid] == 5 then
                set LuciaMu[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameShow(NarAdens[3], false)
                    call DzFrameShow(NarAdens[4], false)
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 5
            elseif LuciaMu[pid] == 6 then
                set LuciaMu[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameShow(NarAdens[3], false)
                    call DzFrameShow(NarAdens[4], false)
                    call DzFrameShow(NarAdens[5], false)
                    if LuciaForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[5], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[5], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 6
            endif
        endif
    else
        if LuciaMu[pid] == 0 then
            set LuciaMu[pid] = 0
            return 0
        elseif LuciaMu[pid] == 1 then
            set LuciaMu[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                if LuciaForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 1
        elseif LuciaMu[pid] == 2 then
            set LuciaMu[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                if LuciaForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 2
        elseif LuciaMu[pid] == 3 then
            set LuciaMu[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                if LuciaForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 3
        elseif LuciaMu[pid] == 4 then
            set LuciaMu[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                if LuciaForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 4
        elseif LuciaMu[pid] == 5 then
            set LuciaMu[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                call DzFrameShow(NarAdens[4], false)
                if LuciaForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 5
        elseif LuciaMu[pid] == 6 then
            set LuciaMu[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                call DzFrameShow(NarAdens[4], false)
                call DzFrameShow(NarAdens[5], false)
                if LuciaForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[5], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[5], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 6
        endif
    endif
    return 0
endfunction


endlibrary