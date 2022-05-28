_G.FOB.Name = "FOB"

local FOB = _G.FOB
local enabled = true
local enabledForScene = true
local enabledScenes = {
    ["hud"] = true,
    ["provisioner"] = true
}
local take = GetString(_G.FOB_TAKE)
local talk = GetString(_G.FOB_TALK)
local catch = GetString(_G.FOB_CATCH)
local companions = {
    [FOB.BASTIAN] = true,
    [FOB.MIRRI] = true
}

local BASTIAN = 1 -- Bastian's Def Id
local MIRRI = 2 -- Mirri's Def Id

local fonts = {
    ["Standard"] = "EsoUi/Common/Fonts/Univers57.otf",
    ["ESO Bold"] = "EsoUi/Common/Fonts/Univers67.otf",
    ["Antique"] = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
    ["Handwritten"] = "EsoUI/Common/Fonts/Handwritten_Bold.otf",
    ["Trajan"] = "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
    ["Futura"] = "EsoUI/Common/Fonts/FuturaStd-CondensedLight.otf",
    ["Futura Bold"] = "EsoUI/Common/Fonts/FuturaStd-Condensed.otf"
}

local PENDING_COMPANION_STATES = {
    [_G.COMPANION_STATE_PENDING] = true,
    [_G.COMPANION_STATE_INITIALIZED_PENDING] = true
}

local ACTIVE_COMPANION_STATES = {
    [_G.COMPANION_STATE_ACTIVE] = true
}

local ILLEGAL = {
    [GetString(_G.SI_GAMECAMERAACTIONTYPE20)] = true, -- Steal From
    [GetString(_G.SI_GAMECAMERAACTIONTYPE21)] = true, -- Pickpocket
    [GetString(_G.SI_GAMECAMERAACTIONTYPE23)] = true -- Trespass
}

-- slower matcher for users of RuEso
-- RuEso modifies the text so a direct comparison is not possible
-- have to check if the string contains the expected text instead
local function PartialMatch(inputString, compareList)
    for key, value in pairs(compareList) do
        if (string.find(inputString, key)) then
            return value
        end
    end

    return false
end

local function FOBHandler(interactionPossible, _)
    if (interactionPossible and enabled and enabledForScene and HasActiveCompanion()) then
        local action, interactableName, _, _, _, _, _, isCriminalInteract = GetGameCameraInteractableActionInfo()

        -- are we trying to talk to someone?
        if (action == talk) then
            --FOB.Log("talk","warn")
            -- is it a companion?
            local isCompanionAction = companions[interactableName] or false

            if (FOB.UsingRuEso) then
                isCompanionAction = PartialMatch(interactableName, companions)
            end

            if (isCompanionAction) then
                -- companion detected - we don't want to talk to you, cancel the interaction
                --FOB.Log("Companion", "info")
                local interactionType = GetInteractionType()
                EndInteraction(interactionType)
                return true
            end
        end

        if (action == take or action == catch) then
            --FOB.Log("take","warn")

            if (FOB.Vars.IgnoreInsects or FOB.Vars.IgnoreAllInsects) then
                local insectList = FOB.FLYING_INSECTS

                if (FOB.Vars.IgnoreInsects) then
                    local activeCompanion = GetActiveCompanionDefId()

                    if (activeCompanion == MIRRI) then
                        if (FOB.Vars.IgnoreMirriInsects) then
                            insectList = FOB.MIRRI_INSECTS
                        end
                    else
                        return false
                    end
                end

                local ignoreInsects = insectList[interactableName] or false

                if (FOB.UsingRuEso) then
                    ignoreInsects = PartialMatch(interactableName, insectList)
                end

                if (ignoreInsects) then
                    --FOB.Log("Flying insect", "info")
                    local interactionType = GetInteractionType()
                    EndInteraction(interactionType)
                    return true
                end
            end
        end

        -- disable criminal interactions if Bastian is summoned
        --FOB.Log(isCriminalInteract, "warn")
        if (FOB.Vars.PreventCriminal) then
            local activeCompanion = GetActiveCompanionDefId()

            if (activeCompanion ~= BASTIAN) then
                return false
            end

            if (isCriminalInteract ~= true and action) then
                isCriminalInteract = PartialMatch(action, ILLEGAL)
            end

            if (isCriminalInteract) then
                local interactionType = GetInteractionType()
                EndInteraction(interactionType)
                return true
            end
        end

        return false
    end
end

local function CheckIngredients(recipeData)
    local maxIngredients = GetMaxRecipeIngredients()

    -- check the texture name, should be safe enough
    for idx = 1, maxIngredients do
        local name, texturename = GetRecipeIngredientItemInfo(recipeData.recipeListIndex, recipeData.recipeIndex, idx)
        if (name ~= "") then
            --FOB.Log(texturename, "info")
            if (string.find(texturename, "quest_trollfat_001")) then
                FOB.ShowCheeseAlert()
                return true
            end
        end
    end

    return false
