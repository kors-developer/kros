local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function create(instanceType, props)
    local instance = Instance.new(instanceType)

    for key, value in pairs(props or {}) do
        instance[key] = value
    end

    return instance
end

local function corner(parent, radius)
    local uiCorner = create("UICorner", {
        CornerRadius = UDim.new(0, radius or 18),
        Parent = parent,
    })

    return uiCorner
end

local function stroke(parent, color, transparency, thickness)
    local uiStroke = create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })

    return uiStroke
end

local function padding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        Parent = parent,
    })
end

local function inferParent()
    local coreGui = game:GetService("CoreGui")
    if coreGui then
        return coreGui
    end

    local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return playerGui
end

local KorsUI = {
    Theme = {
        Accent = Color3.fromRGB(90, 180, 255),
        AccentDark = Color3.fromRGB(36, 110, 220),
        WindowFill = Color3.fromRGB(20, 24, 36),
        PanelFill = Color3.fromRGB(33, 40, 56),
        Surface = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(245, 247, 255),
        MutedText = Color3.fromRGB(168, 176, 196),
        Divider = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(61, 220, 132),
    },
    _notifications = nil,
}

function KorsUI:_ensureNotifications()
    if self._notifications and self._notifications.Parent then
        return self._notifications
    end

    local container = create("ScreenGui", {
        Name = "KorsUI_Notifications",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = inferParent(),
    })

    local holder = create("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.new(0, 320, 1, -36),
        Parent = container,
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = holder,
    })

    self._notifications = holder
    return holder
end

function KorsUI:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    local holder = self:_ensureNotifications()

    local card = create("Frame", {
        BackgroundColor3 = self.Theme.PanelFill,
        BackgroundTransparency = 0.14,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = holder,
    })
    corner(card, 20)
    stroke(card, self.Theme.Surface, 0.82, 1)

    local glow = create("Frame", {
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = card.ZIndex - 1,
        Parent = card,
    })
    corner(glow, 20)

    padding(card, 14, 14, 12, 12)

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 18),
        Parent = card,
    })

    local contentLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = content,
        TextColor3 = self.Theme.MutedText,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card,
    })

    card.Position = UDim2.new(1, 22, 0, 0)
    card.BackgroundTransparency = 1
    TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.14,
    }):Play()

    task.delay(duration, function()
        if not card.Parent then
            return
        end

        local tween = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 24, 0, 0),
            BackgroundTransparency = 1,
        })
        tween:Play()
        tween.Completed:Wait()
        card:Destroy()
    end)
end

local WindowMethods = {}
local TabMethods = {}

