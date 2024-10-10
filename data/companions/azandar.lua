local FOB = _G.FOB
local cid = GetCompanionCollectibleId(FOB.DefIds.Azander)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[FOB.DefIds.Azander] = {
    Sort = name,
    Dislikes = function(interactableName, action)
        if (FOB.Vars.PreventMushroom) then
            if (action == FOB.Actions.Collect) then
                local ignoreMushrooms = FOB.Mushrooms[interactableName] or false

                if (FOB.UsingRuEso) then
                    ignoreMushrooms = FOB.PartialMatch(interactableName, FOB.Mushrooms)
                end

                return ignoreMushrooms
            end
        end

        return false
    end,
    Settings = function(options)
        name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.FOB_PREVENT_MUSHROOM),
                getFunc = function()
                    return FOB.Vars.PreventMushroom
                end,
                setFunc = function(value)
                    FOB.Vars.PreventMushroom = value
                end,
                width = "full"
            },
            [2] = {
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
            },
            [3] = {
                type = "dropdown",
                name = GetString(_G.FOB_ALERT_FONT),
                choices = FOB.Fonts,
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
            },
            [4] = {
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
            },
            [5] = {
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
            },
            [6] = {
                type = "iconpicker",
                name = GetString(_G.FOB_ALERT_ICON),
                getFunc = function()
                    return FOB.Vars.CoffeeIcon
                end,
                setFunc = function(value)
                    FOB.Vars.CoffeeIcon = value
                    FOB.CoffeeAlert.Texture:SetTexture(value)
                end,
                choices = FOB.CoffeeIcons,
                disabled = function()
                    return FOB.Vars.CoffeeWarning == false
                end,
                iconSize = 48,
                width = "full"
            }
        }

        options[#options + 1] = {
            type = "submenu",
            name = FOB.COLOURS.MUSTARD:Colorize(name),
            controls = submenu,
            icon = icon
        }
    end
}
