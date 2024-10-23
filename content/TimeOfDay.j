scope TimeOfDay initializer main
        private function main takes nothing returns nothing
                call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.00)
                call SuspendTimeOfDay(true)
                call SuspendTimeOfDay(true)
        endfunction    
endscope