function KorsUI:CreateWindow(options)
    options = options or {}

    local title = options.Title or "KorsUI"
    local subtitle = options.Subtitle or "iOS style transparent library"
    local size = options.Size or UDim2.fromOffset(640, 430)
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

    local existing = inferParent() and inferParent():FindFirstChild("KorsUI_Window")
    if existing then
        existing:Destroy()
    end

    local screenGui = create("ScreenGui", {
        Name = "KorsUI_Window",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = inferParent(),
    })

    local root = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundColor3 = self.Theme.WindowFill,
        BackgroundTransparency = options.Transparent == false and 0.06 or 0.16,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    corner(root, 28)
    stroke(root, self.Theme.Surface, 0.84, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 32, 48)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 20, 31)),
        }),
        Rotation = 55,
        Parent = root,
    })

    local highlight = create("Frame", {
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 72),
        Parent = root,
    })
    corner(highlight, 24)

    local topBar = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 0, 68),
        Position = UDim2.new(0, 12, 0, 10),
        Parent = root,
    })

    local traffic = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 14),
        Position = UDim2.new(0, 8, 0, 8),
        Parent = topBar,
    })

    local trafficColors = {
        Color3.fromRGB(255, 95, 87),
        Color3.fromRGB(255, 189, 46),
        Color3.fromRGB(39, 201, 63),
    }

    for index, color in ipairs(trafficColors) do
        local dot = create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(10, 10),
            Position = UDim2.new(0, (index - 1) * 16, 0, 0),
            Parent = traffic,
        })
        corner(dot, 999)
    end

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 26),
        Size = UDim2.new(1, -120, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    local subtitleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 48),
        Size = UDim2.new(1, -120, 0, 16),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = self.Theme.MutedText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    local keyChip = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, 12),
        Size = UDim2.fromOffset(106, 26),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.9,
        Font = Enum.Font.GothamMedium,
        Text = "Toggle: " .. toggleKey.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 11,
        Parent = topBar,
    })
    corner(keyChip, 999)
    stroke(keyChip, self.Theme.Surface, 0.86, 1)

    local body = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 88),
        Size = UDim2.new(1, -24, 1, -100),
        Parent = root,
    })

    local sidebar = create("Frame", {
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.92,
        Size = UDim2.new(0, options.SidebarWidth or 170, 1, 0),
        Parent = body,
    })
    corner(sidebar, 24)
    stroke(sidebar, self.Theme.Surface, 0.88, 1)

    local sidebarLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar,
    })

    padding(sidebar, 10, 10, 10, 10)

    local content = create("Frame", {
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.94,
        Position = UDim2.new(0, (options.SidebarWidth or 170) + 12, 0, 0),
        Size = UDim2.new(1, -(options.SidebarWidth or 170) - 12, 1, 0),
        Parent = body,
    })
    corner(content, 24)
    stroke(content, self.Theme.Surface, 0.9, 1)

    local window = setmetatable({
        Library = self,
        ScreenGui = screenGui,
        Root = root,
        KeyChip = keyChip,
        Sidebar = sidebar,
        Content = content,
        Tabs = {},
        SelectedTab = nil,
        ToggleKey = toggleKey,
        Visible = true,
        _inputConnection = nil,
    }, {
        __index = WindowMethods,
    })

    do
        local dragging = false
        local dragStart
        local startPos

        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = root.Position
            end
        end)

        topBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end

            local delta = input.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end)
    end

    window:_bindToggleKey(toggleKey, keyChip)
    return window
end

function WindowMethods:_bindToggleKey(keyCode, keyChip)
    self.ToggleKey = keyCode
    if keyChip then
        keyChip.Text = "Toggle: " .. keyCode.Name
    end

    if self._inputConnection then
        self._inputConnection:Disconnect()
    end

    self._inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            self.Root.Visible = self.Visible
        end
    end)
end

function WindowMethods:SetToggleKey(keyCode)
    if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
        self:_bindToggleKey(keyCode, self.KeyChip)
    end
end

function WindowMethods:Tab(options)
    options = options or {}
    local title = options.Title or "Tab"
    local icon = options.Icon or ""

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Library.Theme.Surface,
        BackgroundTransparency = 0.96,
        Size = UDim2.new(1, 0, 0, 50),
        Font = Enum.Font.GothamMedium,
        Text = "",
        Parent = self.Sidebar,
    })
    corner(button, 18)
    local buttonStroke = stroke(button, self.Library.Theme.Surface, 0.94, 1)

    local iconLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 26, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = icon ~= "" and icon or "•",
        TextColor3 = self.Library.Theme.Accent,
        TextSize = 18,
        Parent = button,
    })

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 0),
        Size = UDim2.new(1, -58, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = title,
        TextColor3 = self.Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
    })

    local page = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = self.Content,
    })

    local pageLayout = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    padding(page, 14, 14, 14, 14)

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 14)
    end)

    local tab = setmetatable({
        Window = self,
        Button = button,
        ButtonStroke = buttonStroke,
        IconLabel = iconLabel,
        TitleLabel = titleLabel,
        Page = page,
    }, {
        __index = TabMethods,
    })

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function WindowMethods:SelectTab(tabOrIndex)
    local nextTab = tabOrIndex
    if type(tabOrIndex) == "number" then
        nextTab = self.Tabs[tabOrIndex]
    end

    if not nextTab then
        return
    end

    for _, tab in ipairs(self.Tabs) do
        local selected = tab == nextTab
        tab.Page.Visible = selected
        TweenService:Create(tab.Button, TweenInfo.new(0.18), {
            BackgroundTransparency = selected and 0.8 or 0.96,
            BackgroundColor3 = selected and self.Library.Theme.AccentDark or self.Library.Theme.Surface,
        }):Play()
        TweenService:Create(tab.ButtonStroke, TweenInfo.new(0.18), {
            Transparency = selected and 0.75 or 0.94,
            Color = selected and self.Library.Theme.Accent or self.Library.Theme.Surface,
        }):Play()
        tab.IconLabel.TextColor3 = selected and self.Library.Theme.Text or self.Library.Theme.Accent
    end

    self.SelectedTab = nextTab
