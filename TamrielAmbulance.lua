TamrielAmbulance = {}

-- AddOn variables
TamrielAmbulance.name = "TamrielAmbulance"
TamrielAmbulance.prettyName = "Tamriel Ambulance"
TamrielAmbulance.coloredName = "|cff0000Tamriel |c000000Ambulance|r"
TamrielAmbulance.author = "|cff6600Infenix|r"
TamrielAmbulance.version = "1.2.0"
TamrielAmbulance.website = "https://github.com/ImInfenix/TamrielAmbulance"

-------------------------------------------------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.Initialize()
	TamrielAmbulance.savedVariables = ZO_SavedVars:NewAccountWide("TamrielAmbulance_SavedVariables", 1, nil, {})
	TamrielAmbulance.displayAddonLoadedMessage = TamrielAmbulance.savedVariables.displayAddonLoadedMessage

	-- LibAddonMenu-2.0 Initializing
	TamrielAmbulance.InitializeLAM()

	-- Window display settings restore
	if TamrielAmbulance.savedVariables.GUILeft == nil then
		TamrielAmbulance.savedVariables.GUILeft = 0
	end
	if TamrielAmbulance.savedVariables.GUITop == nil then
		TamrielAmbulance.savedVariables.GUITop = 540
	end
	if TamrielAmbulance.savedVariables.resurrectionCount == nil then
		TamrielAmbulance.savedVariables.resurrectionCount = 0
	end
	if TamrielAmbulance.savedVariables.recordedResurrections == nil then
		TamrielAmbulance.savedVariables.recordedResurrections = {}
	end

	TamrielAmbulance.shouldDisplay = true
	TamrielAmbulance.UpdateDisplayCondition()

	local left = TamrielAmbulance.savedVariables.GUILeft
	local top = TamrielAmbulance.savedVariables.GUITop

	GUI_TamrielAmbulance:ClearAnchors()
	GUI_TamrielAmbulance:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	TamrielAmbulance.UpdateFontSize()

	-- AddOn Loading
	EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_PLAYER_ACTIVATED, TamrielAmbulance.OnPlayerActivated)

	-- Game Layout
	EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ACTION_LAYER_POPPED, TamrielAmbulance.LayerPopped)
	EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ACTION_LAYER_PUSHED, TamrielAmbulance.LayerPushed)

	-- AddOn Tracking
	EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_RESURRECT_RESULT,
		TamrielAmbulance.OnResurrectionResultReceived)
	EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_GROUP_MEMBER_JOINED,
		TamrielAmbulance.OnMemberJoinedGroup)
	EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_GROUP_MEMBER_LEFT, TamrielAmbulance.OnMemberLeftGroup)

	TamrielAmbulance.UpdateWindow()
end

function TamrielAmbulance.OnAddOnLoaded(eventCode, addonName)
	if (addonName ~= TamrielAmbulance.name or isLoaded) then
		return
	end

	-- Unregister for load event
	EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

	TamrielAmbulance.Initialize()
end

function TamrielAmbulance.OnPlayerActivated(eventCode)
	-- Unregister for player activated event
	EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
end

-------------------------------------------------------------------------------------------------------------------------
-- Core AddOn Callbacks
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.OnResurrectionResultReceived(eventCode, targetCharacterName, result, targetDisplayName)
	if (result == RESURRECT_RESULT_SUCCESS) then
		local resurrectionsTable = TamrielAmbulance.savedVariables.recordedResurrections
		local currentCount = resurrectionsTable[targetCharacterName]
		if(currentCount == nil) then resurrectionsTable[targetCharacterName] = 1
		else resurrectionsTable[targetCharacterName] = currentCount + 1 end
		TamrielAmbulance.UpdateWindow()
	end
end

-------------------------------------------------------------------------------------------------------------------------
-- Core AddOn Functions
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.UpdateDisplayCondition()
	if (TamrielAmbulance.savedVariables.showOnlyInGroup) then
		TamrielAmbulance.shouldDisplay = IsPlayerInGroup(GetUnitName("player"))
	else
		TamrielAmbulance.shouldDisplay = true
	end
end

