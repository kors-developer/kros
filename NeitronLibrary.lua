local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function create(className, props)
    local instance = Instance.new(className)
    for key, value in pairs(props or {}) do
        instance[key] = value
    end
    return instance
end

local function round(target, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 18),
        Parent = target,
    })
end

local function stroke(target, color, transparency, thickness)
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        Parent = target,
    })
end

local function padding(target, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        Parent = target,
    })
end

local function tween(target, duration, goal, style, direction)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local handle = TweenService:Create(target, info, goal)
    handle:Play()
    return handle
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function getGuiParent()
    if CoreGui then
        return CoreGui
    end

    local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return playerGui
end

local Library = {
    Theme = {
        Background = Color3.fromRGB(8, 11, 18),
        Panel = Color3.fromRGB(16, 21, 32),
        PanelSoft = Color3.fromRGB(22, 29, 44),
        PanelRaised = Color3.fromRGB(27, 35, 52),
        Accent = Color3.fromRGB(0, 170, 255),
        AccentSoft = Color3.fromRGB(24, 83, 133),
        AccentDark = Color3.fromRGB(0, 117, 188),
        Text = Color3.fromRGB(243, 247, 255),
        Muted = Color3.fromRGB(153, 165, 186),
        Outline = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(57, 214, 147),
        Dim = Color3.fromRGB(87, 96, 113),
    },
}

local WindowMethods = {}
local TabMethods = {}

local function createPage(parent)
    local page = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        Parent = parent,
    })
    padding(page, 12, 12, 12, 12)

    local holder = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = page,
    })

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        holder.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end)

    return page, holder
end

local function createSectionCard(tab, side, text)
    local holder = side == "right" and tab.RightHolder or tab.CenterHolder

    local section = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = holder,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        Text = string.upper(text or "SECTION"),
        TextColor3 = tab.Window.Library.Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section,
    })

    create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = tab.Window.Library.Theme.Accent,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.28, 0, 0, 2),
        Parent = section,
    })

    return section
end

local function computeCardHeight(desc, baseHeight)
    if desc and desc ~= "" then
        return baseHeight + 26
    end
    return baseHeight
end

local function createCard(tab, options, height, side)
    options = options or {}
    local holder = side == "right" and tab.RightHolder or tab.CenterHolder
    local theme = tab.Window.Library.Theme

    local card = create("Frame", {
        BackgroundColor3 = theme.PanelRaised,
        BackgroundTransparency = 0.16,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height),
        Parent = holder,
    })
    round(card, 20)
    local cardStroke = stroke(card, theme.Outline, 0.92, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.PanelRaised),
            ColorSequenceKeypoint.new(1, theme.PanelSoft),
        }),
        Rotation = 18,
        Parent = card,
    })

    local shine = create("Frame", {
        BackgroundColor3 = theme.Outline,
        BackgroundTransparency = 0.985,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 0, 24),
        Parent = card,
    })
    round(shine, 20)

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(0, 14, 0, 12),
        Size = UDim2.new(1, -28, 0, 18),
        Text = options.Title or options.Name or "Element",
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local desc = options.Desc or options.Description or options.Text
    local descLabel = nil
    if desc and desc ~= "" then
        descLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0, 14, 0, 34),
            Size = UDim2.new(1, -28, 0, 34),
            Text = desc,
            TextColor3 = theme.Muted,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = card,
        })
    end

    return {
        Card = card,
        Stroke = cardStroke,
        Title = titleLabel,
        Description = descLabel,
    }
end

local function reserveCardTextSpace(cardData, rightInset)
    if not cardData then
        return
    end

    if cardData.Title then
        cardData.Title.Size = UDim2.new(1, -(rightInset + 14), 0, 18)
    end

    if cardData.Description then
        cardData.Description.Size = UDim2.new(1, -(rightInset + 14), 0, 34)
    end
end

