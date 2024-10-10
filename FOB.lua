_G.FOB.Name = "FOB"

local FOB = _G.FOB
local enabledForScene = true
local enabledScenes = {
    ["hud"] = true,
    ["provisioner"] = true
}

local PENDING_COMPANION_STATES = {
    [_G.COMPANION_STATE_PENDING] = true,
    [_G.COMPANION_STATE_INITIALIZED_PENDING] = true
}

local ACTIVE_COMPANION_STATES = {
    [_G.COMPANION_STATE_ACTIVE] = true
}

local INTERACTION_TYPES = {
    _G.INTERACTION_NONE,
    _G.INTERACTION_FISH,
    _G.INTERACTION_HARVEST,
    _G.INTERACTION_LOOT,
    _G.INTERACTION_BOOK
}

FOB.Enabled = true

local function endInteraction()
    if (_G.INTERACTIVE_WHEEL_MANAGER) then
        _G.INTERACTIVE_WHEEL_MANAGER:StopInteraction(_G.ZO_INTERACTIVE_WHEEL_TYPE_UTILITY)
    end

    EndPendingInteraction()

    for _, interactionType in ipairs(INTERACTION_TYPES) do
        EndInteraction(interactionType)
    end

    return true
end

local function FOBHandler(interactionPossible, _)
    if (interactionPossible and FOB.Enabled and enabledForScene and HasActiveCompanion()) then
        local action, interactableName, _, _, additionalInfo, _, _, isCriminalInteract =
            GetGameCameraInteractableActionInfo()

        if
            (FOB.Functions[FOB.ActiveCompanionDefId].Dislikes(
                action,
                interactableName,
                isCriminalInteract,
                additionalInfo
            ))
         then
            EndPendingInteraction()
            return endInteraction
        end

        -- are we trying to talk to someone?
        if (action == FOB.Actions.Talk and FOB.Vars.DisableCompanionInteraction) then
            -- is it a companion?
            local isCompanionAction = FOB.PartialMatch(interactableName, FOB.CompanionNames)

            if (isCompanionAction) then
                if (not FOB.Exceptions[interactableName]) then
                    -- companion detected - we don't want to talk to you, cancel the interaction
                    EndPendingInteraction()
                    return endInteraction()
                end
            end
        end

        return false
    end
end

-- handler for built in provisioning interface
local function FOBProvisionerHandler()
    local check = FOB.Vars.CheeseWarning == true and FOB.ActiveCompanion == FOB.Bastian
    local recipeData

    if (check) then
        recipeData = _G.PROVISIONER.recipeTree:GetSelectedData()
        return FOB.CheckIngredients(recipeData, FOB.Bastian)
    end

    check = FOB.Vars.CoffeeWarning == true and FOB.ActiveCompanionDefId == FOB.Azander

    if (check) then
        recipeData = _G.PROVISIONER.recipeTree:GetSelectedData()
        return FOB.CheckIngredients(recipeData, FOB.Azander)
    end
end

-- handle for DailyProvisioning addon, based on original code from that
local function DailyProvisioningOverride()
    local check = FOB.Vars.CheeseWarning == true and FOB.ActiveCompanion == FOB.Bastian

    check = check or (FOB.Vars.CoffeeWarning == true and FOB.ActiveCompanion == FOB.Azander)

    if (not check) then
        return false
    end

    local infos, hasMaster, hasDaily, hasEvent = _G.DailyProvisioning:GetQuestInfos()

    if (not infos) or #infos == 0 then
        return false
    end

    _G.DailyProvisioning.recipeList =
        _G.DailyProvisioning.recipeList or _G.DailyProvisioning:GetRecipeList(hasMaster, hasDaily, hasEvent)
    if (_G.DailyProvisioning.savedVariables.isDontKnow) then
        if (_G.DailyProvisioning:ExistUnknownRecipe(infos)) then
            return false
        end
    end

    local parameter

    for _, info in pairs(infos) do
        info.convertedTxt =
            _G.DailyProvisioning:IsValidConditions(info.convertedTxt, info.current, info.max, info.isVisible)
        if (info.convertedTxt) then
            parameter = _G.DailyProvisioning:CreateParameter(info)[1]

            if (not parameter) then
                return false
            elseif (parameter.recipeLink) then
                local recipeData = {
                    recipeListIndex = parameter.listIndex,
                    recipeIndex = parameter.recipeIndex
                }

                return FOB.CheckIngredients(recipeData, FOB.ActiveCompanion)
            end
        end
    end

    return false
end

---- Alerts ----

-- disable FOB in irrelevant scenes
local function sceneHandler(_, newState)
    local scene = SCENE_MANAGER:GetCurrentScene():GetName()

    if (newState == "showing") then
        enabledForScene = enabledScenes[scene] or false
    --FOB.Log(enabledForScene, "warn")
    end
