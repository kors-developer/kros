local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local function create(className, props)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    return object
end

local function round(object, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 16),
        Parent = object,
    })
end

local function stroke(object, color, transparency, thickness)
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        Parent = object,
    })
end

local function padding(object, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        Parent = object,
    })
end

local function tween(object, time, goal, style, direction)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local handle = TweenService:Create(object, info, goal)
    handle:Play()
    return handle
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function guiParent()
    if CoreGui then
        return CoreGui
    end

    local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return playerGui
end

local Library = {
    Theme = {
        Accent = Color3.fromRGB(78, 185, 255),
        AccentDark = Color3.fromRGB(24, 92, 255),
        AccentSoft = Color3.fromRGB(20, 38, 72),
        Window = Color3.fromRGB(7, 11, 19),
        WindowTop = Color3.fromRGB(15, 21, 32),
        Card = Color3.fromRGB(19, 27, 41),
        CardDark = Color3.fromRGB(13, 18, 28),
        Text = Color3.fromRGB(244, 247, 255),
        Muted = Color3.fromRGB(157, 166, 186),
        White = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(65, 218, 150),
    },
    _notifyHolder = nil,
}

local WindowMethods = {}
local TabMethods = {}
local ModulePanelMethods = {}
local ModuleMethods = {}

function Library:_getNotifyHolder()
    if self._notifyHolder and self._notifyHolder.Parent then
        return self._notifyHolder
    end

    local screenGui = create("ScreenGui", {
        Name = "RoinUI_Notify",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = guiParent(),
    })

    local holder = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.new(0, 330, 1, -32),
        Parent = screenGui,
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    self._notifyHolder = holder
    return holder
end

