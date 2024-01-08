library Add
    function Abs takes real x returns real
        if x < 0 then
            return - 1.0 * x
        endif
        return x
    endfunction
endlibrary
    
    