function Library:CreateWindow(options)
    options = options or {}

    local theme = self.Theme
    local title = options.Title or options.Name or "Neitron UI"
    local subtitle = options.Subtitle or "Three panel library"
    local toggleKey = options.ToggleKey or Enum.KeyCode.K
    local size = options.Size or UDim2.fromScale(0.9, 0.82)
    local minSize = options.MinSize or Vector2.new(920, 560)
    local maxSize = options.MaxSize or Vector2.new(1500, 900)
    local leftWidth = options.LeftWidth or 0.19
    local rightWidth = options.RightWidth or 0.21
    local gap = options.Gap or 16
    local footerHeight = options.FooterHeight or 68
    local overlayTransparency = options.OverlayTransparency or 0.45
    local leftPanelTransparency = options.LeftPanelTransparency or 0.18
    local centerPanelTransparency = options.CenterPanelTransparency or 0.12
    local rightPanelTransparency = options.RightPanelTransparency or 0.18

    local rightPanelEnabled = options.RightPanelEnabled
    if rightPanelEnabled == nil then
        rightPanelEnabled = options.ShowRightPanel
    end
    if rightPanelEnabled == nil then
        rightPanelEnabled = options.RightPanel
    end
    if rightPanelEnabled == nil then
        rightPanelEnabled = true
    end

    local parent = getGuiParent()
    local oldGui = parent and parent:FindFirstChild("NeitronUI_Main")
    if oldGui then
        oldGui:Destroy()
    end

    local screenGui = create("ScreenGui", {
        Name = "NeitronUI_Main",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent,
    })

    local overlay = create("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = overlayTransparency,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = screenGui,
    })

    local stage = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        Parent = overlay,
    })

    create("UISizeConstraint", {
        MinSize = minSize,
        MaxSize = maxSize,
        Parent = stage,
    })

    local leftPanel = create("Frame", {
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = leftPanelTransparency,
        BorderSizePixel = 0,
        Size = UDim2.new(leftWidth, 0, 1, 0),
        Parent = stage,
    })
    round(leftPanel, 26)
    stroke(leftPanel, theme.Outline, 0.92, 1)

    local centerPanel = create("Frame", {
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = centerPanelTransparency,
        BorderSizePixel = 0,
        Position = UDim2.new(leftWidth, gap, 0, 0),
        Size = UDim2.new(1 - leftWidth - rightWidth, -(gap * 2), 1, 0),
        Parent = stage,
    })
    round(centerPanel, 28)
    stroke(centerPanel, theme.Outline, 0.9, 1)

    local rightPanel = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = rightPanelTransparency,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(rightWidth, 0, 1, 0),
        Parent = stage,
    })
    round(rightPanel, 26)
    stroke(rightPanel, theme.Outline, 0.92, 1)

    padding(leftPanel, 14, 14, 14, 14)
    padding(centerPanel, 14, 14, 14, 14)
    padding(rightPanel, 12, 12, 14, 12)

    local leftHeader = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 78),
        Parent = leftPanel,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 0, 0, 4),
        Size = UDim2.new(1, 0, 0, 24),
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = leftHeader,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 16),
        Text = subtitle,
        TextColor3 = theme.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = leftHeader,
    })

    local keyHint = create("TextLabel", {
        BackgroundColor3 = theme.AccentSoft,
        BackgroundTransparency = 0.52,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -28),
        Size = UDim2.fromOffset(78, 28),
        Font = Enum.Font.GothamSemibold,
        Text = toggleKey.Name .. " Toggle",
        TextColor3 = theme.Text,
        TextSize = 11,
        Parent = leftHeader,
    })
    round(keyHint, 999)
    stroke(keyHint, theme.Outline, 0.92, 1)

    local tabsWrap = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        Position = UDim2.new(0, 0, 0, 88),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        Size = UDim2.new(1, 0, 1, -(88 + footerHeight + 10)),
        Parent = leftPanel,
    })

    local tabsLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabsWrap,
    })

    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsWrap.CanvasSize = UDim2.new(0, 0, 0, tabsLayout.AbsoluteContentSize.Y + 8)
    end)

    local profileCard = create("Frame", {
        BackgroundColor3 = theme.PanelSoft,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -footerHeight),
        Size = UDim2.new(1, 0, 0, footerHeight),
        Parent = leftPanel,
    })
    round(profileCard, 20)
    stroke(profileCard, theme.Outline, 0.93, 1)

    local avatar = create("ImageLabel", {
        BackgroundColor3 = theme.AccentSoft,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -20),
        Size = UDim2.fromOffset(40, 40),
        Parent = profileCard,
    })
    round(avatar, 999)
    stroke(avatar, theme.Outline, 0.9, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(0, 58, 0, 14),
        Size = UDim2.new(1, -66, 0, 16),
        Text = LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name) or "Player",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = profileCard,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 58, 0, 32),
        Size = UDim2.new(1, -66, 0, 14),
        Text = LocalPlayer and ("@" .. LocalPlayer.Name) or "@Player",
        TextColor3 = theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = profileCard,
    })

    if LocalPlayer then
        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.AvatarBust,
                    Enum.ThumbnailSize.Size100x100
                )
            end)

            if ok and avatar.Parent then
                avatar.Image = image
            end
        end)
    end

    local centerHeader = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70),
        Parent = centerPanel,
    })

    local centerBadge = create("Frame", {
        BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.fromOffset(4, 54),
        Parent = centerHeader,
    })
    round(centerBadge, 999)

    local activeTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 16, 0, 10),
        Size = UDim2.new(1, -16, 0, 26),
        Text = "No Tab",
        TextColor3 = theme.Text,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = centerHeader,
    })

    local activeSubtitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 16, 0, 38),
        Size = UDim2.new(1, -16, 0, 18),
        Text = "Select a tab on the left",
        TextColor3 = theme.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = centerHeader,
    })

    local centerBody = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 78),
        Size = UDim2.new(1, 0, 1, -78),
        Parent = centerPanel,
    })

    local rightHeader = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70),
        Parent = rightPanel,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(0, 2, 0, 10),
        Size = UDim2.new(1, -4, 0, 20),
        Text = "Side Panel",
        TextColor3 = theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = rightHeader,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 2, 0, 34),
        Size = UDim2.new(1, -4, 0, 16),
        Text = "Separate widgets for the active tab",
        TextColor3 = theme.Muted,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = rightHeader,
    })

    local rightBody = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 78),
        Size = UDim2.new(1, 0, 1, -78),
        Parent = rightPanel,
    })

    local window = setmetatable({
        Library = self,
        ScreenGui = screenGui,
        Overlay = overlay,
        Stage = stage,
        LeftPanel = leftPanel,
        CenterPanel = centerPanel,
        RightPanel = rightPanel,
        TabsContainer = tabsWrap,
        CenterBody = centerBody,
        RightBody = rightBody,
        ActiveTitle = activeTitle,
        ActiveSubtitle = activeSubtitle,
        KeyHint = keyHint,
        LeftWidth = leftWidth,
        RightWidth = rightWidth,
        PanelGap = gap,
        OverlayBaseTransparency = overlayTransparency,
        LeftPanelBaseTransparency = leftPanelTransparency,
        CenterPanelBaseTransparency = centerPanelTransparency,
        RightPanelBaseTransparency = rightPanelTransparency,
        RightPanelEnabled = rightPanelEnabled,
        Tabs = {},
        SelectedTab = nil,
        ToggleKey = toggleKey,
        Visible = true,
        _keyConnection = nil,
    }, {
        __index = WindowMethods,
    })

    window:SetToggleKey(toggleKey)
    window:SetRightPanelVisible(rightPanelEnabled, true)

    stage.Size = UDim2.new(size.X.Scale, math.max(-40, size.X.Offset - 60), size.Y.Scale, math.max(-40, size.Y.Offset - 40))
    leftPanel.BackgroundTransparency = 1
    centerPanel.BackgroundTransparency = 1
    rightPanel.BackgroundTransparency = 1
    overlay.BackgroundTransparency = 1

    tween(overlay, 0.18, { BackgroundTransparency = overlayTransparency })
    tween(stage, 0.28, { Size = size }, Enum.EasingStyle.Quint)
    tween(leftPanel, 0.22, { BackgroundTransparency = leftPanelTransparency })
    tween(centerPanel, 0.22, { BackgroundTransparency = centerPanelTransparency })
    if rightPanelEnabled then
        tween(rightPanel, 0.22, { BackgroundTransparency = rightPanelTransparency })
    end

    return window
