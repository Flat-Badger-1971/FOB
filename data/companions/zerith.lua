local defId = _G.FOB.DefIds.Zerith

if (_G.CURT_IMPERIAL_FRAGMENTS) then
    local FOB = _G.FOB
    local cid = GetCompanionCollectibleId(defId)
    local name, _, icon = GetCollectibleInfo(cid)

    FOB.Functions[defId] = {
        Sort = name,
        Dislikes = function()
            return false
        end,
        Settings = function(options)
            name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, name)

            local submenu = {
                [1] = {
                    type = "checkbox",
                    name = GetString(_G.FOB_PREVENT_EDICTS),
                    getFunc = function()
                        return FOB.Vars.PreventEdicts or false
                    end,
                    setFunc = function(value)
                        FOB.Vars.PreventEdicts = value

                        if (value) then
                            CALLBACK_MANAGER:RegisterCallback("BackpackFullUpdate", FOB.Functions[defId].Other)
                            _G.PLAYER_INVENTORY:RefreshAllInventorySlots(_G.INVENTORY_BACKPACK)
                        else
                            CALLBACK_MANAGER:UnregisterCallback("BackpackFullUpdate", FOB.Functions[defId].Other)
                        end
                    end,
                    width = "full"
                },
                [2] = {
                    type = "checkbox",
                    name = GetString(_G.FOB_PREVENT_FENCE),
                    getFunc = function()
                        return FOB.Vars.PreventFence or false
                    end,
                    setFunc = function(value)
                        FOB.Vars.PreventFence = value
                    end,
                    width = "full"
                },
                [3] = {
                    type = "checkbox",
                    name = GetString(_G.FOB_PREVENT_TREASURES),
                    tooltip = GetString(_G.FOB_PREVENT_SPECIFIC_TT),
                    getFunc = function()
                        return FOB.Vars.PreventTreasure or false
                    end,
                    setFunc = function(value)
                        FOB.Vars.PreventTreasure = value
                    end,
                    width = "full"
                },
                [4] = {
                    type = "checkbox",
                    name = GetString(_G.FOB_PREVENT_BLADE_OF_WOE),
                    getFunc = function()
                        return FOB.Vars.PreventBladeOfWoeZerith
                    end,
                    setFunc = function(value)
                        FOB.Vars.PreventBladeOfWoeZerith = value

                        if (value) then
                            FOB.RegisterForBladeOfWoe(defId)
                        else
                            FOB.UnregisterForBladeOfWoe(defId)
                        end
                    end,
                    width = "full"
                }
            }

            options[#options + 1] = {
                type = "submenu",
                name = FOB.COLOURS.MUSTARD:Colorize(name),
                controls = submenu,
                icon = icon
            }
        end,
        Other = function()
            if (FOB.Vars) then
                if (FOB.Vars.PreventEdicts) then
                    for _, i in pairs(_G.PLAYER_INVENTORY.inventories) do
                        local listView = i.listView

                        if (listView and listView.dataTypes and listView.dataTypes[1]) then
                            local originalCall = listView.dataTypes[1].setupCallback

                            listView.dataTypes[1].setupCallback = function(rowControl, slot)
                                originalCall(rowControl, slot)

                                if
                                    (slot.itemType == _G.ITEMTYPE_TROPHY and
                                        slot.specializedItemType == _G.SPECIALIZED_ITEMTYPE_TROPHY_SCROLL)
                                 then
                                    local id = GetItemId(slot.bagId, slot.slotIndex)

                                    if (id == 71779 or id == 73754) then
                                        local info = rowControl:GetNamedChild("TraitInfo")

                                        if (info) then
                                            if (FOB.ActiveCompanionDefId == defId and FOB.Enabled) then
                                                if (not info:HasIcon(FOB.Logo)) then
                                                    info:ClearIcons()
                                                    info:AddIcon(FOB.Logo)
                                                    info:AddIcon(FOB.LogoBlock)
                                                    info:Show()
                                                    _G.ZO_PlayerInventorySlot_SetupUsableAndLockedColor(
                                                        slot.slotControl,
                                                        false,
                                                        true
                                                    )
                                                    CALLBACK_MANAGER:FireCallbacks(
                                                        "InventorySlotUpdate",
                                                        slot.slotControl:GetNamedChild("Button")
                                                    )

                                                    rowControl:SetMouseEnabled(false)
                                                    _G.PLAYER_INVENTORY.isListDirty[_G.INVENTORY_BACKPACK] = true
                                                end
                                            else
                                                info:Hide()
                                                info:ClearIcons()

                                                rowControl:SetMouseEnabled(true)
                                                _G.PLAYER_INVENTORY.isListDirty[_G.INVENTORY_BACKPACK] = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end,
        OnFenceOpened = function()
            if (FOB.Enabled) then
                local modeBar = _G.FENCE_KEYBOARD.modeBar
                local menuBar = modeBar.menuBar.m_object
                local sellButton = menuBar:ButtonObjectForDescriptor(_G.SI_STORE_MODE_SELL)

                if (sellButton:GetState() ~= _G.BSTATE_DISABLED) then
                    if (_G.FOB.Vars.PreventFence and _G.FOB.ActiveCompanionDefId == defId) then
                        sellButton.m_buttonData.disabled = FOB.LogoBlock
                        menuBar:SetDescriptorEnabled(_G.SI_STORE_MODE_SELL, false)

                        zo_callLater(
                            function()
                                _G.FENCE_KEYBOARD.modeBar:SelectFragment(_G.SI_FENCE_LAUNDER_TAB)
                            end,
                            500
                        )
                    end
                else
                    menuBar:SetDescriptorEnabled(_G.SI_STORE_MODE_SELL)
                end
            end
        end,
        OnBackpackFullUpdate = function()
            _G.FOB.Functions[defId].Other()
            _G.PLAYER_INVENTORY:UpdateList(_G.INVENTORY_BACKPACK, true)
        end,
        OnSingleSlotInventoryUpdate = function()
            zo_callLater(
                function()
                    CALLBACK_MANAGER:FireCallbacks("BackpackFullUpdate")
                end,
                500
            )
        end,
        LootWatcher = function()
            local origFunction = _G.LOOT_SHARED.GetSortedLootData

            _G.LOOT_SHARED.GetSortedLootData = function()
                local lootData = origFunction(_G.LOOT_SHARED)
                if (_G.FOB.Vars.PreventTreasure and _G.FOB.Enabled and _G.FOB.ActiveCompanionDefId == defId) then
                    for idx, data in ipairs(lootData) do
                        if (data.isStolen and _G.ITEMTYPE_TREASURE) then
                            local link = GetLootItemLink(data.lootId)
                            local numTags = GetItemLinkNumItemTags(link)
                            local lootAll = _G.LOOT_WINDOW:GetButtonByKeybind("LOOT_ALL")
                            local lootOne = _G.LOOT_WINDOW:GetButtonByKeybind()
                            local disabled = false

                            for tag = 1, numTags do
                                local desc = GetItemLinkItemTagInfo(link, tag)

                                if (_G.FOB.Treasures[desc]) then
                                    lootData[idx].icon = FOB.Logo
                                    lootData[idx].disable = true
                                    lootAll:SetEnabled(false)
                                    disabled = true

                                    if (#lootData == 1) then
                                        lootOne:SetEnabled(false)
                                    end
                                end
                            end

                            if (not disabled) then
                                lootAll:SetEnabled(true)
                                lootOne:SetEnabled(true)
                            end
                        end
                    end
                end

                return lootData
            end

            SCENE_MANAGER:RegisterCallback(
                "SceneStateChanged",
                function(_, newState)
                    local scene = SCENE_MANAGER:GetCurrentScene():GetName()

                    if ((scene == "loot") and (newState == "showing")) then
                        local rows = _G.ZO_LootAlphaContainerListContents:GetNumChildren()

                        for rowNum = 1, rows do
                            local row = _G.ZO_LootAlphaContainerListContents:GetChild(rowNum)

                            local icons = row:GetNamedChild("MultiIcon")
                            if (icons) then
                                if (icons:HasIcon(FOB.Logo)) then
                                    icons:Add(FOB.LogoBlock)
                                    row:SetMouseEnabled(false)
                                else
                                    row:SetMouseEnabled(true)
                                end
                            end
                        end
                    end
                end
            )
        end
    }
end

if (IsCollectibleUsable(GetCompanionCollectibleId(defId))) then
    CALLBACK_MANAGER:RegisterCallback("BackpackFullUpdate", _G.FOB.Functions[defId].OnBackpackFullUpdate)
    SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", _G.FOB.Functions[defId].OnSingleSlotInventoryUpdate)
    FENCE_MANAGER:RegisterCallback("FenceOpened", _G.FOB.Functions[defId].OnFenceOpened)
    _G.FOB.Functions[defId].LootWatcher()
end