function Library:Notify(options)
    options = options or {}

    local holder = self:_getNotifyHolder()
    local title = options.Title or "Neitron UI"
    local content = options.Content or ""
    local duration = options.Duration or 3

    local toast = create("Frame", {
        BackgroundColor3 = self.Theme.Card,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 76),
        Parent = holder,
    })
    round(toast, 20)
    local toastStroke = stroke(toast, self.Theme.White, 0.87, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Theme.Card),
            ColorSequenceKeypoint.new(1, self.Theme.CardDark),
        }),
        Rotation = 20,
        Parent = toast,
    })

    local accent = create("Frame", {
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 4, 1, -20),
        Parent = toast,
    })
    round(accent, 99)

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 12),
        Size = UDim2.new(1, -36, 0, 18),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toast,
    })

    local contentLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 32),
        Size = UDim2.new(1, -36, 0, 30),
        Font = Enum.Font.Gotham,
        Text = content,
        TextColor3 = self.Theme.Muted,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = toast,
    })

    toast.AnchorPoint = Vector2.new(1, 0)
    toast.Position = UDim2.new(1, 26, 0, 0)
    toast.BackgroundTransparency = 1
    accent.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    contentLabel.TextTransparency = 1
    toastStroke.Transparency = 1

    tween(toast, 0.28, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.08 }, Enum.EasingStyle.Quint)
    tween(accent, 0.22, { BackgroundTransparency = 0.1 })
    tween(titleLabel, 0.22, { TextTransparency = 0 })
    tween(contentLabel, 0.22, { TextTransparency = 0 })
    tween(toastStroke, 0.22, { Transparency = 0.87 })

    task.delay(duration, function()
        if not toast.Parent then
            return
        end

        tween(accent, 0.18, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(titleLabel, 0.18, { TextTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(contentLabel, 0.18, { TextTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(toastStroke, 0.18, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local hide = tween(toast, 0.22, { Position = UDim2.new(1, 26, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        hide.Completed:Wait()
        toast:Destroy()
    end)
end

function Library:CreateWindow(options)
    options = options or {}

    local title = options.Title or "Neitron UI"
    local subtitle = options.Subtitle or "Transparent custom library"
    local size = options.Size or UDim2.fromOffset(720, 470)
    local sidebarWidth = options.SidebarWidth or 180
    local toggleKey = options.ToggleKey or Enum.KeyCode.K
    local blurSize = options.BlurSize or 18

    local parent = guiParent()
    local old = parent and parent:FindFirstChild("RoinUI_Main")
    if old then
        old:Destroy()
    end

    local screenGui = create("ScreenGui", {
        Name = "RoinUI_Main",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent,
    })

    local root = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundColor3 = self.Theme.Window,
        BackgroundTransparency = 0.03,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    round(root, 30)
    local rootStroke = stroke(root, self.Theme.White, 0.88, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Theme.WindowTop),
            ColorSequenceKeypoint.new(1, self.Theme.Window),
        }),
        Rotation = 35,
        Parent = root,
    })

    local headerGlass = create("Frame", {
        BackgroundColor3 = self.Theme.White,
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 76),
        Parent = root,
    })
    round(headerGlass, 24)

    local topBar = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 12),
        Size = UDim2.new(1, -28, 0, 66),
        Parent = root,
    })

    for index, color in ipairs({
        Color3.fromRGB(255, 95, 87),
        Color3.fromRGB(255, 189, 46),
        Color3.fromRGB(39, 201, 63),
    }) do
        local dot = create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(0, (index - 1) * 16, 0, 5),
            Size = UDim2.fromOffset(10, 10),
            Parent = topBar,
        })
        round(dot, 99)
    end

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, -140, 0, 24),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    local subtitleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, -140, 0, 16),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = self.Theme.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    local keyChip = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 8),
        Size = UDim2.fromOffset(114, 30),
        BackgroundColor3 = self.Theme.White,
        BackgroundTransparency = 0.9,
        Font = Enum.Font.GothamMedium,
        Text = "Toggle: " .. toggleKey.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 11,
        Parent = topBar,
    })
    round(keyChip, 99)
    local keyStroke = stroke(keyChip, self.Theme.White, 0.9, 1)

    local body = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 96),
        Size = UDim2.new(1, -28, 1, -110),
        Parent = root,
    })

    local sidebar = create("Frame", {
        BackgroundColor3 = self.Theme.White,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        Parent = body,
    })
    round(sidebar, 24)
    local sidebarStroke = stroke(sidebar, self.Theme.White, 0.92, 1)
    padding(sidebar, 10, 10, 10, 10)

    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar,
    })

    local content = create("Frame", {
        BackgroundColor3 = self.Theme.White,
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0, sidebarWidth + 14, 0, 0),
        Size = UDim2.new(1, -(sidebarWidth + 14), 1, 0),
        Parent = body,
    })
    round(content, 24)
    local contentStroke = stroke(content, self.Theme.White, 0.93, 1)

    local blur = Lighting:FindFirstChild("RoinUI_Blur")
    if not blur then
        blur = create("BlurEffect", {
            Name = "RoinUI_Blur",
            Size = 0,
            Enabled = true,
            Parent = Lighting,
        })
    else
        blur.Enabled = true
    end

    local window = setmetatable({
        Library = self,
        ScreenGui = screenGui,
        Root = root,
        Sidebar = sidebar,
        Content = content,
        Tabs = {},
        SelectedTab = nil,
        ToggleKey = toggleKey,
        Visible = true,
        KeyChip = keyChip,
        Blur = blur,
        BlurSize = blurSize,
        _keyConnection = nil,
    }, {
        __index = WindowMethods,
    })

    do
        local dragging = false
        local dragStart = nil
        local startPos = nil

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
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    root.Size = UDim2.fromOffset(math.max(size.X.Offset - 40, 340), math.max(size.Y.Offset - 28, 260))
    root.BackgroundTransparency = 1
    headerGlass.BackgroundTransparency = 1
    sidebar.BackgroundTransparency = 1
    content.BackgroundTransparency = 1
    keyChip.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    subtitleLabel.TextTransparency = 1
    keyChip.TextTransparency = 1
    rootStroke.Transparency = 1
    sidebarStroke.Transparency = 1
    contentStroke.Transparency = 1
    keyStroke.Transparency = 1

    tween(root, 0.34, { Size = size, BackgroundTransparency = 0.03 }, Enum.EasingStyle.Quint)
    tween(headerGlass, 0.24, { BackgroundTransparency = 0.96 })
    tween(sidebar, 0.24, { BackgroundTransparency = 0.94 })
    tween(content, 0.24, { BackgroundTransparency = 0.96 })
    tween(keyChip, 0.24, { BackgroundTransparency = 0.9, TextTransparency = 0 })
    tween(titleLabel, 0.22, { TextTransparency = 0 })
    tween(subtitleLabel, 0.22, { TextTransparency = 0 })
    tween(rootStroke, 0.24, { Transparency = 0.88 })
    tween(sidebarStroke, 0.24, { Transparency = 0.92 })
    tween(contentStroke, 0.24, { Transparency = 0.93 })
    tween(keyStroke, 0.24, { Transparency = 0.9 })
    tween(blur, 0.24, { Size = blurSize })

    window:SetToggleKey(toggleKey)
    return window
