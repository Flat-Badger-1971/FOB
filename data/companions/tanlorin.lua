local FOB = _G.FOB
local defId = FOB.DefIds.Tanlorin
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(action, interactableName)
        if (FOB.Vars.PreventNirnroot) then
            if (action == FOB.Actions.Collect) then
                if (FOB.LC.PartialMatch(interactableName, {[FOB.Nirnroot] = true})) then
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
            -- examine
            if (action == FOB.Actions.Examine) then
                local questInteraction = select(3, GetGameCameraInteractableInfo())

                if (not questInteraction) then
                    return true
                end
            end

            -- search
            if (action == FOB.Actions.Search and FOB.LC.PartialMatch(interactableName, {[FOB.Bookshelf] = true})) then
                return true
            end
        end

        return false
    end,
    Settings = function(options)
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
            name = FOB.LC.Mustard:Colorize(name),
            controls = submenu,
            icon = icon
        }
    end
}
