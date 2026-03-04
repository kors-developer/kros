--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              NEITRON UI LIBRARY v1.1 FIXED                   ║
    ║              CS2-Style Modern Interface                      ║
    ║              Author: BMA Team                                ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local NeitronUI = {}
NeitronUI.__index = NeitronUI
NeitronUI.Version = "1.1.0"

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
--  UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local function Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    local ti = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

local function CreateInstance(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  THEME
-- ════════════════════════════════════════════════════════════════

local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    BackgroundDark = Color3.fromRGB(12, 12, 12),
    BackgroundLight = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(100, 150, 255),
    AccentDark = Color3.fromRGB(70, 120, 225),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    TextDisabled = Color3.fromRGB(100, 100, 100),
    Border = Color3.fromRGB(45, 45, 45),
    Hover = Color3.fromRGB(38, 38, 38),
    Active = Color3.fromRGB(50, 50, 50),
    Success = Color3.fromRGB(80, 200, 120),
    Error = Color3.fromRGB(255, 80, 80),
}

-- ════════════════════════════════════════════════════════════════
--  WINDOW
-- ════════════════════════════════════════════════════════════════

function NeitronUI:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Name = config.Name or "NEITRON UI",
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
    }
    
    -- ScreenGui
    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "NeitronUI_" .. math.random(1000, 9999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Parent safely
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = CoreGui
        elseif gethui then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = CoreGui
        end
    end)
    
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame
    local Main = CreateInstance("Frame", {
        Name = "Main",
        Size = config.Size or UDim2.new(0, 850, 0, 550),
        Position = UDim2.new(0.5, -425, 0.5, -275),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})
    CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = Main})
    
    -- Shadow
    local Shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1,
        Parent = Main,
    })
    
    -- Title Bar
    local TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.BackgroundDark,
        BorderSizePixel = 0,
        Parent = Main,
    })
    
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TitleBar})
    
    -- Fix corner overlap
    local TitleFix = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundColor3 = Theme.BackgroundDark,
        BorderSizePixel = 0,
        Parent = TitleBar,
    })
    
    -- Title
    local Title = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = Window.Name,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar,
    })
    
    -- Close Button
    local CloseBtn = CreateInstance("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundColor3 = Theme.Error,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar,
    })
    
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseBtn})
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MakeDraggable(Main, TitleBar)
    
    -- Container
    local Container = CreateInstance("Frame", {
        Name = "Container",
        Size = UDim2.new(1, 0, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1,
        Parent = Main,
    })
    
    -- ═══════════════════════════════════════════════════════════════
    --  LEFT PANEL (TABS)
    -- ═══════════════════════════════════════════════════════════════
    
    local TabsPanel = CreateInstance("Frame", {
        Name = "TabsPanel",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Theme.BackgroundDark,
        BorderSizePixel = 0,
        Parent = Container,
    })
    
    local TabsScroll = CreateInstance("ScrollingFrame", {
        Name = "TabsScroll",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabsPanel,
    })
    
    local TabsLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = TabsScroll,
    })
    
    -- ═══════════════════════════════════════════════════════════════
    --  CENTER PANEL (CONTENT)
    -- ═══════════════════════════════════════════════════════════════
    
    local ContentPanel = CreateInstance("Frame", {
        Name = "ContentPanel",
        Size = UDim2.new(1, -320, 1, 0),
        Position = UDim2.new(0, 155, 0, 0),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Parent = Container,
    })
    
    -- ═══════════════════════════════════════════════════════════════
    --  RIGHT PANEL (INFO)
    -- ═══════════════════════════════════════════════════════════════
    
    local InfoPanel = CreateInstance("Frame", {
        Name = "InfoPanel",
        Size = UDim2.new(0, 160, 1, 0),
        Position = UDim2.new(1, -160, 0, 0),
        BackgroundColor3 = Theme.BackgroundDark,
        BorderSizePixel = 0,
        Parent = Container,
    })
    
    -- Info Box
    local InfoBox = CreateInstance("Frame", {
        Size = UDim2.new(1, -16, 0, 100),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = InfoPanel,
    })
    
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = InfoBox})
    CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = InfoBox})
    
    local InfoTitle = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        Text = "INFO",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = InfoBox,
    })
    
    local InfoText = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -16, 1, -35),
        Position = UDim2.new(0, 8, 0, 30),
        BackgroundTransparency = 1,
        Text = "Player: " .. LocalPlayer.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = InfoBox,
    })
    
    -- FPS/Ping Update
    task.spawn(function()
        while ScreenGui.Parent do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            InfoText.Text = string.format("Player: %s\nFPS: %d\nPing: %dms\nPlayers: %d", 
                LocalPlayer.Name, fps, ping, #Players:GetPlayers())
        end
    end)
    
    -- Toggle Key
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == ToggleKey then
            Window.Visible = not Window.Visible
            Main.Visible = Window.Visible
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    --  TAB CLASS
    -- ═══════════════════════════════════════════════════════════════
    
    function Window:CreateTab(name, icon)
        local Tab = {
            Name = name or "Tab",
            Icon = icon or "📁",
            Sections = {},
            Active = false,
        }
        
        -- Tab Button
        local TabBtn = CreateInstance("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Theme.BackgroundDark,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = TabsScroll,
        })
        
        CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})
        
        local TabIcon = CreateInstance("TextLabel", {
            Size = UDim2.new(0, 25, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = Tab.Icon,
            TextSize = 14,
            Parent = TabBtn,
        })
        
        local TabName = CreateInstance("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = Tab.Name,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn,
        })
        
        -- Tab Content
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "_Content",
            Size = UDim2.new(1, -16, 1, -16),
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentPanel,
        })
        
        local ContentLayout = CreateInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = TabContent,
        })
        
        Tab.Button = TabBtn
        Tab.Content = TabContent
        Tab.IconLabel = TabIcon
        Tab.NameLabel = TabName
        
        -- Activate Tab
        local function Activate()
            for _, t in ipairs(Window.Tabs) do
                t.Active = false
                t.Button.BackgroundColor3 = Theme.BackgroundDark
                t.NameLabel.TextColor3 = Theme.TextDark
                t.Content.Visible = false
            end
            
            Tab.Active = true
            TabBtn.BackgroundColor3 = Theme.Active
            TabName.TextColor3 = Theme.Accent
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        TabBtn.MouseEnter:Connect(function()
            if not Tab.Active then
                Tween(TabBtn, {BackgroundColor3 = Theme.Hover}, 0.15)
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if not Tab.Active then
                Tween(TabBtn, {BackgroundColor3 = Theme.BackgroundDark}, 0.15)
            end
        end)
        
        TabBtn.MouseButton1Click:Connect(Activate)
        
        -- ═══════════════════════════════════════════════════════════════
        --  SECTION CLASS
        -- ═══════════════════════════════════════════════════════════════
        
        function Tab:CreateSection(name)
            local Section = {
                Name = name or "Section",
                Elements = {},
            }
            
            local SectionFrame = CreateInstance("Frame", {
                Name = name,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabContent,
            })
            
            CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SectionFrame})
            CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = SectionFrame})
            CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = SectionFrame,
            })
            
            local SectionTitle = CreateInstance("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = Section.Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame,
            })
            
            local ElementsFrame = CreateInstance("Frame", {
                Name = "Elements",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 28),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame,
            })
            
            local ElementsLayout = CreateInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = ElementsFrame,
            })
            
            Section.Frame = SectionFrame
            Section.Elements = ElementsFrame
            
            -- ═══════════════════════════════════════════════════════════════
            --  TOGGLE
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateToggle(config)
                config = config or {}
                local Toggled = config.CurrentValue or false
                
                local ToggleFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Parent = ElementsFrame,
                })
                
                local ToggleName = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -55, 1, 0),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Toggle",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame,
                })
                
                local ToggleBtn = CreateInstance("TextButton", {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -44, 0.5, -11),
                    BackgroundColor3 = Theme.BackgroundDark,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ToggleFrame,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})
                CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = ToggleBtn})
                
                local ToggleCircle = CreateInstance("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Theme.TextDark,
                    BorderSizePixel = 0,
                    Parent = ToggleBtn,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
                
                local function Update()
                    if Toggled then
                        Tween(ToggleCircle, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Theme.Accent}, 0.15)
                        Tween(ToggleBtn, {BackgroundColor3 = Theme.AccentDark}, 0.15)
                    else
                        Tween(ToggleCircle, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Theme.TextDark}, 0.15)
                        Tween(ToggleBtn, {BackgroundColor3 = Theme.BackgroundDark}, 0.15)
                    end
                    if config.Callback then
                        pcall(config.Callback, Toggled)
                    end
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)
                
                Update()
                
                return {
                    SetValue = function(v) Toggled = v; Update() end,
                    GetValue = function() return Toggled end,
                }
            end
            
            -- ═══════════════════════════════════════════════════════════════
            --  SLIDER
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateSlider(config)
                config = config or {}
                local Min = config.Range and config.Range[1] or 0
                local Max = config.Range and config.Range[2] or 100
                local Inc = config.Increment or 1
                local Value = config.CurrentValue or Min
                
                local SliderFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 1,
                    Parent = ElementsFrame,
                })
                
                local SliderName = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 18),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Slider",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame,
                })
                
                local SliderValue = CreateInstance("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(Value),
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame,
                })
                
                local SliderBar = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundColor3 = Theme.BackgroundDark,
                    BorderSizePixel = 0,
                    Parent = SliderFrame,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBar})
                
                local SliderFill = CreateInstance("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = SliderBar,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
                
                local SliderKnob = CreateInstance("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -8, 0.5, -8),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Parent = SliderFill,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderKnob})
                CreateInstance("UIStroke", {Color = Theme.Accent, Thickness = 2, Parent = SliderKnob})
                
                local Dragging = false
                
                local function Update(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    Value = math.floor((Min + (Max - Min) * pos) / Inc + 0.5) * Inc
                    Value = math.clamp(Value, Min, Max)
                    
                    local fillPos = (Value - Min) / (Max - Min)
                    SliderFill.Size = UDim2.new(fillPos, 0, 1, 0)
                    SliderValue.Text = tostring(Value)
                    
                    if config.Callback then
                        pcall(config.Callback, Value)
                    end
                end
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Update(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                -- Initial
                local initPos = (Value - Min) / (Max - Min)
                SliderFill.Size = UDim2.new(initPos, 0, 1, 0)
                
                return {
                    SetValue = function(v)
                        Value = math.clamp(v, Min, Max)
                        local pos = (Value - Min) / (Max - Min)
                        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                        SliderValue.Text = tostring(Value)
                        if config.Callback then pcall(config.Callback, Value) end
                    end,
                    GetValue = function() return Value end,
                }
            end
            
            -- ═══════════════════════════════════════════════════════════════
            --  BUTTON
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateButton(config)
                config = config or {}
                
                local Btn = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BackgroundDark,
                    BorderSizePixel = 0,
                    Text = config.Name or "Button",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    AutoButtonColor = false,
                    Parent = ElementsFrame,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Btn})
                CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = Btn})
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Hover}, 0.1)
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.BackgroundDark}, 0.1)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Accent}, 0.1)
                    task.delay(0.1, function()
                        Tween(Btn, {BackgroundColor3 = Theme.BackgroundDark}, 0.1)
                    end)
                    if config.Callback then
                        pcall(config.Callback)
                    end
                end)
                
                return Btn
            end
            
            -- ═══════════════════════════════════════════════════════════════
            --  DROPDOWN
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateDropdown(config)
                config = config or {}
                local Options = config.Options or {}
                local Selected = config.CurrentOption or (Options[1] or "None")
                local Opened = false
                
                local DropFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = ElementsFrame,
                })
                
                local DropBtn = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BackgroundDark,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropFrame,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropBtn})
                CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = DropBtn})
                
                local DropLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -35, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = (config.Name or "Dropdown") .. ": " .. Selected,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropBtn,
                })
                
                local Arrow = CreateInstance("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Parent = DropBtn,
                })
                
                local DropList = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 36),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = false,
                    Parent = DropFrame,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropList})
                CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = DropList})
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    Parent = DropList,
                })
                
                local ListLayout = CreateInstance("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = DropList,
                })
                
                local function Toggle()
                    Opened = not Opened
                    DropList.Visible = Opened
                    Arrow.Text = Opened and "▲" or "▼"
                    
                    local height = Opened and (36 + DropList.AbsoluteSize.Y + 8) or 32
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.15)
                end
                
                DropBtn.MouseButton1Click:Connect(Toggle)
                
                for _, opt in ipairs(Options) do
                    local OptBtn = CreateInstance("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.BackgroundDark,
                        BorderSizePixel = 0,
                        Text = opt,
                        TextColor3 = Theme.Text,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        AutoButtonColor = false,
                        Parent = DropList,
                    })
                    
                    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptBtn})
                    
                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Theme.Hover}, 0.1)
                    end)
                    
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, {BackgroundColor3 = Theme.BackgroundDark}, 0.1)
                    end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        Selected = opt
                        DropLabel.Text = (config.Name or "Dropdown") .. ": " .. opt
                        Toggle()
                        if config.Callback then
                            pcall(config.Callback, opt)
                        end
                    end)
                end
                
                return {
                    SetValue = function(v)
                        Selected = v
                        DropLabel.Text = (config.Name or "Dropdown") .. ": " .. v
                    end,
                    GetValue = function() return Selected end,
                }
            end
            
            -- ═══════════════════════════════════════════════════════════════
            --  COLOR PICKER
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateColorPicker(config)
                config = config or {}
                local CurrentColor = config.Color or Color3.new(1, 1, 1)
                local Opened = false
                
                local ColorFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = ElementsFrame,
                })
                
                local ColorName = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 28),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Color",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame,
                })
                
                local ColorDisplay = CreateInstance("TextButton", {
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -40, 0, 3),
                    BackgroundColor3 = CurrentColor,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ColorFrame,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorDisplay})
                CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = ColorDisplay})
                
                -- Color Picker Panel
                local PickerPanel = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 120),
                    Position = UDim2.new(0, 0, 0, 32),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Visible = false,
                    Parent = ColorFrame,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = PickerPanel})
                CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = PickerPanel})
                
                -- Color Gradient
                local ColorGradient = CreateInstance("ImageButton", {
                    Size = UDim2.new(1, -60, 0, 80),
                    Position = UDim2.new(0, 8, 0, 8),
                    BackgroundColor3 = Color3.new(1, 0, 0),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = PickerPanel,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorGradient})
                
                -- Gradient overlays
                local WhiteGrad = CreateInstance("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                    Parent = ColorGradient,
                })
                
                local BlackOverlay = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = ColorGradient,
                })
                
                CreateInstance("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    }),
                    Rotation = 90,
                    Parent = BlackOverlay,
                })
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = BlackOverlay})
                
                -- Hue Slider
                local HueSlider = CreateInstance("ImageButton", {
                    Size = UDim2.new(0, 20, 0, 80),
                    Position = UDim2.new(1, -45, 0, 8),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = PickerPanel,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = HueSlider})
                CreateInstance("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                    }),
                    Rotation = 90,
                    Parent = HueSlider,
                })
                
                -- Preview
                local Preview = CreateInstance("Frame", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -45, 0, 92),
                    BackgroundColor3 = CurrentColor,
                    BorderSizePixel = 0,
                    Parent = PickerPanel,
                })
                
                CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Preview})
                CreateInstance("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = Preview})
                
                -- State
                local Hue, Sat, Val = 0, 1, 1
                
                local function UpdateColor()
                    CurrentColor = Color3.fromHSV(Hue, Sat, Val)
                    ColorDisplay.BackgroundColor3 = CurrentColor
                    Preview.BackgroundColor3 = CurrentColor
                    ColorGradient.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
                    
                    if config.Callback then
                        pcall(config.Callback, CurrentColor)
                    end
                end
                
                local function Toggle()
                    Opened = not Opened
                    PickerPanel.Visible = Opened
                    local height = Opened and 160 or 28
                    Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.15)
                end
                
                ColorDisplay.MouseButton1Click:Connect(Toggle)
                
                -- Gradient dragging
                local draggingGrad = false
                ColorGradient.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingGrad = true
                    end
                end)
                
                -- Hue dragging
                local draggingHue = false
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingGrad then
                            local x = math.clamp((input.Position.X - ColorGradient.AbsolutePosition.X) / ColorGradient.AbsoluteSize.X, 0, 1)
                            local y = math.clamp((input.Position.Y - ColorGradient.AbsolutePosition.Y) / ColorGradient.AbsoluteSize.Y, 0, 1)
                            Sat = x
                            Val = 1 - y
                            UpdateColor()
                        elseif draggingHue then
                            local y = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                            Hue = y
                            UpdateColor()
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingGrad = false
                        draggingHue = false
                    end
                end)
                
                return {
                    SetValue = function(c)
                        CurrentColor = c
                        Hue, Sat, Val = Color3.toHSV(c)
                        UpdateColor()
                    end,
                    GetValue = function() return CurrentColor end,
                }
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Activate()
        end
        
        return Tab
    end
    
    return Window