end

function WindowMethods:SetToggleKey(keyCode)
    if typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode then
        return
    end

    self.ToggleKey = keyCode
    if self.KeyHint then
        self.KeyHint.Text = keyCode.Name .. " Toggle"
    end

    if self._keyConnection then
        self._keyConnection:Disconnect()
    end

    self._keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.KeyCode ~= self.ToggleKey then
            return
        end

        self.Visible = not self.Visible

        if self.Visible then
            self.Overlay.Visible = true
            self.Stage.Visible = true
            self.Overlay.BackgroundTransparency = 1
            self.Stage.Position = UDim2.fromScale(0.5, 0.52)
            tween(self.Overlay, 0.15, { BackgroundTransparency = self.OverlayBaseTransparency or 0.45 })
            tween(self.Stage, 0.16, { Position = UDim2.fromScale(0.5, 0.5) })
        else
            local fade = tween(self.Overlay, 0.14, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tween(self.Stage, 0.14, { Position = UDim2.fromScale(0.5, 0.52) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            fade.Completed:Connect(function()
                if not self.Visible then
                    self.Stage.Visible = false
                    self.Overlay.Visible = false
                    self.Stage.Position = UDim2.fromScale(0.5, 0.5)
                end
            end)
        end
    end)
end

function WindowMethods:SetRightPanelVisible(visible, instant)
    local shouldShow = visible ~= false
    local centerPosition = UDim2.new(self.LeftWidth, self.PanelGap, 0, 0)
    local centerSize

    self.RightPanelEnabled = shouldShow

    if shouldShow then
        centerSize = UDim2.new(1 - self.LeftWidth - self.RightWidth, -(self.PanelGap * 2), 1, 0)
        self.RightPanel.Visible = true
    else
        centerSize = UDim2.new(1 - self.LeftWidth, -self.PanelGap, 1, 0)
    end

    if instant then
        self.CenterPanel.Position = centerPosition
        self.CenterPanel.Size = centerSize
        self.RightPanel.BackgroundTransparency = shouldShow and self.RightPanelBaseTransparency or 1
        self.RightPanel.Visible = shouldShow
    else
        tween(self.CenterPanel, 0.18, {
            Position = centerPosition,
            Size = centerSize,
        })

        if shouldShow then
            self.RightPanel.Visible = true
            self.RightPanel.BackgroundTransparency = 1
            tween(self.RightPanel, 0.18, {
                BackgroundTransparency = self.RightPanelBaseTransparency,
            })
        else
            local hide = tween(self.RightPanel, 0.16, {
                BackgroundTransparency = 1,
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

            hide.Completed:Connect(function()
                if not self.RightPanelEnabled then
                    self.RightPanel.Visible = false
                end
            end)
        end
    end

    for _, tab in ipairs(self.Tabs) do
        tab.RightPage.Visible = shouldShow and tab == self.SelectedTab
    end
end

WindowMethods.SetSidePanelVisible = WindowMethods.SetRightPanelVisible

function WindowMethods:Destroy()
    if self._keyConnection then
        self._keyConnection:Disconnect()
        self._keyConnection = nil
    end

    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

function WindowMethods:Tab(options)
    options = options or {}
    local theme = self.Library.Theme

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.PanelSoft,
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 58),
        Text = "",
        Parent = self.TabsContainer,
    })
    round(button, 18)
    local buttonStroke = stroke(button, theme.Outline, 0.93, 1)

    local accent = create("Frame", {
        BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -14),
        Size = UDim2.fromOffset(4, 28),
        Parent = button,
    })
    round(accent, 999)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(0, 22, 0, 10),
        Size = UDim2.new(1, -30, 0, 18),
        Text = options.Title or options.Name or "Tab",
        TextColor3 = theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 22, 0, 30),
        Size = UDim2.new(1, -30, 0, 14),
        Text = options.Description or options.Desc or "Open this tab",
        TextColor3 = theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
    })

    local centerPage, centerHolder = createPage(self.CenterBody)
    local rightPage, rightHolder = createPage(self.RightBody)

    local tab = setmetatable({
        Window = self,
        Button = button,
        ButtonStroke = buttonStroke,
        Accent = accent,
        CenterPage = centerPage,
        CenterHolder = centerHolder,
        RightPage = rightPage,
        RightHolder = rightHolder,
        Title = options.Title or options.Name or "Tab",
        Description = options.Description or options.Desc or "Open this tab",
    }, {
        __index = TabMethods,
    })

    button.MouseEnter:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0.14 })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0.22 })
        end
    end)

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function WindowMethods:SelectTab(indexOrTab)
    local tab = indexOrTab
    if type(indexOrTab) == "number" then
        tab = self.Tabs[indexOrTab]
    end

    if not tab then
        return
    end

    for _, entry in ipairs(self.Tabs) do
        local active = entry == tab
        entry.CenterPage.Visible = active
        entry.RightPage.Visible = active and self.RightPanelEnabled

        tween(entry.Button, 0.18, {
            BackgroundTransparency = active and 0.08 or 0.22,
            BackgroundColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.PanelSoft,
        })
        tween(entry.ButtonStroke, 0.18, {
            Transparency = active and 0.86 or 0.93,
            Color = active and self.Library.Theme.Accent or self.Library.Theme.Outline,
        })
        tween(entry.Accent, 0.18, {
            BackgroundTransparency = active and 0.05 or 1,
        })
    end

    self.SelectedTab = tab
    self.ActiveTitle.Text = tab.Title
    self.ActiveSubtitle.Text = tab.Description
