local FOB = _G.FOB

FOB.dislikes[FOB.Tanlorin] = function(action, interactableName)
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
end
