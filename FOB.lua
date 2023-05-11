--TODO: prevent porting to Eyevea or Artaeum for Azandar
--      pickpocket beggar - possible? (sharp)
--      prevent destroying items (sharp)
--      check gear breaking (sharp)
--      check enchant running out (sharp)
--      settings

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
local open = GetString(_G.FOB_OPEN)
local collect = GetString(_G.FOB_COLLECT)
local use = GetString(_G.FOB_USE)
local companions = {
    [FOB.BASTIAN] = true,
    [FOB.MIRRI] = true,
    [FOB.EMBER] = true,
    [FOB.ISOBEL] = true
}

if (FOB.Necrom) then
    companions[FOB.SHARPASNIGHT] = true
    companions[FOB.AZANDAR] = true
end

local BASTIAN = 1 -- Bastian's Def Id
local MIRRI = 2 -- Mirri's Def Id
local EMBER = 5 -- Ember's Def Id
local ISOBEL = 6 -- Isobel's Def Id
local SHARPASNIGHT = 8 -- Sharp as Night's Def Id
local AZANDAR = 9 -- Azandar Al-Cybiades' Def Id

local language = GetCVar("language.2")

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

local OUTLAWS_REFUGE = {
    [string.lower(GetString(_G.FOB_OUTLAWS_REFUGE))] = true,
    [string.lower(GetString(_G.FOB_THIEVES_DEN))] = true
}

local EXCEPTIONS = {}

do
    if (language == "de") then
        EXCEPTIONS[GetString(_G.FOB_LADY_LLARELS_SHELTER)] = true
        EXCEPTIONS[GetString(_G.FOB_BLACKHEART_HAVEN)] = true
    end
end

local INTERACTION_TYPES = {
    _G.INTERACTION_NONE,
    _G.INTERACTION_FISH,
    _G.INTERACTION_HARVEST
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

local function endInteraction()
    EndPendingInteraction()

    for _, interactionType in ipairs(INTERACTION_TYPES) do
        EndInteraction(interactionType)
    end

    return true
end

local function FOBHandler(interactionPossible, _)
    if (interactionPossible and enabled and enabledForScene and HasActiveCompanion()) then
        local action, interactableName, _, _, additionalInfo, _, _, isCriminalInteract =
            GetGameCameraInteractableActionInfo()

        -- prevent outfit station interaction
        if (action == use) then
            if (FOB.Vars.PreventOutfit) then
                local activeCompanion = GetActiveCompanionDefId()

                if (interactableName == ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_RESTYLE_STATION_MENU_ROOT_TITLE))) then
                    if (activeCompanion == SHARPASNIGHT) then
                        EndPendingInteraction()
                        return endInteraction
                    end
                end
            end
        end

        -- prevent mushroom gathering
        if (action == collect) then
            if (FOB.Vars.PreventMushroom) then
                local activeCompanion = GetActiveCompanionDefId()

                if (activeCompanion == AZANDAR) then
                    local mushroomList = FOB.MUSHROOMS
                    local ignoreMushrooms = mushroomList[interactableName] or false
                    if (FOB.UsingRuEso) then
                        ignoreMushrooms = PartialMatch(interactableName, mushroomList)
                    end

                    if (ignoreMushrooms) then
                        EndPendingInteraction()
                        return endInteraction
                    end
                end
            end
        end

        -- prevent entry to the outlaw's refuge
        if (action == open) then
            if (FOB.Vars.PreventOutlawsRefuge) then
                -- Exceptions to the rule

                if (PartialMatch(string.lower(interactableName), OUTLAWS_REFUGE) and (not EXCEPTIONS[interactableName])) then
                    local activeCompanion = GetActiveCompanionDefId()

                    if (activeCompanion == ISOBEL) then
                        EndPendingInteraction()
                        return endInteraction()
                    end
                end
            end
        end

        -- prevent fishing is Ember is out
        if (additionalInfo == _G.ADDITIONAL_INTERACT_INFO_FISHING_NODE) then
            if (FOB.Vars.PreventFishing) then
                local activeCompanion = GetActiveCompanionDefId()

                if (activeCompanion == EMBER) then
                    FISHING_MANAGER:StopInteraction()
                    EndPendingInteraction()
                    return endInteraction()
                end
            end
        end

        -- are we trying to talk to someone?
        if (action == talk and FOB.Vars.DisableCompanionInteraction) then
            -- is it a companion?
            local isCompanionAction = companions[interactableName] or false

            if (FOB.UsingRuEso) then
                isCompanionAction = PartialMatch(interactableName, companions)
            end

            if (isCompanionAction) then
                -- companion detected - we don't want to talk to you, cancel the interaction
                EndPendingInteraction()
                return endInteraction()
            end
        end

        if (action == take or action == catch) then
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
                    EndPendingInteraction()
                    return endInteraction()
                end
            end
        end

        -- disable criminal interactions if Bastian or Isobel is summoned
        --FOB.Log(isCriminalInteract, "warn")
        local activeCompanion = GetActiveCompanionDefId()
        if
            ((FOB.Vars.PreventCriminalBastian and activeCompanion == BASTIAN) or
                (FOB.Vars.PreventCriminalIsobel and activeCompanion == ISOBEL))
         then
            if (isCriminalInteract ~= true and action) then
                isCriminalInteract = PartialMatch(action, ILLEGAL)
            end

            if (isCriminalInteract) then
                EndPendingInteraction()
                return endInteraction()
            end
        end

        return false
    end
