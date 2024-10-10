if (_G.CURT_IMPERIAL_FRAGMENTS) then
    local FOB = _G.FOB
    local cid = GetCompanionCollectibleId(FOB.DefIds.Zerith)
    local name, _, icon = GetCollectibleInfo(cid)

    -- getting a bounty/assaulting someone, innocent with blade of woe, stealing medical, religious or sentimental items,
    -- using pardon edict (71779) or leniency edict (73754), fencing stolen goods

    FOB.Functions[FOB.DefIds.Zerith] = {
        Sort = name,
        Dislikes = function()
            return false
        end,
        Settings = function(options)
            name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

            local submenu = {}

            options[#options + 1] = {
                type = "submenu",
                name = FOB.COLOURS.MUSTARD:Colorize(name),
                controls = submenu,
                icon = icon
            }
        end
    }
end
