local FOB = _G.FOB

FOB.dislikes[FOB.Ember] = function(_, _, _, additionalInfo)
    if (FOB.Vars.PreventFishing) then
        if (additionalInfo == _G.ADDITIONAL_INTERACT_INFO_FISHING_NODE) then
            if (_G.FISHING_MANAGER) then
                _G.FISHING_MANAGER:StopInteraction()
            else
                _G.INTERACTIVE_WHEEL_MANAGER:StopInteraction(_G.ZO_INTERACTIVE_WHEEL_TYPE_FISHING)
            end

            return true
        end
    end

    return false
end
