// 사건 본문을 단어 단위로 미리 줄로 나눠 줄마다 TEXT를 배치할 수 있게 한다.
// 프레임은 건드리지 않고 문자열만 계산하므로, 실패하면 호출부가 원본 TEXT를 그대로 둔다.
library StoryLineLayout initializer Init
    globals
        constant integer STORY_LINE_MAX = 24
        string array StoryLines
        integer StoryLineCount = 0
        // 한글 한 글자 폭 / 글꼴 크기. 비교 샘플의 눈금 줄로 보정한다.
        real StoryLineEm = 1.0
        private integer CharBytes = 3
        private hashtable Narrow = InitHashtable()
        private string Source
        private string Line
        private string LineColor
        private real LineUnits
        private real LineCap
        private integer WordStart
        private string WordColor
        private real WordUnits
        private boolean Failed
    endglobals

    // ASCII는 한글의 절반 폭으로 본다. 그 밖의 바이트는 멀티바이트 글자의 일부로 보고 나눠 센다.
    private function ByteUnits takes string c returns real
        if HaveSavedBoolean(Narrow, StringHash(c), 0) then
            return 0.5
        endif
        return 1.0 / CharBytes
    endfunction

    private function PushLine takes nothing returns nothing
        if StoryLineCount >= STORY_LINE_MAX then
            set Failed = true
            return
        endif
        set StoryLines[StoryLineCount] = LineColor + Line
        set StoryLineCount = StoryLineCount + 1
        set Line = ""
        set LineUnits = 0.0
    endfunction

    // 단어는 원문에서 잘라 오므로 색상 태그와 문장부호가 그대로 남는다.
    private function FlushWord takes integer stop returns nothing
        local string word
        if WordStart < 0 then
            return
        endif
        set word = SubString(Source, WordStart, stop)
        set WordStart = -1
        if WordUnits <= 0.0 then
            // 색상 태그만 있는 조각은 폭 없이 현재 줄에 붙인다.
            set Line = Line + word
            return
        endif
        if WordUnits > LineCap then
            // 한 줄보다 긴 단어는 자르지 않고 실패로 돌려 원본 TEXT를 유지한다.
            set Failed = true
            return
        endif
        if LineUnits > 0.0 and LineUnits + 0.5 + WordUnits > LineCap then
            call PushLine()
        endif
        if LineUnits > 0.0 then
            set Line = Line + " " + word
            set LineUnits = LineUnits + 0.5 + WordUnits
        else
            if Line == "" then
                set LineColor = WordColor
            endif
            set Line = Line + word
            set LineUnits = WordUnits
        endif
    endfunction

    private function StartWord takes integer i, string active returns nothing
        if WordStart < 0 then
            set WordStart = i
            set WordColor = active
            set WordUnits = 0.0
        endif
    endfunction

    // 성공하면 StoryLines[0..StoryLineCount-1]에 각 줄의 시작 색이 붙은 문자열을 남긴다.
    function StoryLineLayout takes string value, real width, real fontSize returns boolean
        local integer i = 0
        local integer n = StringLength(value)
        local string c
        local string two
        local string active = ""
        set Source = value
        set StoryLineCount = 0
        set Line = ""
        set LineColor = ""
        set LineUnits = 0.0
        set WordStart = -1
        set WordColor = ""
        set WordUnits = 0.0
        set Failed = false
        set LineCap = width / (fontSize * StoryLineEm)
        // 아주 긴 글은 작업량 한도 전에 포기하고 원본 TEXT를 쓴다.
        if n <= 0 or n > 2400 or LineCap < 2.0 then
            return false
        endif
        loop
            exitwhen i >= n or Failed
            set c = SubString(value, i, i + 1)
            if c == "|" then
                set two = SubString(value, i, i + 2)
                if two == "|c" or two == "|C" then
                    call StartWord(i, active)
                    set active = SubString(value, i, i + 10)
                    set i = i + 10
                elseif two == "|r" or two == "|R" then
                    call StartWord(i, active)
                    set active = ""
                    set i = i + 2
                elseif two == "|n" or two == "|N" then
                    // 원문 줄바꿈과 빈 줄은 그대로 한 줄씩 유지해 기존 문단 구성을 바꾸지 않는다.
                    call FlushWord(i)
                    call PushLine()
                    set LineColor = active
                    set i = i + 2
                else
                    call StartWord(i, active)
                    set WordUnits = WordUnits + 0.5
                    set i = i + 1
                endif
            elseif c == " " then
                call FlushWord(i)
                set i = i + 1
            else
                call StartWord(i, active)
                set WordUnits = WordUnits + ByteUnits(c)
                set i = i + 1
            endif
        endloop
        if not Failed then
            call FlushWord(n)
        endif
        if not Failed and Line != "" then
            call PushLine()
        endif
        return not Failed
    endfunction

    private function Init takes nothing returns nothing
        local string narrow = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{}~"
        local integer i = 0
        local integer n = StringLength(narrow)
        // 1.28 문자열 함수가 바이트 단위인지 글자 단위인지 실제 엔진 값으로 정한다.
        set CharBytes = StringLength("가")
        if CharBytes < 1 then
            set CharBytes = 3
        endif
        loop
            exitwhen i >= n
            call SaveBoolean(Narrow, StringHash(SubString(narrow, i, i + 1)), 0, true)
            set i = i + 1
        endloop
    endfunction
endlibrary