end

-- handler for built in provisioning interface
local function FOBProvisionerHandler()
    if (FOB.Vars.CheeseWarning ~= true or GetActiveCompanionDefId() ~= 1) then
        return false
    end

    local recipeData = _G.PROVISIONER.recipeTree:GetSelectedData()
    return CheckIngredients(recipeData)
end

-- handle for DailyProvisioning addon, based on original code from that
local function DailyProvisioningOverride()
    if (FOB.Vars.CheeseWarning ~= true or GetActiveCompanionDefId() ~= 1) then
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

                return CheckIngredients(recipeData)
            end
        end
    end

    return false
end

---- Cheese Alert! ----
local function SetupCheeseAlert()
    local name = "FOB_Cheese_Alert"
    local alert = WINDOW_MANAGER:CreateTopLevelWindow(name)

    -- main window
    alert:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    alert:SetDimensions(256, 64)
    alert:SetHidden(true)

    -- icon
    alert.Texture = WINDOW_MANAGER:CreateControl(name .. "_Texture", alert, CT_TEXTURE)
    alert.Texture:SetTexture(FOB.Vars.CheeseIcon)
    alert.Texture:SetAnchor(LEFT, alert, LEFT)
    alert.Texture:SetDimensions(64, 64)

    -- label
    local font = FOB.GetFont(FOB.Vars.CheeseFont, FOB.Vars.CheeseFontSize, FOB.Vars.CheeseFontShadow)

    alert.Label = WINDOW_MANAGER:CreateControl(name .. "_Label", alert, CT_LABEL)
    alert.Label:SetFont(font)
    alert.Label:SetColor(
        FOB.Vars.CheeseFontColour.r,
        FOB.Vars.CheeseFontColour.g,
        FOB.Vars.CheeseFontColour.b,
        FOB.Vars.CheeseFontColour.a
    )
    alert.Label:SetHorizontalAlignment(_G.TEXT_ALIGN_CENTER)
    alert.Label:SetVerticalAlignment(_G.TEXT_ALIGN_CENTER)
    alert.Label:SetText(GetString(_G.FOB_CHEESE_ALERT))
    alert.Label:SetDimensions(184, 64)
    alert.Label:SetAnchor(LEFT, alert.Texture, RIGHT)
    alert.Label:SetHidden(false)

    -- fade out animation
    local fadeAnimation, fadeTimeline = CreateSimpleAnimation(_G.ANIMATION_ALPHA, alert)

    fadeAnimation:SetAlphaValues(1, 0)
    fadeAnimation:SetDuration(1000)
    fadeAnimation:SetHandler(
        "OnStop",
        function()
            FOB.Alert:SetHidden(true)
        end
    )

    fadeTimeline:SetPlaybackType(_G.ANIMATION_PLAYBACK_ONE_SHOT)

    alert.FadeAnimation = fadeTimeline

    local animation, timeline = CreateSimpleAnimation(_G.ANIMATION_SCALE, alert)

    -- scaling animation
    animation:SetStartScale(1)
    animation:SetEndScale(3)
    animation:SetDuration(1500)

    timeline:SetPlaybackType(_G.ANIMATION_PLAYBACK_ONE_SHOT)

    alert.Animation = timeline
    alert.FadeAnimation = fadeTimeline

    FOB.Alert = alert
end

-- disable FOB in irrelevant scenes
local function sceneHandler(_, newState)
    local scene = SCENE_MANAGER:GetCurrentScene():GetName()

    if (newState == "showing") then
        enabledForScene = enabledScenes[scene] or false
    --FOB.Log(enabledForScene, "warn")
    end
end

-- companion summoning frame
function FOB.CreateCompanionSummoningFrame()
    local name = FOB.Name .. "_CompanionSummoningFrame"

    FOB.SummoningFrame = _G[name] or WINDOW_MANAGER:CreateTopLevelWindow(name)
    FOB.SummoningFrame:SetDimensions(GuiRoot:GetWidth() / 3, 30)
    FOB.SummoningFrame:SetAnchor(CENTER, GuiRoot, CENTER)
    FOB.SummoningFrame:SetDrawTier(DT_HIGH)

    FOB.SummoningFrame.Message = WINDOW_MANAGER:CreateControl(name .. "_Message", FOB.SummoningFrame, CT_LABEL)
    FOB.SummoningFrame.Message:SetDimensions(400, 30)
    FOB.SummoningFrame.Message:SetAnchor(CENTER, FOB.SummoningFrame, CENTER, 0, (GuiRoot:GetHeight() / 4) * -1)
    FOB.SummoningFrame.Message:SetFont(FOB.GetFont("ESO Bold", 28, true))
    FOB.SummoningFrame.Message:SetHorizontalAlignment(CENTER)
    FOB.SummoningFrame.Message:SetVerticalAlignment(CENTER)
    FOB.SummoningFrame.Message:SetColor(157 / 255, 132 / 255, 13 / 255, 1)
