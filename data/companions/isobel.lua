local FOB = _G.FOB

FOB.Functions[FOB.Isobel] = {
    Dislikes = function(action, interactableName, isCriminalInteract)
        local isCriminal = isCriminalInteract

        if (FOB.Vars.PreventCriminalIsobel) then
            if (isCriminal ~= true and action) then
                isCriminal = FOB.PartialMatch(action, FOB.Illegal)
            end

            return isCriminal
        end

        if (FOB.Vars.PreventOutlawsRefuge) then
            if (action == FOB.Actions.Open) then
                if (FOB.PartialMatch(interactableName, FOB.OutlawsRefuge) and (not FOB.Exceptions[interactableName])) then
                    return true
                end
            end
        end

        return false
    end,
    Settings = function(options)
        local cid = GetCompanionCollectibleId(FOB.Isobel)
        local name, _, icon = GetCollectibleInfo(cid)

        name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
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
            [2] = {
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
            type = "submenu",
            name = FOB.COLOURS.MUSTARD:Colorize(name),
            controls = submenu,
            icon = icon
        }
    end
}