local FOB = _G.FOB

FOB.Defaults = {
    IgnoreInsects = false,
    PreventCriminal = false
}

FOB.LAM = _G.LibAddonMenu2

local panel = {
    type = "panel",
    name = "FOB - Companion Helper",
    displayName = "|cdc143cFOB|r - Companion Helper",
    author = "Flat Badger",
    version = "2.0.2",
    slashCommand = "/fob"
}

local options = {
    [1] = {
        type = "checkbox",
        name = GetString(_G.FOB_IGNORE_INSECTS),
        getFunc = function()
            return FOB.Vars.IgnoreFlying
        end,
        setFunc = function(value)
            FOB.Vars.IgnoreFlying = value
        end,
        width = "full"
    },
    [2] = {
        type = "checkbox",
        name = GetString(_G.FOB_PREVENT_CRIMINAL),
        getFunc = function()
            return FOB.Vars.PreventCriminal
        end,
        setFunc = function(value)
            FOB.Vars.PreventCriminal = value
        end,
        width = "full"
    }
}

function FOB.RegisterSettings()
    FOB.LAM:RegisterAddonPanel("FOBOptionsPanel", panel)
    FOB.LAM:RegisterOptionControls("FOBOptionsPanel", options)
end