end

local function DismissCompanion()
    local defId = GetActiveCompanionDefId()
    local character = GetUnitName("player")
    FOB.Vars.LastActiveCompanionId[character] = GetCompanionCollectibleId(defId)
    UseCollectible(FOB.Vars.LastActiveCompanionId[character])
end

local function SummonCompanion()
    local character = GetUnitName("player")
    if (FOB.Vars.LastActiveCompanionId[character] or 0 ~= 0) then
        UseCollectible(FOB.Vars.LastActiveCompanionId[character])
    end
end

local function HideDefaultCompanionFrame()
    if (not IsUnitGrouped("player") and UNIT_FRAMES:GetFrame("companion") ~= nil) then
        UNIT_FRAMES:GetFrame("companion"):SetHiddenForReason("disabled", true)
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
        HideDefaultCompanionFrame()

        if (HasPendingCompanion()) and not IsCollectibleBlocked(GetCompanionCollectibleId(GetActiveCompanionDefId())) then
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

function FOB.GetFont(fontName, fontSize, fontShadow)
    local hasShadow = fontShadow and "|soft-shadow-thick" or ""
    return fonts[fontName] .. "|" .. fontSize .. hasShadow
end

function FOB.ShowCheeseAlert()
    FOB.Alert:SetAlpha(1)
    FOB.Alert:SetHidden(false)
    FOB.Alert.Animation:PlayFromStart()

    PlaySound(_G.SOUNDS.QUEST_ABANDONED)

    zo_callLater(
        function()
            FOB.Alert.FadeAnimation:PlayFromStart()
        end,
        750
    )
end

-- unfortunately this doesn't correctly enable all functionality
-- when not called by ESO - disabling for now
--[[
function FOB.ShowCompanionMenu()
    if (HasActiveCompanion()) then
        if (not IsInGamepadPreferredMode()) then
            local sceneGroup = SCENE_MANAGER:GetSceneGroup("companionSceneGroup")
            local specificScene = sceneGroup:GetActiveScene()
            SCENE_MANAGER:Show(specificScene)
        end
    end
end
--]]
function FOB.ToggleDefaultInteraction()
    enabled = not enabled
    local message = GetString(enabled and _G.FOB_ENABLED or _G.FOB_DISABLED)
    FOB.Chat:SetTagColor("dc143c"):Print(message)
end

function FOB.ToggleCompanion()
    if (HasActiveCompanion()) then
        DismissCompanion()
    else
        SummonCompanion()
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

    if (_G.RuEsoVariables ~= nil) then
        FOB.UsingRuEso = true
    end

    --FOB.Log("Loaded", "info")
    EVENT_MANAGER:UnregisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED)

    -- monitor scene changes
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", sceneHandler)

    -- saved variables
    FOB.Vars =
        _G.LibSavedVars:NewAccountWide("FOBSavedVars", "Account", FOB.Defaults):AddCharacterSettingsToggle(
        "FOBSavedVars",
        "Characters"
    )

    -- reset the old account-wide companion information
    if (type(FOB.Vars.LastActiveCompanionId) == "number") then
        local character = GetUnitName("player")
        local id = FOB.Vars.LastActiveCompanionId
        FOB.Vars.LastActiveCompanionId = {}
        FOB.Vars.LastActiveCompanionId[character] = id
    end

    -- settings
    FOB.RegisterSettings()

    -- hook into the reticle interaction handler
    ZO_PreHook(RETICLE, "TryHandlingInteraction", FOBHandler)

    ZO_PreHook(ZO_Provisioner, "Create", FOBProvisionerHandler)

    if (_G.DailyProvisioning) then
        ZO_PreHook(_G.DailyProvisioning, "Crafting", DailyProvisioningOverride)
    end

    SetupCheeseAlert()

    -- if Companion Frame is installed, let it handle the summoning frame
    if (not _G.CF) then
        FOB.CreateCompanionSummoningFrame()
    end

    if (FOB.Vars.UseCompanionSummmoningFrame) then
        EVENT_MANAGER:RegisterForEvent(FOB.Name, EVENT_ACTIVE_COMPANION_STATE_CHANGED, FOB.OnCompanionStateChanged)
    end

    -- utiltity
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED, FOB.OnAddonLoaded)
