library UIShop initializer init requires DataUnit, FrameCount
	globals
	integer SHOP_BackDrop                         //상점 배경
	integer SHOP_CancelButton                     //상점 취소버튼
	integer SHOP_Sell                             //상점 1개 팔기
	integer SHOP_Sell2                            //상점 10개 팔기
	integer SHOP_SellAll                          //상점 다팔기
	integer SHOP_CombinationText
	integer SHOP_L
	string SHOP_Select = ""
	integer array SHOP_Button                     //템 버튼
	integer array SHOP_ButtonBackDrop             //템 백드롭
	integer array SHOP_HowMuch                    //템 백드롭
	integer array SHOP_Much                       //템 백드롭
	
	boolean array SHOP_OnOff                      //플레이어 온오프


	integer SHOP2_BackDrop                        //상점 배경
	integer SHOP2_CancelButton                    //상점 취소버튼
	integer SHOP2_Sell                            //상점 1개 팔기
	integer SHOP2_Sell2                           //상점 10개 팔기
	integer SHOP2_SellAll                         //상점 다팔기
	integer SHOP2_CombinationText
	integer SHOP2_L
	string SHOP2_Select = ""
	integer array SHOP2_Button                    //템 버튼
	integer array SHOP2_ButtonBackDrop            //템 백드롭
	integer array SHOP2_HowMuch                   //템 백드롭
	integer array SHOP2_Much                      //템 백드롭
	integer array SHOP2_MuchP                     //실제 가격
	
	boolean array SHOP2_OnOff                     //플레이어 온오프
	endglobals
	
	private function ShowMenu takes nothing returns nothing
		if SHOP_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
			call DzFrameShow(SHOP_BackDrop, false)
			set SHOP_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
		else
			call DzFrameShow(SHOP_BackDrop, true)
			set SHOP_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
		endif
	endfunction
	
	private function ShowMenu2 takes nothing returns nothing
		if SHOP2_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
			call DzFrameShow(SHOP2_BackDrop, false)
			set SHOP2_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
		else
			call DzFrameShow(SHOP2_BackDrop, true)
			set SHOP2_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
		endif
	endfunction

	private function Sell takes nothing returns nothing
		local integer f = DzGetTriggerUIEventFrame()
		local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
		local integer i = 0
        //루프
		local integer j = 50
        //개수
        local integer k = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer length = 0
        local integer pri
		
		if GetItemIDs2(SHOP_Select) == "73" then
			set i = 1
		elseif GetItemIDs2(SHOP_Select) == "74" then
			set i = 2
		elseif GetItemIDs2(SHOP_Select) == "75" then
			set i = 3
		elseif GetItemIDs2(SHOP_Select) == "76" then
			set i = 4
		elseif GetItemIDs2(SHOP_Select) == "77" then
			set i = 5
		endif

		if i != 0 then
			loop
				if StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0") == SHOP_Select then
					set k = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0"))
					//1개면 지우기
					if k == 1 then
						//아이템 지우기
						call DzFrameSetTexture(F_ItemButtonsBackDrop[j], "UI_Inventory.blp", 0)
						call DzFrameShow(UI_Tip, false)
						call StashRemove(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j))
					else
						set SHOP_Select = SetItemCharge(SHOP_Select, k-1)
						call StashSave(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), SHOP_Select)
					endif
					//i를 사용하여 1개만큼 돈주세요
					set pri = S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) + Price[i-1]
					call StashSave(PLAYER_DATA[pid], "골드", I2S(pri))
					call DzFrameSetText(F_GoldText, I2S(pri))
				endif
				set j = j + 1
			exitwhen j == 100
			endloop
		endif
	endfunction
	
	
	private function Sell3 takes nothing returns nothing
		local integer f = DzGetTriggerUIEventFrame()
		local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
		local integer i = 0
        //루프
		local integer j = 50
        //개수
        local integer k = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer length = 0
        local integer pri
		//누른버튼
		local integer sb = 0
		
		if f == SHOP2_Sell then
			set sb = 1
		elseif f == SHOP2_Sell2 then
			set sb = 2
		elseif f == SHOP2_SellAll then
			set sb = 3
		endif
		
		if GetItemIDs2(SHOP2_Select) == "73" then
			set i = 1
		elseif GetItemIDs2(SHOP2_Select) == "74" then
			set i = 2
		elseif GetItemIDs2(SHOP2_Select) == "75" then
			set i = 3
		elseif GetItemIDs2(SHOP2_Select) == "76" then
			set i = 4
		elseif GetItemIDs2(SHOP2_Select) == "77" then
			set i = 5
		endif

		if i != 0 then
			loop
				if StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0") == SHOP2_Select then
					set k = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0"))
					if sb == 1 then
						//1개면 지우기
						if k == 1 then
							//아이템 지우기
							call DzFrameSetTexture(F_ItemButtonsBackDrop[j], "UI_Inventory.blp", 0)
							call DzFrameShow(UI_Tip, false)
							call StashRemove(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j))
						else
							set SHOP2_Select = SetItemCharge(SHOP2_Select, k-1)
							call StashSave(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), SHOP2_Select)
						endif
						//i를 사용하여 1개만큼 돈주세요
						set pri = S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) + SHOP2_MuchP[i]
						call StashSave(PLAYER_DATA[pid], "골드", I2S(pri))
						call DzFrameSetText(F_GoldText, I2S(pri))
					elseif sb == 2 then
						if k < 10 then
						else
						//10개면 지우기
							if k == 10 then
								//아이템 지우기
								call DzFrameSetTexture(F_ItemButtonsBackDrop[j], "UI_Inventory.blp", 0)
								call DzFrameShow(UI_Tip, false)
								call StashRemove(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j))
							else
								set SHOP2_Select = SetItemCharge(SHOP2_Select, k-10)
								call StashSave(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), SHOP2_Select)
							endif
							//i를 사용하여 10개만큼 돈주세요
							set pri = S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) + ( SHOP2_MuchP[i] * 10 )
							call StashSave(PLAYER_DATA[pid], "골드", I2S(pri))
							call DzFrameSetText(F_GoldText, I2S(pri))
						endif
					elseif sb == 3 then
						//아이템 지우기
						call DzFrameSetTexture(F_ItemButtonsBackDrop[j], "UI_Inventory.blp", 0)
						call DzFrameShow(UI_Tip, false)
						call StashRemove(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j))
						//i를 사용하여 판만큼 돈주세요
						set pri = S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) + ( SHOP2_MuchP[i] * k )
						call StashSave(PLAYER_DATA[pid], "골드", I2S(pri))
						call DzFrameSetText(F_GoldText, I2S(pri))
					endif
				endif
				set j = j + 1
			exitwhen j == 100
			endloop
		endif
	endfunction

	private function Sell2 takes nothing returns nothing
		local integer f = DzGetTriggerUIEventFrame()
		local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
		local integer i = 0
        //루프
		local integer j = 50
        //개수
        local integer k = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer length = 0
        local integer pri
		
		if GetItemIDs2(SHOP_Select) == "73" then
			set i = 1
		elseif GetItemIDs2(SHOP_Select)  == "74" then
			set i = 2
		elseif GetItemIDs2(SHOP_Select)  == "75" then
			set i = 3
		elseif GetItemIDs2(SHOP_Select)  == "76" then
			set i = 4
		elseif GetItemIDs2(SHOP_Select)  == "77" then
			set i = 5
		endif

		if i != 0 then
			loop
				if StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0") == SHOP_Select then
					set k = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0"))
					if k < 10 then
					else
					//1개면 지우기
						if k == 10 then
							//아이템 지우기
							call DzFrameSetTexture(F_ItemButtonsBackDrop[j], "UI_Inventory.blp", 0)
							call DzFrameShow(UI_Tip, false)
							call StashRemove(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j))
						else
							set SHOP_Select = SetItemCharge(SHOP_Select, k-10)
							call StashSave(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), SHOP_Select)
						endif
						//i를 사용하여 10개만큼 돈주세요
						set pri = S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) + ( Price[i-1] * 10 )
						call StashSave(PLAYER_DATA[pid], "골드", I2S(pri))
						call DzFrameSetText(F_GoldText, I2S(pri))
					endif
				endif
				set j = j + 1
			exitwhen j == 100
			endloop
		endif
	endfunction

	private function SellAll takes nothing returns nothing
		local integer f = DzGetTriggerUIEventFrame()
		local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
		local integer i = 0
        //루프
		local integer j = 50
        //개수
        local integer k = 0
        local string sn = I2S(PlayerSlotNumber[pid])
        local integer pri
		
		if GetItemIDs2(SHOP_Select) == "73" then
			set i = 1
		elseif GetItemIDs2(SHOP_Select) == "74" then
			set i = 2
		elseif GetItemIDs2(SHOP_Select) == "75" then
			set i = 3
		elseif GetItemIDs2(SHOP_Select) == "76" then
			set i = 4
		elseif GetItemIDs2(SHOP_Select) == "77" then
			set i = 5
		endif

		if i != 0 then
			loop
				if StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0") == SHOP_Select then
					set k = GetItemCharge(StashLoad(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j), "0"))
					//아이템 지우기
					call DzFrameSetTexture(F_ItemButtonsBackDrop[j], "UI_Inventory.blp", 0)
					call DzFrameShow(UI_Tip, false)
					call StashRemove(PLAYER_DATA[pid], "슬롯" + sn + ".아이템" + I2S(j))
					//i를 사용하여 판만큼 돈주세요
					set pri = S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) + ( Price[i-1] * k )
					call StashSave(PLAYER_DATA[pid], "골드", I2S(pri))
					call DzFrameSetText(F_GoldText, I2S(pri))
				endif
				set j = j + 1
			exitwhen j == 100
			endloop
		endif
	endfunction
	
	private function F_OFF_Actions takes nothing returns nothing
		call DzFrameShow(UI_Tip, false)
	endfunction
	
	//아이콘 생성 함수
	private function CreateItemButton takes integer types, real x, real y returns nothing
		set SHOP_Button[types]= DzCreateFrameByTagName("BUTTON", "", SHOP_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
		call DzFrameSetPoint(SHOP_Button[types], JN_FRAMEPOINT_CENTER, SHOP_BackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
		call DzFrameSetSize(SHOP_Button[types], 0.040, 0.040)
		
		set SHOP_ButtonBackDrop[types]= DzCreateFrameByTagName("BACKDROP", "", SHOP_Button[types], "", FrameCount())
		call DzFrameSetAllPoints(SHOP_ButtonBackDrop[types], SHOP_Button[types])
	endfunction

	//아이콘 생성 함수
	private function CreateItemButton2 takes integer types, real x, real y returns nothing
		set SHOP2_Button[types]= DzCreateFrameByTagName("BUTTON", "", SHOP2_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
		call DzFrameSetPoint(SHOP2_Button[types], JN_FRAMEPOINT_CENTER, SHOP2_BackDrop , JN_FRAMEPOINT_TOPLEFT, x, y)
		call DzFrameSetSize(SHOP2_Button[types], 0.040, 0.040)
		
		set SHOP2_ButtonBackDrop[types]= DzCreateFrameByTagName("BACKDROP", "", SHOP2_Button[types], "", FrameCount())
		call DzFrameSetAllPoints(SHOP2_ButtonBackDrop[types], SHOP2_Button[types])
	endfunction
	
	private function Main takes nothing returns nothing
		local string s
		local integer i
		
		set SHOP_BackDrop = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
		call DzFrameSetAbsolutePoint(SHOP_BackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.300)
		call DzFrameSetSize(SHOP_BackDrop, 0.40, 0.30)
		
		set SHOP_CombinationText = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_CombinationText, JN_FRAMEPOINT_TOPLEFT, SHOP_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.025, -0.025)
		call DzFrameSetText(SHOP_CombinationText, "가공품 상점")
		
		set SHOP_CancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP_CancelButton, JN_FRAMEPOINT_TOPRIGHT, SHOP_BackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
		call DzFrameSetText(SHOP_CancelButton, "X")
		call DzFrameSetSize(SHOP_CancelButton, 0.03, 0.03)
		call DzFrameSetScriptByCode(SHOP_CancelButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
		
		call CreateItemButton(0 , 0.045 , -0.070)
		call CreateItemButton(1 , 0.045 , -0.115)
		call CreateItemButton(2 , 0.045 , -0.160)
		call CreateItemButton(3 , 0.045 , -0.205)
		call CreateItemButton(4 , 0.045 , -0.250)
		
		call DzFrameSetTexture(SHOP_ButtonBackDrop[0], "ReplaceableTextures\\CommandButtons\\BTNArcana19.blp", 0)
		call DzFrameSetTexture(SHOP_ButtonBackDrop[1], "ReplaceableTextures\\CommandButtons\\BTNArcana20.blp", 0)
		call DzFrameSetTexture(SHOP_ButtonBackDrop[2], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
		call DzFrameSetTexture(SHOP_ButtonBackDrop[3], "ReplaceableTextures\\CommandButtons\\BTNArcana12.blp", 0)
		call DzFrameSetTexture(SHOP_ButtonBackDrop[4], "ReplaceableTextures\\CommandButtons\\BTNArcana09.blp", 0)
		
		set SHOP_HowMuch[0] = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_HowMuch[0], JN_FRAMEPOINT_CENTER, SHOP_ButtonBackDrop[0] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP_HowMuch[0], "1234")
		set SHOP_HowMuch[1] = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_HowMuch[1], JN_FRAMEPOINT_CENTER, SHOP_ButtonBackDrop[1] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP_HowMuch[1], "1234")
		set SHOP_HowMuch[2] = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_HowMuch[2], JN_FRAMEPOINT_CENTER, SHOP_ButtonBackDrop[2] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP_HowMuch[2], "1234")
		set SHOP_HowMuch[3] = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_HowMuch[3], JN_FRAMEPOINT_CENTER, SHOP_ButtonBackDrop[3] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP_HowMuch[3], "1234")
		set SHOP_HowMuch[4] = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_HowMuch[4], JN_FRAMEPOINT_CENTER, SHOP_ButtonBackDrop[4] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP_HowMuch[4], "1234")
		
		set SHOP_L = DzCreateFrameByTagName("BACKDROP", "", SHOP_BackDrop, "template", FrameCount())
		call DzFrameSetTexture(SHOP_L, "UI_L.blp", 0)
		call DzFrameSetSize(SHOP_L, 0.060, 0.060)
		call DzFrameSetPoint(SHOP_L, JN_FRAMEPOINT_CENTER, SHOP_BackDrop, JN_FRAMEPOINT_CENTER, -0.010, 0.030)
		
		set SHOP_Sell = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP_Sell, JN_FRAMEPOINT_CENTER, SHOP_BackDrop , JN_FRAMEPOINT_CENTER, 0.050, -0.070)
		call DzFrameSetText(SHOP_Sell, "1개 팔기")
		call DzFrameSetSize(SHOP_Sell, 0.080, 0.030)
		call DzFrameSetScriptByCode(SHOP_Sell, JN_FRAMEEVENT_MOUSE_UP, function Sell, false)
		set SHOP_Sell2 = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP_Sell2, JN_FRAMEPOINT_CENTER, SHOP_BackDrop , JN_FRAMEPOINT_CENTER, 0.130, -0.070)
		call DzFrameSetText(SHOP_Sell2, "10개 팔기")
		call DzFrameSetSize(SHOP_Sell2, 0.080, 0.030)
		call DzFrameSetScriptByCode(SHOP_Sell2, JN_FRAMEEVENT_MOUSE_UP, function Sell2, false)
		set SHOP_SellAll = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP_SellAll, JN_FRAMEPOINT_CENTER, SHOP_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, -0.100)
		call DzFrameSetText(SHOP_SellAll, "다팔기")
		call DzFrameSetSize(SHOP_SellAll, 0.160, 0.030)
		call DzFrameSetScriptByCode(SHOP_SellAll, JN_FRAMEEVENT_MOUSE_UP, function SellAll, false)
		
		set SHOP_Button[5]= DzCreateFrameByTagName("BUTTON", "", SHOP_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
		call DzFrameSetPoint(SHOP_Button[5], JN_FRAMEPOINT_CENTER, SHOP_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, 0.075)
		call DzFrameSetSize(SHOP_Button[5], 0.040, 0.040)
		
		set SHOP_ButtonBackDrop[5]= DzCreateFrameByTagName("BACKDROP", "", SHOP_Button[5], "", FrameCount())
		call DzFrameSetAllPoints(SHOP_ButtonBackDrop[5], SHOP_Button[5])
		call DzFrameSetTexture(SHOP_ButtonBackDrop[5], "UI_Inventory.blp", 0)
		
		set SHOP_Much[0] = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_Much[0], JN_FRAMEPOINT_CENTER, SHOP_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, 0.020)
		call DzFrameSetText(SHOP_Much[0], " 1개 가격 :       ")
		
		set SHOP_Much[1] = DzCreateFrameByTagName("TEXT", "", SHOP_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP_Much[1], JN_FRAMEPOINT_CENTER, SHOP_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, -0.020)
		call DzFrameSetText(SHOP_Much[1], "10개 가격 :       ")
		
		call DzFrameShow(SHOP_BackDrop, false)

		
		set SHOP2_BackDrop = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
		call DzFrameSetAbsolutePoint(SHOP2_BackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.300)
		call DzFrameSetSize(SHOP2_BackDrop, 0.40, 0.30)
		
		set SHOP2_CombinationText = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_CombinationText, JN_FRAMEPOINT_TOPLEFT, SHOP2_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.025, -0.025)
		call DzFrameSetText(SHOP2_CombinationText, "재료 판매")
		
		set SHOP2_CancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP2_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP2_CancelButton, JN_FRAMEPOINT_TOPRIGHT, SHOP2_BackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
		call DzFrameSetText(SHOP2_CancelButton, "X")
		call DzFrameSetSize(SHOP2_CancelButton, 0.03, 0.03)
		call DzFrameSetScriptByCode(SHOP2_CancelButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu2, false)
		
		call CreateItemButton2(0 , 0.045 , -0.070)
		call CreateItemButton2(1 , 0.045 , -0.115)
		call CreateItemButton2(2 , 0.045 , -0.160)
		call CreateItemButton2(3 , 0.045 , -0.205)
		call CreateItemButton2(4 , 0.045 , -0.250)
		
		call DzFrameSetTexture(SHOP2_ButtonBackDrop[0], "ReplaceableTextures\\CommandButtons\\BTNArcana19.blp", 0)
		call DzFrameSetTexture(SHOP2_ButtonBackDrop[1], "ReplaceableTextures\\CommandButtons\\BTNArcana20.blp", 0)
		call DzFrameSetTexture(SHOP2_ButtonBackDrop[2], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
		call DzFrameSetTexture(SHOP2_ButtonBackDrop[3], "ReplaceableTextures\\CommandButtons\\BTNArcana12.blp", 0)
		call DzFrameSetTexture(SHOP2_ButtonBackDrop[4], "ReplaceableTextures\\CommandButtons\\BTNArcana09.blp", 0)
		
		set SHOP2_HowMuch[0] = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_HowMuch[0], JN_FRAMEPOINT_CENTER, SHOP2_ButtonBackDrop[0] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP2_HowMuch[0], "5")
		set SHOP2_HowMuch[1] = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_HowMuch[1], JN_FRAMEPOINT_CENTER, SHOP2_ButtonBackDrop[1] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP2_HowMuch[1], "25")
		set SHOP2_HowMuch[2] = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_HowMuch[2], JN_FRAMEPOINT_CENTER, SHOP2_ButtonBackDrop[2] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP2_HowMuch[2], "125")
		set SHOP2_HowMuch[3] = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_HowMuch[3], JN_FRAMEPOINT_CENTER, SHOP2_ButtonBackDrop[3] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP2_HowMuch[3], "625")
		set SHOP2_HowMuch[4] = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_HowMuch[4], JN_FRAMEPOINT_CENTER, SHOP2_ButtonBackDrop[4] , JN_FRAMEPOINT_CENTER, 0.070, 0.0)
		call DzFrameSetText(SHOP2_HowMuch[4], "3125")
		set SHOP2_MuchP[1] = 5
		set SHOP2_MuchP[2] = 25
		set SHOP2_MuchP[3] = 125
		set SHOP2_MuchP[4] = 625
		set SHOP2_MuchP[5] = 3125
		
		set SHOP2_L = DzCreateFrameByTagName("BACKDROP", "", SHOP2_BackDrop, "template", FrameCount())
		call DzFrameSetTexture(SHOP2_L, "UI_L.blp", 0)
		call DzFrameSetSize(SHOP2_L, 0.060, 0.060)
		call DzFrameSetPoint(SHOP2_L, JN_FRAMEPOINT_CENTER, SHOP2_BackDrop, JN_FRAMEPOINT_CENTER, -0.010, 0.030)
		
		set SHOP2_Sell = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP2_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP2_Sell, JN_FRAMEPOINT_CENTER, SHOP2_BackDrop , JN_FRAMEPOINT_CENTER, 0.050, -0.070)
		call DzFrameSetText(SHOP2_Sell, "1개 팔기")
		call DzFrameSetSize(SHOP2_Sell, 0.080, 0.030)
		call DzFrameSetScriptByCode(SHOP2_Sell, JN_FRAMEEVENT_MOUSE_UP, function Sell3, false)
		set SHOP2_Sell2 = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP2_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP2_Sell2, JN_FRAMEPOINT_CENTER, SHOP2_BackDrop , JN_FRAMEPOINT_CENTER, 0.130, -0.070)
		call DzFrameSetText(SHOP2_Sell2, "10개 팔기")
		call DzFrameSetSize(SHOP2_Sell2, 0.080, 0.030)
		call DzFrameSetScriptByCode(SHOP2_Sell2, JN_FRAMEEVENT_MOUSE_UP, function Sell3, false)
		set SHOP2_SellAll = DzCreateFrameByTagName("GLUETEXTBUTTON", "", SHOP2_BackDrop, "ScriptDialogButton", 0)
		call DzFrameSetPoint(SHOP2_SellAll, JN_FRAMEPOINT_CENTER, SHOP2_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, -0.100)
		call DzFrameSetText(SHOP2_SellAll, "다팔기")
		call DzFrameSetSize(SHOP2_SellAll, 0.160, 0.030)
		call DzFrameSetScriptByCode(SHOP2_SellAll, JN_FRAMEEVENT_MOUSE_UP, function Sell3, false)
		
		set SHOP2_Button[5]= DzCreateFrameByTagName("BUTTON", "", SHOP2_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
		call DzFrameSetPoint(SHOP2_Button[5], JN_FRAMEPOINT_CENTER, SHOP2_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, 0.075)
		call DzFrameSetSize(SHOP2_Button[5], 0.040, 0.040)
		
		set SHOP2_ButtonBackDrop[5]= DzCreateFrameByTagName("BACKDROP", "", SHOP2_Button[5], "", FrameCount())
		call DzFrameSetAllPoints(SHOP2_ButtonBackDrop[5], SHOP2_Button[5])
		call DzFrameSetTexture(SHOP2_ButtonBackDrop[5], "UI_Inventory.blp", 0)
		
		set SHOP2_Much[0] = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_Much[0], JN_FRAMEPOINT_CENTER, SHOP2_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, 0.020)
		call DzFrameSetText(SHOP2_Much[0], " 1개 가격 :       ")
		
		set SHOP2_Much[1] = DzCreateFrameByTagName("TEXT", "", SHOP2_BackDrop, "", FrameCount())
		call DzFrameSetPoint(SHOP2_Much[1], JN_FRAMEPOINT_CENTER, SHOP2_BackDrop , JN_FRAMEPOINT_CENTER, 0.090, -0.020)
		call DzFrameSetText(SHOP2_Much[1], "10개 가격 :       ")
		
		call DzFrameShow(SHOP2_BackDrop, false)
	endfunction

	private function init takes nothing returns nothing
		local trigger t = CreateTrigger()
		local integer index
		
		set t = CreateTrigger()
		call TriggerAddAction(t, function Main)
		call TriggerRegisterTimerEventSingle(t, 0.1)
		
		set index = 0
		loop
			set SHOP_OnOff[index] = false
			set SHOP2_OnOff[index] = false
			set index = index + 1
		exitwhen index == 6
		endloop
		
		set t = null
		
	endfunction
endlibrary