end

function TabMethods:Section(name)
    return createSectionCard(self, "center", name)
end

function TabMethods:RightSection(name)
    return createSectionCard(self, "right", name)
end

function TabMethods:Paragraph(options)
    local card = createCard(self, options, computeCardHeight(options and (options.Desc or options.Description or options.Text), 78), "center")
    return card.Card
end

function TabMethods:RightParagraph(options)
    local card = createCard(self, options, computeCardHeight(options and (options.Desc or options.Description or options.Text), 78), "right")
    return card.Card
end

function TabMethods:Label(options)
    options = options or {}
    local card = createCard(self, options, computeCardHeight(options.Desc or options.Description or options.Text, 62), "center")
    return card.Card
end

function TabMethods:RightLabel(options)
    options = options or {}
    local card = createCard(self, options, computeCardHeight(options.Desc or options.Description or options.Text, 62), "right")
    return card.Card
end

local function addButton(tab, options, side)
    options = options or {}
    local card = createCard(tab, options, computeCardHeight(options.Desc or options.Description, 72), side)
    local theme = tab.Window.Library.Theme
    reserveCardTextSpace(card, 132)

    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = theme.AccentDark,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(104, 36),
        Font = Enum.Font.GothamSemibold,
        Text = options.ButtonText or options.ActionText or "Run",
        TextColor3 = theme.Text,
        TextSize = 13,
        Parent = card.Card,
    })
    round(button, 14)
    stroke(button, theme.Outline, 0.9, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(1, theme.AccentDark),
        }),
        Rotation = 20,
        Parent = button,
    })

    button.MouseEnter:Connect(function()
        tween(button, 0.12, { Size = UDim2.fromOffset(108, 38) })
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.12, { Size = UDim2.fromOffset(104, 36) })
    end)

    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)

    return {
        Card = card.Card,
        Button = button,
    }
