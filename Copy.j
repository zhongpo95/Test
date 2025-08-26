
function Overlay2 takes integer pid, integer SkillCode, real damage, boolean Cri returns nothing
    local integer i = 0
    local boolean bool = false
    if GetLocalPlayer() == Player(pid) then
        //이미있음
        loop
            exitwhen i > 14
            if Overlay2Velue_SkillName[i] == SkillCode then
                set bool = true
            endif
            set i = i + 1
        endloop
        //없음
        if bool == false then
            set i = 0
            loop
                exitwhen i > 14
                if Overlay2Velue_SkillName[i] != 0 then
                    set Overlay2Velue_SkillName[i] = SkillCode
                    set bool = true
                endif
                set i = i + 1
            endloop
        endif
        
        set Overlay2Velue_Damage[i] = Overlay2Velue_Damage[i] + damage
        set Overlay2Velue_HitCount[i] = Overlay2Velue_HitCount[i] + 1
        if Cri == true then
            set Overlay2Velue_Cri[i] = Overlay2Velue_Cri[i] + 1
        endif
    endif
endfunction