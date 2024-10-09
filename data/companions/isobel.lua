local FOB = _G.FOB

FOB.dislikes[FOB.Isobel] = function(action, interactableName, isCriminalInteract)
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
end