end

function TabMethods:Button(options)
    return addButton(self, options, "center")
end

function TabMethods:RightButton(options)
    return addButton(self, options, "right")
end

local function addToggle(tab, options, side)
    options = options or {}
    local theme = tab.Window.Library.Theme
    local state = options.Value == true or options.Default == true or options.CurrentValue == true
    local card = createCard(tab, options, computeCardHeight(options.Desc or options.Description, 72), side)
    reserveCardTextSpace(card, 86)

    local toggle = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = state and theme.Success or theme.Dim,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(58, 32),
        Text = "",
        Parent = card.Card,
    })
    round(toggle, 999)
    stroke(toggle, theme.Outline, 0.9, 1)

    local knob = create("Frame", {
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Position = state and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3),
        Size = UDim2.fromOffset(26, 26),
        Parent = toggle,
    })
    round(knob, 999)

    local function setState(value)
        state = value
        tween(toggle, 0.16, { BackgroundColor3 = state and theme.Success or theme.Dim })
        tween(knob, 0.16, { Position = state and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3) })

        if options.Callback then
            options.Callback(state)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return {
        Card = card.Card,
        Get = function()
            return state
        end,
        Set = setState,
    }
end

function TabMethods:Toggle(options)
    return addToggle(self, options, "center")
end

function TabMethods:RightToggle(options)
    return addToggle(self, options, "right")
end

