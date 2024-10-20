local FOB = _G.FOB

function FOB.CreateMultiIcon(name, parent, size)
    local logo = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_MultiIcon")

    logo:SetAnchor(CENTER)
    logo:SetDimensions(size, size)
    logo:AddIcon(FOB.Logo)
    logo:AddIcon(FOB.LogoBlock)
    logo:Hide()
    -- logo:SetTexture(FOB.ReticlePath)
    -- logo:SetHidden(true)

    return logo
end

function FOB.ReplaceReticle()
    if (FOB.Vars.UseReticle) then
        if (not FOB.UsingFOBReticle) then
            _G.ZO_ReticleContainerReticle:SetAlpha(0)
            FOB.Reticle:SetHidden(false)
            FOB.UsingFOBReticle = true
        end
    else
        FOB.UsingFOBReticle = false
    end
end

function FOB.RestoreReticle()
    if (FOB.UsingFOBReticle) then
        _G.ZO_ReticleContainerReticle:SetAlpha(1)
        FOB.Reticle:SetHidden(true)
        FOB.UsingFOBReticle = false
    end
end

function FOB.ShowAlert(alert)
    alert:SetAlpha(1)
    alert:SetHidden(false)
    alert.Animation:PlayFromStart()

    PlaySound(_G.SOUNDS.QUEST_ABANDONED)

    zo_callLater(
        function()
            alert.FadeAnimation:PlayFromStart()
        end,
        750
    )
end

function FOB.SetupCheeseAlert()
    local font = {
        font = FOB.Vars.CheeseFont,
        size = FOB.Vars.CheeseFontSize,
        shadow = FOB.Vars.CheeseFontShadow,
        colour = FOB.Vars.CheeseFontColour
    }

    FOB.Alert = FOB.SetupAlert("FOB_Cheese_Alert", FOB.Vars.CheeseIcon, font, _G.FOB_CHEESE_ALERT)
end

function FOB.SetupCoffeeAlert()
    local font = {
        font = FOB.Vars.CoffeeFont,
        size = FOB.Vars.CoffeeFontSize,
        shadow = FOB.Vars.CoffeeFontShadow,
        colour = FOB.Vars.CoffeeFontColour
    }

    FOB.CoffeeAlert = FOB.SetupAlert("FOB_Coffee_Alert", FOB.Vars.CoffeeIcon, font, _G.FOB_COFFEE_ALERT)
end

function FOB.SetupAlert(name, icon, fontInfo, text)
    local alert = WINDOW_MANAGER:CreateTopLevelWindow(name)

    -- main window
    alert:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    alert:SetDimensions(256, 64)
    alert:SetHidden(true)

    -- icon
    alert.Texture = WINDOW_MANAGER:CreateControl(name .. "_Texture", alert, CT_TEXTURE)
    alert.Texture:SetTexture(icon)
    alert.Texture:SetAnchor(LEFT, alert, LEFT)
    alert.Texture:SetDimensions(64, 64)

    -- label
    local font = FOB.GetFont(fontInfo.font, fontInfo.size, fontInfo.shadow)

    alert.Label = WINDOW_MANAGER:CreateControl(name .. "_Label", alert, CT_LABEL)
    alert.Label:SetFont(font)
    alert.Label:SetColor(fontInfo.colour.r, fontInfo.colour.g, fontInfo.colour.b, fontInfo.colour.a)
    alert.Label:SetHorizontalAlignment(_G.TEXT_ALIGN_CENTER)
    alert.Label:SetVerticalAlignment(_G.TEXT_ALIGN_CENTER)
    alert.Label:SetText(GetString(text))
    alert.Label:SetDimensions(184, 64)
    alert.Label:SetAnchor(LEFT, alert.Texture, RIGHT)
    alert.Label:SetHidden(false)

    -- fade out animation
    local fadeAnimation, fadeTimeline = CreateSimpleAnimation(_G.ANIMATION_ALPHA, alert)

    fadeAnimation:SetAlphaValues(1, 0)
    fadeAnimation:SetDuration(1000)
    fadeAnimation:SetHandler(
        "OnStop",
        function()
            FOB.Alert:SetHidden(true)
        end
    )

    fadeTimeline:SetPlaybackType(_G.ANIMATION_PLAYBACK_ONE_SHOT)

    alert.FadeAnimation = fadeTimeline

    local animation, timeline = CreateSimpleAnimation(_G.ANIMATION_SCALE, alert)

    -- scaling animation
    animation:SetStartScale(1)
    animation:SetEndScale(3)
    animation:SetDuration(1500)

    timeline:SetPlaybackType(_G.ANIMATION_PLAYBACK_ONE_SHOT)

    alert.Animation = timeline
    alert.FadeAnimation = fadeTimeline

    return alert
