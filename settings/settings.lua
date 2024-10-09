local FOB = _G.FOB
local version = "2.2.0"

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

FOB.BASTIAN = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(1)))
FOB.MIRRI = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(2)))
FOB.EMBER = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(5)))
FOB.ISOBEL = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(6)))
FOB.SHARPASNIGHT =
    ZO_CachedStrFormat(_G.SI_UNIT_NAME, FOB.GetFirstWord(GetCollectibleInfo(GetCompanionCollectibleId(8))))
FOB.AZANDAR = ZO_CachedStrFormat(_G.SI_UNIT_NAME, FOB.GetFirstWord(GetCollectibleInfo(GetCompanionCollectibleId(9))))
FOB.TANLORIN = ZO_CachedStrFormat(_G.SI_UNIT_NAME, FOB.GetFirstWord(GetCollectibleInfo(GetCompanionCollectibleId(12))))
FOB.ZERITH = ZO_CachedStrFormat(_G.SI_UNIT_NAME, FOB.GetFirstWord(GetCollectibleInfo(GetCompanionCollectibleId(13))))

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

local coffeeIcons = {
    "/esoui/art/icons/crafting_coffee_beans.dds",
    "/esoui/art/icons/housing_orc_inc_cupbone001.dds",
    "/esoui/art/icons/crowncrate_magickahealth_drink.dds"
}

FOB.Defaults = {
    IgnoreInsects = false,
    IgnoreAllInsects = false,
    IgnoreMirriInsects = false,
    PreventCriminalBastian = false,
    PreventCriminalIsobel = false,
    PreventDarkBrotherhood = false,
    PreventFishing = false,
    PreventMushroom = false,
    PreventOutlawsRefuge = false,
    CheeseWarning = false,
    CheeseFontColour = {r = 0.9, g = 0.8, b = 0.2, a = 1},
    CheeseFont = "ESO Bold",
    CheeseFontSize = 24,
    CheeseFontShadow = true,
    CheeseIcon = "/esoui/art/icons/housing_bre_inc_cheese001.dds",
    CoffeeWarning = false,
    CoffeeFontColour = {r = 0.9, g = 0.8, b = 0.2, a = 1},
    CoffeeFont = "ESO Bold",
    CoffeeFontSize = 24,
    CoffeeFontShadow = true,
    CoffeeIcon = "/esoui/art/icons/crafting_coffee_beans.dds",
    UseCompanionSummmoningFrame = true,
    LastActiveCompanionId = {},
    DisableCompanionInteraction = true
}

FOB.LAM = _G.LibAddonMenu2

local panel = {
    type = "panel",
    name = "FOB - Companion Helper",
    displayName = "|cdc143cFOB|r - Companion Helper",
    author = "Flat Badger",
    version = version,
    slashCommand = "/fob",
    registerForRefresh = true
}

