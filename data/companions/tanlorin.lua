local FOB = _G.FOB

FOB.Functions[FOB.Tanlorin] = {
    Dislikes = function(action, interactableName)
        if (FOB.Vars.PreventNirnroot) then
            if (action == FOB.Actions.Collect) then
                if (FOB.PartialMatch(interactableName, FOB.Nirnroot)) then
                    return true
                end
            end
        end

        if (FOB.Vars.PreventMagesGuild) then
            if (action == FOB.Actions.Open) then
                if (interactableName == FOB.MagesGuild) then
                    return true
                end
            end
        end

        if (FOB.Vars.PreventLorebooks) then
            if (action == FOB.Actions.Read) then
                return true
            end
        end

        return false
    end,
    Settings = function(options)
        local cid = GetCompanionCollectibleId(FOB.Tanlorin)
        local name, _, icon = GetCollectibleInfo(cid)

        name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.FOB_PREVENT_NIRNROOT),
                getFunc = function()
                    return FOB.Vars.PreventNirnroot
                end,
                setFunc = function(value)
                    FOB.Vars.PreventNirnroot = value
                end,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(_G.FOB_PREVENT_MAGES_GUILD),
                getFunc = function()
                    return FOB.Vars.PreventMagesGuild
                end,
                setFunc = function(value)
                    FOB.Vars.PreventMagesGuild = value
                end,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(_G.FOB_PREVENT_LOREBOOKS),
                getFunc = function()
                    return FOB.Vars.PreventLorebooks
                end,
                setFunc = function(value)
                    FOB.Vars.PreventLorebooks = value
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
