-- 맵 루트의 UI 정의를 읽고 시험 프레임 높이로 실제 FDF 적용을 확인한다.
local catalog = {
[ [====[
IncludeFile "UI\FrameDef\Glue\StandardTemplates.fdf",
IncludeFile "UI\FrameDef\Glue\BattleNetTemplates.fdf",

Frame "TEXTBUTTON" "ChooBlankButtonTemplatetA" {
    ControlStyle "AUTOTRACK",
}




//背景模板
Frame "BACKDROP" "panel" {
	BackdropBackground  "core\Transparent.tga",
	//BackdropBlendAll,
}
//背景模板
Frame "BACKDROP" "texture" {
	BackdropBackground  "core\Transparent.tga",
	//BackdropBlendAll,
}

//按钮模板
Frame "GLUETEXTBUTTON" "buttonAAA" {
  SetAllPoints,
}
//字
Frame "TEXT" "text" {
    LayerStyle "IGNORETRACKEVENTS",
    FrameFont "Fonts\gamefont.ttc", 10, "",
}


Frame "TEXT" "shadow_text1" {
    LayerStyle "IGNORETRACKEVENTS",
    FontShadowColor 0.0 0.0 0.0 0.9, // 描边
    FontShadowOffset 0.0012 -0.0012,         // 阴影
    FrameFont "fonts\dfst-m3u.ttf", 0.013, "",
}

Frame "TEXT" "musictext10" {
    LayerStyle "IGNORETRACKEVENTS",
    FrameFont "fontj.ttf", 10, "",
}

Frame "TEXT" "musictext20" {
    LayerStyle "IGNORETRACKEVENTS",
    FrameFont "fontj.ttf", 20, "",
}

Frame "TEXT" "fontyt7" {
    LayerStyle "IGNORETRACKEVENTS",
    FrameFont "fontyt.ttf", 7, "",
}

Frame "TEXT" "fontyt10" {
    LayerStyle "IGNORETRACKEVENTS",
    FrameFont "Fonts\gamefont.ttc", 10, "",
}

Frame "TEXT" "shigetext20" {
    LayerStyle "IGNORETRACKEVENTS",
    FrameFont "font1.ttf", 20, "",
}

Frame "SPRITE" "model" {
    LayerStyle "IGNORETRACKEVENTS",
    BackgroundArt "HeroShadowHunter2.mdx",
    //SetAllPoints,
}

Frame "TEXT" "old_text" {
    LayerStyle "IGNORETRACKEVENTS",
    FrameFont "MasterFont", 1, "",
    FontJustificationH JUSTIFYCENTER,
    FontJustificationV JUSTIFYMIDDLE,
}


Frame "BACKDROP" "tooltip_backdrop" {
    UseActiveContext,
    BackdropTileBackground,
    BackdropBackground  "UI\Widgets\ToolTips\Human\human-tooltip-background.blp",
    BackdropCornerFlags "UL|UR|BL|BR|T|L|B|R",
    BackdropCornerSize  0.01,
    BackdropBackgroundInsets 0.001f 0.001f 0.001f 0.001f,
    BackdropEdgeFile  "UI\Widgets\ToolTips\Human\human-tooltip-border.blp",
}


Frame "BACKDROP" "tooltip_backdrop2" {
    BackdropTileBackground,
    BackdropBackgroundInsets 0.002 0.002 0.002 0.002,
    BackdropBackground "UI\Widgets\ToolTips\Human\human-tooltip-background.blp",
    BackdropCornerFlags "UL|UR|BL|BR|T|L|B|R",
    BackdropCornerSize  0.01,
    BackdropEdgeFile "UI\Widgets\BattleNet\bnet-dialoguebox-border.blp",
    BackdropBlendAll,
}


]====] ] = "base",
[ [====[
    Frame "TEXT" "text0" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.0, "",
    }
]====] ] = "font_0",
[ [====[
    Frame "TEXT" "text0" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.0, "",
    }
]====] ] = "font2_0",
[ [====[
    Frame "EDITBOX" "edit0" {
        EditTextFrame "edit_text0",
        Frame "TEXT" "edit_text0" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.000000, "", 
        }
    }
]====] ] = "edit_0",
[ [====[
    Frame "TEXT" "text1" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.001, "",
    }
]====] ] = "font_1",
[ [====[
    Frame "TEXT" "text1" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.001, "",
    }
]====] ] = "font2_1",
[ [====[
    Frame "EDITBOX" "edit1" {
        EditTextFrame "edit_text1",
        Frame "TEXT" "edit_text1" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.001000, "", 
        }
    }
]====] ] = "edit_1",
[ [====[
    Frame "TEXT" "text2" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.002, "",
    }
]====] ] = "font_2",
[ [====[
    Frame "TEXT" "text2" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.002, "",
    }
]====] ] = "font2_2",
[ [====[
    Frame "EDITBOX" "edit2" {
        EditTextFrame "edit_text2",
        Frame "TEXT" "edit_text2" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.002000, "", 
        }
    }
]====] ] = "edit_2",
[ [====[
    Frame "TEXT" "text3" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.003, "",
    }
]====] ] = "font_3",
[ [====[
    Frame "TEXT" "text3" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.003, "",
    }
]====] ] = "font2_3",
[ [====[
    Frame "EDITBOX" "edit3" {
        EditTextFrame "edit_text3",
        Frame "TEXT" "edit_text3" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.003000, "", 
        }
    }
]====] ] = "edit_3",
[ [====[
    Frame "TEXT" "text4" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.004, "",
    }
]====] ] = "font_4",
[ [====[
    Frame "TEXT" "text4" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.004, "",
    }
]====] ] = "font2_4",
[ [====[
    Frame "EDITBOX" "edit4" {
        EditTextFrame "edit_text4",
        Frame "TEXT" "edit_text4" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.004000, "", 
        }
    }
]====] ] = "edit_4",
[ [====[
    Frame "TEXT" "text5" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.005, "",
    }
]====] ] = "font_5",
[ [====[
    Frame "TEXT" "text5" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.005, "",
    }
]====] ] = "font2_5",
[ [====[
    Frame "EDITBOX" "edit5" {
        EditTextFrame "edit_text5",
        Frame "TEXT" "edit_text5" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.005000, "", 
        }
    }
]====] ] = "edit_5",
[ [====[
    Frame "TEXT" "text6" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.006, "",
    }
]====] ] = "font_6",
[ [====[
    Frame "TEXT" "text6" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.006, "",
    }
]====] ] = "font2_6",
[ [====[
    Frame "EDITBOX" "edit6" {
        EditTextFrame "edit_text6",
        Frame "TEXT" "edit_text6" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.006000, "", 
        }
    }
]====] ] = "edit_6",
[ [====[
    Frame "TEXT" "text7" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.007, "",
    }
]====] ] = "font_7",
[ [====[
    Frame "TEXT" "text7" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.007, "",
    }
]====] ] = "font2_7",
[ [====[
    Frame "EDITBOX" "edit7" {
        EditTextFrame "edit_text7",
        Frame "TEXT" "edit_text7" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.007000, "", 
        }
    }
]====] ] = "edit_7",
[ [====[
    Frame "TEXT" "text8" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.008, "",
    }
]====] ] = "font_8",
[ [====[
    Frame "TEXT" "text8" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.008, "",
    }
]====] ] = "font2_8",
[ [====[
    Frame "EDITBOX" "edit8" {
        EditTextFrame "edit_text8",
        Frame "TEXT" "edit_text8" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.008000, "", 
        }
    }
]====] ] = "edit_8",
[ [====[
    Frame "TEXT" "text9" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.009, "",
    }
]====] ] = "font_9",
[ [====[
    Frame "TEXT" "text9" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.009, "",
    }
]====] ] = "font2_9",
[ [====[
    Frame "EDITBOX" "edit9" {
        EditTextFrame "edit_text9",
        Frame "TEXT" "edit_text9" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.009000, "", 
        }
    }
]====] ] = "edit_9",
[ [====[
    Frame "TEXT" "text10" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.01, "",
    }
]====] ] = "font_10",
[ [====[
    Frame "TEXT" "text10" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.01, "",
    }
]====] ] = "font2_10",
[ [====[
    Frame "EDITBOX" "edit10" {
        EditTextFrame "edit_text10",
        Frame "TEXT" "edit_text10" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.010000, "", 
        }
    }
]====] ] = "edit_10",
[ [====[
    Frame "TEXT" "text11" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.011, "",
    }
]====] ] = "font_11",
[ [====[
    Frame "TEXT" "text11" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.011, "",
    }
]====] ] = "font2_11",
[ [====[
    Frame "EDITBOX" "edit11" {
        EditTextFrame "edit_text11",
        Frame "TEXT" "edit_text11" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.011000, "", 
        }
    }
]====] ] = "edit_11",
[ [====[
    Frame "TEXT" "text12" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.012, "",
    }
]====] ] = "font_12",
[ [====[
    Frame "TEXT" "text12" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.012, "",
    }
]====] ] = "font2_12",
[ [====[
    Frame "EDITBOX" "edit12" {
        EditTextFrame "edit_text12",
        Frame "TEXT" "edit_text12" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.012000, "", 
        }
    }
]====] ] = "edit_12",
[ [====[
    Frame "TEXT" "text13" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.013, "",
    }
]====] ] = "font_13",
[ [====[
    Frame "TEXT" "text13" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.013, "",
    }
]====] ] = "font2_13",
[ [====[
    Frame "EDITBOX" "edit13" {
        EditTextFrame "edit_text13",
        Frame "TEXT" "edit_text13" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.013000, "", 
        }
    }
]====] ] = "edit_13",
[ [====[
    Frame "TEXT" "text14" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.014, "",
    }
]====] ] = "font_14",
[ [====[
    Frame "TEXT" "text14" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.014, "",
    }
]====] ] = "font2_14",
[ [====[
    Frame "EDITBOX" "edit14" {
        EditTextFrame "edit_text14",
        Frame "TEXT" "edit_text14" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.014000, "", 
        }
    }
]====] ] = "edit_14",
[ [====[
    Frame "TEXT" "text15" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.015, "",
    }
]====] ] = "font_15",
[ [====[
    Frame "TEXT" "text15" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.015, "",
    }
]====] ] = "font2_15",
[ [====[
    Frame "EDITBOX" "edit15" {
        EditTextFrame "edit_text15",
        Frame "TEXT" "edit_text15" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.015000, "", 
        }
    }
]====] ] = "edit_15",
[ [====[
    Frame "TEXT" "text16" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.016, "",
    }
]====] ] = "font_16",
[ [====[
    Frame "TEXT" "text16" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.016, "",
    }
]====] ] = "font2_16",
[ [====[
    Frame "EDITBOX" "edit16" {
        EditTextFrame "edit_text16",
        Frame "TEXT" "edit_text16" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.016000, "", 
        }
    }
]====] ] = "edit_16",
[ [====[
    Frame "TEXT" "text17" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.017, "",
    }
]====] ] = "font_17",
[ [====[
    Frame "TEXT" "text17" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.017, "",
    }
]====] ] = "font2_17",
[ [====[
    Frame "EDITBOX" "edit17" {
        EditTextFrame "edit_text17",
        Frame "TEXT" "edit_text17" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.017000, "", 
        }
    }
]====] ] = "edit_17",
[ [====[
    Frame "TEXT" "text18" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.018, "",
    }
]====] ] = "font_18",
[ [====[
    Frame "TEXT" "text18" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.018, "",
    }
]====] ] = "font2_18",
[ [====[
    Frame "EDITBOX" "edit18" {
        EditTextFrame "edit_text18",
        Frame "TEXT" "edit_text18" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.018000, "", 
        }
    }
]====] ] = "edit_18",
[ [====[
    Frame "TEXT" "text19" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.019, "",
    }
]====] ] = "font_19",
[ [====[
    Frame "TEXT" "text19" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.019, "",
    }
]====] ] = "font2_19",
[ [====[
    Frame "EDITBOX" "edit19" {
        EditTextFrame "edit_text19",
        Frame "TEXT" "edit_text19" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.019000, "", 
        }
    }
]====] ] = "edit_19",
[ [====[
    Frame "TEXT" "text20" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.02, "",
    }
]====] ] = "font_20",
[ [====[
    Frame "TEXT" "text20" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.02, "",
    }
]====] ] = "font2_20",
[ [====[
    Frame "EDITBOX" "edit20" {
        EditTextFrame "edit_text20",
        Frame "TEXT" "edit_text20" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.020000, "", 
        }
    }
]====] ] = "edit_20",
[ [====[
    Frame "TEXT" "text21" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.021, "",
    }
]====] ] = "font_21",
[ [====[
    Frame "TEXT" "text21" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.021, "",
    }
]====] ] = "font2_21",
[ [====[
    Frame "EDITBOX" "edit21" {
        EditTextFrame "edit_text21",
        Frame "TEXT" "edit_text21" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.021000, "", 
        }
    }
]====] ] = "edit_21",
[ [====[
    Frame "TEXT" "text22" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.022, "",
    }
]====] ] = "font_22",
[ [====[
    Frame "TEXT" "text22" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.022, "",
    }
]====] ] = "font2_22",
[ [====[
    Frame "EDITBOX" "edit22" {
        EditTextFrame "edit_text22",
        Frame "TEXT" "edit_text22" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.022000, "", 
        }
    }
]====] ] = "edit_22",
[ [====[
    Frame "TEXT" "text23" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.023, "",
    }
]====] ] = "font_23",
[ [====[
    Frame "TEXT" "text23" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.023, "",
    }
]====] ] = "font2_23",
[ [====[
    Frame "EDITBOX" "edit23" {
        EditTextFrame "edit_text23",
        Frame "TEXT" "edit_text23" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.023000, "", 
        }
    }
]====] ] = "edit_23",
[ [====[
    Frame "TEXT" "text24" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.024, "",
    }
]====] ] = "font_24",
[ [====[
    Frame "TEXT" "text24" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.024, "",
    }
]====] ] = "font2_24",
[ [====[
    Frame "EDITBOX" "edit24" {
        EditTextFrame "edit_text24",
        Frame "TEXT" "edit_text24" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.024000, "", 
        }
    }
]====] ] = "edit_24",
[ [====[
    Frame "TEXT" "text25" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.025, "",
    }
]====] ] = "font_25",
[ [====[
    Frame "TEXT" "text25" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.025, "",
    }
]====] ] = "font2_25",
[ [====[
    Frame "EDITBOX" "edit25" {
        EditTextFrame "edit_text25",
        Frame "TEXT" "edit_text25" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.025000, "", 
        }
    }
]====] ] = "edit_25",
[ [====[
    Frame "TEXT" "text26" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.026, "",
    }
]====] ] = "font_26",
[ [====[
    Frame "TEXT" "text26" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.026, "",
    }
]====] ] = "font2_26",
[ [====[
    Frame "EDITBOX" "edit26" {
        EditTextFrame "edit_text26",
        Frame "TEXT" "edit_text26" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.026000, "", 
        }
    }
]====] ] = "edit_26",
[ [====[
    Frame "TEXT" "text27" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.027, "",
    }
]====] ] = "font_27",
[ [====[
    Frame "TEXT" "text27" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.027, "",
    }
]====] ] = "font2_27",
[ [====[
    Frame "EDITBOX" "edit27" {
        EditTextFrame "edit_text27",
        Frame "TEXT" "edit_text27" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.027000, "", 
        }
    }
]====] ] = "edit_27",
[ [====[
    Frame "TEXT" "text28" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.028, "",
    }
]====] ] = "font_28",
[ [====[
    Frame "TEXT" "text28" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.028, "",
    }
]====] ] = "font2_28",
[ [====[
    Frame "EDITBOX" "edit28" {
        EditTextFrame "edit_text28",
        Frame "TEXT" "edit_text28" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.028000, "", 
        }
    }
]====] ] = "edit_28",
[ [====[
    Frame "TEXT" "text29" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.029, "",
    }
]====] ] = "font_29",
[ [====[
    Frame "TEXT" "text29" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.029, "",
    }
]====] ] = "font2_29",
[ [====[
    Frame "EDITBOX" "edit29" {
        EditTextFrame "edit_text29",
        Frame "TEXT" "edit_text29" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.029000, "", 
        }
    }
]====] ] = "edit_29",
[ [====[
    Frame "TEXT" "text30" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.03, "",
    }
]====] ] = "font_30",
[ [====[
    Frame "TEXT" "text30" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.03, "",
    }
]====] ] = "font2_30",
[ [====[
    Frame "EDITBOX" "edit30" {
        EditTextFrame "edit_text30",
        Frame "TEXT" "edit_text30" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.030000, "", 
        }
    }
]====] ] = "edit_30",
[ [====[
    Frame "TEXT" "text31" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.031, "",
    }
]====] ] = "font_31",
[ [====[
    Frame "TEXT" "text31" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.031, "",
    }
]====] ] = "font2_31",
[ [====[
    Frame "EDITBOX" "edit31" {
        EditTextFrame "edit_text31",
        Frame "TEXT" "edit_text31" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.031000, "", 
        }
    }
]====] ] = "edit_31",
[ [====[
    Frame "TEXT" "text32" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.032, "",
    }
]====] ] = "font_32",
[ [====[
    Frame "TEXT" "text32" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.032, "",
    }
]====] ] = "font2_32",
[ [====[
    Frame "EDITBOX" "edit32" {
        EditTextFrame "edit_text32",
        Frame "TEXT" "edit_text32" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.032000, "", 
        }
    }
]====] ] = "edit_32",
[ [====[
    Frame "TEXT" "text33" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.033, "",
    }
]====] ] = "font_33",
[ [====[
    Frame "TEXT" "text33" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.033, "",
    }
]====] ] = "font2_33",
[ [====[
    Frame "EDITBOX" "edit33" {
        EditTextFrame "edit_text33",
        Frame "TEXT" "edit_text33" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.033000, "", 
        }
    }
]====] ] = "edit_33",
[ [====[
    Frame "TEXT" "text34" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.034, "",
    }
]====] ] = "font_34",
[ [====[
    Frame "TEXT" "text34" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.034, "",
    }
]====] ] = "font2_34",
[ [====[
    Frame "EDITBOX" "edit34" {
        EditTextFrame "edit_text34",
        Frame "TEXT" "edit_text34" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.034000, "", 
        }
    }
]====] ] = "edit_34",
[ [====[
    Frame "TEXT" "text35" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.035, "",
    }
]====] ] = "font_35",
[ [====[
    Frame "TEXT" "text35" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.035, "",
    }
]====] ] = "font2_35",
[ [====[
    Frame "EDITBOX" "edit35" {
        EditTextFrame "edit_text35",
        Frame "TEXT" "edit_text35" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.035000, "", 
        }
    }
]====] ] = "edit_35",
[ [====[
    Frame "TEXT" "text36" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.036, "",
    }
]====] ] = "font_36",
[ [====[
    Frame "TEXT" "text36" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.036, "",
    }
]====] ] = "font2_36",
[ [====[
    Frame "EDITBOX" "edit36" {
        EditTextFrame "edit_text36",
        Frame "TEXT" "edit_text36" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.036000, "", 
        }
    }
]====] ] = "edit_36",
[ [====[
    Frame "TEXT" "text37" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.037, "",
    }
]====] ] = "font_37",
[ [====[
    Frame "TEXT" "text37" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.037, "",
    }
]====] ] = "font2_37",
[ [====[
    Frame "EDITBOX" "edit37" {
        EditTextFrame "edit_text37",
        Frame "TEXT" "edit_text37" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.037000, "", 
        }
    }
]====] ] = "edit_37",
[ [====[
    Frame "TEXT" "text38" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.038, "",
    }
]====] ] = "font_38",
[ [====[
    Frame "TEXT" "text38" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.038, "",
    }
]====] ] = "font2_38",
[ [====[
    Frame "EDITBOX" "edit38" {
        EditTextFrame "edit_text38",
        Frame "TEXT" "edit_text38" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.038000, "", 
        }
    }
]====] ] = "edit_38",
[ [====[
    Frame "TEXT" "text39" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.039, "",
    }
]====] ] = "font_39",
[ [====[
    Frame "TEXT" "text39" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.039, "",
    }
]====] ] = "font2_39",
[ [====[
    Frame "EDITBOX" "edit39" {
        EditTextFrame "edit_text39",
        Frame "TEXT" "edit_text39" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.039000, "", 
        }
    }
]====] ] = "edit_39",
[ [====[
    Frame "TEXT" "text40" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.04, "",
    }
]====] ] = "font_40",
[ [====[
    Frame "TEXT" "text40" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.04, "",
    }
]====] ] = "font2_40",
[ [====[
    Frame "EDITBOX" "edit40" {
        EditTextFrame "edit_text40",
        Frame "TEXT" "edit_text40" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.040000, "", 
        }
    }
]====] ] = "edit_40",
[ [====[
    Frame "TEXT" "text41" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.041, "",
    }
]====] ] = "font_41",
[ [====[
    Frame "TEXT" "text41" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.041, "",
    }
]====] ] = "font2_41",
[ [====[
    Frame "EDITBOX" "edit41" {
        EditTextFrame "edit_text41",
        Frame "TEXT" "edit_text41" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.041000, "", 
        }
    }
]====] ] = "edit_41",
[ [====[
    Frame "TEXT" "text42" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.042, "",
    }
]====] ] = "font_42",
[ [====[
    Frame "TEXT" "text42" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.042, "",
    }
]====] ] = "font2_42",
[ [====[
    Frame "EDITBOX" "edit42" {
        EditTextFrame "edit_text42",
        Frame "TEXT" "edit_text42" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.042000, "", 
        }
    }
]====] ] = "edit_42",
[ [====[
    Frame "TEXT" "text43" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.043, "",
    }
]====] ] = "font_43",
[ [====[
    Frame "TEXT" "text43" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.043, "",
    }
]====] ] = "font2_43",
[ [====[
    Frame "EDITBOX" "edit43" {
        EditTextFrame "edit_text43",
        Frame "TEXT" "edit_text43" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.043000, "", 
        }
    }
]====] ] = "edit_43",
[ [====[
    Frame "TEXT" "text44" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.044, "",
    }
]====] ] = "font_44",
[ [====[
    Frame "TEXT" "text44" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.044, "",
    }
]====] ] = "font2_44",
[ [====[
    Frame "EDITBOX" "edit44" {
        EditTextFrame "edit_text44",
        Frame "TEXT" "edit_text44" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.044000, "", 
        }
    }
]====] ] = "edit_44",
[ [====[
    Frame "TEXT" "text45" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.045, "",
    }
]====] ] = "font_45",
[ [====[
    Frame "TEXT" "text45" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.045, "",
    }
]====] ] = "font2_45",
[ [====[
    Frame "EDITBOX" "edit45" {
        EditTextFrame "edit_text45",
        Frame "TEXT" "edit_text45" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.045000, "", 
        }
    }
]====] ] = "edit_45",
[ [====[
    Frame "TEXT" "text46" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.046, "",
    }
]====] ] = "font_46",
[ [====[
    Frame "TEXT" "text46" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.046, "",
    }
]====] ] = "font2_46",
[ [====[
    Frame "EDITBOX" "edit46" {
        EditTextFrame "edit_text46",
        Frame "TEXT" "edit_text46" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.046000, "", 
        }
    }
]====] ] = "edit_46",
[ [====[
    Frame "TEXT" "text47" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.047, "",
    }
]====] ] = "font_47",
[ [====[
    Frame "TEXT" "text47" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.047, "",
    }
]====] ] = "font2_47",
[ [====[
    Frame "EDITBOX" "edit47" {
        EditTextFrame "edit_text47",
        Frame "TEXT" "edit_text47" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.047000, "", 
        }
    }
]====] ] = "edit_47",
[ [====[
    Frame "TEXT" "text48" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.048, "",
    }
]====] ] = "font_48",
[ [====[
    Frame "TEXT" "text48" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.048, "",
    }
]====] ] = "font2_48",
[ [====[
    Frame "EDITBOX" "edit48" {
        EditTextFrame "edit_text48",
        Frame "TEXT" "edit_text48" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.048000, "", 
        }
    }
]====] ] = "edit_48",
[ [====[
    Frame "TEXT" "text49" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.049, "",
    }
]====] ] = "font_49",
[ [====[
    Frame "TEXT" "text49" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.049, "",
    }
]====] ] = "font2_49",
[ [====[
    Frame "EDITBOX" "edit49" {
        EditTextFrame "edit_text49",
        Frame "TEXT" "edit_text49" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.049000, "", 
        }
    }
]====] ] = "edit_49",
[ [====[
    Frame "TEXT" "text50" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.05, "",
    }
]====] ] = "font_50",
[ [====[
    Frame "TEXT" "text50" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.05, "",
    }
]====] ] = "font2_50",
[ [====[
    Frame "EDITBOX" "edit50" {
        EditTextFrame "edit_text50",
        Frame "TEXT" "edit_text50" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.050000, "", 
        }
    }
]====] ] = "edit_50",
[ [====[
    Frame "TEXT" "text51" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.051, "",
    }
]====] ] = "font_51",
[ [====[
    Frame "TEXT" "text51" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.051, "",
    }
]====] ] = "font2_51",
[ [====[
    Frame "EDITBOX" "edit51" {
        EditTextFrame "edit_text51",
        Frame "TEXT" "edit_text51" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.051000, "", 
        }
    }
]====] ] = "edit_51",
[ [====[
    Frame "TEXT" "text52" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.052, "",
    }
]====] ] = "font_52",
[ [====[
    Frame "TEXT" "text52" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.052, "",
    }
]====] ] = "font2_52",
[ [====[
    Frame "EDITBOX" "edit52" {
        EditTextFrame "edit_text52",
        Frame "TEXT" "edit_text52" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.052000, "", 
        }
    }
]====] ] = "edit_52",
[ [====[
    Frame "TEXT" "text53" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.053, "",
    }
]====] ] = "font_53",
[ [====[
    Frame "TEXT" "text53" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.053, "",
    }
]====] ] = "font2_53",
[ [====[
    Frame "EDITBOX" "edit53" {
        EditTextFrame "edit_text53",
        Frame "TEXT" "edit_text53" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.053000, "", 
        }
    }
]====] ] = "edit_53",
[ [====[
    Frame "TEXT" "text54" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.054, "",
    }
]====] ] = "font_54",
[ [====[
    Frame "TEXT" "text54" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.054, "",
    }
]====] ] = "font2_54",
[ [====[
    Frame "EDITBOX" "edit54" {
        EditTextFrame "edit_text54",
        Frame "TEXT" "edit_text54" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.054000, "", 
        }
    }
]====] ] = "edit_54",
[ [====[
    Frame "TEXT" "text55" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.055, "",
    }
]====] ] = "font_55",
[ [====[
    Frame "TEXT" "text55" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.055, "",
    }
]====] ] = "font2_55",
[ [====[
    Frame "EDITBOX" "edit55" {
        EditTextFrame "edit_text55",
        Frame "TEXT" "edit_text55" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.055000, "", 
        }
    }
]====] ] = "edit_55",
[ [====[
    Frame "TEXT" "text56" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.056, "",
    }
]====] ] = "font_56",
[ [====[
    Frame "TEXT" "text56" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.056, "",
    }
]====] ] = "font2_56",
[ [====[
    Frame "EDITBOX" "edit56" {
        EditTextFrame "edit_text56",
        Frame "TEXT" "edit_text56" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.056000, "", 
        }
    }
]====] ] = "edit_56",
[ [====[
    Frame "TEXT" "text57" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.057, "",
    }
]====] ] = "font_57",
[ [====[
    Frame "TEXT" "text57" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.057, "",
    }
]====] ] = "font2_57",
[ [====[
    Frame "EDITBOX" "edit57" {
        EditTextFrame "edit_text57",
        Frame "TEXT" "edit_text57" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.057000, "", 
        }
    }
]====] ] = "edit_57",
[ [====[
    Frame "TEXT" "text58" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.058, "",
    }
]====] ] = "font_58",
[ [====[
    Frame "TEXT" "text58" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.058, "",
    }
]====] ] = "font2_58",
[ [====[
    Frame "EDITBOX" "edit58" {
        EditTextFrame "edit_text58",
        Frame "TEXT" "edit_text58" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.058000, "", 
        }
    }
]====] ] = "edit_58",
[ [====[
    Frame "TEXT" "text59" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.059, "",
    }
]====] ] = "font_59",
[ [====[
    Frame "TEXT" "text59" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.059, "",
    }
]====] ] = "font2_59",
[ [====[
    Frame "EDITBOX" "edit59" {
        EditTextFrame "edit_text59",
        Frame "TEXT" "edit_text59" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.059000, "", 
        }
    }
]====] ] = "edit_59",
[ [====[
    Frame "TEXT" "text60" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.06, "",
    }
]====] ] = "font_60",
[ [====[
    Frame "TEXT" "text60" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.06, "",
    }
]====] ] = "font2_60",
[ [====[
    Frame "EDITBOX" "edit60" {
        EditTextFrame "edit_text60",
        Frame "TEXT" "edit_text60" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.060000, "", 
        }
    }
]====] ] = "edit_60",
[ [====[
    Frame "TEXT" "text61" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.061, "",
    }
]====] ] = "font_61",
[ [====[
    Frame "TEXT" "text61" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.061, "",
    }
]====] ] = "font2_61",
[ [====[
    Frame "EDITBOX" "edit61" {
        EditTextFrame "edit_text61",
        Frame "TEXT" "edit_text61" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.061000, "", 
        }
    }
]====] ] = "edit_61",
[ [====[
    Frame "TEXT" "text62" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.062, "",
    }
]====] ] = "font_62",
[ [====[
    Frame "TEXT" "text62" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.062, "",
    }
]====] ] = "font2_62",
[ [====[
    Frame "EDITBOX" "edit62" {
        EditTextFrame "edit_text62",
        Frame "TEXT" "edit_text62" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.062000, "", 
        }
    }
]====] ] = "edit_62",
[ [====[
    Frame "TEXT" "text63" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.063, "",
    }
]====] ] = "font_63",
[ [====[
    Frame "TEXT" "text63" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.063, "",
    }
]====] ] = "font2_63",
[ [====[
    Frame "EDITBOX" "edit63" {
        EditTextFrame "edit_text63",
        Frame "TEXT" "edit_text63" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.063000, "", 
        }
    }
]====] ] = "edit_63",
[ [====[
    Frame "TEXT" "text64" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont.ttc", 0.064, "",
    }
]====] ] = "font_64",
[ [====[
    Frame "TEXT" "text64" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "Fonts\gamefont2.ttc", 0.064, "",
    }
]====] ] = "font2_64",
[ [====[
    Frame "EDITBOX" "edit64" {
        EditTextFrame "edit_text64",
        Frame "TEXT" "edit_text64" {
            LayerStyle "IGNORETRACKEVENTS",
            FrameFont "MasterFont", 0.064000, "", 
        }
    }
]====] ] = "edit_64",
}
-- 생성된 원본 정의 표를 사용해 파일 읽기 진단과 실제 FDF 로딩을 구분한다.
local M, loaded = {}, {}
local function marker(name)
  return '\nFrame "BACKDROP" "HeraFdfCheckTemplate_' .. name .. '" {\n    Width 0.015625,\n    Height 0.015625,\n}\n'
