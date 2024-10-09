local FOB = _G.FOB

FOB.dislikes[FOB.Azander] = function(interactableName, action)
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
end
