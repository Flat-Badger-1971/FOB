_G.FOB.Name = "FOB"

local FOB = _G.FOB
local enabled = true
local take = GetString(_G.FOB_TAKE)
local talk = GetString(_G.FOB_TALK)
local catch = GetString(_G.FOB_CATCH)
local BASTIAN = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(1)))
local MIRRI = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(2)))

local companions = {
    [BASTIAN] = true,
    [MIRRI] = true
}

local function FOBHandler(interactionPossible, _)
    if (interactionPossible and enabled and HasActiveCompanion()) then
        local action, interactableName, _, _, _, _, _, isCriminalInteract = GetGameCameraInteractableActionInfo()

        -- are we trying to talk to someone?
        if (action == talk) then
            --FOB.Log("talk","warn")
            -- remove any gender assignments from the string

            -- is it a companion?
            local isCompanionAction = companions[interactableName] or false

            if (isCompanionAction) then
                -- companion detected - we don't want to talk to you, cancel the interaction
                --FOB.Log("Companion", "info")
                local interactionType = GetInteractionType()
                EndInteraction(interactionType)
                return true
            end
        end

        if ((action == take or action == catch) and FOB.Vars.IgnoreFlying) then
            --FOB.Log("take","warn")
            -- is it a flying insect?
            local isFlyingInsect = FOB.FLYING_INSECTS[interactableName] or false
            --FOB.Log(interactableName, "info")
            if (isFlyingInsect) then
                local activeCompanion = GetActiveCompanionDefId()

                -- if Mirri is out, leave those flying insects alone
                if (activeCompanion == 2) then
                    --FOB.Log("Flying insect", "info")
                    local interactionType = GetInteractionType()
                    EndInteraction(interactionType)
                    return true
                end
            end
        end

        -- disable criminal interactions is Bastian is summonedwww
        if (isCriminalInteract and FOB.Vars.PreventCriminal) then
            local activeCompanion = GetActiveCompanionDefId()
            if (activeCompanion == 1) then
                local interactionType = GetInteractionType()
                EndInteraction(interactionType)
                return true
            end
        end

        return false
    end
end

function FOB.ShowCompanionMenu()
    if (HasActiveCompanion()) then
        if (not IsInGamepadPreferredMode()) then
            local sceneGroup = SCENE_MANAGER:GetSceneGroup("companionSceneGroup")
            local specificScene = sceneGroup:GetActiveScene()
            SCENE_MANAGER:Show(specificScene)
        end
    end
end

function FOB.ToggleDefaultInteraction()
    enabled = not enabled
    local message = GetString(enabled and _G.FOB_ENABLED or _G.FOB_DISABLED)
    FOB.Chat:SetTagColor("dc143c"):Print(message)
end

function FOB.DismissCompanion()
    if (HasActiveCompanion()) then
        local defId = GetActiveCompanionDefId()
        local collId = GetCompanionCollectibleId(defId)
        UseCollectible(collId)
    end
end

function FOB.Log(message, severity)
    if (FOB.Logger) then
        if (severity == "info") then
            FOB.Logger:Info(message)
        elseif (severity == "warn") then
            FOB.Logger:Warn(message)
        elseif (severity == "debug") then
            FOB.Logger:Debug(message)
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

    --FOB.Log("Loaded", "info")
    EVENT_MANAGER:UnregisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED)

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

    -- utiltity
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED, FOB.OnAddonLoaded)