end

local function inspect(storm, path, expected)
  local ok, actual = pcall(storm.load, path)
  if not ok then
    print("HERA FDF read exception " .. path .. " " .. tostring(actual))
  elseif actual == nil or actual == "" then
    -- 빈 Storm 읽기만으로 초기화를 중단하지 않고 아래 네이티브 적용 검사를 수행한다.
    print("HERA FDF read unavailable " .. path .. " result=" .. tostring(actual == nil and "nil" or "empty") .. "; native validation required")
  else
    assert(type(actual) == "string", "HERA_FDF_READ_TYPE: " .. path .. " " .. type(actual))
    assert(actual == expected, "HERA_FDF_CONTENT: " .. path .. " expected=" .. #expected .. " actual=" .. #actual)
    print("HERA FDF read matched " .. path .. " bytes=" .. #actual)
  end
end

function M.load(data)
  local name = catalog[data]
  assert(name, "HERA_FDF_UNPACKAGED: UI definition is not in this build (font/edit sizes 0..64)")
  if loaded[name] then return end
  local stem = "HeraRPGv3_" .. name
  local fdf, toc = stem .. ".fdf", stem .. ".toc"
  local storm = require("jass.storm")
  inspect(storm, fdf, data .. marker(name))
  inspect(storm, toc, fdf .. "\r\n")
  local ui = require("jass.japi")
  print("HERA FDF native loading " .. toc)
  ui.LoadToc(toc)
  local frame = ui.CreateFrameByTagName("BACKDROP", "HeraFdfCheck_" .. name,
    ui.GetGameUI(), "HeraFdfCheckTemplate_" .. name, 0)
  assert(frame and frame ~= 0, "HERA_FDF_CREATE: " .. toc)
  local ok, height = pcall(function()
    ui.FrameShow(frame, false)
    return ui.FrameGetHeight(frame)
  end)
  ui.DestroyFrame(frame)
  if not ok then error(height, 0) end
  assert(type(height) == "number" and math.abs(height - 0.015625) < 0.00001,
    "HERA_FDF_APPLY: " .. toc .. " expected height=0.015625 actual=" .. tostring(height))
  loaded[name] = true
  print("HERA FDF native verified " .. toc .. " height=" .. tostring(height))
end
return M
