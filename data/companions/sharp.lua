local FOB = _G.FOB

FOB.dislikes[FOB.Sharp] = function(action, interactableName)
    if (FOB.Vars.PreventOutfit) then
        if (action == FOB.Actions.Use) then
            if (interactableName == ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_RESTYLE_STATION_MENU_ROOT_TITLE))) then
                return true
            end
        end
    end

    return false
end
