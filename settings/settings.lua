local FOB = _G.FOB
FOB.BASTIAN = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(1)))
FOB.MIRRI = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(2)))
FOB.EMBER = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetActiveCompanionDefId(5)))
FOB.ISOBEL = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetActiveCompanionDefId(6)))

local fonts = {
    "Standard",
    "ESO Bold",
    "Antique",
    "Handwritten",
    "Trajan",
    "Futura",
    "Futura Bold"
}

local icons = {
    "/esoui/art/icons/housing_bre_inc_cheese001.dds",
    "/esoui/art/icons/quest_trollfat_001.dds",
    "/esoui/art/icons/quest_critter_001.dds",
    "/esoui/art/icons/ability_1handed_004.dds",
    "/esoui/art/icons/adornment_uni_radiusrebreather.dds"
}

FOB.Defaults = {
    IgnoreInsects = false,
    IgnoreAllInsects = false,
    IgnoreMirriInsects = false,
    PreventCriminal = false,
    CheeseWarning = false,
    CheeseFontColour = {r = 0.9, g = 0.8, b = 0.2, a = 1},
    CheeseFont = "ESO Bold",
    CheeseFontSize = 24,
    CheeseFontShadow = true,
    CheeseIcon = "/esoui/art/icons/housing_bre_inc_cheese001.dds",
    UseCompanionSummmoningFrame = true,
    LastActiveCompanionId = {}
}

FOB.LAM = _G.LibAddonMenu2

local panel = {
    type = "panel",
    name = "FOB - Companion Helper",
    displayName = "|cdc143cFOB|r - Companion Helper",
    author = "Flat Badger",
    version = "2.6.0",
    slashCommand = "/fob",
    registerForRefresh = true
}

local options = {
    [1] = {
        type = "checkbox",
        name = GetString(_G.FOB_IGNORE_ALL_INSECTS),
        getFunc = function()
            return FOB.Vars.IgnoreAllInsects
        end,
        setFunc = function(value)
            FOB.Vars.IgnoreAllInsects = value

            if (value) then
                FOB.Vars.IgnoreInsects = false
                FOB.Vars.IgnoreMirriInsects = false
                CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FOB.OptionsPanel)
            end
        end,
        width = "full"
    },
    [2] = {
        type = "checkbox",
        name = GetString(_G.FOB_SHOWSUMMONING),
        getFunc = function()
            return FOB.Vars.UseCompanionSummmoningFrame
        end,
        setFunc = function(value)
            FOB.Vars.UseCompanionSummmoningFrame = value

            if (value == true) then
                EVENT_MANAGER:RegisterForEvent(
                    FOB.Name,
                    EVENT_ACTIVE_COMPANION_STATE_CHANGED,
                    FOB.OnCompanionStateChanged
                )
            else
                EVENT_MANAGER:UnregisterForEvent(FOB.Name, EVENT_ACTIVE_COMPANION_STATE_CHANGED)
                UNIT_FRAMES:GetFrame("companion"):SetHiddenForReason("disabled", false)
            end
        end,
        disabled = function()
            return _G.CF ~= nil
        end,
        width = "full"
    },
    [4] = {
        type = "header",
        name = "|c9d840d" .. FOB.MIRRI .. "|r",
        width = "full"
    },
    [5] = {
        type = "checkbox",
        name = GetString(_G.FOB_IGNORE_INSECTS),
        getFunc = function()
            return FOB.Vars.IgnoreInsects
        end,
        setFunc = function(value)
            FOB.Vars.IgnoreInsects = value

            if (value) then
                FOB.Vars.IgnoreAllInsects = false
            end

            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FOB.OptionsPanel)
        end,
        disabled = function()
            return FOB.Vars.IgnoreAllInsects
        end,
        width = "full"
    },
    [6] = {
        type = "checkbox",
        name = GetString(_G.FOB_IGNORE_MIRRI_INSECTS),
        getFunc = function()
            return FOB.Vars.IgnoreMirriInsects
        end,
        setFunc = function(value)
            FOB.Vars.IgnoreMirriInsects = value
        end,
        disabled = function()
            return FOB.Vars.IgnoreInsects == false
        end,
        width = "full"
    },
    [7] = {
        type = "header",
        name = "|c9d840d" .. FOB.BASTIAN .. "|r",
        width = "full"
    },
    [8] = {
        type = "checkbox",
        name = GetString(_G.FOB_PREVENT_CRIMINAL),
        getFunc = function()
            return FOB.Vars.PreventCriminal
        end,
        setFunc = function(value)
            FOB.Vars.PreventCriminal = value
        end,
        width = "full"
    },
    [9] = {
        type = "checkbox",
        name = GetString(_G.FOB_CHEESE_WARNING),
        getFunc = function()
            return FOB.Vars.CheeseWarning
        end,
        setFunc = function(value)
            FOB.Vars.CheeseWarning = value
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FOB.OptionsPanel)
        end,
        width = "full"
    },
    [10] = {
        type = "dropdown",
        name = GetString(_G.FOB_ALERT_FONT),
        choices = fonts,
        getFunc = function()
            return FOB.Vars.CheeseFont
        end,
        setFunc = function(value)
            FOB.Vars.CheeseFont = value
            local font = FOB.GetFont(value, FOB.Vars.CheeseFontSize, FOB.Vars.CheeseFontShadow)
            FOB.Alert.Label:SetFont(font)
        end,
        disabled = function()
            return FOB.Vars.CheeseWarning == false
        end,
        width = "full"
    },
    [11] = {
        type = "colorpicker",
        name = GetString(_G.FOB_ALERT_COLOUR),
        getFunc = function()
            return FOB.Vars.CheeseFontColour.r, FOB.Vars.CheeseFontColour.g, FOB.Vars.CheeseFontColour.b, FOB.Vars.CheeseFontColour.a
        end,
        setFunc = function(r, g, b, a)
            FOB.Vars.CheeseFontColour = {r = r, g = g, b = b, a = a}
            FOB.Alert.Label:SetColor(r, g, b, a)
        end,
        disabled = function()
            return FOB.Vars.CheeseWarning == false
        end,
        width = "full"
    },
    [12] = {
        type = "checkbox",
        name = GetString(_G.FOB_ALERT_SHADOW),
        getFunc = function()
            return FOB.Vars.CheeseFontShadow
        end,
        setFunc = function(value)
            FOB.Vars.CheeseFontShadow = value
            local font = FOB.GetFont(FOB.Vars.CheeseFont, FOB.Vars.CheeseFontSize, FOB.Vars.CheeseFontShadow)
            FOB.Alert.Label:SetFont(font)
        end,
        disabled = function()
            return FOB.Vars.CheeseWarning == false
        end,
        width = "full"
    },
    [13] = {
        type = "iconpicker",
        name = GetString(_G.FOB_ALERT_ICON),
        getFunc = function()
            return FOB.Vars.CheeseIcon
        end,
        setFunc = function(value)
            FOB.Vars.CheeseIcon = value
            FOB.Alert.Texture:SetTexture(value)
        end,
        choices = icons,
        disabled = function()
            return FOB.Vars.CheeseWarning == false
        end,
        iconSize = 48,
        width = "full"
    }
}

function FOB.RegisterSettings()
    FOB.OptionsPanel = FOB.LAM:RegisterAddonPanel("FOBOptionsPanel", panel)
    FOB.LAM:RegisterOptionControls("FOBOptionsPanel", options)
end