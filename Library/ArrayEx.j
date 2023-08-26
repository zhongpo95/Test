
library ArrayEx



    globals

        private hashtable TABLE = InitHashtable()

        private integer BASE = 0

        private integer INDEX = 0

        private integer ARR_MAX = 0

    endglobals



    struct ArrayExKey

        //! runtextmacro ArrayEx_IO("ability","AbilityHandle")

        //! runtextmacro ArrayEx_I("agent","AgentHandle")

        //! runtextmacro ArrayEx_IO("boolean","Boolean")

        //! runtextmacro ArrayEx_IO("boolexpr","BooleanExprHandle")

        //! runtextmacro ArrayEx_IO("button","ButtonHandle")

        //! runtextmacro ArrayEx_IO("defeatcondition","DefeatConditionHandle")

        //! runtextmacro ArrayEx_IO("destructable","DestructableHandle")

        //! runtextmacro ArrayEx_IO("dialog","DialogHandle")

        //! runtextmacro ArrayEx_IO("effect","EffectHandle")

        //! runtextmacro ArrayEx_IO("fogmodifier","FogModifierHandle")

        //! runtextmacro ArrayEx_IO("fogstate","FogStateHandle")

        //! runtextmacro ArrayEx_IO("force","ForceHandle")

        //! runtextmacro ArrayEx_IO("group","GroupHandle")

        //! runtextmacro ArrayEx_IO("hashtable","HashtableHandle")

        //! runtextmacro ArrayEx_IO("image","ImageHandle")

        //! runtextmacro ArrayEx_IO("integer","Integer")

        //! runtextmacro ArrayEx_IO("item","ItemHandle")

        //! runtextmacro ArrayEx_IO("itempool","ItemPoolHandle")

        //! runtextmacro ArrayEx_IO("leaderboard","LeaderboardHandle")

        //! runtextmacro ArrayEx_IO("lightning","LightningHandle")

        //! runtextmacro ArrayEx_IO("location","LocationHandle")

        //! runtextmacro ArrayEx_IO("multiboard","MultiboardHandle")

        //! runtextmacro ArrayEx_IO("multiboarditem","MultiboardItemHandle")

        //! runtextmacro ArrayEx_IO("player","PlayerHandle")

        //! runtextmacro ArrayEx_IO("quest","QuestHandle")

        //! runtextmacro ArrayEx_IO("questitem","QuestItemHandle")

        //! runtextmacro ArrayEx_IO("real","Real")

        //! runtextmacro ArrayEx_IO("rect","RectHandle")

        //! runtextmacro ArrayEx_IO("region","RegionHandle")

        //! runtextmacro ArrayEx_IO("string","Str")

        //! runtextmacro ArrayEx_IO("texttag","TextTagHandle")

        //! runtextmacro ArrayEx_IO("sound","SoundHandle")

        //! runtextmacro ArrayEx_IO("timer","TimerHandle")

        //! runtextmacro ArrayEx_IO("trackable","TrackableHandle")

        //! runtextmacro ArrayEx_IO("triggeraction","TriggerActionHandle")

        //! runtextmacro ArrayEx_IO("triggercondition","TriggerConditionHandle")

        //! runtextmacro ArrayEx_IO("event","TriggerEventHandle")

        //! runtextmacro ArrayEx_IO("trigger","TriggerHandle")

        //! runtextmacro ArrayEx_IO("ubersplat","UbersplatHandle")

        //! runtextmacro ArrayEx_IO("unit","UnitHandle")

        //! runtextmacro ArrayEx_IO("unitpool","UnitPoolHandle")

        //! runtextmacro ArrayEx_IO("widget","WidgetHandle")

        //! runtextmacro ArrayEx_IOS("struct","integer","Integer")

        //! runtextmacro ArrayEx_IOS("ArrayEx","ArrayEx","Integer")

        method operator [] takes integer k returns thistype

            set BASE = this

            set INDEX = k

            return LoadInteger(TABLE,this,k)

        endmethod

        method operator []= takes integer k, ArrayEx v returns nothing

            call SaveInteger(TABLE,this,k,v)

        endmethod

    endstruct



    struct ArrayEx

        static method Create takes nothing returns thistype

            local integer stacks = LoadInteger(TABLE,-1,0)

            if stacks > 0 then

                call SaveInteger(TABLE,-1,0,stacks - 1)

                return LoadInteger(TABLE,-1,stacks)

            endif

            set ARR_MAX = ARR_MAX + 1

            return ARR_MAX

        endmethod

        method Destroy takes nothing returns nothing

            local integer stacks = LoadInteger(TABLE,-1,0)

            set stacks = stacks + 1

            call SaveInteger(TABLE,-1,0,stacks)

            call SaveInteger(TABLE,-1,stacks,this)

            call FlushChildHashtable(TABLE,this)

        endmethod

        method operator [] takes integer k returns ArrayExKey

            set BASE = this

            set INDEX = k

            return LoadInteger(TABLE,this,k)

        endmethod

        method operator []= takes integer k, thistype v returns nothing

            call SaveInteger(TABLE,this,k,v)

        endmethod

    endstruct



endlibrary

//! textmacro ArrayEx_IO takes TYPE,FUNC

method operator $TYPE$ takes nothing returns $TYPE$

    local boolean doNotInline

    return Load$FUNC$(TABLE,BASE,INDEX)

endmethod

method operator $TYPE$= takes $TYPE$ v returns nothing

    local boolean doNotInline

    call Save$FUNC$(TABLE,BASE,INDEX,v)

endmethod

//! endtextmacro

//! textmacro ArrayEx_IOS takes CALLER,TYPE,FUNC

method operator $CALLER$= takes $TYPE$ v returns nothing

    local boolean doNotInline

    call Save$FUNC$(TABLE,BASE,INDEX,v)

endmethod

method operator $CALLER$ takes nothing returns $TYPE$

    local boolean doNotInline

    return Load$FUNC$(TABLE,BASE,INDEX)

endmethod

//! endtextmacro

//! textmacro ArrayEx_I takes TYPE,FUNC

method operator $TYPE$= takes $TYPE$ v returns nothing

    local boolean doNotInline

    call Save$FUNC$(TABLE,BASE,INDEX,v)

endmethod

//! endtextmacro