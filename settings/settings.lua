local FOB = _G.FOB
local version = FOB.GetAddonVersion()

FOB.LAM = _G.LibAddonMenu2

local panel = {
    type = "panel",
    name = "FOB - Companion Helper",
    displayName = "|cdc143cFOB|r - Companion Helper",
    author = "Flat Badger",
    version = version,
    slashCommand = "/fob",
    registerForRefresh = true
}

local function getOptions()
    local options = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.FOB_DISABLE_COMPANION_INTERACTION),
            getFunc = function()
                return FOB.Vars.DisableCompanionInteraction
            end,
            setFunc = function(value)
                FOB.Vars.DisableCompanionInteraction = value
            end,
            width = "full"
        },
        [2] = {
            type = "checkbox",
            name = GetString(_G.FOB_IGNORE_ALL_INSECTS),
            getFunc = function()
                return FOB.Vars.IgnoreAllInsects
            end,
            setFunc = function(value)
                FOB.Vars.IgnoreAllInsects = value

                if (value) then
                    FOB.Vars.IgnoreInsects = false
                    FOB.Vars.IgnoreMirriInsects = false
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FOB.OptionsPanel)
                end
            end,
            width = "full"
        },
        [3] = {
            type = "checkbox",
            name = GetString(_G.FOB_SHOWSUMMONING),
            getFunc = function()
                return FOB.Vars.UseCompanionSummmoningFrame
            end,
            setFunc = function(value)
                FOB.Vars.UseCompanionSummmoningFrame = value

                if (value == true) then
                    EVENT_MANAGER:RegisterForEvent(
                        FOB.Name,
                        _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED,
                        FOB.OnCompanionStateChanged
                    )
                else
                    EVENT_MANAGER:UnregisterForEvent(FOB.Name, _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED)
                    UNIT_FRAMES:GetFrame("companion"):SetHiddenForReason("disabled", false)
                end
            end,
            disabled = function()
                return _G.CF ~= nil
            end,
            width = "full"
        }
    }

    local sorted = {}

    for id, functions in pairs(FOB.Functions) do
        table.insert(sorted, {sort = functions.Sort, id = id})
    end

    table.sort(
        sorted,
        function(a, b)
            return a.sort < b.sort
        end
    )

    for _, companion in ipairs(sorted) do
        if (FOB.Functions[companion.id].Settings) then
            FOB.Functions[companion.id].Settings(options)
        end
    end

    return options
end

function FOB.RegisterSettings()
    FOB.OptionsPanel = FOB.LAM:RegisterAddonPanel("FOBOptionsPanel", panel)
    FOB.LAM:RegisterOptionControls("FOBOptionsPanel", getOptions())
end