end

local function makeCard(tab, options, height)
    options = options or {}

    local card = create("Frame", {
        BackgroundColor3 = tab.Window.Library.Theme.Surface,
        BackgroundTransparency = 0.94,
        Size = UDim2.new(1, 0, 0, height or 62),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab.Page,
    })
    corner(card, 20)
    stroke(card, tab.Window.Library.Theme.Surface, 0.9, 1)
    padding(card, 14, 14, 12, 12)

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -90, 0, 18),
        Font = Enum.Font.GothamSemibold,
        Text = options.Title or "Untitled",
        TextColor3 = tab.Window.Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local descLabel
    if options.Desc then
        descLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 22),
            Size = UDim2.new(1, -20, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = options.Desc,
            TextColor3 = tab.Window.Library.Theme.MutedText,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = card,
        })
    end

    return card, titleLabel, descLabel
end

function TabMethods:Paragraph(options)
    local card = makeCard(self, options, 74)
    return card
end

function TabMethods:Label(options)
    local card = makeCard(self, options, 64)
    return card
end

function TabMethods:Button(options)
    local card = makeCard(self, options, options.Desc and 92 or 68)

    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(92, 34),
        AutoButtonColor = false,
        BackgroundColor3 = self.Window.Library.Theme.AccentDark,
        Font = Enum.Font.GothamSemibold,
        Text = options.ButtonText or "Run",
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 13,
        Parent = card,
    })
    corner(button, 16)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Window.Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, self.Window.Library.Theme.AccentDark),
        }),
        Rotation = 35,
        Parent = button,
    })

    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)

    return {
        Card = card,
        Button = button,
    }
end

function TabMethods:Toggle(options)
    options = options or {}
    local state = options.Value == true
    local card = makeCard(self, options, options.Desc and 92 or 68)

    local toggleButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(54, 32),
        AutoButtonColor = false,
        BackgroundColor3 = state and self.Window.Library.Theme.Success or Color3.fromRGB(120, 128, 145),
        Text = "",
        Parent = card,
    })
    corner(toggleButton, 999)

    local knob = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(26, 26),
        Position = state and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3),
        Parent = toggleButton,
    })
    corner(knob, 999)

    local function setState(newState)
        state = newState
        TweenService:Create(toggleButton, TweenInfo.new(0.18), {
            BackgroundColor3 = state and self.Window.Library.Theme.Success or Color3.fromRGB(120, 128, 145),
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3),
        }):Play()

        if options.Callback then
            options.Callback(state)
        end
    end

    toggleButton.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return {
        Card = card,
        Set = setState,
        Get = function()
            return state
        end,
    }
end

function TabMethods:Slider(options)
    options = options or {}

    local range = options.Value or {}
    local minValue = options.Min or range.Min or 0
    local maxValue = options.Max or range.Max or 100
    local step = options.Step or 1
    local currentValue = options.Default or range.Default or minValue

    currentValue = clamp(currentValue, minValue, maxValue)

    local card = makeCard(self, options, options.Desc and 116 or 92)

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(70, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = tostring(currentValue),
        TextColor3 = self.Window.Library.Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = card,
    })

    local barY = options.Desc and 72 or 48

    local bar = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(96, 103, 120),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, barY),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = card,
    })
    corner(bar, 999)

    local fill = create("Frame", {
        BackgroundColor3 = self.Window.Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = bar,
    })
    corner(fill, 999)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = bar,
    })
    corner(knob, 999)

    local dragging = false

    local function applyValue(rawValue)
        local snapped = math.floor(((rawValue - minValue) / step) + 0.5) * step + minValue
        currentValue = clamp(snapped, minValue, maxValue)
        local alpha = (currentValue - minValue) / math.max(maxValue - minValue, 1)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(currentValue)

        if options.Callback then
            options.Callback(currentValue)
        end
    end

    local function updateFromInput(input)
        local alpha = clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local rawValue = minValue + (maxValue - minValue) * alpha
        applyValue(rawValue)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    end)

    applyValue(currentValue)

    return {
        Card = card,
        Set = applyValue,
        Get = function()
            return currentValue
        end,
    }
end

return KorsUI