local function getOptions()
    local options = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.FOB_DISABLE_COMPANION_INTERACTION),
            getFunc = function()
                return FOB.Vars.DisableCompanionInteraction
            end,
            setFunc = function(value)
                FOB.Vars.DisableCompanionInteraction = value
            end,
            width = "full"
        },
        [2] = {
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
        [3] = {
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
                        _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED,
                        FOB.OnCompanionStateChanged
                    )
                else
                    EVENT_MANAGER:UnregisterForEvent(FOB.Name, _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED)
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
            name = FOB.COLOURS.MUSTARD:Colorize(FOB.MIRRI),
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
            type = "checkbox",
            name = GetString(_G.FOB_PREVENT_DARK_BROTHERHOOD),
            getFunc = function()
                return FOB.Vars.PreventDarkBrotherhood
            end,
            setFunc = function(value)
                FOB.Vars.PreventDarkBrotherhood = value
            end,
            width = "full"
        },
        [8] = {
            type = "header",
            name = FOB.COLOURS.MUSTARD:Colorize(FOB.BASTIAN),
            width = "full"
        },
        [9] = {
            type = "checkbox",
            name = GetString(_G.FOB_PREVENT_CRIMINAL),
            getFunc = function()
                return FOB.Vars.PreventCriminalBastian
            end,
            setFunc = function(value)
                FOB.Vars.PreventCriminalBastian = value
            end,
            width = "full"
        },
        [10] = {
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
        [11] = {
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
        [12] = {
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
        [13] = {
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
        [14] = {
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
        },
        [15] = {
            type = "header",
            name = FOB.COLOURS.MUSTARD:Colorize(FOB.EMBER),
            width = "full"
        },
        [16] = {
            type = "checkbox",
            name = GetString(_G.FOB_PREVENT_FISHING),
            getFunc = function()
                return FOB.Vars.PreventFishing
            end,
            setFunc = function(value)
                FOB.Vars.PreventFishing = value
            end,
            width = "full"
        },
        [17] = {
            type = "header",
            name = FOB.COLOURS.MUSTARD:Colorize(FOB.ISOBEL),
            width = "full"
        },
        [18] = {
            type = "checkbox",
            name = GetString(_G.FOB_PREVENT_CRIMINAL),
            getFunc = function()
                return FOB.Vars.PreventCriminalIsobel
            end,
            setFunc = function(value)
                FOB.Vars.PreventCriminalIsobel = value
            end,
            width = "full"
        },
        [19] = {
            type = "checkbox",
            name = GetString(_G.FOB_PREVENT_OUTLAW),
            getFunc = function()
                return FOB.Vars.PreventOutlawsRefuge
            end,
            setFunc = function(value)
                FOB.Vars.PreventOutlawsRefuge = value
            end,
            width = "full"
        }
    }

    options[#options + 1] = {
        type = "header",
        name = FOB.COLOURS.MUSTARD:Colorize(FOB.SHARPASNIGHT),
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = GetString(_G.FOB_PREVENT_OUTFIT),
        getFunc = function()
            return FOB.Vars.PreventOutfit
        end,
        setFunc = function(value)
            FOB.Vars.PreventOutfit = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = GetString(_G.FOB_WARN_BROKEN),
        getFunc = function()
            return FOB.Vars.CheckDamage
        end,
        setFunc = function(value)
            FOB.Vars.CheckDamage = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "header",
        name = FOB.COLOURS.MUSTARD:Colorize(FOB.AZANDAR),
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = GetString(_G.FOB_PREVENT_MUSHROOM),
        getFunc = function()
            return FOB.Vars.PreventMushroom
        end,
        setFunc = function(value)
            FOB.Vars.PreventMushroom = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = GetString(_G.FOB_COFFEE_WARNING),
        getFunc = function()
            return FOB.Vars.CoffeeWarning
        end,
        setFunc = function(value)
            FOB.Vars.CoffeeWarning = value
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FOB.OptionsPanel)
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "dropdown",
        name = GetString(_G.FOB_ALERT_FONT),
        choices = fonts,
        getFunc = function()
            return FOB.Vars.CoffeeFont
        end,
        setFunc = function(value)
            FOB.Vars.CoffeeFont = value
            local font = FOB.GetFont(value, FOB.Vars.CoffeeFontSize, FOB.Vars.CoffeeFontShadow)
            FOB.CoffeeAlert.Label:SetFont(font)
        end,
        disabled = function()
            return FOB.Vars.CoffeeWarning == false
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "colorpicker",
        name = GetString(_G.FOB_ALERT_COLOUR),
        getFunc = function()
            return FOB.Vars.CoffeeFontColour.r, FOB.Vars.CoffeeFontColour.g, FOB.Vars.CoffeeFontColour.b, FOB.Vars.CoffeeFontColour.a
        end,
        setFunc = function(r, g, b, a)
            FOB.Vars.CoffeeFontColour = {r = r, g = g, b = b, a = a}
            FOB.CoffeeAlert.Label:SetColor(r, g, b, a)
        end,
        disabled = function()
            return FOB.Vars.CoffeeWarning == false
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = GetString(_G.FOB_ALERT_SHADOW),
        getFunc = function()
            return FOB.Vars.CoffeeFontShadow
        end,
        setFunc = function(value)
            FOB.Vars.CofeeFontShadow = value
            local font = FOB.GetFont(FOB.Vars.CoffeeFont, FOB.Vars.CoffeeFontSize, FOB.Vars.CoffeeFontShadow)
            FOB.CoffeeAlert.Label:SetFont(font)
        end,
        disabled = function()
            return FOB.Vars.CoffeeWarning == false
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "iconpicker",
        name = GetString(_G.FOB_ALERT_ICON),
        getFunc = function()
            return FOB.Vars.CoffeeIcon
        end,
        setFunc = function(value)
            FOB.Vars.CoffeeIcon = value
            FOB.CoffeeAlert.Texture:SetTexture(value)
        end,
        choices = coffeeIcons,
        disabled = function()
            return FOB.Vars.CoffeeWarning == false
        end,
        iconSize = 48,
        width = "full"
    }

    -- update 44
    if (_G.CURT_IMPERIAL_FRAGMENTS) then
        options[#options + 1] = {
            type = "header",
            name = FOB.COLOURS.MUSTARD:Colorize(FOB.TANLORIN),
            width = "full"
        }

        -- getting a bounty/assaulting someone, innocent with blade of woe, stealing medical, religious or sentimental items,
        -- using pardon edict (71779) or leniency edict (73754), fencing stolen goods
        options[#options + 1] = {
            type = "header",
            name = FOB.COLOURS.MUSTARD:Colorize(FOB.ZERITH),
            width = "full"
        }
    end

    return options
end

function FOB.RegisterSettings()
    FOB.OptionsPanel = FOB.LAM:RegisterAddonPanel("FOBOptionsPanel", panel)
    FOB.LAM:RegisterOptionControls("FOBOptionsPanel", getOptions())
end