end

function WindowMethods:SetToggleKey(keyCode)
    if typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode then
        return
    end

    self.ToggleKey = keyCode
    self.KeyChip.Text = "Toggle: " .. keyCode.Name

    if self._keyConnection then
        self._keyConnection:Disconnect()
    end

    self._keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.KeyCode ~= self.ToggleKey then
            return
        end

        self.Visible = not self.Visible

        if self.Visible then
            self.Root.Visible = true
            if self.Blur then
                self.Blur.Enabled = true
                tween(self.Blur, 0.18, { Size = self.BlurSize })
            end
            self.Root.Position = UDim2.new(self.Root.Position.X.Scale, self.Root.Position.X.Offset, self.Root.Position.Y.Scale, self.Root.Position.Y.Offset + 8)
            tween(self.Root, 0.18, { Position = UDim2.new(self.Root.Position.X.Scale, self.Root.Position.X.Offset, self.Root.Position.Y.Scale, self.Root.Position.Y.Offset - 8) })
        else
            if self.Blur then
                local blurHide = tween(self.Blur, 0.14, { Size = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                blurHide.Completed:Connect(function()
                    if self.Blur and not self.Visible then
                        self.Blur.Enabled = false
                    end
                end)
            end
            local hide = tween(self.Root, 0.14, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            hide.Completed:Connect(function()
                if not self.Visible then
                    self.Root.Visible = false
                    self.Root.BackgroundTransparency = 0.03
                end
            end)
        end
    end)
end

function WindowMethods:Tab(options)
    options = options or {}

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = self.Library.Theme.Card,
        BackgroundTransparency = 0.24,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52),
        Text = "",
        Parent = self.Sidebar,
    })
    round(button, 18)
    local buttonStroke = stroke(button, self.Library.Theme.White, 0.94, 1)

    local strip = create("Frame", {
        BackgroundColor3 = self.Library.Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(0, 3, 1, -20),
        Parent = button,
    })
    round(strip, 99)

    local iconFrame = create("Frame", {
        BackgroundColor3 = self.Library.Theme.AccentSoft,
        BackgroundTransparency = 0.34,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0.5, -16),
        Size = UDim2.fromOffset(32, 32),
        Parent = button,
    })
    round(iconFrame, 12)

    local iconLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamSemibold,
        Text = options.Icon or string.sub(options.Title or "T", 1, 1),
        TextColor3 = self.Library.Theme.Accent,
        TextSize = 16,
        Parent = iconFrame,
    })

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(1, -58, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = options.Title or "Tab",
        TextColor3 = self.Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
    })

    local page = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ClipsDescendants = true,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = self.Content,
    })
    padding(page, 14, 14, 14, 14)

    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })

    local list = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        holder.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y)
        page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 28)
    end)

    local tab = setmetatable({
        Window = self,
        Button = button,
        ButtonStroke = buttonStroke,
        Strip = strip,
        IconFrame = iconFrame,
        IconLabel = iconLabel,
        TitleLabel = titleLabel,
        Page = page,
        Holder = holder,
        Layout = list,
    }, {
        __index = TabMethods,
    })

    button.MouseEnter:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0.15 })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0.24 })
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
    local selected = indexOrTab
    if type(indexOrTab) == "number" then
        selected = self.Tabs[indexOrTab]
    end

    if not selected then
        return
    end

    for _, tab in ipairs(self.Tabs) do
        local active = tab == selected
        tab.Page.Visible = active
        tab.Page.CanvasPosition = Vector2.zero

        tween(tab.Button, 0.18, {
            BackgroundTransparency = active and 0.04 or 0.24,
            BackgroundColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.Card,
        })
        tween(tab.ButtonStroke, 0.18, {
            Transparency = active and 0.84 or 0.94,
            Color = active and self.Library.Theme.Accent or self.Library.Theme.White,
        })
        tween(tab.Strip, 0.18, { BackgroundTransparency = active and 0.05 or 1 })
        tween(tab.IconFrame, 0.18, {
            BackgroundTransparency = active and 0.08 or 0.34,
            BackgroundColor3 = active and self.Library.Theme.AccentDark or self.Library.Theme.AccentSoft,
        })
        tab.IconLabel.TextColor3 = active and self.Library.Theme.White or self.Library.Theme.Accent
    end

    self.SelectedTab = selected
