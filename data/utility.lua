local FOB = _G.FOB

function FOB.PartialMatch(inputString, compareList)
    for key, value in pairs(compareList) do
        if (key ~= "") then
            if (inputString:lower():find(key:lower())) then
                return value
            end
        end
    end

    return false
end

function FOB.CheckIngredients(recipeData, companion)
    local maxIngredients = GetMaxRecipeIngredients()

    -- check the texture name, should be safe enough
    for idx = 1, maxIngredients do
        local name, texturename = GetRecipeIngredientItemInfo(recipeData.recipeListIndex, recipeData.recipeIndex, idx)
        if (name ~= "") then
            --FOB.Log(texturename, "info")
            if (texturename:find("quest_trollfat_001") and companion == FOB.Bastian) then
                FOB.ShowAlert(FOB.Alert)
                return true
            end

            if (texturename:find("crafting_coffee_beans") and companion == FOB.Azander) then
                FOB.ShowAlert(FOB.CoffeeAlert)
                return true
            end
        end
    end

    return false
end

-- handler for built in provisioning interface
function FOB.ProvisionerHandler()
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

function FOB.DailyProvisioningOverride()
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

function FOB.DismissCompanion()
    local character = GetUnitName("player")

    FOB.Vars.LastActiveCompanionId[character] = GetCompanionCollectibleId(FOB.ActiveCompanion)
    UseCollectible(FOB.Vars.LastActiveCompanionId[character])
end

function FOB.SummonCompanion()
    local character = GetUnitName("player")

    if (FOB.Vars.LastActiveCompanionId[character] or 0 ~= 0) then
        UseCollectible(FOB.Vars.LastActiveCompanionId[character])
    end
end

function FOB.HideDefaultCompanionFrame()
    if (not IsUnitGrouped("player") and UNIT_FRAMES:GetFrame("companion") ~= nil) then
        UNIT_FRAMES:GetFrame("companion"):SetHiddenForReason("disabled", true)
    end
end

function FOB.GetFont(fontName, fontSize, fontShadow)
    local hasShadow = fontShadow and "|soft-shadow-thick" or ""

    return FOB.FontDefs[fontName] .. "|" .. fontSize .. hasShadow
end

function FOB.ToggleDefaultInteraction()
    FOB.Enabled = not FOB.Enabled
    FOB.RunCompanionFunctions()

    local message = GetString(FOB.Enabled and _G.FOB_ENABLED or _G.FOB_DISABLED)

    if (not FOB.Enabled) then
        FOB.RestoreReticle()
    end

    FOB.Chat:SetTagColor("dc143c"):Print(message)
end

function FOB.ToggleCompanion()
    if (HasActiveCompanion()) then
        FOB.DismissCompanion()
    else
        FOB.SummonCompanion()
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

function FOB.Announce(header, message)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(_G.CSA_CATEGORY_LARGE_TEXT)

    messageParams:SetSound("Justice_NowKOS")
    messageParams:SetText(header, message)
    messageParams:SetLifespanMS(6000)
    messageParams:SetCSAType(_G.CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
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

function FOB.GetFirstWord(text)
    local space = text:find(" ")

    if (not space) then
        space = text:find("-")

        if (not space) then
            return text
        end
    end

    return text:sub(1, space - 1)
end

function FOB.GetAddonVersion()
    local manager = GetAddOnManager()
    local numAddons = manager:GetNumAddOns()
    local version = "?"

    for addon = 1, numAddons do
        local name = manager:GetAddOnInfo(addon)

        if (name == FOB.Name) then
            version = tostring(manager:GetAddOnVersion(addon))

            local major = tonumber(version:sub(1, 1))
            local minor = tonumber(version:sub(2, 2))
            local revision = tonumber(version:sub(3))

            version = string.format("%d.%d.%d", major, minor, revision)
            break
        end
    end

    return version
end

-- UI
function FOB.CreateLogo(parent)
    local logo = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)

    logo:SetAnchor(CENTER)
    logo:SetDimensions(64, 64)
    logo:SetTexture(FOB.ReticlePath)
    logo:SetHidden(true)

    return logo
end

function FOB.ReplaceReticle()
    if (FOB.Vars.UseReticle) then
        if (not FOB.UsingFOBReticle) then
            _G.ZO_ReticleContainerReticle:SetAlpha(0)
            FOB.Reticle:SetHidden(false)
            FOB.UsingFOBReticle = true
        end
    else
        FOB.UsingFOBReticle = false
    end
end

function FOB.RestoreReticle()
    if (FOB.UsingFOBReticle) then
        _G.ZO_ReticleContainerReticle:SetAlpha(1)
        FOB.Reticle:SetHidden(true)
        FOB.UsingFOBReticle = false
    end
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

function FOB.SetupCheeseAlert()
    local font = {
        font = FOB.Vars.CheeseFont,
        size = FOB.Vars.CheeseFontSize,
        shadow = FOB.Vars.CheeseFontShadow,
        colour = FOB.Vars.CheeseFontColour
    }

    FOB.Alert = FOB.SetupAlert("FOB_Cheese_Alert", FOB.Vars.CheeseIcon, font, _G.FOB_CHEESE_ALERT)
end

function FOB.SetupCoffeeAlert()
    local font = {
        font = FOB.Vars.CoffeeFont,
        size = FOB.Vars.CoffeeFontSize,
        shadow = FOB.Vars.CoffeeFontShadow,
        colour = FOB.Vars.CoffeeFontColour
    }

    FOB.CoffeeAlert = FOB.SetupAlert("FOB_Coffee_Alert", FOB.Vars.CoffeeIcon, font, _G.FOB_COFFEE_ALERT)
end

function FOB.SetupAlert(name, icon, fontInfo, text)
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

-- init
do
    _G.FOB.Fonts = {}
    _G.FOB.CompanionNames = {}

    for fontName, _ in pairs(_G.FOB.FontDefs) do
        table.insert(_G.FOB.Fonts, fontName)
    end

    for _, defId in pairs(_G.FOB.DefIds) do
        local cid = GetCompanionCollectibleId(defId)
        local name = FOB.GetFirstWord(GetCollectibleInfo(cid))

        _G.FOB.CompanionNames[name] = true
    end

    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end

    FOB.Reticle = FOB.CreateLogo(_G.ZO_ReticleContainer)
end
