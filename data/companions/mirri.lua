local FOB = _G.FOB

FOB.dislikes[FOB.Mirri] = function(action, interactableName)
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
end