end

-- companion summoning frame
function FOB.CreateCompanionSummoningFrame()
    local name = FOB.Name .. "_CompanionSummoningFrame"

    FOB.SummoningFrame = _G[name] or WINDOW_MANAGER:CreateTopLevelWindow(name)
    FOB.SummoningFrame:SetDimensions(GuiRoot:GetWidth() / 3, 30)
    FOB.SummoningFrame:SetAnchor(CENTER, GuiRoot, CENTER)
    FOB.SummoningFrame:SetDrawTier(DT_HIGH)

    FOB.SummoningFrame.Message = WINDOW_MANAGER:CreateControl(name .. "_Message", FOB.SummoningFrame, CT_LABEL)
    FOB.SummoningFrame.Message:SetDimensions(400, 30)
    FOB.SummoningFrame.Message:SetAnchor(CENTER, FOB.SummoningFrame, CENTER, 0, (GuiRoot:GetHeight() / 4) * -1)
    FOB.SummoningFrame.Message:SetFont(FOB.GetFont("ESO Bold", 28, true))
    FOB.SummoningFrame.Message:SetHorizontalAlignment(CENTER)
    FOB.SummoningFrame.Message:SetVerticalAlignment(CENTER)
    FOB.SummoningFrame.Message:SetColor(157 / 255, 132 / 255, 13 / 255, 1)
end

local function createFobInfoControl()
    local name = "FOB_INFO"
    local control = WINDOW_MANAGER:CreateTopLevelWindow(name)

    control:SetAnchorFill()

    control.container = WINDOW_MANAGER:CreateControl(name .. "Container", control, CT_CONTROL)
    control.container:SetResizeToFitDescendents(true)
    control.container:SetResizeToFitPadding(10)
    control.container:SetAnchor(BOTTOM, control, BOTTOM, 0, _G.ZO_COMMON_INFO_DEFAULT_KEYBOARD_BOTTOM_OFFSET_Y)

    control.icon = FOB.CreateMultiIcon(name .. "Icon", control.container, 50) --WINDOW_MANAGER:CreateControl(name .. "Icon", control.container, CT_TEXTURE)
    control.icon:ClearAnchors()
    control.icon:SetAnchor(LEFT)
    --control.icon:SetDimensions(50, 50)
    -- control.icon:SetTexture(FOB.ReticlePath)

    control.frame = WINDOW_MANAGER:CreateControl(name .. "Frame", control.icon, CT_TEXTURE)
    control.frame:SetTexture("esoui/art/actionbar/abilityFrame64_up.dds")
    control.frame:SetDrawLayer(_G.CONTROLS)

    control.action = WINDOW_MANAGER:CreateControl(name .. "Action", control.container, CT_LABEL)
    control.action:SetFont("ZoInteractionPrompt")
    control.action:SetHorizontalAlignment(CENTER)
    control.action:SetAnchor(LEFT, control.icon, RIGHT, 15, 0)
    control.action:SetText(FOB.BladeOfWoeFormatted)

    return control
end