end

local function cardHeight(desc, baseHeight)
    if desc and desc ~= "" then
        return baseHeight + 24
    end
    return baseHeight
end

local function createCard(tab, options, height)
    options = options or {}

    local card = create("Frame", {
        BackgroundColor3 = tab.Window.Library.Theme.Card,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height),
        Parent = tab.Holder,
    })
    round(card, 20)
    local cardStroke = stroke(card, tab.Window.Library.Theme.White, 0.92, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, tab.Window.Library.Theme.Card),
            ColorSequenceKeypoint.new(1, tab.Window.Library.Theme.CardDark),
        }),
        Rotation = 18,
        Parent = card,
    })

    local shine = create("Frame", {
        BackgroundColor3 = tab.Window.Library.Theme.White,
        BackgroundTransparency = 0.97,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 0, 22),
        Parent = card,
    })
    round(shine, 20)

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 12),
        Size = UDim2.new(1, -120, 0, 18),
        Font = Enum.Font.GothamSemibold,
        Text = options.Title or "Element",
        TextColor3 = tab.Window.Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local descLabel = nil
    if options.Desc and options.Desc ~= "" then
        descLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 32),
            Size = UDim2.new(1, -28, 0, 30),
            Font = Enum.Font.Gotham,
            Text = options.Desc,
            TextColor3 = tab.Window.Library.Theme.Muted,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = card,
        })
    end

    return card, cardStroke, titleLabel, descLabel
end

function TabMethods:Paragraph(options)
    return createCard(self, options, cardHeight(options and options.Desc, 68))
end

function TabMethods:Label(options)
    return createCard(self, options, cardHeight(options and options.Desc, 60))
end

function TabMethods:Button(options)
    options = options or {}

    local card = createCard(self, options, cardHeight(options.Desc, 64))

    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = self.Window.Library.Theme.AccentDark,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(100, 34),
        Font = Enum.Font.GothamSemibold,
        Text = options.ButtonText or "Run",
        TextColor3 = self.Window.Library.Theme.White,
        TextSize = 13,
        Parent = card,
    })
    round(button, 16)
    stroke(button, self.Window.Library.Theme.White, 0.88, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Window.Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, self.Window.Library.Theme.AccentDark),
        }),
        Rotation = 25,
        Parent = button,
    })

    button.MouseEnter:Connect(function()
        tween(button, 0.12, { Size = UDim2.fromOffset(104, 36) })
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.12, { Size = UDim2.fromOffset(100, 34) })
    end)

    button.MouseButton1Down:Connect(function()
        tween(button, 0.08, { Size = UDim2.fromOffset(96, 32) })
    end)

    button.MouseButton1Up:Connect(function()
        tween(button, 0.08, { Size = UDim2.fromOffset(100, 34) })
    end)

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

    local card = createCard(self, options, cardHeight(options.Desc, 64))

    local toggle = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = state and self.Window.Library.Theme.Success or Color3.fromRGB(92, 102, 120),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(56, 32),
        Text = "",
        Parent = card,
    })
    round(toggle, 99)
    stroke(toggle, self.Window.Library.Theme.White, 0.9, 1)

    local knob = create("Frame", {
        BackgroundColor3 = self.Window.Library.Theme.White,
        BorderSizePixel = 0,
        Position = state and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3),
        Size = UDim2.fromOffset(26, 26),
        Parent = toggle,
    })
    round(knob, 99)

    local function setState(value)
        state = value
        tween(toggle, 0.18, {
            BackgroundColor3 = state and self.Window.Library.Theme.Success or Color3.fromRGB(92, 102, 120),
        })
        tween(knob, 0.18, {
            Position = state and UDim2.new(1, -29, 0, 3) or UDim2.new(0, 3, 0, 3),
        })

        if options.Callback then
            options.Callback(state)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return {
        Card = card,
        Get = function()
            return state
        end,
        Set = setState,
    }
end

