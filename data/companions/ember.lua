local FOB = _G.FOB
local defId = FOB.DefIds.Ember
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(_, _, _, additionalInfo)
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
    end,
    Settings = function(options)
        name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.FOB_PREVENT_FISHING),
                getFunc = function()
                    return FOB.Vars.PreventFishing
                end,
                setFunc = function(value)
                    FOB.Vars.PreventFishing = value
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
