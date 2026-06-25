library Party
     struct party
         private group G
         static method create takes nothing returns thistype
             local thistype this = thistype.allocate()
             if .G == null then
                 set .G = CreateGroup()
             endif
             call GroupClear( .G )
             return this
         endmethod
         method operator super takes nothing returns group
             return .G
         endmethod
         method destroy takes nothing returns nothing
             call thistype.deallocate( this )
         endmethod
     endstruct
endlibrary