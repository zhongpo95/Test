library vJDKPluginETT
    globals    
        // for custom centered texttags
        private constant real MEAN_CHAR_WIDTH = 5.5
        private constant real MAX_TEXT_SHIFT = 200.0
        private constant real DEFAULT_HEIGHT = 16.0
        // for default texttags
        private constant real SIGN_SHIFT = 16.0
        private constant real FONT_SIZE = 0.024
    endglobals
    function CreateGoldBountyTextTagVJ takes player p, real x, real y, real z, integer a returns nothing
            local texttag tt = CreateTextTag()
            local string text = "+" + I2S(a)
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, x-SIGN_SHIFT, y, z)
            call SetTextTagColor(tt, 255, 220, 0, 255)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==p or p == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            set tt = null
    endfunction
    function CreateGoldBountyTextTagOnUnitVJ takes player p, unit u, real z, integer a returns nothing
            local texttag tt = CreateTextTag()
            local string text = "+" + I2S(a)
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, GetWidgetX(u)-SIGN_SHIFT, GetWidgetY(u), z)
            call SetTextTagColor(tt, 255, 220, 0, 255)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==p or p == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            set tt = null
    endfunction
    function CreateLumberBountyTextTagVJ takes player p, real x, real y, real z, integer a returns nothing
            local texttag tt = CreateTextTag()
            local string text = "+" + I2S(a)
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, x-SIGN_SHIFT, y, z)
            call SetTextTagColor(tt, 0, 200, 80, 255)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==p or p == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            set tt = null
    endfunction
    function CreateLumberBountyTextTagOnUnitVJ takes player p, unit u, real z, integer a returns nothing
            local texttag tt = CreateTextTag()
            local string text = "+" + I2S(a)
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, GetWidgetX(u)-SIGN_SHIFT, GetWidgetY(u), z)
            call SetTextTagColor(tt, 0, 200, 80, 255)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==p or p == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            set tt = null
    endfunction
    function CreateBountyTextTagVJ takes player p, real x, real y, real z, string text returns nothing
            local texttag tt = CreateTextTag()
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, x-SIGN_SHIFT, y, z)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==p or p == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            set tt = null
    endfunction
    function CreateBountyTextTagOnUnitVJ takes player p, unit u, real z, string text returns nothing
            local texttag tt = CreateTextTag()
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, GetWidgetX(u)-SIGN_SHIFT, GetWidgetY(u), z)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==p or p == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            set tt = null
    endfunction
endlibrary