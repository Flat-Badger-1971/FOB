function FOB.CheckIngredients(recipeData, companion)
    local maxIngredients = GetMaxRecipeIngredients()

    -- check the texture name, should be safe enough
    for idx = 1, maxIngredients do
        local name, texturename = GetRecipeIngredientItemInfo(recipeData.recipeListIndex, recipeData.recipeIndex, idx)
        if (name ~= "") then
            FOB.Log(texturename, "info")
            if (zo_strfind(texturename, "quest_trollfat_001") and companion == FOB.DefIds.Bastian) then
                FOB.ShowAlert(FOB.Alert)
                return true
            end

            if (zo_strfind(texturename, "crafting_coffee_beans") and companion == FOB.DefIds.Azander) then
                FOB.ShowAlert(FOB.CoffeeAlert)
                return true
            end
        end
    end

    return false
end

-- handler for built in provisioning interface
function FOB.ProvisionerHandler()
    local check = FOB.Vars.CheeseWarning == true and FOB.ActiveCompanionDefId == FOB.DefIds.Bastian
    local recipeData

    if (check) then
        recipeData = PROVISIONER.recipeTree:GetSelectedData()
        return FOB.CheckIngredients(recipeData, FOB.DefIds.Bastian)
    end

    check = FOB.Vars.CoffeeWarning == true and FOB.ActiveCompanionDefId == FOB.DefIds.Azander

    if (check) then
        recipeData = PROVISIONER.recipeTree:GetSelectedData()
        return FOB.CheckIngredients(recipeData, FOB.DefIds.Azander)
    end
end

function FOB.DailyProvisioningOverride()
    local check = FOB.Vars.CheeseWarning == true and FOB.ActiveCompanionDefId == FOB.DefIds.Bastian

    check = check or (FOB.Vars.CoffeeWarning == true and FOB.ActiveCompanionDefId == FOB.DefIds.Azander)

    if (not check) then
        return false
    end

    local infos, hasMaster, hasDaily, hasEvent = DailyProvisioning:GetQuestInfos()

    if (not infos) or #infos == 0 then
        return false
    end

    DailyProvisioning.recipeList = DailyProvisioning.recipeList or
        DailyProvisioning:GetRecipeList(hasMaster, hasDaily, hasEvent)
    if (DailyProvisioning.savedVariables.isDontKnow) then
        if (DailyProvisioning:ExistUnknownRecipe(infos)) then
            return false
        end
    end

    local parameter

    for _, info in pairs(infos) do
        info.convertedTxt = DailyProvisioning:IsValidConditions(info.convertedTxt, info.current, info.max,
            info.isVisible)
        if (info.convertedTxt) then
            parameter = DailyProvisioning:CreateParameter(info)[1]

            if (not parameter) then
                return false
            elseif (parameter.recipeLink) then
                local recipeData = {
                    recipeListIndex = parameter.listIndex,
                    recipeIndex = parameter.recipeIndex
                }

                return FOB.CheckIngredients(recipeData, FOB.ActiveCompanionDefId)
            end
        end
    end

    return false
end

function FOB.DismissCompanion()
    local character = GetUnitName("player")

    FOB.Vars.LastActiveCompanionId[character] = GetCompanionCollectibleId(FOB.ActiveCompanionDefId)
    UseCollectible(FOB.Vars.LastActiveCompanionId[character], GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

function FOB.SummonCompanion()
    local character = GetUnitName("player")

    if (FOB.Vars.LastActiveCompanionId[character] or 0 ~= 0) then
        UseCollectible(FOB.Vars.LastActiveCompanionId[character], GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    end
end

function FOB.HideDefaultCompanionFrame()
    if (not IsUnitGrouped("player") and UNIT_FRAMES:GetFrame("companion") ~= nil) then
        UNIT_FRAMES:GetFrame("companion"):SetHiddenForReason("disabled", true)
    end
end

function FOB.GetFont(fontName, fontSize, fontShadow)
    return FOB.LC.GetFont(fontName, fontSize, fontShadow and "Soft Shadow Thick")
end

function FOB.ToggleDefaultInteraction()
    FOB.Enabled = not FOB.Enabled
    FOB.RunCompanionFunctions()

    local message = GetString(FOB.Enabled and FOB_ENABLED or FOB_DISABLED)

    if (not FOB.Enabled) then
        FOB.RestoreReticle()
    end

    if (FOB.FobInfo) then
        FOB.FobInfo:OnSynergyAbilityChanged()
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
    [EQUIP_SLOT_NECK] = true,
    [EQUIP_SLOT_RING1] = true,
    [EQUIP_SLOT_RING2] = true,
    [EQUIP_SLOT_COSTUME] = true,
    [EQUIP_SLOT_POISON] = true,
    [EQUIP_SLOT_BACKUP_POISON] = true,
    [EQUIP_SLOT_MAIN_HAND] = true,
    [EQUIP_SLOT_BACKUP_MAIN] = true,
    [EQUIP_SLOT_BACKUP_OFF] = true
}

function FOB.CheckDurability()
    local lowest = 100
    local lowestName = ""

    if (FOB.Vars.CheckDamage) then
        for _, item in pairs(SHARED_INVENTORY.bagCache[BAG_WORN]) do
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

function FOB.RegisterForBladeOfWoe(companion)
    FOB.Vars.BoWCompanions[companion] = true
end

function FOB.UnregisterForBladeOfWoe(companion)
    FOB.Vars.BoWCompanions[companion] = nil
end

function FOB.AllowPickPocketing()
    local difficulty, _, _, _, socialClass = select(4, GetGameCameraPickpocketingBonusInfo())
    local block = false

    if (difficulty ~= PICKPOCKET_DIFFICULTY_INVALID) then
        if (FOB.NoPickPocketing[FOB.ActiveCompanionDefId]) then
            if (FOB.NoPickPocketing[FOB.ActiveCompanionDefId][socialClass]) then
                block = true
            end
        end
    end

    return block
end

function FOB.IsFromShalidorsLibrary(bookTitle)
    local SHALIDORS_LIBRARY = 1

    local _, numCollections = GetLoreCategoryInfo(SHALIDORS_LIBRARY)

    for collectionIndex = 1, numCollections do
        local _, _, _, totalBooks, hidden = GetLoreCollectionInfo(SHALIDORS_LIBRARY, collectionIndex)
        if not hidden then
            for bookIndex = 1, totalBooks do
                local title = GetLoreBookInfo(SHALIDORS_LIBRARY, collectionIndex, bookIndex)

                if (ZO_CachedStrFormat("<<C:1>>", title) == bookTitle) then
                    return true
                end
            end
        end
    end

    return false
end
