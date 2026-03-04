--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              NEITRON UI LIBRARY v1.0                         ║
    ║              CS2-Style Modern Interface                      ║
    ║              Author: BMA Team                                ║
    ╚══════════════════════════════════════════════════════════════╝
    
    СТРУКТУРА:
    ┌─────────────┬──────────────────────────┬─────────────┐
    │   TABS      │      CONTENT             │   SIDEBAR   │
    │   (LEFT)    │      (CENTER)            │   (RIGHT)   │
    │             │                          │             │
    │  • Main     │  ┌────────────────────┐  │   Info      │
    │  • Player   │  │ Section Title      │  │   Panel     │
    │  • Combat   │  ├────────────────────┤  │             │
    │  • Visual   │  │ • Toggle           │  │   Stats     │
    │  • Misc     │  │ • Slider           │  │             │
    │             │  │ • Button           │  │             │
    │             │  └────────────────────┘  │             │
    └─────────────┴──────────────────────────┴─────────────┘
]]

local NeitronUI = {}
NeitronUI.__index = NeitronUI
NeitronUI.Version = "1.0.0"

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ════════════════════════════════════════════════════════════════
--  UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local function Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, thickness, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Color3.fromRGB(60, 60, 60)
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all or 10)
    padding.PaddingBottom = UDim.new(0, all or 10)
    padding.PaddingLeft = UDim.new(0, all or 10)
    padding.PaddingRight = UDim.new(0, all or 10)
    padding.Parent = parent
    return padding
end

-- ════════════════════════════════════════════════════════════════
--  COLOR SCHEME (CS2-STYLE)
-- ════════════════════════════════════════════════════════════════

local Theme = {
    -- Background colors
    Background = Color3.fromRGB(15, 15, 15),
    BackgroundDark = Color3.fromRGB(10, 10, 10),
    BackgroundLight = Color3.fromRGB(25, 25, 25),
    
    -- Accent colors
    Accent = Color3.fromRGB(100, 150, 255),
    AccentHover = Color3.fromRGB(120, 170, 255),
    AccentActive = Color3.fromRGB(80, 130, 235),
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextDisabled = Color3.fromRGB(100, 100, 100),
    
    -- UI Element colors
    Border = Color3.fromRGB(40, 40, 40),
    Hover = Color3.fromRGB(35, 35, 35),
    Active = Color3.fromRGB(45, 45, 45),
    
    -- Status colors
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 200, 80),
    Error = Color3.fromRGB(255, 80, 80),
}

-- ════════════════════════════════════════════════════════════════
--  WINDOW CLASS
-- ════════════════════════════════════════════════════════════════

