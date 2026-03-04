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
        Background = Color3.fromRGB(4, 4, 6),
        Panel = Color3.fromRGB(6, 6, 8),
        PanelSoft = Color3.fromRGB(10, 10, 13),
        PanelRaised = Color3.fromRGB(12, 12, 16),
        Accent = Color3.fromRGB(0, 119, 255),
        AccentSoft = Color3.fromRGB(8, 18, 34),
        AccentDark = Color3.fromRGB(10, 22, 40),
        Text = Color3.fromRGB(240, 242, 247),
        Muted = Color3.fromRGB(121, 126, 136),
        Outline = Color3.fromRGB(24, 27, 33),
        Success = Color3.fromRGB(57, 214, 147),
        Dim = Color3.fromRGB(40, 44, 52),
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
        BackgroundTransparency = 0.05,
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
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height),
        Parent = holder,
    })
    round(card, 8)
    local cardStroke = stroke(card, theme.Outline, 0.18, 1)

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
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 0, 24),
        Parent = card,
    })
    round(shine, 8)

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
    local subtitle = options.Subtitle or "Module hub"
    local toggleKey = options.ToggleKey or Enum.KeyCode.K
    local size = options.Size or UDim2.fromScale(1, 1)
    local minSize = options.MinSize or Vector2.new(1280, 720)
    local maxSize = options.MaxSize or Vector2.new(3840, 2160)
    local leftPanelWidth = options.LeftPanelWidth or ((type(options.LeftWidth) == "number" and options.LeftWidth > 1) and options.LeftWidth or 272)
    local rightPanelWidth = options.RightPanelWidth or ((type(options.RightWidth) == "number" and options.RightWidth > 1) and options.RightWidth or 360)
    local gap = options.Gap or 22
    local sideMargin = options.SideMargin or 150
    local bodyTop = options.BodyTop or 210
    local bottomInset = options.BottomInset or 96
    local showProfileCard = options.ShowProfileCard == true
    local footerHeight = showProfileCard and (options.FooterHeight or 68) or 0
    local overlayTransparency = options.OverlayTransparency or 0.82
    local leftPanelTransparency = options.LeftPanelTransparency or 0.04
    local centerPanelTransparency = options.CenterPanelTransparency or 0.03
    local rightPanelTransparency = options.RightPanelTransparency or 0.04

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
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = screenGui,
    })

    local dimmer = create("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = overlayTransparency,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.55, 0),
        Size = UDim2.new(1, 0, 0.45, 0),
        Parent = overlay,
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

    local toolbar = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 14),
        Size = UDim2.fromOffset(214, 44),
        Parent = stage,
    })

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = toolbar,
    })

    local toolbarButtons = {}
    for index = 1, 4 do
        local toolbarButton = create("Frame", {
            BackgroundColor3 = theme.PanelSoft,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(index == 2 and 62 or 44, 44),
            Parent = toolbar,
        })
        round(toolbarButton, 999)
        stroke(toolbarButton, theme.Outline, 0.28, 1)
        toolbarButtons[index] = toolbarButton
    end

    local avatarImage = create("ImageLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = toolbarButtons[1],
    })
    round(avatarImage, 999)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(0, 0, 0, -1),
        Size = UDim2.fromScale(1, 1),
        Text = "===",
        TextColor3 = theme.Text,
        TextSize = 18,
        Parent = toolbarButtons[2],
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.fromScale(1, 1),
        Text = "[]",
        TextColor3 = theme.Text,
        TextSize = 15,
        Parent = toolbarButtons[3],
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.fromScale(1, 1),
        Text = "<>",
        TextColor3 = theme.Text,
        TextSize = 15,
        Parent = toolbarButtons[4],
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

            if ok and avatarImage.Parent then
                avatarImage.Image = image
            end
        end)
    end

    local infoCard = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Color3.fromRGB(55, 71, 82),
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -16, 0, 62),
        Size = UDim2.fromOffset(242, 126),
        Parent = stage,
    })
    round(infoCard, 8)
    stroke(infoCard, theme.Outline, 0.55, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(0, 16, 0, 16),
        Text = "X",
        TextColor3 = theme.Text,
        TextSize = 12,
        Parent = infoCard,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 14, 0, 26),
        Size = UDim2.new(0.55, 0, 0, 14),
        Text = "People",
        TextColor3 = theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = infoCard,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0.66, 0, 0, 26),
        Size = UDim2.new(0.28, 0, 0, 14),
        Text = "Value",
        TextColor3 = theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = infoCard,
    })

    local peopleRow = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 14, 0, 52),
        Size = UDim2.new(0.55, 0, 0, 18),
        Text = LocalPlayer and LocalPlayer.Name or "Player",
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = infoCard,
    })

    local keyHint = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0.66, 0, 0, 52),
        Size = UDim2.new(0.28, 0, 0, 18),
        Text = toggleKey.Name,
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = infoCard,
    })

    create("Frame", {
        BackgroundColor3 = theme.Outline,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 78),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = infoCard,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 14, 0, 92),
        Size = UDim2.new(0.55, 0, 0, 18),
        Text = "Players",
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = infoCard,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0.66, 0, 0, 92),
        Size = UDim2.new(0.28, 0, 0, 18),
        Text = tostring(#Players:GetPlayers()),
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = infoCard,
    })

    local leftPanel = create("Frame", {
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = leftPanelTransparency,
        BorderSizePixel = 0,
        Position = UDim2.new(0, sideMargin, 0, bodyTop),
        Size = UDim2.new(0, leftPanelWidth, 1, -(bodyTop + bottomInset)),
        Parent = stage,
    })
    round(leftPanel, 10)
    stroke(leftPanel, theme.Outline, 0.2, 1)

    local centerPanel = create("Frame", {
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = centerPanelTransparency,
        BorderSizePixel = 0,
        Position = UDim2.new(0, sideMargin + leftPanelWidth + gap, 0, bodyTop),
        Size = UDim2.new(1, -((sideMargin * 2) + leftPanelWidth + rightPanelWidth + (gap * 2)), 1, -(bodyTop + bottomInset)),
        Parent = stage,
    })
    round(centerPanel, 10)
    stroke(centerPanel, theme.Outline, 0.18, 1)

    local rightPanel = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = rightPanelTransparency,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -sideMargin, 0, bodyTop),
        Size = UDim2.new(0, rightPanelWidth, 1, -(bodyTop + bottomInset)),
        Parent = stage,
    })
    round(rightPanel, 10)
    stroke(rightPanel, theme.Outline, 0.2, 1)

    padding(leftPanel, 10, 10, 10, 10)
    padding(centerPanel, 10, 10, 8, 8)
    padding(rightPanel, 10, 10, 10, 10)

    local tabsWrap = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        Size = UDim2.new(1, 0, 1, -(footerHeight > 0 and (footerHeight + 10) or 0)),
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

    if showProfileCard then
        local profileCard = create("Frame", {
            BackgroundColor3 = theme.PanelSoft,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -footerHeight),
            Size = UDim2.new(1, 0, 0, footerHeight),
            Parent = leftPanel,
        })
        round(profileCard, 10)
        stroke(profileCard, theme.Outline, 0.25, 1)

        local footerAvatar = create("ImageLabel", {
            BackgroundColor3 = theme.AccentSoft,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0.5, -18),
            Size = UDim2.fromOffset(36, 36),
            Parent = profileCard,
        })
        round(footerAvatar, 999)

        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.new(0, 54, 0, 12),
            Size = UDim2.new(1, -62, 0, 14),
            Text = LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name) or "Player",
            TextColor3 = theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = profileCard,
        })

        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0, 54, 0, 28),
            Size = UDim2.new(1, -62, 0, 12),
            Text = LocalPlayer and ("@" .. LocalPlayer.Name) or "@Player",
            TextColor3 = theme.Muted,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = profileCard,
        })

        if avatarImage.Image ~= "" then
            footerAvatar.Image = avatarImage.Image
        elseif LocalPlayer then
            task.spawn(function()
                local ok, image = pcall(function()
                    return Players:GetUserThumbnailAsync(
                        LocalPlayer.UserId,
                        Enum.ThumbnailType.AvatarBust,
                        Enum.ThumbnailSize.Size100x100
                    )
                end)

                if ok and footerAvatar.Parent then
                    footerAvatar.Image = image
                end
            end)
        end
    end

    local centerHeader = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = centerPanel,
    })

    local activeTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 0, 18),
        Text = title,
        TextColor3 = theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = centerHeader,
    })

    local activeSubtitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 2, 0, 20),
        Size = UDim2.new(1, -4, 0, 14),
        Text = subtitle,
        TextColor3 = theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = centerHeader,
    })

    local centerBody = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 1, -42),
        Parent = centerPanel,
    })

    local rightBody = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = rightPanel,
    })

    local searchWrap = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 1, -18),
        Size = UDim2.fromOffset(520, 58),
        Parent = stage,
    })

    local searchFrame = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = 0.03,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(480, 42),
        Parent = searchWrap,
    })
    round(searchFrame, 8)
    stroke(searchFrame, theme.Outline, 0.22, 1)

    create("TextBox", {
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search modules",
        PlaceholderColor3 = theme.Muted,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Text = "",
        TextColor3 = theme.Text,
        TextSize = 13,
        Parent = searchFrame,
    })

    create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 12),
        Text = "sorrelhub.xyz",
        TextColor3 = theme.Muted,
        TextSize = 9,
        Parent = searchWrap,
    })

    local window = setmetatable({
        Library = self,
        ScreenGui = screenGui,
        Overlay = overlay,
        Dimmer = dimmer,
        Stage = stage,
        Toolbar = toolbar,
        InfoCard = infoCard,
        SearchWrap = searchWrap,
        LeftPanel = leftPanel,
        CenterPanel = centerPanel,
        RightPanel = rightPanel,
        TabsContainer = tabsWrap,
        CenterBody = centerBody,
        RightBody = rightBody,
        ActiveTitle = activeTitle,
        ActiveSubtitle = activeSubtitle,
        PeopleRow = peopleRow,
        KeyHint = keyHint,
        LeftWidth = leftPanelWidth,
        RightWidth = rightPanelWidth,
        PanelGap = gap,
        LeftPanelWidthPx = leftPanelWidth,
        RightPanelWidthPx = rightPanelWidth,
        PanelGapPx = gap,
        BodyLeftOffset = sideMargin,
        BodyTopOffset = bodyTop,
        BodyBottomInset = bottomInset,
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

    stage.Size = UDim2.new(size.X.Scale, math.max(-20, size.X.Offset), size.Y.Scale, math.max(-20, size.Y.Offset))
    leftPanel.BackgroundTransparency = 1
    centerPanel.BackgroundTransparency = 1
    rightPanel.BackgroundTransparency = 1
    dimmer.BackgroundTransparency = 1

    tween(dimmer, 0.18, { BackgroundTransparency = overlayTransparency })
    tween(stage, 0.2, { Size = size }, Enum.EasingStyle.Quint)
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
        self.KeyHint.Text = keyCode.Name
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
            if self.Dimmer then
                self.Dimmer.BackgroundTransparency = 1
            end
            self.Stage.Position = UDim2.fromScale(0.5, 0.52)
            if self.Dimmer then
                tween(self.Dimmer, 0.15, { BackgroundTransparency = self.OverlayBaseTransparency or 0.82 })
            end
            tween(self.Stage, 0.16, { Position = UDim2.fromScale(0.5, 0.5) })
        else
            local fadeTarget = self.Dimmer or self.Overlay
            local fade = tween(fadeTarget, 0.14, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
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
    local centerPosition = UDim2.new(0, self.BodyLeftOffset + self.LeftPanelWidthPx + self.PanelGapPx, 0, self.BodyTopOffset)
    local centerSize

    self.RightPanelEnabled = shouldShow

    if shouldShow then
        centerSize = UDim2.new(
            1,
            -((self.BodyLeftOffset * 2) + self.LeftPanelWidthPx + self.RightPanelWidthPx + (self.PanelGapPx * 2)),
            1,
            -(self.BodyTopOffset + self.BodyBottomInset)
        )
        self.RightPanel.Visible = true
    else
        centerSize = UDim2.new(
            1,
            -((self.BodyLeftOffset * 2) + self.LeftPanelWidthPx + self.PanelGapPx),
            1,
            -(self.BodyTopOffset + self.BodyBottomInset)
        )
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
    local tabTitle = options.Title or options.Name or "Tab"
    local tabIcon = options.Icon or string.sub(tabTitle, 1, 1)

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.PanelSoft,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Text = "",
        Parent = self.TabsContainer,
    })
    round(button, 8)
    local buttonStroke = stroke(button, theme.Outline, 0.22, 1)

    local accent = create("Frame", {
        BackgroundColor3 = theme.AccentDark,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0.5, -12),
        Size = UDim2.fromOffset(24, 24),
        Parent = button,
    })
    round(accent, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Size = UDim2.fromScale(1, 1),
        Text = string.upper(string.sub(tabIcon, 1, 1)),
        TextColor3 = theme.Accent,
        TextSize = 12,
        Parent = accent,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        Text = tabTitle,
        TextColor3 = theme.Text,
        TextSize = 13,
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
        Title = tabTitle,
        Description = options.Description or options.Desc or "Open this tab",
    }, {
        __index = TabMethods,
    })

    button.MouseEnter:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0 })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0.05 })
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
            BackgroundTransparency = active and 0 or 0.05,
            BackgroundColor3 = active and self.Library.Theme.AccentSoft or self.Library.Theme.PanelSoft,
        })
        tween(entry.ButtonStroke, 0.18, {
            Transparency = active and 0.08 or 0.22,
            Color = active and self.Library.Theme.AccentDark or self.Library.Theme.Outline,
        })
        tween(entry.Accent, 0.18, {
            BackgroundTransparency = active and 0 or 0.02,
            BackgroundColor3 = active and self.Library.Theme.AccentDark or self.Library.Theme.PanelSoft,
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
    reserveCardTextSpace(card, 116)

    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = theme.PanelSoft,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(92, 34),
        Font = Enum.Font.GothamSemibold,
        Text = options.ButtonText or options.ActionText or "Run",
        TextColor3 = theme.Accent,
        TextSize = 12,
        Parent = card.Card,
    })
    round(button, 999)
    stroke(button, theme.Outline, 0.18, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.PanelSoft),
            ColorSequenceKeypoint.new(1, theme.PanelSoft),
        }),
        Rotation = 20,
        Parent = button,
    })

    button.MouseEnter:Connect(function()
        tween(button, 0.12, { Size = UDim2.fromOffset(96, 34) })
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.12, { Size = UDim2.fromOffset(92, 34) })
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
    reserveCardTextSpace(card, 110)
    local currentKey = options.Key or options.Default or Enum.KeyCode.K
    local waiting = false
    local connection = nil

    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = theme.PanelSoft,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(82, 32),
        Font = Enum.Font.GothamSemibold,
        Text = currentKey.Name,
        TextColor3 = theme.Accent,
        TextSize = 12,
        Parent = card.Card,
    })
    round(button, 999)
    stroke(button, theme.Outline, 0.18, 1)

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
