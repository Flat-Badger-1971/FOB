local FOB = _G.FOB

FOB.Functions[FOB.Sharp] = {
    Dislikes = function(action, interactableName)
        if (FOB.Vars.PreventOutfit) then
            if (action == FOB.Actions.Use) then
                if (interactableName == ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_RESTYLE_STATION_MENU_ROOT_TITLE))) then
                    return true
                end
            end
        end

        return false
    end,
    Settings = function(options)
        local cid = GetCompanionCollectibleId(FOB.Sharp)
        local name, _, icon = GetCollectibleInfo(cid)

        name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.FOB_PREVENT_OUTFIT),
                getFunc = function()
                    return FOB.Vars.PreventOutfit
                end,
                setFunc = function(value)
                    FOB.Vars.PreventOutfit = value
                end,
                width = "full"
            },
            [2] = {
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
        }

        options[#options + 1] = {
            type = "submenu",
            name = FOB.COLOURS.MUSTARD:Colorize(name),
            controls = submenu,
            icon = icon
        }
    end
}
