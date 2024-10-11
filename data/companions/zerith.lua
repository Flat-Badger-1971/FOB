if (_G.CURT_IMPERIAL_FRAGMENTS) then
    local FOB = _G.FOB
    local cid = GetCompanionCollectibleId(FOB.DefIds.Zerith)
    local name, _, icon = GetCollectibleInfo(cid)

    -- getting a bounty/assaulting someone, innocent with blade of woe, stealing medical, religious or sentimental items,
    -- fencing stolen goods

    FOB.Functions[FOB.DefIds.Zerith] = {
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
                            CALLBACK_MANAGER:RegisterCallback(
                                "BackpackFullUpdate",
                                FOB.Functions[FOB.DefIds.Zerith].Other
                            )
                            _G.PLAYER_INVENTORY:RefreshAllInventorySlots(_G.INVENTORY_BACKPACK)
                        else
                            CALLBACK_MANAGER:UnregisterCallback(
                                "BackpackFullUpdate",
                                FOB.Functions[FOB.DefIds.Zerith].Other
                            )
                        end
                    end
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
            if (FOB.ActiveCompanionDefId == FOB.Zerith and FOB.Vars.PreventEdicts) then
                for _, i in pairs(_G.PLAYER_INVENTORY.inventories) do
                    local listView = i.listView

                    if listView and listView.dataTypes and listView.dataTypes[1] then
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
                                        info:AddIcon("FOB/assets/fobBlock.dds")
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

                                        rowControl:SetHandler("OnMouseUp", nil)
                                        rowControl:SetHandler("OnMouseEnter", nil)
                                        rowControl:SetHandler("OnMouseDoubleClick", nil)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    }
end
