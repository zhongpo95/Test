//! textmacro 이벤트_플레이어가_명령어를_입력하면_발동 takes NAME,CMD
private struct APArgCmdChat$NAME$ extends array
    method operator [] takes integer i returns string
        return VJGetTriggerChat(i)
    endmethod
endstruct
private struct APEvCmdChat$NAME$ extends array
    private static APArgCmdChat$NAME$ command = 0
    private static method onInit takes nothing returns nothing
        call TriggerRegisterPlayerChatEventEx("$CMD$",function thistype.Wrapper)
    endmethod
    private static method Wrapper takes nothing returns nothing
        call thistype.Action(GetTriggerPlayer(),VJCountTriggerChat())
    endmethod
    private static method Action takes player triggerplayer, integer commandcount returns nothing
//! endtextmacro
//=============================================================
library vJDKPluginChatEx initializer main
        //라이브러리에서 쓸 변수들!
        globals
            //채팅 데이터 갯수
            private integer chatdatacount
            //각 채팅 데이터 저장공간
            private string array chatdata
            
            //채팅 명령어가 저장될 해시 테이블
            private hashtable chattable = InitHashtable()
            //모든 채팅 명령어를 받을 트리거
            private trigger chattrigger = CreateTrigger()
        endglobals
        
        //확장 채팅 - (명령어)입력 시 (함수)를 실행합니다
        function TriggerRegisterPlayerChatEventEx takes string s, code c returns nothing
            //임시 트리거를 하나 만듭니다.
            local trigger t = CreateTrigger()
            //임시 트리거에 조건을 추가합니다. (액션보다 실행이 빠릅니다)
            call TriggerAddCondition( t, Filter(c) )
            //임시 트리거를 해시테이블에 저장합니다!
            call SaveTriggerHandle(chattable, 0, StringHash(s), t)
            //핸들링 누수 제거!
            set t = null
        endfunction
        
        //확장 채팅 - 입력된 채팅 매개값 갯수
        function VJCountTriggerChat takes nothing returns integer
            return chatdatacount
        endfunction
        //확장 채팅 - 입력된 (정수)번 채팅 매개값
        function VJGetTriggerChat takes integer i returns string
            return chatdata[i]
        endfunction
        
        //초기화 된 플레이어가 아무 채팅이나 치면 발동되는 이벤트
        private function ChatEx_Action takes nothing returns nothing
            //현재 데이터를 읽는 상태( FALSE = 시작점 찾는중, TRUE = 중단점 찾는중 )
            local boolean readstate = false
            //현재 데이터의 시작점
            local integer datdex = 0
            //현재 검사 중인 문자열 번호
            local integer strdex = 0
            //방금 친 채트 문자열 전체
            local string chatstr = GetEventPlayerChatString()
            //채트 문자열의 총 길이
            local integer strlen = StringLength(chatstr)
            //채팅을 친 플레이어 설정!
            //set vj_triggerplayer = GetTriggerPlayer()
            //채팅 데이터 초기화 = 0. 0개의 채팅 데이터라고 보시면 됩니다.
            set chatdatacount = 0
            //본격 루프문 시작!
            loop
                //만약 데이터의 시작점을 찾는 중이라면?
                if not readstate then
                    //띄어쓰기가 아닌 어떤 의미있는 값이 나왔을 경우.
                    if SubString(chatstr, strdex, strdex+1) != " " then
                        //현재 위치를 데이터의 시작점으로 마킹하고.
                        set datdex = strdex
                        //이제는 데이터의 중단점을 찾기 시작합니다.
                        set readstate = true
                    endif
                else
                    //만약 데이터의 종결점을 찾는 중이라면?
                    //띄어쓰기가 나왔을 경우.
                    if SubString(chatstr, strdex, strdex+1) == " " then
                        //데이터의 시작점으로부터 현재까지의 텍스트를 데이터로 저장합니다.
                        set chatdata[chatdatacount] = SubString(chatstr, datdex, strdex)
                        //데이터의 갯수를 1만큼 늘립니다.
                        set chatdatacount = chatdatacount + 1
                        //이제는 다음 데이터의 시작점을 찾기 시작합니다.
                        set readstate = false
                    endif
                endif
                set strdex = strdex + 1
                //끝까지 모두 읽었다면 탈출합니다.
                exitwhen strdex == strlen
            endloop
            //탈출했는데 만약 중단점을 찾던 중이었다면? 여기까지 데이터를 끊습니다.
            if readstate then
                    set chatdata[chatdatacount] = SubString(chatstr, datdex, strdex)
                    //데이터의 갯수를 1만큼 늘립니다.
                    set chatdatacount = chatdatacount + 1
            endif
            //만약 맨 앞의 데이터가 실행 대상이 아닌 경우
            if not HaveSavedHandle( chattable, 0, StringHash(chatdata[0]) ) then
                //트리거 즉시 종료!
                return
            endif
            //실행 대상이면 두말없이 실행합니다.
            call TriggerEvaluate(LoadTriggerHandle( chattable, 0, StringHash(chatdata[0]) ))
        endfunction
        
        //확장 채팅 시스템을 초기화합니다.
        private function main takes nothing returns nothing
            local integer i = 0
            //트리거에 액션을 추가합니다. (매우 중요!)
            call TriggerAddAction( chattrigger, function ChatEx_Action )
            //트리거에 이벤트를 추가합니다.
            loop
                exitwhen i == bj_MAX_PLAYERS
                call TriggerRegisterPlayerChatEvent( chattrigger, Player(i), "", false )
                set i = i + 1
            endloop
        endfunction
endlibrary