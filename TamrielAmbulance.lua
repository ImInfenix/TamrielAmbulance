TamrielAmbulance = {}

--AddOn variables
TamrielAmbulance.name = "TamrielAmbulance"
TamrielAmbulance.coloredName = "|cff0000Tamriel |c000000Ambulance|r"
TamrielAmbulance.author = "|cff6600Infenix|r"
TamrielAmbulance.version = "1.0.0"
TamrielAmbulance.website = "https://github.com/ImInfenix/TamrielAmbulance"

function TamrielAmbulance.Initialize()
  TamrielAmbulance.savedVariables = ZO_SavedVars:NewAccountWide("TamrielAmbulance_SavedVariables", 1, nil, {})
  TamrielAmbulance.displayAddonLoadedMessage = TamrielAmbulance.savedVariables.displayAddonLoadedMessage

  --LibAddonMenu-2.0 Initializing
  TamrielAmbulance.InitializeLAM()

  --Window display settings restore
  if TamrielAmbulance.savedVariables.GUILeft == nil then TamrielAmbulance.savedVariables.GUILeft = 0 end
  if TamrielAmbulance.savedVariables.GUITop == nil then TamrielAmbulance.savedVariables.GUITop = 540 end
  if TamrielAmbulance.savedVariables.resurrectionCount == nil then TamrielAmbulance.savedVariables.resurrectionCount = 0 end
  if TamrielAmbulance.savedVariables.shouldDisplay == nil then TamrielAmbulance.savedVariables.shouldDisplay = true end

  local left = TamrielAmbulance.savedVariables.GUILeft
  local top = TamrielAmbulance.savedVariables.GUITop

  GUI_TamrielAmbulance:ClearAnchors()
  GUI_TamrielAmbulance:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

  --AddOn Loading
  EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_PLAYER_ACTIVATED, TamrielAmbulance.OnPlayerActivated)

  --Game Layout
  EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ACTION_LAYER_POPPED, TamrielAmbulance.LayerPopped)
  EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ACTION_LAYER_PUSHED, TamrielAmbulance.LayerPushed)

  --AddOn Tracking
  EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_RESURRECT_RESULT, TamrielAmbulance.OnResurrectionResultReceived)

  TamrielAmbulance.UpdateWindow()
end

function TamrielAmbulance.OnAddOnLoaded(eventCode, addonName)
  if(addonName ~= TamrielAmbulance.name or isLoaded) then
    return
  end

  --Unregister for load event
  EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

  TamrielAmbulance.Initialize()
end

function TamrielAmbulance.OnPlayerActivated(eventCode)
    --Unregister for player activated event
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
end

function TamrielAmbulance.OnResurrectionResultReceived(eventCode, targetCharacterName, result, targetDisplayName)
  if(result == RESURRECT_RESULT_SUCCESS) then
    TamrielAmbulance.savedVariables.resurrectionCount = TamrielAmbulance.savedVariables.resurrectionCount + 1;
  end
end

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
  GUI_TamrielAmbulance:SetHidden(not value or not TamrielAmbulance.savedVariables.shouldDisplay)
end

function TamrielAmbulance.SwitchDisplayStatus()
  TamrielAmbulance.savedVariables.shouldDisplay = not TamrielAmbulance.savedVariables.shouldDisplay
  TamrielAmbulance.ToggleWindow(true)
end

function TamrielAmbulance.ResetCounter()
  TamrielAmbulance.savedVariables.resurrectionCount = 0
  TamrielAmbulance.UpdateWindow()
end

function TamrielAmbulance.UpdateWindow()
  GUI_TamrielAmbulanceCounter:SetText(TamrielAmbulance.savedVariables.resurrectionCount)
end

EVENT_MANAGER:RegisterForEvent(TamrielAmbulance.name, EVENT_ADD_ON_LOADED, TamrielAmbulance.OnAddOnLoaded)

SLASH_COMMANDS["/ambulance"] = TamrielAmbulance.SwitchDisplayStatus
SLASH_COMMANDS["/resetambulance"] = TamrielAmbulance.ResetCounter