function TabMethods:Slider(options)
    options = options or {}

    local range = options.Value or {}
    local minimum = options.Min or range.Min or 0
    local maximum = options.Max or range.Max or 100
    local step = options.Step or 1
    local current = options.Default or range.Default or minimum
    local dragging = false

    local card = createCard(self, options, cardHeight(options.Desc, 92))

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -14, 0, 12),
        Size = UDim2.fromOffset(72, 18),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(current),
        TextColor3 = self.Window.Library.Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = card,
    })

    local trackY = options.Desc and 70 or 50

    local track = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(75, 83, 99),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0, trackY),
        Size = UDim2.new(1, -28, 0, 8),
        Parent = card,
    })
    round(track, 99)

    local fill = create("Frame", {
        BackgroundColor3 = self.Window.Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    round(fill, 99)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Window.Library.Theme.White,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = track,
    })
    round(knob, 99)

    local function setValue(rawValue)
        local snapped = math.floor(((rawValue - minimum) / step) + 0.5) * step + minimum
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
        Card = card,
        Get = function()
            return current
        end,
        Set = setValue,
    }
end

function TabMethods:ModulePanel(options)
    options = options or {}

    local panel = create("Frame", {
        BackgroundColor3 = self.Window.Library.Theme.CardDark,
        BackgroundTransparency = 0.14,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, options.Height or 340),
        Parent = self.Holder,
    })
    round(panel, 24)
    stroke(panel, self.Window.Library.Theme.White, 0.92, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 24, 38)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 20)),
        }),
        Rotation = 20,
        Parent = panel,
    })

    local shine = create("Frame", {
        BackgroundColor3 = self.Window.Library.Theme.White,
        BackgroundTransparency = 0.97,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 0, 22),
        Parent = panel,
    })
    round(shine, 24)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 14),
        Size = UDim2.new(1, -32, 0, 18),
        Font = Enum.Font.GothamSemibold,
        Text = options.Title or "Modules",
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = panel,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 34),
        Size = UDim2.new(1, -32, 0, 16),
        Font = Enum.Font.Gotham,
        Text = options.Desc or "Left click toggles module. Right click opens settings.",
        TextColor3 = self.Window.Library.Theme.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = panel,
    })

    local stack = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 62),
        Size = UDim2.new(1, -24, 1, -74),
        Parent = panel,
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = stack,
    })

    return setmetatable({
        Tab = self,
        Panel = panel,
        Stack = stack,
    }, {
        __index = ModulePanelMethods,
    })
end

function ModulePanelMethods:AddModule(options)
    options = options or {}

    local enabled = options.Enabled == true
    local expanded = false
    local settingsHeight = options.SettingsHeight or 88

    local card = create("Frame", {
        BackgroundColor3 = self.Tab.Window.Library.Theme.Card,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 62),
        Parent = self.Stack,
    })
    round(card, 20)
    local cardStroke = stroke(card, self.Tab.Window.Library.Theme.White, 0.93, 1)

    local leftBar = create("Frame", {
        BackgroundColor3 = self.Tab.Window.Library.Theme.Accent,
        BackgroundTransparency = enabled and 0.08 or 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(0, 3, 1, -20),
        Parent = card,
    })
    round(leftBar, 999)

    local hitbox = create("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 62),
        Text = "",
        Parent = card,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -120, 0, 18),
        Font = Enum.Font.GothamSemibold,
        Text = options.Title or "Module",
        TextColor3 = self.Tab.Window.Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 32),
        Size = UDim2.new(1, -130, 0, 16),
        Font = Enum.Font.Gotham,
        Text = options.Desc or "Left click toggles. Right click opens settings.",
        TextColor3 = self.Tab.Window.Library.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local statePill = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = enabled and self.Tab.Window.Library.Theme.AccentDark or Color3.fromRGB(56, 64, 80),
        BackgroundTransparency = 0.18,
        Position = UDim2.new(1, -14, 0, 22),
        Size = UDim2.fromOffset(64, 24),
        Font = Enum.Font.GothamSemibold,
        Text = enabled and "ON" or "OFF",
        TextColor3 = self.Tab.Window.Library.Theme.White,
        TextSize = 11,
        Parent = card,
    })
    round(statePill, 999)

    local settings = create("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(0, 16, 0, 62),
        Size = UDim2.new(1, -32, 0, 0),
        Parent = card,
    })

    local module = setmetatable({
        Panel = self,
        Card = card,
        Settings = settings,
        StatePill = statePill,
        LeftBar = leftBar,
        CardStroke = cardStroke,
        Enabled = enabled,
        Expanded = expanded,
        SettingsHeight = settingsHeight,
        OnToggle = options.OnToggle,
    }, {
        __index = ModuleMethods,
    })

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            module:SetEnabled(not module.Enabled)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            module:SetExpanded(not module.Expanded)
        end
    end)

    if options.BuildSettings then
        options.BuildSettings(module)
    end

    module:SetEnabled(enabled, true)
    return module