function NeitronUI:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Name = config.Name or "NEITRON UI",
        Size = config.Size or UDim2.new(0, 900, 0, 600),
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
        Tabs = {},
        CurrentTab = nil,
    }
    
    -- ════════════════════════════════════════════════════════════════
    --  MAIN CONTAINER
    -- ════════════════════════════════════════════════════════════════
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeitronUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Window.Size
    MainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    CreateCorner(MainFrame, 12)
    CreateStroke(MainFrame, 2, Theme.Border)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Theme.BackgroundDark
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    CreateCorner(TitleBar, 12)
    
    -- Title Bar Bottom Border
    local TitleBorder = Instance.new("Frame")
    TitleBorder.Size = UDim2.new(1, 0, 0, 1)
    TitleBorder.Position = UDim2.new(0, 0, 1, -1)
    TitleBorder.BackgroundColor3 = Theme.Border
    TitleBorder.BorderSizePixel = 0
    TitleBorder.Parent = TitleBar
    
    -- Title Text
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = Window.Name
    Title.TextColor3 = Theme.TextPrimary
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Version Label
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Name = "Version"
    VersionLabel.Size = UDim2.new(0, 100, 1, 0)
    VersionLabel.Position = UDim2.new(1, -120, 0, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "v" .. NeitronUI.Version
    VersionLabel.TextColor3 = Theme.TextSecondary
    VersionLabel.TextSize = 12
    VersionLabel.Font = Enum.Font.Gotham
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.Parent = TitleBar
    
    MakeDraggable(MainFrame, TitleBar)
    
    -- ════════════════════════════════════════════════════════════════
    --  LEFT PANEL (TABS)
    -- ════════════════════════════════════════════════════════════════
    
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Size = UDim2.new(0, 160, 1, -40)
    TabsContainer.Position = UDim2.new(0, 0, 0, 40)
    TabsContainer.BackgroundColor3 = Theme.BackgroundDark
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Parent = MainFrame
    
    -- Tabs Border Right
    local TabsBorder = Instance.new("Frame")
    TabsBorder.Size = UDim2.new(0, 1, 1, 0)
    TabsBorder.Position = UDim2.new(1, -1, 0, 0)
    TabsBorder.BackgroundColor3 = Theme.Border
    TabsBorder.BorderSizePixel = 0
    TabsBorder.Parent = TabsContainer
    
    -- Tabs List
    local TabsList = Instance.new("ScrollingFrame")
    TabsList.Name = "TabsList"
    TabsList.Size = UDim2.new(1, 0, 1, 0)
    TabsList.BackgroundTransparency = 1
    TabsList.BorderSizePixel = 0
    TabsList.ScrollBarThickness = 4
    TabsList.ScrollBarImageColor3 = Theme.Accent
    TabsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabsList.Parent = TabsContainer
    
    CreatePadding(TabsList, 8)
    
    local TabsListLayout = Instance.new("UIListLayout")
    TabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsListLayout.Padding = UDim.new(0, 4)
    TabsListLayout.Parent = TabsList
    
    -- ════════════════════════════════════════════════════════════════
    --  CENTER PANEL (CONTENT)
    -- ════════════════════════════════════════════════════════════════
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -330, 1, -40)
    ContentContainer.Position = UDim2.new(0, 160, 0, 40)
    ContentContainer.BackgroundColor3 = Theme.BackgroundLight
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    -- Content Border Right
    local ContentBorder = Instance.new("Frame")
    ContentBorder.Size = UDim2.new(0, 1, 1, 0)
    ContentBorder.Position = UDim2.new(1, -1, 0, 0)
    ContentBorder.BackgroundColor3 = Theme.Border
    ContentBorder.BorderSizePixel = 0
    ContentBorder.Parent = ContentContainer
    
    -- ════════════════════════════════════════════════════════════════
    --  RIGHT PANEL (SIDEBAR)
    -- ════════════════════════════════════════════════════════════════
    
    local SidebarContainer = Instance.new("Frame")
    SidebarContainer.Name = "SidebarContainer"
    SidebarContainer.Size = UDim2.new(0, 170, 1, -40)
    SidebarContainer.Position = UDim2.new(1, -170, 0, 40)
    SidebarContainer.BackgroundColor3 = Theme.BackgroundDark
    SidebarContainer.BorderSizePixel = 0
    SidebarContainer.Parent = MainFrame
    
    -- Sidebar Info Panel
    local SidebarInfo = Instance.new("Frame")
    SidebarInfo.Name = "InfoPanel"
    SidebarInfo.Size = UDim2.new(1, -16, 0, 120)
    SidebarInfo.Position = UDim2.new(0, 8, 0, 8)
    SidebarInfo.BackgroundColor3 = Theme.Background
    SidebarInfo.BorderSizePixel = 0
    SidebarInfo.Parent = SidebarContainer
    
    CreateCorner(SidebarInfo, 6)
    CreateStroke(SidebarInfo, 1, Theme.Border)
    CreatePadding(SidebarInfo, 10)
    
    -- Info Title
    local InfoTitle = Instance.new("TextLabel")
    InfoTitle.Name = "InfoTitle"
    InfoTitle.Size = UDim2.new(1, 0, 0, 20)
    InfoTitle.BackgroundTransparency = 1
    InfoTitle.Text = "INFO"
    InfoTitle.TextColor3 = Theme.TextPrimary
    InfoTitle.TextSize = 13
    InfoTitle.Font = Enum.Font.GothamBold
    InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
    InfoTitle.Parent = SidebarInfo
    
    -- Info Content
    local InfoContent = Instance.new("TextLabel")
    InfoContent.Name = "InfoContent"
    InfoContent.Size = UDim2.new(1, 0, 1, -25)
    InfoContent.Position = UDim2.new(0, 0, 0, 25)
    InfoContent.BackgroundTransparency = 1
    InfoContent.Text = "Player: " .. LocalPlayer.Name .. "\nFPS: 60\nPing: 0ms"
    InfoContent.TextColor3 = Theme.TextSecondary
    InfoContent.TextSize = 11
    InfoContent.Font = Enum.Font.Gotham
    InfoContent.TextXAlignment = Enum.TextXAlignment.Left
    InfoContent.TextYAlignment = Enum.TextYAlignment.Top
    InfoContent.TextWrapped = true
    InfoContent.Parent = SidebarInfo
    
    -- Update FPS/Ping
    task.spawn(function()
        while task.wait(1) do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            InfoContent.Text = string.format("Player: %s\nFPS: %d\nPing: %dms", LocalPlayer.Name, fps, ping)
        end
    end)
    
    -- ════════════════════════════════════════════════════════════════
    --  TOGGLE VISIBILITY
    -- ════════════════════════════════════════════════════════════════
    
    local Visible = true
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Window.ToggleKey then
            Visible = not Visible
            MainFrame.Visible = Visible
        end
    end)
    
    -- ════════════════════════════════════════════════════════════════
    --  TAB CREATION
    -- ════════════════════════════════════════════════════════════════
    
    function Window:CreateTab(name, icon)
        local Tab = {
            Name = name or "Tab",
            Icon = icon or "📋",
            Sections = {},
            Elements = {},
        }
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = Theme.BackgroundDark
        TabButton.BorderSizePixel = 0
        TabButton.AutoButtonColor = false
        TabButton.Text = ""
        TabButton.Parent = TabsList
        
        CreateCorner(TabButton, 6)
        
        -- Tab Icon
        local TabIcon = Instance.new("TextLabel")
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 12, 0.5, -10)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Text = Tab.Icon
        TabIcon.TextColor3 = Theme.TextSecondary
        TabIcon.TextSize = 16
        TabIcon.Font = Enum.Font.GothamBold
        TabIcon.Parent = TabButton
        
        -- Tab Label
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.Size = UDim2.new(1, -44, 1, 0)
        TabLabel.Position = UDim2.new(0, 40, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = Tab.Name
        TabLabel.TextColor3 = Theme.TextSecondary
        TabLabel.TextSize = 13
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = Theme.Accent
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        CreatePadding(TabContent, 12)
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 12)
        ContentLayout.Parent = TabContent
        
        -- Tab Activation
        local function ActivateTab()
            -- Deactivate all tabs
            for _, tab in ipairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Theme.BackgroundDark
                tab.Icon.TextColor3 = Theme.TextSecondary
                tab.Label.TextColor3 = Theme.TextSecondary
                tab.Content.Visible = false
            end
            
            -- Activate this tab
            TabButton.BackgroundColor3 = Theme.Active
            TabIcon.TextColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.TextPrimary
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Hover}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.BackgroundDark}, 0.2)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(ActivateTab)
        
        Tab.Button = TabButton
        Tab.Icon = TabIcon
        Tab.Label = TabLabel
        Tab.Content = TabContent
        Tab.Activate = ActivateTab
        
        -- ════════════════════════════════════════════════════════════════
        --  SECTION CREATION
        -- ════════════════════════════════════════════════════════════════
        
        function Tab:CreateSection(name)
            local Section = {
                Name = name or "Section",
                Elements = {},
            }
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = name
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.BackgroundColor3 = Theme.Background
            SectionFrame.BorderSizePixel = 0
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent
            
            CreateCorner(SectionFrame, 8)
            CreateStroke(SectionFrame, 1, Theme.Border)
            CreatePadding(SectionFrame, 12)
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, 0, 0, 24)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = Section.Name
            SectionTitle.TextColor3 = Theme.TextPrimary
            SectionTitle.TextSize = 14
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            local SectionDivider = Instance.new("Frame")
            SectionDivider.Name = "Divider"
            SectionDivider.Size = UDim2.new(1, 0, 0, 1)
            SectionDivider.Position = UDim2.new(0, 0, 0, 28)
            SectionDivider.BackgroundColor3 = Theme.Border
            SectionDivider.BorderSizePixel = 0
            SectionDivider.Parent = SectionFrame
            
            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.Size = UDim2.new(1, 0, 0, 0)
            ElementsContainer.Position = UDim2.new(0, 0, 0, 34)
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
            ElementsContainer.Parent = SectionFrame
            
            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 8)
            ElementsLayout.Parent = ElementsContainer
            
            Section.Frame = SectionFrame
            Section.Container = ElementsContainer
            
            -- ════════════════════════════════════════════════════════════════
            --  TOGGLE ELEMENT
            -- ════════════════════════════════════════════════════════════════
            
            function Section:CreateToggle(config)
                config = config or {}
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = "Toggle"
                ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ElementsContainer
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = config.Name or "Toggle"
                ToggleLabel.TextColor3 = Theme.TextPrimary
                ToggleLabel.TextSize = 13
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 44, 0, 22)
                ToggleButton.Position = UDim2.new(1, -44, 0.5, -11)
                ToggleButton.BackgroundColor3 = Theme.BackgroundDark
                ToggleButton.BorderSizePixel = 0
                ToggleButton.AutoButtonColor = false
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                
                CreateCorner(ToggleButton, 11)
                CreateStroke(ToggleButton, 1, Theme.Border)
                
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Name = "Indicator"
                ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                ToggleIndicator.Position = UDim2.new(0, 3, 0.5, -8)
                ToggleIndicator.BackgroundColor3 = Theme.TextSecondary
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Parent = ToggleButton
                
                CreateCorner(ToggleIndicator, 8)
                
                local Toggled = config.CurrentValue or false
                
                local function UpdateToggle()
                    if Toggled then
                        Tween(ToggleIndicator, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Theme.Accent}, 0.2)
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Active}, 0.2)
                    else
                        Tween(ToggleIndicator, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Theme.TextSecondary}, 0.2)
                        Tween(ToggleButton, {BackgroundColor3 = Theme.BackgroundDark}, 0.2)
                    end
                    
                    if config.Callback then
                        config.Callback(Toggled)
                    end
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    UpdateToggle()
                end)
                
                UpdateToggle()
                
                return {
                    SetValue = function(value)
                        Toggled = value
                        UpdateToggle()
                    end,
                    GetValue = function()
                        return Toggled
                    end
                }
            end
            
            -- ════════════════════════════════════════════════════════════════
            --  SLIDER ELEMENT
            -- ════════════════════════════════════════════════════════════════
            
            function Section:CreateSlider(config)
                config = config or {}
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = "Slider"
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = ElementsContainer
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(1, -60, 0, 20)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = config.Name or "Slider"
                SliderLabel.TextColor3 = Theme.TextPrimary
                SliderLabel.TextSize = 13
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Size = UDim2.new(0, 60, 0, 20)
                SliderValue.Position = UDim2.new(1, -60, 0, 0)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(config.CurrentValue or 0)
                SliderValue.TextColor3 = Theme.Accent
                SliderValue.TextSize = 13
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1, 0, 0, 6)
                SliderBar.Position = UDim2.new(0, 0, 0, 30)
                SliderBar.BackgroundColor3 = Theme.BackgroundDark
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame
                
                CreateCorner(SliderBar, 3)
                CreateStroke(SliderBar, 1, Theme.Border)
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.BackgroundColor3 = Theme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar
                
                CreateCorner(SliderFill, 3)
                
                local SliderDrag = Instance.new("Frame")
                SliderDrag.Name = "Drag"
                SliderDrag.Size = UDim2.new(0, 14, 0, 14)
                SliderDrag.Position = UDim2.new(0, -7, 0.5, -7)
                SliderDrag.BackgroundColor3 = Theme.TextPrimary
                SliderDrag.BorderSizePixel = 0
                SliderDrag.Parent = SliderFill
                
                CreateCorner(SliderDrag, 7)
                CreateStroke(SliderDrag, 2, Theme.Accent)
                
                local Min = config.Range[1] or 0
                local Max = config.Range[2] or 100
                local Increment = config.Increment or 1
                local Value = config.CurrentValue or Min
                
                local Dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    Value = math.floor((Min + (Max - Min) * pos) / Increment + 0.5) * Increment
                    Value = math.clamp(Value, Min, Max)
                    
                    SliderValue.Text = tostring(Value)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    
                    if config.Callback then
                        config.Callback(Value)
                    end
                end
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                -- Initial value
                local initPos = (Value - Min) / (Max - Min)
                SliderFill.Size = UDim2.new(initPos, 0, 1, 0)
                
                return {
                    SetValue = function(val)
                        Value = math.clamp(val, Min, Max)
                        local pos = (Value - Min) / (Max - Min)
                        SliderValue.Text = tostring(Value)
                        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                        if config.Callback then config.Callback(Value) end
                    end,
                    GetValue = function()
                        return Value
                    end
                }
            end
            
            -- ════════════════════════════════════════════════════════════════
            --  BUTTON ELEMENT
            -- ════════════════════════════════════════════════════════════════
            
            function Section:CreateButton(config)
                config = config or {}
                
                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.Size = UDim2.new(1, 0, 0, 36)
                Button.BackgroundColor3 = Theme.BackgroundDark
                Button.BorderSizePixel = 0
                Button.AutoButtonColor = false
                Button.Text = config.Name or "Button"
                Button.TextColor3 = Theme.TextPrimary
                Button.TextSize = 13
                Button.Font = Enum.Font.GothamBold
                Button.Parent = ElementsContainer
                
                CreateCorner(Button, 6)
                CreateStroke(Button, 1, Theme.Border)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.Hover}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.BackgroundDark}, 0.2)
                end)
                
                Button.MouseButton1Down:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.Active}, 0.1)
                end)
                
                Button.MouseButton1Up:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.Hover}, 0.1)
                end)
                
                Button.MouseButton1Click:Connect(function()
                    if config.Callback then
                        config.Callback()
                    end
                end)
                
                return Button
            end
            
            -- ════════════════════════════════════════════════════════════════
            --  DROPDOWN ELEMENT
            -- ════════════════════════════════════════════════════════════════
            
            function Section:CreateDropdown(config)
                config = config or {}
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = "Dropdown"
                DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Parent = ElementsContainer
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 0, 36)
                DropdownButton.BackgroundColor3 = Theme.BackgroundDark
                DropdownButton.BorderSizePixel = 0
                DropdownButton.AutoButtonColor = false
                DropdownButton.Text = ""
                DropdownButton.Parent = DropdownFrame
                
                CreateCorner(DropdownButton, 6)
                CreateStroke(DropdownButton, 1, Theme.Border)
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(1, -40, 1, 0)
                DropdownLabel.Position = UDim2.new(0, 12, 0, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = config.Name or "Dropdown"
                DropdownLabel.TextColor3 = Theme.TextPrimary
                DropdownLabel.TextSize = 13
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownButton
                
                local DropdownArrow = Instance.new("TextLabel")
                DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
                DropdownArrow.Position = UDim2.new(1, -28, 0, 0)
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Text = "▼"
                DropdownArrow.TextColor3 = Theme.TextSecondary
                DropdownArrow.TextSize = 10
                DropdownArrow.Font = Enum.Font.GothamBold
                DropdownArrow.Parent = DropdownButton
                
                local DropdownList = Instance.new("Frame")
                DropdownList.Name = "List"
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Position = UDim2.new(0, 0, 0, 40)
                DropdownList.BackgroundColor3 = Theme.Background
                DropdownList.BorderSizePixel = 0
                DropdownList.AutomaticSize = Enum.AutomaticSize.Y
                DropdownList.Visible = false
                DropdownList.Parent = DropdownFrame
                
                CreateCorner(DropdownList, 6)
                CreateStroke(DropdownList, 1, Theme.Border)
                CreatePadding(DropdownList, 4)
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = DropdownList
                
                local Opened = false
                local SelectedOption = config.CurrentOption or (config.Options and config.Options[1]) or "None"
                
                DropdownLabel.Text = config.Name .. ": " .. SelectedOption
                
                local function Toggle()
                    Opened = not Opened
                    DropdownList.Visible = Opened
                    
                    if Opened then
                        Tween(DropdownArrow, {Rotation = 180}, 0.2)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + DropdownList.AbsoluteSize.Y)}, 0.2)
                    else
                        Tween(DropdownArrow, {Rotation = 0}, 0.2)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(Toggle)
                
                if config.Options then
                    for _, option in ipairs(config.Options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Size = UDim2.new(1, 0, 0, 28)
                        OptionButton.BackgroundColor3 = Theme.BackgroundDark
                        OptionButton.BorderSizePixel = 0
                        OptionButton.AutoButtonColor = false
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Theme.TextPrimary
                        OptionButton.TextSize = 12
                        OptionButton.Font = Enum.Font.Gotham
                        OptionButton.Parent = DropdownList
                        
                        CreateCorner(OptionButton, 4)
                        
                        OptionButton.MouseEnter:Connect(function()
                            Tween(OptionButton, {BackgroundColor3 = Theme.Hover}, 0.15)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            Tween(OptionButton, {BackgroundColor3 = Theme.BackgroundDark}, 0.15)
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            SelectedOption = option
                            DropdownLabel.Text = config.Name .. ": " .. option
                            Toggle()
                            if config.Callback then
                                config.Callback(option)
                            end
                        end)
                    end
                end
                
                return {
                    SetValue = function(val)
                        SelectedOption = val
                        DropdownLabel.Text = config.Name .. ": " .. val
                    end,
                    GetValue = function()
                        return SelectedOption
                    end
                }
            end
            
            -- ════════════════════════════════════════════════════════════════
            --  COLORPICKER ELEMENT
            -- ════════════════════════════════════════════════════════════════
            
            function Section:CreateColorPicker(config)
                config = config or {}
                
                local ColorFrame = Instance.new("Frame")
                ColorFrame.Name = "ColorPicker"
                ColorFrame.Size = UDim2.new(1, 0, 0, 32)
                ColorFrame.BackgroundTransparency = 1
                ColorFrame.Parent = ElementsContainer
                
                local ColorLabel = Instance.new("TextLabel")
                ColorLabel.Size = UDim2.new(1, -50, 1, 0)
                ColorLabel.BackgroundTransparency = 1
                ColorLabel.Text = config.Name or "Color"
                ColorLabel.TextColor3 = Theme.TextPrimary
                ColorLabel.TextSize = 13
                ColorLabel.Font = Enum.Font.Gotham
                ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
                ColorLabel.Parent = ColorFrame
                
                local ColorDisplay = Instance.new("TextButton")
                ColorDisplay.Size = UDim2.new(0, 36, 0, 24)
                ColorDisplay.Position = UDim2.new(1, -36, 0.5, -12)
                ColorDisplay.BackgroundColor3 = config.Color or Color3.new(1, 1, 1)
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.AutoButtonColor = false
                ColorDisplay.Text = ""
                ColorDisplay.Parent = ColorFrame
                
                CreateCorner(ColorDisplay, 4)
                CreateStroke(ColorDisplay, 1, Theme.Border)
                
                local SelectedColor = config.Color or Color3.new(1, 1, 1)
                
                ColorDisplay.MouseButton1Click:Connect(function()
                    -- Simple color randomizer for demo
                    SelectedColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                    ColorDisplay.BackgroundColor3 = SelectedColor
                    if config.Callback then
                        config.Callback(SelectedColor)
                    end
                end)
                
                return {
                    SetValue = function(color)
                        SelectedColor = color
                        ColorDisplay.BackgroundColor3 = color
                    end,
                    GetValue = function()
                        return SelectedColor
                    end
                }
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Auto-activate first tab
        if #Window.Tabs == 1 then
            Tab.Activate()
        end
        
        return Tab
    end
    
    return Window
end

-- ════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════

function NeitronUI:Notify(config)
    config = config or {}
    
    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "Notification"
    NotificationContainer.Size = UDim2.new(0, 300, 0, 80)
    NotificationContainer.Position = UDim2.new(1, -320, 1, 100)
    NotificationContainer.BackgroundColor3 = Theme.Background
    NotificationContainer.BorderSizePixel = 0
    
    local ScreenGui = game:GetService("CoreGui"):FindFirstChild("NeitronUI")
    if not ScreenGui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "NeitronUI"
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    NotificationContainer.Parent = ScreenGui
    
    CreateCorner(NotificationContainer, 8)
    CreateStroke(NotificationContainer, 2, Theme.Accent)
    CreatePadding(NotificationContainer, 12)
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, 0, 0, 20)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = config.Title or "Notification"
    NotifTitle.TextColor3 = Theme.TextPrimary
    NotifTitle.TextSize = 14
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = NotificationContainer
    
    local NotifContent = Instance.new("TextLabel")
    NotifContent.Size = UDim2.new(1, 0, 1, -25)
    NotifContent.Position = UDim2.new(0, 0, 0, 25)
    NotifContent.BackgroundTransparency = 1
    NotifContent.Text = config.Content or "This is a notification"
    NotifContent.TextColor3 = Theme.TextSecondary
    NotifContent.TextSize = 12
    NotifContent.Font = Enum.Font.Gotham
    NotifContent.TextXAlignment = Enum.TextXAlignment.Left
    NotifContent.TextYAlignment = Enum.TextYAlignment.Top
    NotifContent.TextWrapped = true
    NotifContent.Parent = NotificationContainer
    
    -- Animate in
    Tween(NotificationContainer, {Position = UDim2.new(1, -320, 1, -100)}, 0.5, Enum.EasingStyle.Back)
    
    -- Auto-dismiss
    task.delay(config.Duration or 3, function()
        Tween(NotificationContainer, {Position = UDim2.new(1, -320, 1, 100)}, 0.3)
        task.wait(0.3)
        NotificationContainer:Destroy()
    end)
end

return NeitronUI
