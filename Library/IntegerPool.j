library IntegerPool

    private struct Iterator
        integer value
        real weight
        Iterator next
        static method create takes integer v, real w returns thistype
            local thistype this = thistype.allocate()
            set this.value = v
            set this.weight = w
            return this
        endmethod
    endstruct

    struct IntegerPool
        private Iterator head
        private Iterator temp
        private real weight
        private integer size
        
        static method Create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.weight = 0.00
            set this.size = 0
            set this.head = 0
            set this.temp = 0
            return this
        endmethod
        
        method add takes integer i, real w returns nothing
            local Iterator ind = Iterator.create( i, w )
            set this.weight = this.weight + w
            set this.size = this.size + 1
            set ind.next = this.head
            set this.head = ind
        endmethod
        
        method clear takes nothing returns nothing
            local Iterator ind = this.head
            local Iterator tnd
            loop
                exitwhen ind == 0
                set tnd = ind
                set ind = ind.next
                call tnd.destroy()
            endloop
            set ind = this.temp
            loop
                exitwhen ind == 0
                set tnd = ind
                set ind = ind.next
                call tnd.destroy()
            endloop
        endmethod
        
        method onDestroy takes nothing returns nothing
            call clear(  )
        endmethod
        
        method getSize takes nothing returns integer
            return this.size
        endmethod
        
        method remove takes integer i returns boolean
            local Iterator ind = this.head
            local Iterator indb = 0
            loop
                exitwhen ind == 0
                if ind.value == i then
                    if indb == 0 then
                        set this.head = ind.next
                    else
                        set indb.next = ind.next
                    endif
                    set this.size = this.size - 1
                    set this.weight = this.weight - ind.weight
                    call ind.destroy()
                    return true
                endif
                set indb = ind
                set ind = ind.next
            endloop
            return false
        endmethod
        
        method pick takes boolean ram returns integer
            local Iterator ind = this.head
            local Iterator indb = 0
            local real seed = GetRandomReal(0.00,this.weight)
            local real stack = 0.00
            loop
                exitwhen ind == 0
                if seed <= stack + ind.weight then
                    if ram then
                        if indb == 0 then
                            set this.head = ind.next
                        else
                            set indb.next = ind.next
                        endif
                        set ind.next = temp
                        set temp = ind
                        set size = size - 1
                        set weight = weight - ind.weight
                    endif
                    return ind.value
                endif
                set stack = stack + ind.weight
                set indb = ind
                set ind = ind.next
            endloop
            return 0
        endmethod
        
    endstruct
    
endlibrary