end

local function CheckIngredients(recipeData, companion)
    local maxIngredients = GetMaxRecipeIngredients()

    -- check the texture name, should be safe enough
    for idx = 1, maxIngredients do
        local name, texturename = GetRecipeIngredientItemInfo(recipeData.recipeListIndex, recipeData.recipeIndex, idx)
        if (name ~= "") then
            --FOB.Log(texturename, "info")
            if (string.find(texturename, "quest_trollfat_001") and companion == BASTIAN) then
                FOB.ShowAlert(FOB.Alert)
                return true
            end

            if (string.find(texturename, "crafting_coffee_beans") and companion == AZANDAR) then
                FOB.ShowAlert(FOB.CoffeeAlert)
                return true
            end
        end
    end

    return false
end

-- handler for built in provisioning interface
local function FOBProvisionerHandler()
    local check = FOB.Vars.CheeseWarning == true and GetActiveCompanionDefId() == BASTIAN
    local recipeData

    if (check) then
        recipeData = _G.PROVISIONER.recipeTree:GetSelectedData()
        return CheckIngredients(recipeData, BASTIAN)
    end

    check = FOB.Vars.CoffeeWarning == true and GetActiveCompanionDefId() == AZANDAR

    if (check) then
        recipeData = _G.PROVISIONER.recipeTree:GetSelectedData()
        return CheckIngredients(recipeData, AZANDAR)
    end
end

-- handle for DailyProvisioning addon, based on original code from that
local function DailyProvisioningOverride()
    local check = FOB.Vars.CheeseWarning == true and GetActiveCompanionDefId() == BASTIAN

    check = check or (FOB.Vars.CoffeeWarning == true and GetActiveCompanionDefId() == AZANDAR)

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

                return CheckIngredients(recipeData, GetActiveCompanionDefId())
            end
        end
    end

    return false
end

---- Alerts ----
local function SetupAlert(name, icon, fontInfo, text)
    local alert = WINDOW_MANAGER:CreateTopLevelWindow(name)

    -- main window
    alert:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    alert:SetDimensions(256, 64)
    alert:SetHidden(true)

    -- icon
    alert.Texture = WINDOW_MANAGER:CreateControl(name .. "_Texture", alert, CT_TEXTURE)
    alert.Texture:SetTexture(icon)
    alert.Texture:SetAnchor(LEFT, alert, LEFT)
    alert.Texture:SetDimensions(64, 64)

    -- label
    local font = FOB.GetFont(fontInfo.font, fontInfo.size, fontInfo.shadow)

    alert.Label = WINDOW_MANAGER:CreateControl(name .. "_Label", alert, CT_LABEL)
    alert.Label:SetFont(font)
    alert.Label:SetColor(fontInfo.colour.r, fontInfo.colour.g, fontInfo.colour.b, fontInfo.colour.a)
    alert.Label:SetHorizontalAlignment(_G.TEXT_ALIGN_CENTER)
    alert.Label:SetVerticalAlignment(_G.TEXT_ALIGN_CENTER)
    alert.Label:SetText(GetString(text))
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

    return alert
end

local function SetupCheeseAlert()
    local font = {
        font = FOB.Vars.CheeseFont,
        size = FOB.Vars.CheeseFontSize,
        shadow = FOB.Vars.CheeseFontShadow,
        colour = FOB.Vars.CheeseFontColour
    }

    FOB.Alert = SetupAlert("FOB_Cheese_Alert", FOB.Vars.CheeseIcon, font, _G.FOB_CHEESE_ALERT)
end

