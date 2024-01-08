library Add
    function Abs takes real x returns real
        if x < 0 then
            return - 1.0 * x
        endif
        return x
    endfunction
endlibrary
    

## Settings file was created by plugin Skinwalker Mod v2.0.2
## Plugin GUID: RugbugRedfern.SkinwalkerMod

[Monster Voices]

# Setting type: Boolean
# Default value: true
Baboon Hawk = false

# Setting type: Boolean
# Default value: true
Bracken = false

# Setting type: Boolean
# Default value: true
Bunker Spider = false

# Setting type: Boolean
# Default value: true
Centipede = false

# Setting type: Boolean
# Default value: true
Coil Head = false

# Setting type: Boolean
# Default value: true
Eyeless Dog = false

# Setting type: Boolean
# Default value: false
Forest Giant = false

# Setting type: Boolean
# Default value: true
Ghost Girl = false

# Setting type: Boolean
# Default value: false
Giant Worm = false

# Setting type: Boolean
# Default value: true
Hoarding Bug = false

# Setting type: Boolean
# Default value: false
Hygrodere = false

# Setting type: Boolean
# Default value: true
Jester = false

# Setting type: Boolean
# Default value: true
Masked = true

# Setting type: Boolean
# Default value: true
Nutcracker = false

# Setting type: Boolean
# Default value: true
Spore Lizard = false

# Setting type: Boolean
# Default value: true
Thumper = false

[Voice Settings]

## 1 is the default, and voice lines will occur every 15 to 40 seconds per enemy. Setting this to 2 means they will occur twice as often, 0.5 means half as often, etc.
# Setting type: Single
# Default value: 1
VoiceLineFrequency = 2.5

