//! import "JNMemory.j"
//! import "JNCommon.j"

library EXSetEffectXYHook initializer Init requires MemoryLib, Typecast, optional EndGameHook
    globals
        private integer pEXSetEffectXY
        private integer pTrampoline
        private integer pNewFunc
        private integer MemoryBlockOldProtect
        private integer array originalEXSetEffectXY

    endglobals

    //! runtextmacro MemoryLib_DefineMemoryBlock("private", "MemoryBlock", "EXSetEffectXYHook__MemoryBlock", "400")

    private function VirtualProtect takes Ptr lpAddress, integer dwSize, integer flNewProtect, Ptr pflOldProtect returns integer
        local Ptr pFunc = IntPtr[pGameDll + 0xA6B384]
        call SaveStr(JNProc_ht, JNProc_key, 0, "(IIII)I")
        call SaveInteger(JNProc_ht, JNProc_key, 1, lpAddress)
        call SaveInteger(JNProc_ht, JNProc_key, 2, dwSize)
        call SaveInteger(JNProc_ht, JNProc_key, 3, flNewProtect)
        call SaveInteger(JNProc_ht, JNProc_key, 4, pflOldProtect)
        if (JNProcCall(JNProc__stdcall, pFunc, JNProc_ht)) then
            return LoadInteger(JNProc_ht, JNProc_key, 0)
        endif
        return 0
    endfunction

    private function GetNativeFuncStruct takes string funcName returns Ptr
        local Ptr pFunc = pGameDll + 0x8C1940
        call SaveStr(JNProc_ht, JNProc_key, 0, "(S)I")
        call SaveStr(JNProc_ht, JNProc_key, 1, funcName)
        if (JNProcCall(JNProc__thiscall, pFunc, JNProc_ht)) then
            return LoadInteger(JNProc_ht, JNProc_key, 0)
        endif
        return 0
    endfunction

    private function MakeMemoryBlockExecutable takes nothing returns nothing
        call VirtualProtect(MemoryBlock.pHead, MemoryBlock.size, 0x40, MemoryBlock.pHead)
        set MemoryBlockOldProtect = IntPtr[MemoryBlock.pHead]
    endfunction
    
    private struct AssemblyWriter
        public Ptr pCursor

        public static method create takes Ptr pHead returns thistype
            local thistype this = thistype.allocate()
            set this.pCursor = pHead
            return this
        endmethod

        public method malloc takes integer size returns Ptr
            local Ptr pBlock = this.pCursor
            set this.pCursor = this.pCursor + size
            return pBlock
        endmethod

        public method writePadding takes integer size returns nothing
            local integer i = 0
            loop
                exitwhen i >= size
                set BytePtr[this.pCursor] = 0xCC
                set this.pCursor = this.pCursor + 1
                set i = i + 1
            endloop
        endmethod

        public method writeByte takes integer byteValue returns nothing
            set BytePtr[this.pCursor] = byteValue
            set this.pCursor = this.pCursor + 1
        endmethod

        public method writeInt takes integer intValue returns nothing
            set IntPtr[this.pCursor] = intValue
            set this.pCursor = this.pCursor + 4
        endmethod

        public method writeOffset takes integer address returns nothing
            set IntPtr[this.pCursor] = address - (this.pCursor + 4)
            set this.pCursor = this.pCursor + 4
        endmethod
    endstruct

    private function InitMemoryBlock takes nothing returns nothing
        local AssemblyWriter asm

        call MakeMemoryBlockExecutable()

        set asm = AssemblyWriter.create(MemoryBlock.pHead)

        call asm.writePadding(8)

        set pNewFunc = asm.pCursor

        call asm.writeByte(0x55)        // push ebp
        call asm.writeByte(0x8B)        // mov ebp, esp
        call asm.writeByte(0xEC)        // -

        call asm.writeByte(0x56)        // push esi
        call asm.writeByte(0x51)        // push ecx


        call asm.writeByte(0x8B)        // mov ecx, dword ptr ss:[ebp+0x8]
        call asm.writeByte(0x4D)        // -
        call asm.writeByte(0x08)        // -
        call asm.writeByte(0xE8)        // call HandleToObject
        call asm.writeOffset(pGameDll + 0x021F4A0)   // -

        call asm.writeByte(0x8B)        // mov esi, eax
        call asm.writeByte(0xF0)        // -
        call asm.writeByte(0x85)        // test esi, esi
        call asm.writeByte(0xF6)        // -

        call asm.writeByte(0x74)        // je
        call asm.writeByte(0x44)        // -

        call asm.writeByte(0x83)        // sub esp, 0x8
        call asm.writeByte(0xEC)        // -
        call asm.writeByte(0x08)        // -

        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[ebp+0xC]
        call asm.writeByte(0x45)        // -
        call asm.writeByte(0x0C)        // -
        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[eax]
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x89)        // mov dword ptr ss:[ebp-0x10], eax
        call asm.writeByte(0x45)        // -
        call asm.writeByte(0xF0)        // -
        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[ebp+0x10]
        call asm.writeByte(0x45)        // -
        call asm.writeByte(0x10)        // -
        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[eax]
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x89)        // mov dword ptr ss:[ebp-0xC], eax
        call asm.writeByte(0x45)        // -
        call asm.writeByte(0xF4)        // -

        call asm.writeByte(0x8D)        // lea ecx, dword ptr ss:[ebp-0x10]
        call asm.writeByte(0x4D)        // -
        call asm.writeByte(0xF0)        // -
        call asm.writeByte(0x6A)        // push 0x1
        call asm.writeByte(0x01)        // -
        call asm.writeByte(0x51)        // push ecx

        // GetSmartPostion
        call asm.writeByte(0x89)        // mov ecx, esi
        call asm.writeByte(0xF1)        // -
        call asm.writeByte(0x81)        // add ecx, 0x84
        call asm.writeByte(0xC1)        // -
        call asm.writeByte(0x84)        // -
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x00)        // -

        call asm.writeByte(0xE8)        // call SetSmartPostion
        call asm.writeOffset(pGameDll + 0x085D70)   // -

        // SetSpriteXY
        call asm.writeByte(0x8B)        // mov ecx, dword ptr ds:[esi+0x28]
        call asm.writeByte(0x4E)        // -
        call asm.writeByte(0x28)        // -
        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[ebp+0xC]
        call asm.writeByte(0x45)        // -
        call asm.writeByte(0x0C)        // -
        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[eax]
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x36)        // mov dword ptr ss:[ecx+0xC0], eax
        call asm.writeByte(0x89)        // -
        call asm.writeByte(0x81)        // -
        call asm.writeByte(0xC0)        // -
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[ebp+0x10]
        call asm.writeByte(0x45)        // -
        call asm.writeByte(0x10)        // -
        call asm.writeByte(0x8B)        // mov eax, dword ptr ss:[eax]
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x36)        // mov dword ptr ss:[ecx+0xC4], eax
        call asm.writeByte(0x89)        // -
        call asm.writeByte(0x81)        // -
        call asm.writeByte(0xC4)        // -
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x00)        // -
        call asm.writeByte(0x00)        // -

        call asm.writeByte(0x83)        // add esp, 0x8
        call asm.writeByte(0xC4)        // -
        call asm.writeByte(0x08)        // -

        call asm.writeByte(0x59)        // pop ecx
        call asm.writeByte(0x5E)        // pop esi
        call asm.writeByte(0x89)        // mov esp, ebp
        call asm.writeByte(0xEC)        // -
        call asm.writeByte(0x5D)        // pop ebp

        call asm.writeByte(0xC3)        // ret

        call asm.writePadding(8)
        
        call asm.destroy()
    endfunction

    private function IsHookedAlready takes nothing returns boolean
        return IntPtr[pEXSetEffectXY] != 0x56EC8B55
    endfunction

    private function HookEXSetEffectXY takes nothing returns nothing
        local AssemblyWriter asm


        // Backup EXSetEffectXY
        set originalEXSetEffectXY[0] = IntPtr(pEXSetEffectXY)[0]
        set originalEXSetEffectXY[1] = IntPtr(pEXSetEffectXY)[1]

        // Inject trampoline into EXSetEffectXY
        set asm = AssemblyWriter.create(pEXSetEffectXY)
        call asm.writeByte(0xE9)       // jmp newFunc
        call asm.writeOffset(pNewFunc) // -
        call asm.destroy()
    endfunction

    function UnhookEXSetEffectXY takes nothing returns nothing
        // Restore EXSetEffectXY
        set IntPtr(pEXSetEffectXY)[0] = originalEXSetEffectXY[0]
        set IntPtr(pEXSetEffectXY)[1] = originalEXSetEffectXY[1]
    endfunction

    private function InitHook takes nothing returns nothing
        if IsHookedAlready() then
            debug call JNWriteLog("[EXSetEffectXYHook] The function is hooked already.")
            return
        endif

        call InitMemoryBlock()
        call HookEXSetEffectXY()
    endfunction

    private function Init takes nothing returns nothing
        set pEXSetEffectXY = IntPtr(GetNativeFuncStruct("EXSetEffectXY"))[7]
        call InitHook()
    endfunction

endlibrary