end

-- ════════════════════════════════════════════════════════════════
--  NOTIFICATION
-- ════════════════════════════════════════════════════════════════

function NeitronUI:Notify(config)
    config = config or {}
    
    local gui = CoreGui:FindFirstChild("NeitronNotifications")
    if not gui then
        gui = CreateInstance("ScreenGui", {
            Name = "NeitronNotifications",
            ResetOnSpawn = false,
            Parent = CoreGui,
        })
    end
    
    local Notif = CreateInstance("Frame", {
        Size = UDim2.new(0, 280, 0, 70),
        Position = UDim2.new(1, 300, 1, -80),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = gui,
    })
    
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notif})
    CreateInstance("UIStroke", {Color = Theme.Accent, Thickness = 2, Parent = Notif})
    
    local Title = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = config.Title or "Notification",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notif,
    })
    
    local Content = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 1, -35),
        Position = UDim2.new(0, 10, 0, 32),
        BackgroundTransparency = 1,
        Text = config.Content or "",
        TextColor3 = Theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Notif,
    })
    
    Tween(Notif, {Position = UDim2.new(1, -290, 1, -80)}, 0.4)
    
    task.delay(config.Duration or 3, function()
        Tween(Notif, {Position = UDim2.new(1, 300, 1, -80)}, 0.3)
        task.wait(0.3)
        Notif:Destroy()
    end)
end

return NeitronUI
