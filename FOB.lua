_G.FOB = {
    Name = "FOB"
}

local FOB = _G.FOB
local enabled = true
local BASTIAN = GetCollectibleInfo(9245)
local MIRRI = GetCollectibleInfo(9353)
local companions = {
    [BASTIAN] = true,
    [MIRRI] = true
}

local function FOBHandler(interactionPossible, _)
    if (interactionPossible and enabled) then
        local action, interactableName = GetGameCameraInteractableActionInfo()

        -- are we trying to talk to someone?
        if (action == GetString(_G.SI_GAMECAMERAACTIONTYPE2)) then

            -- is it a companion?
            local isCompanionAction = companions[interactableName] or false

            if (isCompanionAction) then
                -- companion detected - we don't want to talk to you, cancel the interaction
                local interactionType = GetInteractionType()
                EndInteraction(interactionType)
                return true
            end
        end

        return false
    end

    return false
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

    -- hook into the reticle interaction handler
    ZO_PreHook(RETICLE, "TryHandlingInteraction", FOBHandler)
end

EVENT_MANAGER:RegisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED, FOB.OnAddonLoaded)
