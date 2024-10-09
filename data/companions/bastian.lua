local FOB = _G.FOB

FOB.dislikes[FOB.Bastian] = function(action, _, isCriminalInteract)
    local isCriminal = isCriminalInteract

    if (FOB.Vars.PreventCriminalBastian) then
        if (isCriminal ~= true and action) then
            isCriminal = FOB.PartialMatch(action, FOB.Illegal)
        end

        return isCriminal
    end

    return false
end