-------------------------------------------------------------------------------------------------------------------------
-- Other Callbacks
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.OnMemberJoinedGroup(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
	if (isLocalPlayer) then
		if (TamrielAmbulance.savedVariables.showOnlyInGroup) then
			TamrielAmbulance.shouldDisplay = true
			TamrielAmbulance.ToggleWindow(true)
		end
		if (TamrielAmbulance.savedVariables.resetOnGroupJoined) then
			TamrielAmbulance.ResetCounter()
		end
	end
end

function TamrielAmbulance.OnMemberLeftGroup(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader,
	memberDisplayName, actionRequiredVote)
	if (isLocalPlayer and TamrielAmbulance.savedVariables.showOnlyInGroup) then
		TamrielAmbulance.shouldDisplay = false
		TamrielAmbulance.ToggleWindow(false)
	end
end

-------------------------------------------------------------------------------------------------------------------------
-- UI Handling
-------------------------------------------------------------------------------------------------------------------------

function TamrielAmbulance.LayerPopped(eventCode, layerIndex, activeLayerIndex)
	TamrielAmbulance.ToggleWindow(activeLayerIndex == 2)
end

function TamrielAmbulance.LayerPushed(eventCode, layerIndex, activeLayerIndex)
	TamrielAmbulance.ToggleWindow(activeLayerIndex == 2)
end

function TamrielAmbulance.SaveWindowPosition()
	TamrielAmbulance.savedVariables.GUILeft = GUI_TamrielAmbulance:GetLeft()
	TamrielAmbulance.savedVariables.GUITop = GUI_TamrielAmbulance:GetTop()
end

function TamrielAmbulance.ToggleWindow(value)
	GUI_TamrielAmbulance:SetHidden(not value or not TamrielAmbulance.shouldDisplay)
end

function TamrielAmbulance.SwitchDisplayStatus()
	TamrielAmbulance.shouldDisplay = not TamrielAmbulance.shouldDisplay
	TamrielAmbulance.ToggleWindow(true)
end

function TamrielAmbulance.ResetCounter()
	TamrielAmbulance.savedVariables.recordedResurrections = {}
	TamrielAmbulance.UpdateWindow()
end

function TamrielAmbulance.UpdateWindow()

	local resurrectionsTable = TamrielAmbulance.savedVariables.recordedResurrections

	if (not TamrielAmbulance.savedVariables.displayByPlayer) then
		local resurrectionCount = 0
		for name, count in pairs(resurrectionsTable) do
			resurrectionCount = resurrectionCount + count
		end
		GUI_TamrielAmbulanceCounter:SetText(resurrectionCount)
	else
		local playersNames = nil

		local ordered_keys = {}

		for key in pairs(resurrectionsTable) do
			table.insert(ordered_keys, key)
		end

		table.sort(ordered_keys)
		for i = 1, #ordered_keys do
			local key, value = ordered_keys[i], resurrectionsTable[ordered_keys[i]]
			local toPrint = key .. " " .. value
			if(playersNames == nil) then playersNames = toPrint
			else playersNames = playersNames .. "\n" .. toPrint end
		end

		GUI_TamrielAmbulanceCounter:SetText(playersNames)
	end
end

function TamrielAmbulance.UpdateFontSize()
	local font = "ZoFontWinH3"
	if (TamrielAmbulance.savedVariables.fontSize == "Large") then
		font = "ZoFontWinH2"
	end
	if (TamrielAmbulance.savedVariables.fontSize == "Small") then
		font = "ZoFontWinH4"
	end
	if (TamrielAmbulance.savedVariables.fontSize == "Tiny") then
		font = "ZoFontWinH5"
	end
	GUI_TamrielAmbulanceTitle:SetFont(font)
	GUI_TamrielAmbulanceCounter:SetFont(font)
end

-------------------------------------------------------------------------------------------------------------------------
-- Entry Point
-------------------------------------------------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ADD_ON_LOADED, TamrielAmbulance.OnAddOnLoaded)

-------------------------------------------------------------------------------------------------------------------------
-- AddOn Commands
-------------------------------------------------------------------------------------------------------------------------

SLASH_COMMANDS["/ambulance"] = TamrielAmbulance.SwitchDisplayStatus
SLASH_COMMANDS["/resetambulance"] = TamrielAmbulance.ResetCounter