-- init
do
    _G.FOB.Fonts = {}
    _G.FOB.CompanionNames = {}

    for fontName, _ in pairs(_G.FOB.FontDefs) do
        table.insert(_G.FOB.Fonts, fontName)
    end

    for _, defId in pairs(_G.FOB.DefIds) do
        local cid = GetCompanionCollectibleId(defId)
        local name = FOB.GetFirstWord(GetCollectibleInfo(cid))

        _G.FOB.CompanionNames[name] = true
    end

    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end

    FOB.Reticle = FOB.CreateLogo(_G.ZO_ReticleContainer)
    FOB.BladeOfWoeFormatted = ZO_CachedStrFormat("<<C:1>>", FOB.BladeOfWoe)

    -- setup FOB information area
    local fobControl = createFobInfoControl()
    local fobInfo = ZO_Object:Subclass()

    function fobInfo:New(control)
        local fi = ZO_Object.New(self)

        fi:Initialise(control)

        return self
    end

    function fobInfo:Initialise(control)
        local priority = 4 -- SYNERGY_PRIORITY
        local category = 4 -- next category (made need updating in future patches or for addon compatibility)

        self.control = control

        local function onSynergyAbilityChanged()
            self:OnSynergyAbilityChanged()
        end

        self.control:RegisterForEvent(_G.EVENT_PLAYER_ACTIVATED, onSynergyAbilityChanged)
        self.control:RegisterForEvent(_G.EVENT_SYNERGY_ABILITY_CHANGED, onSynergyAbilityChanged)

        _G.SHARED_INFORMATION_AREA.prioritizedVisibility:Add(self, priority, category, "FobInfo")

        self.container = self.control.container
        self.action = self.control.action
        self.icon = self.control.icon
        self.frame = self.control.frame

        _G.ZO_PlatformStyle:New(
            function(constants)
                self:ApplyTextStyle(constants)
            end,
            {
                FONT = "ZoInteractionPrompt",
                TEMPLATE = "ZO_KeybindButton_Keyboard_Template",
                OFFSET_Y = _G.ZO_COMMON_INFO_DEFAULT_KEYBOARD_BOTTOM_OFFSET_Y,
                FRAME_TEXTURE = "esoui/art/actionbar/abilityframe64_up.dds"
            },
            {
                FONT = "ZoFontGamepad42",
                TEMPLATE = "ZO_KeybindButton_Gamepad_Template",
                OFFSET_Y = _G.ZO_COMMON_INFO_DEFAULT_GAMEPAD_BOTTOM_OFFSET_Y,
                FRAME_TEXTURE = "esoui/art/actionbar/gamepad/gp_abilityframe64.dds"
            }
        )
    end

    function fobInfo:ApplyTextStyle(constants)
        self.frame:SetTexture(constants.FRAME_TEXTURE)
        self.action:SetFont(constants.FONT)
        ApplyTemplateToControl(self.key, constants.TEMPLATE)
        self.container:ClearAnchors()
        self.container:SetAnchor(BOTTOM, nil, BOTTOM, 0, constants.OFFSET_Y)
    end

    function fobInfo:ShowInfo()
        SHARED_INFORMATION_AREA:SetCategoriesSuppressed(
            true,
            _G.ZO_SHARED_INFORMATION_AREA_SUPPRESSION_CATEGORIES.HAS_KEYBINDS,
            "Synergy"
        )

        self.lastSynergyName = FOB.BladeOfWoe

        if (_G.SHARED_INFORMATION_AREA.prioritizedVisibility:GetObjectInfo(self)) then
            SHARED_INFORMATION_AREA:SetHidden(self, false)
        end
    end

    function fobInfo:HideInfo()
        SHARED_INFORMATION_AREA:SetCategoriesSuppressed(
            false,
            _G.ZO_SHARED_INFORMATION_AREA_SUPPRESSION_CATEGORIES.HAS_KEYBINDS,
            "Synergy"
        )

        self.lastSynergyName = nil

        if (self:IsVisible()) then
            SHARED_INFORMATION_AREA:SetHidden(self, true)
        end
    end

    function fobInfo:OnSynergyAbilityChanged()
        if (FOB.Enabled) then
            if (FOB.Vars.BoWCompanions[FOB.ActiveCompanionDefId]) then
                local hasSynergy, synergyName = GetCurrentSynergyInfo()

                if (hasSynergy) then
                    if (self.lastSynergyName ~= FOB.BladeOfWoe) then
                        if (synergyName == FOB.BladeOfWoe) then
                            self:ShowInfo()
                        else
                            self:HideInfo()
                        end
                    end
                else
                    self:HideInfo()
                end
            end
        else
            self:HideInfo()
        end
    end

    function fobInfo:SetHidden(hidden)
        self.control:SetHidden(hidden)
    end

    function fobInfo:IsVisible()
        return not SHARED_INFORMATION_AREA:IsHidden(self) and not SHARED_INFORMATION_AREA:IsSuppressed()
    end

    FOB.FobInfo = fobInfo:New(fobControl)
end
