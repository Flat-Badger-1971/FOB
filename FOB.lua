_G.FOB = {
    Name = "FOB"
}

local FOB = _G.FOB
local BASTIAN = GetCollectibleInfo(9245)
local MIRRI = GetCollectibleInfo(9353)

--tried just copying the original function and calling it - failed
--tried prehooking the original function -- failed
local function FOBHandler(interactionPossible, currentFrameTimeSeconds)
    if interactionPossible then
        local action,
            interactableName,
            interactionBlocked,
            isOwned,
            additionalInteractInfo,
            context,
            contextLink,
            isCriminalInteract = GetGameCameraInteractableActionInfo()

        if (action == GetString(_G.SI_GAMECAMERAACTIONTYPE2)) then
            isCompanionAction = interactableName == MIRRI or interactableName == BASTIAN

            if (isCompanionAction) then
                -- companion detected
                local interactionType = GetInteractionType()
                EndInteraction(interactionType)
                return false
            end
        end

        local interactKeybindButtonColor = ZO_NORMAL_TEXT
        local additionalInfoLabelColor = ZO_CONTRAST_TEXT
        RETICLE.interactKeybindButton:ShowKeyIcon()

        if action and interactableName then
            if isOwned or isCriminalInteract then
                interactKeybindButtonColor = ZO_ERROR_COLOR
            end

            if
                additionalInteractInfo == ADDITIONAL_INTERACT_INFO_NONE or
                    additionalInteractInfo == ADDITIONAL_INTERACT_INFO_INSTANCE_TYPE or
                    additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_BANK or
                    additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_INSTANCE_DOOR
             then
                RETICLE.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET, action))
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_EMPTY then
                RETICLE.interactKeybindButton:SetText(
                    zo_strformat(SI_FORMAT_BULLET_TEXT, GetString(SI_GAME_CAMERA_ACTION_EMPTY))
                )
                RETICLE.interactKeybindButton:HideKeyIcon()
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_LOCKED then
                RETICLE.interactKeybindButton:SetText(
                    zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO, action, GetString("SI_LOCKQUALITY", context))
                )
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
                RETICLE.additionalInfo:SetHidden(false)
                RETICLE.additionalInfo:SetText(GetString(SI_HOLD_TO_SELECT_BAIT))
                local lure = GetFishingLure()
                if lure then
                    local name = GetFishingLureInfo(lure)
                    RETICLE.interactKeybindButton:SetText(
                        zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO_BAIT, action, name)
                    )
                else
                    RETICLE.interactKeybindButton:SetText(
                        zo_strformat(
                            SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO,
                            action,
                            GetString(SI_NO_BAIT_OR_LURE_SELECTED)
                        )
                    )
                end
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_REQUIRES_KEY then
                local itemName = GetItemLinkName(contextLink)
                if interactionBlocked == true then
                    RETICLE.interactKeybindButton:SetText(
                        zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO_REQUIRES_KEY, action, itemName)
                    )
                else
                    RETICLE.interactKeybindButton:SetText(
                        zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO_WILL_CONSUME_KEY, action, itemName)
                    )
                end
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE then
                local isHostile, difficulty, isEmpty, prospectiveResult, monsterSocialClassString, monsterSocialClass
                RETICLE.isInBonus,
                    isHostile,
                    RETICLE.percentChance,
                    difficulty,
                    isEmpty,
                    prospectiveResult,
                    monsterSocialClassString,
                    monsterSocialClass = GetGameCameraPickpocketingBonusInfo()

                -- Prevent your success chance from going over 100%
                RETICLE.percentChance = zo_min(RETICLE.percentChance, 100)

                local additionalInfoText
                if (isEmpty and prospectiveResult == PROSPECTIVE_PICKPOCKET_RESULT_INVENTORY_FULL) then
                    additionalInfoText = GetString(SI_JUSTICE_PICKPOCKET_TARGET_EMPTY)
                elseif prospectiveResult ~= PROSPECTIVE_PICKPOCKET_RESULT_CAN_ATTEMPT then
                    additionalInfoText = GetString("SI_PROSPECTIVEPICKPOCKETRESULT", prospectiveResult)
                else
                    additionalInfoText =
                        isEmpty and GetString(SI_JUSTICE_PICKPOCKET_TARGET_EMPTY) or monsterSocialClassString
                end

                RETICLE.interactKeybindButton:SetText(
                    zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO, action, additionalInfoText)
                )

                interactKeybindButtonColor = ((not isHostile) and ZO_ERROR_COLOR or ZO_NORMAL_TEXT)

                if not interactionBlocked then
                    TriggerTutorial(TUTORIAL_TRIGGER_PICKPOCKET_PROMPT_VIEWED)
                    RETICLE.additionalInfo:SetHidden(false)
                    additionalInfoLabelColor = (RETICLE.isInBonus and ZO_SUCCEEDED_TEXT or ZO_CONTRAST_TEXT)

                    if (RETICLE.isInBonus and not RETICLE.wasInBonus) then
                        RETICLE.bonusScrollTimeline:PlayForward()
                        PlaySound(SOUNDS.JUSTICE_PICKPOCKET_BONUS)
                        RETICLE.wasInBonus = true
                    elseif (not RETICLE.isInBonus and RETICLE.wasInBonus) then
                        RETICLE.bonusScrollTimeline:PlayBackward()
                        RETICLE.wasInBonus = false
                    elseif (not RETICLE.bonusScrollTimeline:IsPlaying()) then
                        RETICLE.additionalInfo:SetText(
                            zo_strformat(SI_PICKPOCKET_SUCCESS_CHANCE, RETICLE.percentChance)
                        )
                        RETICLE.oldPercentChance = RETICLE.percentChance
                    end
                else
                    RETICLE.additionalInfo:SetHidden(true)
                end
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_WEREWOLF_ACTIVE_WHILE_ATTEMPTING_TO_CRAFT then
                RETICLE.interactKeybindButton:SetText(zo_strformat(SI_CANNOT_CRAFT_WHILE_WEREWOLF))
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_WEREWOLF_ACTIVE_WHILE_ATTEMPTING_TO_EXCAVATE then
                RETICLE.interactKeybindButton:SetText(zo_strformat(SI_CANNOT_EXCAVATE_WHILE_WEREWOLF))
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_IN_HIDEYHOLE then
                RETICLE.interactKeybindButton:SetText(zo_strformat(SI_EXIT_HIDEYHOLE))
            end

            local interactContextString = interactableName
            if additionalInteractInfo == ADDITIONAL_INTERACT_INFO_INSTANCE_TYPE then
                local instanceType = context
                if instanceType ~= INSTANCE_DISPLAY_TYPE_NONE then
                    local instanceTypeString =
                        zo_iconTextFormat(
                        GetInstanceDisplayTypeIcon(instanceType),
                        34,
                        34,
                        GetString("SI_INSTANCEDISPLAYTYPE", instanceType)
                    )
                    interactContextString =
                        zo_strformat(SI_ZONE_DOOR_RETICLE_INSTANCE_TYPE_FORMAT, interactableName, instanceTypeString)
                end
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_BANK then
                --Don't attempt to add the collectible nickname to the prompt if it isn't our house bank
                if IsOwnerOfCurrentHouse() then
                    local bankBag = context
                    local collectibleId = GetCollectibleForHouseBankBag(bankBag)
                    if collectibleId ~= 0 then
                        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
                        if collectibleData then
                            local nickname = collectibleData:GetNickname()
                            if nickname ~= "" then
                                interactContextString =
                                    zo_strformat(SI_RETICLE_HOUSE_BANK_WITH_NICKNAME_FORMAT, interactableName, nickname)
                            end
                        end
                    end
                end
            elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_INSTANCE_DOOR then
                local instanceType = INSTANCE_DISPLAY_TYPE_HOUSING
                local instanceTypeString =
                    zo_iconTextFormat(
                    GetInstanceDisplayTypeIcon(instanceType),
                    34,
                    34,
                    GetString("SI_INSTANCEDISPLAYTYPE", instanceType)
                )
                local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(context)
                if collectibleData then
                    local nickname = collectibleData:GetNickname()
                    --Theoretically it should be impossible for the nickname to be blank, but guard against it just in case
                    if nickname ~= "" then
                        interactContextString =
                            zo_strformat(
                            SI_HOUSE_DOOR_RETICLE_INSTANCE_TYPE_FORMAT,
                            interactableName,
                            nickname,
                            instanceTypeString
                        )
                    else
                        interactContextString =
                            zo_strformat(
                            SI_ZONE_DOOR_RETICLE_INSTANCE_TYPE_FORMAT,
                            interactableName,
                            instanceTypeString
                        )
                    end
                end
            end
            RETICLE.interactContext:SetText(interactContextString)

            RETICLE.interactionBlocked = interactionBlocked
            RETICLE.interactKeybindButton:SetNormalTextColor(interactKeybindButtonColor)
            RETICLE.additionalInfo:SetColor(additionalInfoLabelColor:UnpackRGBA())
            return true
        end
    end
