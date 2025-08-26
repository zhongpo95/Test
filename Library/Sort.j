//! import "DzAPIPlus.j"
library Sort
    globals
        private string compareFuncName      // Compare 함수 이름 저장
        private string swapFuncName         // Swap 함수 이름 저장
        public integer indexA               // 함수 매개 변수 인덱스 A
        public integer indexB               // 함수 매개 변수 인덱스 B
        public boolean isCompare            // Compare 결과 값 저장
    endglobals
    
    private function Partition takes integer left, integer right returns integer
        local integer pivot = right
        local integer i = left - 1
        local integer j = left
        loop
            exitwhen j >= right
            set indexA = pivot
            set indexB = j
            call DzExecuteFunc(compareFuncName)
            if isCompare then
                set i = i + 1
                set indexA = i
                set indexB = j
                call DzExecuteFunc(swapFuncName)
            endif
            set j = j + 1
        endloop
        
        set indexA = i + 1
        set indexB = right
        call DzExecuteFunc(swapFuncName)
        return i + 1
    endfunction
    
    private function QuickSort takes integer left, integer right returns nothing
        local integer array st
        local integer top = -1
        local integer tempLeft
        local integer tempRight
        local integer p
        
        set top = top + 1
        set st[top] = left
        set top = top + 1
        set st[top] = right
        
        loop
            exitwhen top < 0
            set tempRight = st[top]
            set top = top - 1
            set tempLeft = st[top]
            set top = top - 1
            
            if tempLeft < tempRight then
                set p = Partition(tempLeft, tempRight)
                
                if p + 1 < tempRight then
                    set top = top + 1
                    set st[top] = p + 1
                    set top = top + 1
                    set st[top] = tempRight
                endif
                
                if p - 1 > tempLeft then
                    set top = top + 1
                    set st[top] = tempLeft
                    set top = top + 1
                    set st[top] = p - 1
                endif
            endif
        endloop
    endfunction
    
    /*
    * 정렬 시작
    * start:        정렬할 시작 인덱스
    * end:          정렬할 마지막 인덱스
    * compareFunc:  두 값을 비교하는 함수 이름
    * swapFunc:     두 값을 교체하는 함수 이름
    */
    public function Run takes integer start, integer end, string compareFunc, string swapFunc returns nothing
        if start < end then
            set compareFuncName = compareFunc
            set swapFuncName = swapFunc
            call QuickSort(start, end)
        endif
    endfunction
endlibrary
//[출처] (JN) 정렬 시스템 (+JN 미사용 정렬 추가) (워크래프트3 리포지드 유즈맵 포럼 [W3UMF]) | 작성자 Howww