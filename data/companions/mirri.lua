local FOB = _G.FOB
local defId = FOB.DefIds.Mirri
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(action, interactableName)
        if (FOB.Vars.PreventDarkBrotherhood) then
            if (action == FOB.Actions.Open) then
                if (interactableName == FOB.DarkBrotherhood) then
                    return true
                end
            end
        end

        if (FOB.Vars.IgnoreInsects or FOB.Vars.IgnoreAllInsects) then
            if (action == FOB.Actions.Take or action == FOB.Actions.Catch) then
                local insectList = FOB.FlyingInsects

                if (FOB.Vars.IgnoreInsects) then
                    if (FOB.Vars.IgnoreMirriInsects) then
                        insectList = FOB.MirriInsects
                    end
                else
                    return false
                end

                local ignoreInsects = insectList[interactableName] or false

                if (FOB.UsingRuEso) then
                    ignoreInsects = FOB.PartialMatch(interactableName, insectList)
                end

                if (ignoreInsects) then
                    return true
                end
            end
        end

        return false
    end,
    Settings = function(options)
        name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
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
            [2] = {
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
            [3] = {
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
            [4] = {
                type = "checkbox",
                name = GetString(_G.FOB_PREVENT_BLADE_OF_WOE),
                getFunc = function()
                    return FOB.Vars.PreventBladeOfWoeMirri
                end,
                setFunc = function(value)
                    FOB.Vars.PreventBladeOfWoeMirri = value

                    if (value) then
                        FOB.RegisterForBladeOfWoe(defId)
                    else
                        FOB.UnregisterForBladeOfWoe(defId)
                    end
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

-- blade of woe (ability 78219)
