if SelectAdvice == 65 then

    set i = 4
    set j = 0
    if El_Level[pid][path] + i >= 10 then
        set j = 10 - El_Level[pid][path]
        set El_Level[pid][path] = 10
    endif


    set El_Level[pid][path] = El_Level[pid][path] + 4


    set El_Level[pid][path] = El_Level[pid][path] + 1
    if El_Level[pid][path] == 11 then
        set El_Level[pid][path] = 10
    endif


    set path = GetRandomPath(pid)
    set El_Level[pid][path] = El_Level[pid][path] + 1
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
    endif
    if El_RateLucky[pid][path] >= r then
        if El_Level[pid][path] != 10 then
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
            endif
        endif
    endif
elseif SelectAdvice == 66 then
    set path = GetRandomPath(pid)
    set El_Level[pid][path] = El_Level[pid][path] + 1
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
    endif
    if El_RateLucky[pid][path] >= r then
        if El_Level[pid][path] != 10 then
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
            endif
        endif
    endif
elseif SelectAdvice == 67 then
    set path = GetRandomPath(pid)
    set El_Level[pid][path] = El_Level[pid][path] + 1
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
    endif
    if El_RateLucky[pid][path] >= r then
        if El_Level[pid][path] != 10 then
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
            endif
        endif
    endif
elseif SelectAdvice == 68 then
    set path = GetRandomPath(pid)
    set El_Level[pid][path] = El_Level[pid][path] + 1
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
    endif
    if El_RateLucky[pid][path] >= r then
        if El_Level[pid][path] != 10 then
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
            endif
        endif
    endif
elseif SelectAdvice == 69 then
    set path = GetRandomPath(pid)
    set El_Level[pid][path] = El_Level[pid][path] + 1
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
    endif
    if El_RateLucky[pid][path] >= r then
        if El_Level[pid][path] != 10 then
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
            endif
        endif
    endif
elseif SelectAdvice == 70 then
    set path = GetRandomPath(pid)
    set El_Level[pid][path] = El_Level[pid][path] + 1
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
    endif
    if El_RateLucky[pid][path] >= r then
        if El_Level[pid][path] != 10 then
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
            endif
        endif
    endif
endif