end

RETICLE.TryHandlingInteraction = FOBHandler

function FOB.ShowCompanionMenu()
    if (HasActiveCompanion()) then
        if (not IsInGamepadPreferredMode()) then
            local sceneGroup = SCENE_MANAGER:GetSceneGroup("companionSceneGroup")
            local specificScene = sceneGroup:GetActiveScene()
            SCENE_MANAGER:Show(specificScene)
        end
    end
end

function FOB.DismissCompanion()
    if (HasActiveCompanion()) then
        local defId = GetActiveCompanionDefId()
        local collId = GetCompanionCollectibleId(defId)
        UseCollectible(collId)
    end
end

function FOB.Log(message, severity)
    if (FOB.Logger) then
        if (severity == "info") then
            FOB.Logger:Info(message)
        elseif (severity == "warn") then
            FOB.Logger:Warn(message)
        elseif (severity == "debug") then
            FOB.Logger:Debug(message)
        end
    end
end

function FOB.OnAddonLoaded(_, addonName)
    if (addonName == "LibDebugLogger") then
        zo_callLater(
            function()
                FOB.Logger = _G.LibDebugLogger(FOB.Name)
            end,
            2000
        )
    end

    if (addonName ~= FOB.Name) then
        return
    end

    --FOB.Log("Loaded", "info")
    EVENT_MANAGER:UnregisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED, FOB.OnAddonLoaded)
