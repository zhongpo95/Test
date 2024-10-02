library HeroNarZ

globals
    integer array NarForm
    integer array NarStack
    integer array NarNabi
    unit array NarFormG
    unit array NarFormC
endglobals

function NarNabiPlus takes integer pid, integer i returns nothing
    loop
    exitwhen i <= 0
        if GetLocalPlayer() == Player(pid) then
            if NarNabi[pid] == 0 then
                call DzFrameShow(NarAdens[0], true)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                endif
            elseif NarNabi[pid] == 1 then
                call DzFrameShow(NarAdens[1], true)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                endif
            elseif NarNabi[pid] == 2 then
                call DzFrameShow(NarAdens[2], true)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                endif
            elseif NarNabi[pid] == 3 then
                call DzFrameShow(NarAdens[3], true)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[3], "Narmaya_pink2.mdx", 0, 0)
                endif
            elseif NarNabi[pid] == 4 then
                call DzFrameShow(NarAdens[4], true)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[4], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[4], "Narmaya_pink2.mdx", 0, 0)
                endif
            elseif NarNabi[pid] == 5 then
                call DzFrameShow(NarAdens[5], true)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[5], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[5], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
        endif

        if NarNabi[pid] == 6 then
            set NarNabi[pid] = 5
        endif

        set i = i - 1
        set NarNabi[pid] = NarNabi[pid] + 1
    endloop


endfunction

function NarNabiUse takes integer pid, boolean b returns integer
    if b == true then
        if GetRandomInt(0,1) == 1 then
            if NarNabi[pid] == 0 then
                return 0
            elseif NarNabi[pid] == 1 then
                if GetLocalPlayer() == Player(pid) then
                    if NarForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 1
            elseif NarNabi[pid] == 2 then
                if GetLocalPlayer() == Player(pid) then
                    if NarForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 2
            elseif NarNabi[pid] == 3 then
                if GetLocalPlayer() == Player(pid) then
                    if NarForm[pid] == 0 then
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
            elseif NarNabi[pid] == 4 then
                if GetLocalPlayer() == Player(pid) then
                    if NarForm[pid] == 0 then
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
            elseif NarNabi[pid] == 5 then
                if GetLocalPlayer() == Player(pid) then
                    if NarForm[pid] == 0 then
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
            elseif NarNabi[pid] == 6 then
                if GetLocalPlayer() == Player(pid) then
                    if NarForm[pid] == 0 then
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
            if NarNabi[pid] == 0 then
                set NarNabi[pid] = 0
                return 0
            elseif NarNabi[pid] == 1 then
                set NarNabi[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    if NarForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 1
            elseif NarNabi[pid] == 2 then
                set NarNabi[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    if NarForm[pid] == 0 then
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                    else
                        call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                        call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    endif
                endif
                return 2
            elseif NarNabi[pid] == 3 then
                set NarNabi[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[2], "Narmaya_pink2.mdx", 0, 0)
                    if NarForm[pid] == 0 then
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
            elseif NarNabi[pid] == 4 then
                set NarNabi[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameShow(NarAdens[3], false)
                    if NarForm[pid] == 0 then
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
            elseif NarNabi[pid] == 5 then
                set NarNabi[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameShow(NarAdens[3], false)
                    call DzFrameShow(NarAdens[4], false)
                    if NarForm[pid] == 0 then
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
            elseif NarNabi[pid] == 6 then
                set NarNabi[pid] = 0
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameShow(NarAdens[0], false)
                    call DzFrameShow(NarAdens[1], false)
                    call DzFrameShow(NarAdens[2], false)
                    call DzFrameShow(NarAdens[3], false)
                    call DzFrameShow(NarAdens[4], false)
                    call DzFrameShow(NarAdens[5], false)
                    if NarForm[pid] == 0 then
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
        if NarNabi[pid] == 0 then
            set NarNabi[pid] = 0
            return 0
        elseif NarNabi[pid] == 1 then
            set NarNabi[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 1
        elseif NarNabi[pid] == 2 then
            set NarNabi[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                if NarForm[pid] == 0 then
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_blue2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_blue2.mdx", 0, 0)
                else
                    call DzFrameSetModel(NarAdens2[0], "Narmaya_pink2.mdx", 0, 0)
                    call DzFrameSetModel(NarAdens2[1], "Narmaya_pink2.mdx", 0, 0)
                endif
            endif
            return 2
        elseif NarNabi[pid] == 3 then
            set NarNabi[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                if NarForm[pid] == 0 then
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
        elseif NarNabi[pid] == 4 then
            set NarNabi[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                if NarForm[pid] == 0 then
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
        elseif NarNabi[pid] == 5 then
            set NarNabi[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                call DzFrameShow(NarAdens[4], false)
                if NarForm[pid] == 0 then
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
        elseif NarNabi[pid] == 6 then
            set NarNabi[pid] = 0
            if GetLocalPlayer() == Player(pid) then
                call DzFrameShow(NarAdens[0], false)
                call DzFrameShow(NarAdens[1], false)
                call DzFrameShow(NarAdens[2], false)
                call DzFrameShow(NarAdens[3], false)
                call DzFrameShow(NarAdens[4], false)
                call DzFrameShow(NarAdens[5], false)
                if NarForm[pid] == 0 then
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