local function SetupCoffeeAlert()
    local font = {
        font = FOB.Vars.CoffeeFont,
        size = FOB.Vars.CoffeeFontSize,
        shadow = FOB.Vars.CoffeeFontShadow,
        colour = FOB.Vars.CoffeeFontColour
    }

    FOB.CoffeeAlert = SetupAlert("FOB_Coffee_Alert", FOB.Vars.CoffeeIcon, font, _G.FOB_COFFEE_ALERT)
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

function FOB.ShowAlert(alert)
    alert:SetAlpha(1)
    alert:SetHidden(false)
    alert.Animation:PlayFromStart()

    PlaySound(_G.SOUNDS.QUEST_ABANDONED)

    zo_callLater(
        function()
            alert.FadeAnimation:PlayFromStart()
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

local ignoreSlots = {
    [_G.EQUIP_SLOT_NECK] = true,
    [_G.EQUIP_SLOT_RING1] = true,
    [_G.EQUIP_SLOT_RING2] = true,
    [_G.EQUIP_SLOT_COSTUME] = true,
    [_G.EQUIP_SLOT_POISON] = true,
    [_G.EQUIP_SLOT_BACKUP_POISON] = true,
    [_G.EQUIP_SLOT_MAIN_HAND] = true,
    [_G.EQUIP_SLOT_BACKUP_MAIN] = true,
    [_G.EQUIP_SLOT_BACKUP_OFF] = true
}

function FOB.CheckDurability()
    local lowest = 100
    local lowestName = ""

    if (FOB.Vars.CheckDamage) then
        for _, item in pairs(_G.SHARED_INVENTORY.bagCache[_G.BAG_WORN]) do
            if (not ignoreSlots[item.slotIndex]) then
                if (item.name ~= "") then
                    if (lowest > item.condition) then
                        lowest = item.condition
                        lowestName = item.name
                    end
                end
            end
        end
    end

    return lowest, lowestName
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

function FOB.Announce(header, message)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(_G.CSA_CATEGORY_LARGE_TEXT)

    messageParams:SetSound("Justice_NowKOS")
    messageParams:SetText(header, message)
    messageParams:SetLifespanMS(6000)
    messageParams:SetCSAType(_G.CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
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
    EVENT_MANAGER:UnregisterForEvent(FOB.Name, _G.EVENT_ADD_ON_LOADED)

    -- monitor scene changes
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", sceneHandler)

    -- saved variables
    FOB.Vars =
        _G.LibSavedVars:NewAccountWide("FOBSavedVars", "Account", FOB.Defaults):AddCharacterSettingsToggle(
        "FOBSavedVars",
        "Characters"
    )

    -- update deprecated variable
    if (FOB.Vars.PreventCriminal) then
        FOB.Vars.PreventCriminalBastian = FOB.Vars.PreventCriminal
        FOB.Vars.PreventCriminal = nil
    end

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
    SetupCoffeeAlert()

    -- handle damaged item tracking
    if (FOB.Necrom) then
        _G.SHARED_INVENTORY:RegisterCallback(
            "SingleSlotInventoryUpdate",
            function()
                if (FOB.Vars.CheckDamage) then
                    local activeCompanion = GetActiveCompanionDefId()

                    if (activeCompanion == SHARPASNIGHT) then
                        local minDamage, itemName = FOB.CheckDamage()

                        if (minDamage < 10) then
                            local announce = true
                            local previousTime = FOB.Vars.PreviousAnnounceTime or (os.time() - 301)
                            local debounceTime = 300

                            if (os.time() - previousTime <= debounceTime) then
                                announce = false
                            end

                            if (announce == true) then
                                FOB.Vars.PreviousAnnounceTime = os.time()
                                FOB.Announce(
                                    GetString(_G.FOB_WARNING),
                                    zo_strformat(
                                        GetString(
                                            _G.FOB_DAMAGED,
                                            itemName,
                                            ZO_CachedStrFormat(
                                                _G.SI_UNIT_NAME,
                                                GetCollectibleInfo(GetCompanionCollectibleId(AZANDAR))
                                            )
                                        )
                                    )
                                )
                            end
                        end
                    end
                end
            end
        )
    end

    -- if Companion Frame is installed, let it handle the summoning frame
    if (not _G.CF) then
        FOB.CreateCompanionSummoningFrame()
    end

    if (FOB.Vars.UseCompanionSummmoningFrame) then
        EVENT_MANAGER:RegisterForEvent(FOB.Name, _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED, FOB.OnCompanionStateChanged)
    end

    -- utiltity
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(FOB.Name, _G.EVENT_ADD_ON_LOADED, FOB.OnAddonLoaded)