end

function FOB.OnCompanionStateChanged(_, newState, _)
    if (_G.CF ~= nil) then
        return
    end

    if (ACTIVE_COMPANION_STATES[newState]) then
        FOB.SummoningFrame:SetHidden(true)
    end

    if (PENDING_COMPANION_STATES[newState]) then
        FOB.HideDefaultCompanionFrame()

        if (HasPendingCompanion()) and not IsCollectibleBlocked(GetCompanionCollectibleId(FOB.ActiveCompanion)) then
            local pendingCompanionDefId = GetPendingCompanionDefId()
            local pendingCompanionName = GetCompanionName(pendingCompanionDefId)
            local companionName = zo_strformat(_G.SI_COMPANION_NAME_FORMATTER, pendingCompanionName)
            local summoning = GetString(_G.SI_UNIT_FRAME_STATUS_SUMMONING)
            local summoningText = companionName .. ". " .. summoning

            FOB.SummoningFrame.Message:SetText(summoningText)
            FOB.SummoningFrame:SetHidden(false)
        end
    end
end

function FOB.OnAddonLoaded(_, addonName)
    if (addonName ~= FOB.Name) then
        return
    end

    if (_G.LibDebugLogger ~= nil) then
        FOB.Logger = _G.LibDebugLogger(FOB.Name)
    end

    if (_G.LibChatMessage ~= nil) then
        FOB.Chat = _G.LibChatMessage(FOB.Name, "FOB")
    end

    if (_G.RuEsoVariables ~= nil) then
        FOB.UsingRuEso = true
    end

    FOB.COLOURS = {
        GOLD = ZO_ColorDef:New("ffd700"),
        MUSTARD = ZO_ColorDef:New("9d840d"),
        RED = ZO_ColorDef:New("ff0000")
    }

    --FOB.Log("Loaded", "info")
    EVENT_MANAGER:UnregisterForEvent(FOB.Name, _G.EVENT_ADD_ON_LOADED)

    -- monitor scene changes
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", sceneHandler)

    -- saved variables
    FOB.Vars =
        _G.LibSavedVars:NewAccountWide("FOBSavedVars", "Account", FOB.Defaults):AddCharacterSettingsToggle(
        "FOBSavedVars",
        "Characters"
    )

    -- settings
    FOB.RegisterSettings()

    -- hook into the reticle interaction handler
    ZO_PreHook(RETICLE, "TryHandlingInteraction", FOBHandler)
    ZO_PreHook(ZO_Provisioner, "Create", FOBProvisionerHandler)

    if (_G.DailyProvisioning) then
        ZO_PreHook(_G.DailyProvisioning, "Crafting", DailyProvisioningOverride)
    end

    FOB.SetupCheeseAlert()
    FOB.SetupCoffeeAlert()

    -- handle damaged item tracking
    _G.SHARED_INVENTORY:RegisterCallback(
        "SingleSlotInventoryUpdate",
        function()
            if (FOB.Vars.CheckDamage) then
                if (FOB.ActiveCompanion == FOB.Sharp) then
                    local minDamage, itemName = FOB.CheckDurability()

                    if (minDamage < 5) then
                        local announce = true
                        local previousTime = FOB.Vars.PreviousAnnounceTime or (os.time() - 301)
                        local debounceTime = 300

                        if (os.time() - previousTime <= debounceTime) then
                            announce = false
                        end

                        if (announce == true) then
                            FOB.Vars.PreviousAnnounceTime = os.time()
                            FOB.Announce(
                                FOB.COLOURS.RED:Colorize(GetString(_G.FOB_WARNING)),
                                zo_strformat(
                                    GetString(_G.FOB_DAMAGED),
                                    FOB.COLOURS.GOLD:Colorize(itemName),
                                    ZO_CachedStrFormat(
                                        _G.SI_UNIT_NAME,
                                        GetCollectibleInfo(GetCompanionCollectibleId(FOB.Sharp))
                                    )
                                )
                            )
                        end
                    end
                end
            end
        end
    )

    -- if Companion Frame is installed, let it handle the summoning frame
    if (not _G.CF) then
        FOB.CreateCompanionSummoningFrame()
    end

    EVENT_MANAGER:RegisterForEvent(
        FOB.Name,
        _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED,
        function()
            zo_callLater(
                function()
                    FOB.ActiveCompanionDefId = GetActiveCompanionDefId()
                end,
                2000
            )

            if (FOB.Vars.UseCompanionSummmoningFrame) then
                FOB.OnCompanionStateChanged()
            end
        end
    )

    -- utiltity
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(FOB.Name, _G.EVENT_ADD_ON_LOADED, FOB.OnAddonLoaded)