local function addSlider(tab, options, side)
    options = options or {}

    local theme = tab.Window.Library.Theme
    local range = options.Range or options.Value or {}
    local minimum = options.Min or range.Min or range[1] or 0
    local maximum = options.Max or range.Max or range[2] or 100
    local step = options.Step or options.Increment or 1
    local current = options.Default or options.CurrentValue or range.Default or minimum
    local dragging = false

    local card = createCard(tab, options, computeCardHeight(options.Desc or options.Description, 100), side)
    reserveCardTextSpace(card, 104)

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(1, -14, 0, 12),
        Size = UDim2.fromOffset(90, 18),
        Text = tostring(current),
        TextColor3 = theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = card.Card,
    })

    local trackY = (options.Desc or options.Description) and 74 or 54
    local track = create("Frame", {
        BackgroundColor3 = theme.Dim,
        BackgroundTransparency = 0.32,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0, trackY),
        Size = UDim2.new(1, -28, 0, 8),
        Parent = card.Card,
    })
    round(track, 999)

    local fill = create("Frame", {
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    round(fill, 999)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = track,
    })
    round(knob, 999)

    local function setValue(raw)
        local snapped = math.floor(((raw - minimum) / step) + 0.5) * step + minimum
        current = clamp(snapped, minimum, maximum)
        local alpha = (current - minimum) / math.max(maximum - minimum, 1)

        tween(fill, 0.08, { Size = UDim2.new(alpha, 0, 1, 0) })
        tween(knob, 0.08, { Position = UDim2.new(alpha, 0, 0.5, 0) })
        valueLabel.Text = tostring(current)

        if options.Callback then
            options.Callback(current)
        end
    end

    local function updateFromInput(input)
        local alpha = clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setValue(minimum + (maximum - minimum) * alpha)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
        end
    end)

    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    end)

    setValue(current)

    return {
        Card = card.Card,
        Get = function()
            return current
        end,
        Set = setValue,
    }
end

function TabMethods:Slider(options)
    return addSlider(self, options, "center")
end

function TabMethods:RightSlider(options)
    return addSlider(self, options, "right")
end

function TabMethods:Bind(options)
    options = options or {}
    local theme = self.Window.Library.Theme
    local card = createCard(self, options, computeCardHeight(options.Desc or options.Description, 72), "right")
    reserveCardTextSpace(card, 120)
    local currentKey = options.Key or options.Default or Enum.KeyCode.K
    local waiting = false
    local connection = nil

    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = theme.PanelSoft,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(92, 34),
        Font = Enum.Font.GothamSemibold,
        Text = currentKey.Name,
        TextColor3 = theme.Text,
        TextSize = 13,
        Parent = card.Card,
    })
    round(button, 14)
    stroke(button, theme.Outline, 0.92, 1)

    local function setKey(key)
        currentKey = key
        button.Text = key.Name

        if options.Callback then
            options.Callback(key)
        end
    end

    button.MouseButton1Click:Connect(function()
        if waiting then
            return
        end

        waiting = true
        button.Text = "..."

        local temp
        temp = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            temp:Disconnect()
            waiting = false
            setKey(input.KeyCode)
        end)
    end)

    if options.ListenCallback then
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == currentKey then
                options.ListenCallback()
            end
        end)
    end

    return {
        Card = card.Card,
        Get = function()
            return currentKey
        end,
        Set = setKey,
        Disconnect = function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
    }
end

WindowMethods.CreateTab = WindowMethods.Tab

TabMethods.CreateSection = TabMethods.Section
TabMethods.CreateRightSection = TabMethods.RightSection
TabMethods.CreateParagraph = TabMethods.Paragraph
TabMethods.CreateRightParagraph = TabMethods.RightParagraph
TabMethods.CreateLabel = TabMethods.Label
TabMethods.CreateRightLabel = TabMethods.RightLabel
TabMethods.CreateButton = TabMethods.Button
TabMethods.CreateRightButton = TabMethods.RightButton
TabMethods.CreateToggle = TabMethods.Toggle
TabMethods.CreateRightToggle = TabMethods.RightToggle
TabMethods.CreateSlider = TabMethods.Slider
TabMethods.CreateRightSlider = TabMethods.RightSlider
TabMethods.CreateBind = TabMethods.Bind

return Library