end

function ModuleMethods:SetEnabled(enabled, skipCallback)
    self.Enabled = enabled
    tween(self.StatePill, 0.16, {
        BackgroundColor3 = enabled and self.Panel.Tab.Window.Library.Theme.AccentDark or Color3.fromRGB(56, 64, 80),
    })
    self.StatePill.Text = enabled and "ON" or "OFF"
    tween(self.LeftBar, 0.16, {
        BackgroundTransparency = enabled and 0.08 or 1,
    })
    tween(self.CardStroke, 0.16, {
        Color = enabled and self.Panel.Tab.Window.Library.Theme.Accent or self.Panel.Tab.Window.Library.Theme.White,
        Transparency = enabled and 0.85 or 0.93,
    })

    if not skipCallback and self.OnToggle then
        self.OnToggle(enabled, self)
    end
end

function ModuleMethods:SetExpanded(expanded)
    self.Expanded = expanded
    tween(self.Settings, 0.18, {
        Size = UDim2.new(1, -32, 0, expanded and self.SettingsHeight or 0),
    })
    tween(self.Card, 0.18, {
        Size = UDim2.new(1, 0, 0, expanded and (72 + self.SettingsHeight) or 62),
    })
end

function ModuleMethods:AddLabel(options)
    options = options or {}

    return create("TextLabel", {
        BackgroundTransparency = 1,
        Position = options.Position or UDim2.new(0, 0, 0, 10),
        Size = options.Size or UDim2.new(1, 0, 0, 20),
        Font = options.Font or Enum.Font.Gotham,
        Text = options.Text or "",
        TextColor3 = options.TextColor3 or self.Panel.Tab.Window.Library.Theme.Muted,
        TextSize = options.TextSize or 11,
        TextWrapped = options.TextWrapped ~= false,
        TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Top,
        Parent = self.Settings,
    })
end

function ModuleMethods:AddButton(options)
    options = options or {}

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = options.Color or self.Panel.Tab.Window.Library.Theme.AccentDark,
        BorderSizePixel = 0,
        Position = options.Position or UDim2.new(0, 0, 0, 10),
        Size = options.Size or UDim2.new(0, 132, 0, 34),
        Font = Enum.Font.GothamSemibold,
        Text = options.Text or "Run",
        TextColor3 = self.Panel.Tab.Window.Library.Theme.White,
        TextSize = 12,
        Parent = self.Settings,
    })
    round(button, 14)
    stroke(button, self.Panel.Tab.Window.Library.Theme.White, 0.88, 1)

    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback(self)
        end
    end)

    return button
end

function ModuleMethods:AddSlider(options)
    options = options or {}

    local value = options.Default or options.Min or 0
    local minValue = options.Min or 0
    local maxValue = options.Max or 100
    local step = options.Step or 1
    local dragging = false

    local root = create("Frame", {
        BackgroundTransparency = 1,
        Position = options.Position or UDim2.new(0, 0, 0, 10),
        Size = options.Size or UDim2.new(1, 0, 0, 36),
        Parent = self.Settings,
    })

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(64, 16),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(value),
        TextColor3 = self.Panel.Tab.Window.Library.Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = root,
    })

    local track = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(68, 76, 94),
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 26),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = root,
    })
    round(track, 999)

    local fill = create("Frame", {
        BackgroundColor3 = self.Panel.Tab.Window.Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    round(fill, 999)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Panel.Tab.Window.Library.Theme.White,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = track,
    })
    round(knob, 999)

    local slider = {}

    local function setValue(rawValue)
        local snapped = math.floor(((rawValue - minValue) / step) + 0.5) * step + minValue
        value = clamp(snapped, minValue, maxValue)
        local alpha = (value - minValue) / math.max(maxValue - minValue, 1)
        tween(fill, 0.08, { Size = UDim2.new(alpha, 0, 1, 0) })
        tween(knob, 0.08, { Position = UDim2.new(alpha, 0, 0.5, 0) })
        valueLabel.Text = tostring(value)

        if options.Callback then
            options.Callback(value, self)
        end
    end

    local function updateFromInput(input)
        local alpha = clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setValue(minValue + ((maxValue - minValue) * alpha))
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

    setValue(value)

    function slider:Get()
        return value
    end

    function slider:Set(nextValue)
        setValue(nextValue)
    end

    slider.Root = root
    return slider
end

return Library
