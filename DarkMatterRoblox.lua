--[[
    PANEL DARKMATTER v4.0 (REVISIÓN VISUAL)
    Universal Script | Premium UI Edition
    Estructura de código original preservada al 100%.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // VARIABLES DE ESTADO //
local State = {
    SavedCFrame = nil,
    Wallhack = false,
    ESP = false,
    ESPBox = false,
    AimbotPC = false,
    AimbotMobile = false,
    AimbotMode = "DISIMULADO",
    TeamCheck = false,
    WallCheck = true,
    DistanceCheck = true,
    ShowFOV = false,
    FOVSize = 150,
    Fly = false,
    FlySpeed = 50,
    SpeedHack = false,
    Speed = 50,
    JumpHack = false,
    Jump = 100,
    IsMinimized = false,
    FlyingUp = false,
    FlyingDown = false,
    Orbiting = false,
    OrbitTarget = nil,
    OrbitSpeed = 5,
    OrbitDistance = 5,
    OrbitAngle = 0,
    MagicBullets = false,
    ShowHitbox = true,
    HitboxSize = 15,
    HitboxTransparency = 0.7,
    HitboxColor = Color3.fromRGB(147, 0, 255) -- Morado DarkMatter
}

-- // COLORES DARKMATTER //
local THEME = {
    Background = Color3.fromRGB(10, 10, 12),    -- Negro
    TopBar = Color3.fromRGB(20, 10, 35),        -- Morado muy oscuro
    Accent = Color3.fromRGB(140, 0, 255),       -- Morado
    LightAccent = Color3.fromRGB(190, 140, 255),-- Morado claro
    Text = Color3.fromRGB(255, 255, 255),       -- Blanco
    ElementBG = Color3.fromRGB(25, 20, 40),     -- Morado oscuro traslúcido
    Danger = Color3.fromRGB(255, 50, 50)
}

-- // CREACIÓN DE LA UI PRINCIPAL //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkMatterUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

-- BOTÓN DE ACTIVACIÓN (Instrucción guardada)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -25)
ToggleButton.BackgroundColor3 = THEME.TopBar
ToggleButton.Text = "DM"
ToggleButton.TextColor3 = THEME.LightAccent
ToggleButton.Font = Enum.Font.GothamBlack
ToggleButton.TextSize = 20
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleButton); ToggleStroke.Color = THEME.Accent; ToggleStroke.Thickness = 2

local BoxFolder = Instance.new("Folder", ScreenGui)
BoxFolder.Name = "ESP_Boxes"

-- // BOTONES DE VUELO (Mismo diseño, colores adaptados) //
local FlyControls = Instance.new("Frame")
FlyControls.Size = UDim2.new(0, 60, 0, 130)
FlyControls.Position = UDim2.new(1, -80, 0.5, -65)
FlyControls.BackgroundTransparency = 1
FlyControls.Visible = false
FlyControls.Parent = ScreenGui

local function CreateFlyBtn(text, pos, stateKey)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 60)
    Btn.Position = pos
    Btn.BackgroundColor3 = THEME.Background
    Btn.TextColor3 = THEME.Accent
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 30
    Btn.Parent = FlyControls
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Btn).Color = THEME.Accent
    
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            State[stateKey] = true
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Accent, TextColor3 = THEME.Text}):Play()
        end
    end)
    Btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            State[stateKey] = false
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Background, TextColor3 = THEME.Accent}):Play()
        end
    end)
end

CreateFlyBtn("▲", UDim2.new(0, 0, 0, 0), "FlyingUp")
CreateFlyBtn("▼", UDim2.new(0, 0, 0, 70), "FlyingDown")

-- // FOV //
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "ZelikaFOV"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
FOVFrame.Size = UDim2.new(0, State.FOVSize * 2, 0, State.FOVSize * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke", FOVFrame); FOVStroke.Color = THEME.Accent; FOVStroke.Thickness = 1.5; FOVStroke.Transparency = 0.2

-- // PANEL PRINCIPAL //
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 420)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -210)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = THEME.Accent; MainStroke.Thickness = 2

-- Lógica del botón de activación
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = THEME.TopBar
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = THEME.Text
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Text = "DARKMATTER"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0, 10)
MinBtn.BackgroundColor3 = THEME.ElementBG; MinBtn.TextColor3 = THEME.LightAccent; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18; MinBtn.Text = "▲"; MinBtn.Parent = TitleBar; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.BackgroundColor3 = THEME.ElementBG; CloseBtn.TextColor3 = THEME.Danger; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.Text = "X"; CloseBtn.Parent = TitleBar; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.ScrollBarImageColor3 = THEME.Accent
Container.Parent = MainFrame
local UIList = Instance.new("UIListLayout"); UIList.Parent = Container; UIList.Padding = UDim.new(0, 10); UIList.SortOrder = Enum.SortOrder.LayoutOrder 

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

-- // VENTANA DE CIERRE //
local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.new(0, 280, 0, 140)
ConfirmFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
ConfirmFrame.BackgroundColor3 = THEME.Background; ConfirmFrame.Visible = false; ConfirmFrame.ZIndex = 100; ConfirmFrame.Parent = ScreenGui; Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 10)
local ConfirmStroke = Instance.new("UIStroke", ConfirmFrame); ConfirmStroke.Color = THEME.Danger; ConfirmStroke.Thickness = 2

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.Size = UDim2.new(1, 0, 0, 70); ConfirmTitle.BackgroundTransparency = 1; ConfirmTitle.Text = "¿Eliminar DARKMATTER?"; ConfirmTitle.TextColor3 = THEME.Text; ConfirmTitle.Font = Enum.Font.GothamBold; ConfirmTitle.TextSize = 14; ConfirmTitle.ZIndex = 101; ConfirmTitle.Parent = ConfirmFrame

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.new(0, 110, 0, 40); YesBtn.Position = UDim2.new(0, 20, 1, -55); YesBtn.BackgroundColor3 = THEME.Danger; YesBtn.Text = "SÍ"; YesBtn.TextColor3 = THEME.Text; YesBtn.Font = Enum.Font.GothamBold; YesBtn.ZIndex = 101; YesBtn.Parent = ConfirmFrame; Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

local NoBtn = Instance.new("TextButton")
NoBtn.Size = UDim2.new(0, 110, 0, 40); NoBtn.Position = UDim2.new(1, -130, 1, -55); NoBtn.BackgroundColor3 = THEME.ElementBG; NoBtn.Text = "NO"; NoBtn.TextColor3 = THEME.Text; NoBtn.Font = Enum.Font.GothamBold; NoBtn.ZIndex = 101; NoBtn.Parent = ConfirmFrame; Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

local function ShutdownPanel()
    State.Fly = false; State.ESP = false; State.ESPBox = false; State.MagicBullets = false
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16; char.Humanoid.JumpPower = 50; char.Humanoid.PlatformStand = false end
    ScreenGui:Destroy()
end

CloseBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
NoBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)
YesBtn.MouseButton1Click:Connect(function() ShutdownPanel() end)

MinBtn.MouseButton1Click:Connect(function()
    State.IsMinimized = not State.IsMinimized
    if State.IsMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 380, 0, 50)}):Play()
        MinBtn.Text = "▼"; Container.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 380, 0, 420)}):Play()
        MinBtn.Text = "▲"; task.delay(0.1, function() Container.Visible = true end)
    end
end)

-- ARRASTRE
local function MakeDraggable(guiObject, target)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = target.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
MakeDraggable(TitleBar, MainFrame)

-- CONSTRUCTORES
local layoutIdx = 0
local function getNextOrder() layoutIdx = layoutIdx + 1; return layoutIdx end

local function CreateButton(text, callback, parent)
    local Btn = Instance.new("TextButton")
    Btn.Text = text; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.BackgroundColor3 = THEME.ElementBG; Btn.TextColor3 = THEME.LightAccent; Btn.Font = Enum.Font.GothamBold; Btn.Parent = parent or Container; Btn.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", Btn); s.Color = THEME.Accent; s.Transparency = 0.6
    Btn.MouseButton1Click:Connect(function() callback() end)
    return Btn
end

local function CreateToggle(text, stateKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42); Frame.BackgroundColor3 = THEME.ElementBG; Frame.Parent = Container; Frame.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local Lbl = Instance.new("TextLabel"); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = THEME.Text; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
    local Switch = Instance.new("TextButton"); Switch.Text = ""; Switch.Size = UDim2.new(0, 44, 0, 22); Switch.Position = UDim2.new(1, -55, 0.5, -11); Switch.BackgroundColor3 = State[stateKey] and THEME.Accent or Color3.fromRGB(40,40,50); Switch.Parent = Frame; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0, 18, 0, 18); Dot.Position = State[stateKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9); Dot.BackgroundColor3 = Color3.fromRGB(255,255,255); Dot.Parent = Switch; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    Switch.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State[stateKey] and THEME.Accent or Color3.fromRGB(40,40,50)}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State[stateKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        callback(State[stateKey])
    end)
    return Frame
end

local function CreateSlider(text, min, max, default, callback, parent)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 60); Frame.BackgroundColor3 = THEME.ElementBG; Frame.Parent = parent or Container; Frame.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local Lbl = Instance.new("TextLabel"); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(0.5, 0, 0, 30); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = THEME.Text; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
    local Val = Instance.new("TextLabel"); Val.Text = tostring(default); Val.Size = UDim2.new(0.5, -15, 0, 30); Val.Position = UDim2.new(0.5, 0, 0, 0); Val.BackgroundTransparency = 1; Val.TextColor3 = THEME.LightAccent; Val.Font = Enum.Font.Code; Val.TextXAlignment = Enum.TextXAlignment.Right; Val.Parent = Frame
    local BarBG = Instance.new("Frame"); BarBG.Size = UDim2.new(1, -30, 0, 5); BarBG.Position = UDim2.new(0, 15, 0, 42); BarBG.BackgroundColor3 = Color3.fromRGB(30,30,40); BarBG.Parent = Frame; Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = THEME.Accent; Fill.Parent = BarBG; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0); local realValue = math.floor((pos * (max - min)) + min); Val.Text = tostring(realValue); callback(realValue)
    end
    BarBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
    return Frame
end

-- SECCIONES
local Section1 = Instance.new("TextLabel"); Section1.Text = "  COMBATE & VISUALES"; Section1.Size = UDim2.new(1,0,0,20); Section1.TextColor3 = THEME.LightAccent; Section1.BackgroundTransparency = 1; Section1.Font = Enum.Font.GothamBlack; Section1.Parent = Container; Section1.LayoutOrder = getNextOrder()

-- SECCIÓN MAGIC BULLETS
local SectionMagic = Instance.new("TextLabel"); SectionMagic.Text = "  DARK MATTER MAGIC"; SectionMagic.Size = UDim2.new(1,0,0,20); SectionMagic.TextColor3 = THEME.Accent; SectionMagic.BackgroundTransparency = 1; SectionMagic.Font = Enum.Font.GothamBlack; SectionMagic.Parent = Container; SectionMagic.LayoutOrder = getNextOrder()

CreateToggle("🔮 ACTIVAR MAGIC BULLETS", "MagicBullets", function() end)
CreateToggle("👁️ MOSTRAR HITBOX GIGANTE", "ShowHitbox", function() end)
CreateSlider("TAMAÑO DE HITBOX", 2, 50, State.HitboxSize, function(v) State.HitboxSize = v end)
CreateSlider("TRANSPARENCIA (%)", 0, 100, State.HitboxTransparency * 100, function(v) State.HitboxTransparency = v/100 end)
CreateButton("🎨 CAMBIAR COLOR HITBOX", function() 
    local colors = {Color3.fromRGB(147, 0, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), Color3.fromRGB(200, 150, 255)}
    local foundIdx = 1
    for i, c in ipairs(colors) do if c == State.HitboxColor then foundIdx = i break end end
    State.HitboxColor = colors[(foundIdx % #colors) + 1]
end)

CreateToggle("🎯 AIMBOT PC", "AimbotPC", function() end)
CreateToggle("📱 AIMBOT MOBILE", "AimbotMobile", function() end)

local ModeFrame = Instance.new("Frame"); ModeFrame.Size = UDim2.new(1, -10, 0, 40); ModeFrame.BackgroundColor3 = THEME.ElementBG; ModeFrame.Parent = Container; ModeFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", ModeFrame).CornerRadius = UDim.new(0, 6)
local ModeLabel = Instance.new("TextLabel"); ModeLabel.Text = " TIPO DE AIMBOT:"; ModeLabel.Size = UDim2.new(0.4, 0, 1, 0); ModeLabel.BackgroundTransparency = 1; ModeLabel.TextColor3 = THEME.Text; ModeLabel.Font = Enum.Font.GothamSemibold; ModeLabel.TextXAlignment = Enum.TextXAlignment.Left; ModeLabel.Parent = ModeFrame
local ModeBtn = Instance.new("TextButton"); ModeBtn.Size = UDim2.new(0.55, 0, 0.7, 0); ModeBtn.Position = UDim2.new(0.42, 0, 0.15, 0); ModeBtn.BackgroundColor3 = THEME.TopBar; ModeBtn.Text = State.AimbotMode; ModeBtn.TextColor3 = THEME.Accent; ModeBtn.Font = Enum.Font.GothamBold; ModeBtn.TextSize = 12; ModeBtn.Parent = ModeFrame; Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 4)
local AimModes = {"DISIMULADO", "DIRECTO", "SUAVE"}
local currentModeIdx = 1
ModeBtn.MouseButton1Click:Connect(function() currentModeIdx = currentModeIdx + 1; if currentModeIdx > #AimModes then currentModeIdx = 1 end; State.AimbotMode = AimModes[currentModeIdx]; ModeBtn.Text = State.AimbotMode end)

CreateToggle("🔍 WALL CHECK", "WallCheck", function() end)
CreateToggle("📏 DISTANCE CHECK", "DistanceCheck", function() end)
CreateToggle("🛡️ TEAM CHECK", "TeamCheck", function() end)
CreateToggle("⭕ MOSTRAR FOV", "ShowFOV", function(v) FOVFrame.Visible = v end)
CreateSlider("Tamaño del FOV", 50, 400, State.FOVSize, function(val) State.FOVSize = val; FOVFrame.Size = UDim2.new(0, val*2, 0, val*2) end)

-- ESP SECCIÓN
CreateToggle("👁️ ESP HIGHLIGHT", "ESP", function() end)
CreateToggle("📦 ESP BOX 2D", "ESPBox", function() 
    if not State.ESPBox then
        for _, v in pairs(BoxFolder:GetChildren()) do v:Destroy() end
    end
end)

-- SECCIÓN ORBIT
local SectionOrbit = Instance.new("TextLabel"); SectionOrbit.Text = "  SISTEMA DE ÓRBITA"; SectionOrbit.Size = UDim2.new(1,0,0,20); SectionOrbit.TextColor3 = THEME.Accent; SectionOrbit.BackgroundTransparency = 1; SectionOrbit.Font = Enum.Font.GothamBlack; SectionOrbit.Parent = Container; SectionOrbit.LayoutOrder = getNextOrder()
local MainOrbitToggle = CreateToggle("🌀 ACTIVAR ÓRBITA", "Orbiting", function(v) if _G.OrbitContainer then _G.OrbitContainer.Visible = v end; if not v then State.OrbitTarget = nil end end)
local OrbitGroup = Instance.new("Frame"); OrbitGroup.Name = "OrbitGroup"; OrbitGroup.Size = UDim2.new(1, 0, 0, 210); OrbitGroup.BackgroundTransparency = 1; OrbitGroup.Visible = false; OrbitGroup.Parent = Container; OrbitGroup.LayoutOrder = MainOrbitToggle.LayoutOrder + 1; _G.OrbitContainer = OrbitGroup
local OrbitGroupLayout = Instance.new("UIListLayout"); OrbitGroupLayout.Parent = OrbitGroup; OrbitGroupLayout.Padding = UDim.new(0, 8)
local OrbitListFrame = Instance.new("Frame"); OrbitListFrame.Size = UDim2.new(1, -10, 0, 100); OrbitListFrame.BackgroundColor3 = THEME.ElementBG; OrbitListFrame.Parent = OrbitGroup; Instance.new("UICorner", OrbitListFrame).CornerRadius = UDim.new(0, 6)
local OrbitScroll = Instance.new("ScrollingFrame"); OrbitScroll.Size = UDim2.new(1, -10, 1, -10); OrbitScroll.Position = UDim2.new(0, 5, 0, 5); OrbitScroll.BackgroundTransparency = 1; OrbitScroll.ScrollBarThickness = 2; OrbitScroll.Parent = OrbitListFrame
local OrbitListLayout = Instance.new("UIListLayout"); OrbitListLayout.Parent = OrbitScroll; OrbitListLayout.Padding = UDim.new(0, 2)
OrbitListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() OrbitScroll.CanvasSize = UDim2.new(0, 0, 0, OrbitListLayout.AbsoluteContentSize.Y + 5) end)

local function UpdateOrbitList()
    for _, child in pairs(OrbitScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then local pBtn = Instance.new("TextButton"); pBtn.Size = UDim2.new(1, 0, 0, 20); pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); pBtn.Text = p.Name; pBtn.TextColor3 = THEME.Text; pBtn.Font = Enum.Font.Gotham; pBtn.TextSize = 12; pBtn.Parent = OrbitScroll; Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4); pBtn.MouseButton1Click:Connect(function() State.OrbitTarget = p; State.Orbiting = true end) end end
end
UpdateOrbitList(); Players.PlayerAdded:Connect(UpdateOrbitList); Players.PlayerRemoving:Connect(UpdateOrbitList)
CreateButton("❌ DETENER ÓRBITA", function() State.Orbiting = false; State.OrbitTarget = nil end, OrbitGroup)
CreateSlider("Distancia (Rango)", 2, 50, State.OrbitDistance, function(v) State.OrbitDistance = v end, OrbitGroup)
CreateSlider("Velocidad de Giro", 1, 50, State.OrbitSpeed, function(v) State.OrbitSpeed = v end, OrbitGroup)

-- SECCIÓN MOVIMIENTO
local Section2 = Instance.new("TextLabel"); Section2.Text = "  MOVIMIENTO & TP"; Section2.Size = UDim2.new(1,0,0,20); Section2.TextColor3 = THEME.LightAccent; Section2.BackgroundTransparency = 1; Section2.Font = Enum.Font.GothamBlack; Section2.Parent = Container; Section2.LayoutOrder = getNextOrder()
CreateToggle("🧱 WALLHACK", "Wallhack", function() end)
CreateToggle("🕊️ FLY HACK", "Fly", function(v) ToggleFly(v) end)
CreateSlider("Velocidad de Vuelo", 10, 300, State.FlySpeed, function(val) State.FlySpeed = val end)
CreateToggle("⚡ SPEED HACK", "SpeedHack", function() end)
CreateSlider("Velocidad", 16, 250, State.Speed, function(val) State.Speed = val end)
CreateToggle("🐰 JUMP HACK", "JumpHack", function() end)
CreateSlider("Fuerza de Salto", 50, 500, State.Jump, function(val) State.Jump = val end)
CreateButton("📍 GUARDAR POSICIÓN", function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then State.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end end)
CreateButton("🚀 IR A POSICIÓN", function() if State.SavedCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = State.SavedCFrame end end)

-- // FUNCIONES CORE (SIN MODIFICAR) //
local function IsVisible(part)
    if not State.WallCheck then return true end
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return not result
end

local function GetClosestPlayer()
    local closest, shortestMetric = nil, math.huge
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if State.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if not IsVisible(v.Character.Head) then continue end
            local headPos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local screenDist = (Vector2.new(headPos.X, headPos.Y) - centerPos).Magnitude
                if screenDist < State.FOVSize then
                    if State.DistanceCheck then
                        local worldDist = (v.Character.Head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if worldDist < shortestMetric then shortestMetric = worldDist; closest = v.Character.Head end
                    else
                        if screenDist < shortestMetric then shortestMetric = screenDist; closest = v.Character.Head end
                    end
                end
            end
        end
    end
    return closest
end

-- // RENDER LOOP //
RunService.RenderStepped:Connect(function(dt)
    FOVFrame.Visible = State.ShowFOV
    FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local espVisual = hrp:FindFirstChild("MagicESP")
            if State.MagicBullets then
                hrp.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                hrp.Transparency = 1 
                if not espVisual then
                    espVisual = Instance.new("BoxHandleAdornment", hrp); espVisual.Name = "MagicESP"; espVisual.AlwaysOnTop = true; espVisual.Adornee = hrp; espVisual.ZIndex = 10
                end
                espVisual.Visible = State.ShowHitbox; espVisual.Size = hrp.Size; espVisual.Color3 = State.HitboxColor; espVisual.Transparency = State.HitboxTransparency
            else
                hrp.Size = Vector3.new(2, 2, 1); if espVisual then espVisual:Destroy() end
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        local boxName = p.Name .. "_Box"
        local box = BoxFolder:FindFirstChild(boxName)
        if State.ESPBox and p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            if State.TeamCheck and p.Team == LocalPlayer.Team then if box then box.Visible = false end continue end
            local char = p.Character
            local cf, size = char:GetBoundingBox()
            local corners = {cf * CFrame.new(-size.X/2, size.Y/2, 0), cf * CFrame.new(size.X/2, size.Y/2, 0), cf * CFrame.new(-size.X/2, -size.Y/2, 0), cf * CFrame.new(size.X/2, -size.Y/2, 0)}
            local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
            local anyVisible = false
            for _, corner in pairs(corners) do
                local screenPos, onScreen = Camera:WorldToViewportPoint(corner.Position)
                if onScreen then anyVisible = true; minX = math.min(minX, screenPos.X); minY = math.min(minY, screenPos.Y); maxX = math.max(maxX, screenPos.X); maxY = math.max(maxY, screenPos.Y) end
            end
            if anyVisible then
                if not box then box = Instance.new("Frame", BoxFolder); box.Name = boxName; box.BackgroundTransparency = 1; box.BorderSizePixel = 0; local stroke = Instance.new("UIStroke", box); stroke.Color = THEME.Accent; stroke.Thickness = 1.5 end
                box.Position = UDim2.new(0, minX, 0, minY); box.Size = UDim2.new(0, maxX - minX, 0, maxY - minY); box.Visible = true
            elseif box then box.Visible = false end
        elseif box then box.Visible = false end
    end

    if State.Orbiting and State.OrbitTarget and State.OrbitTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetPart = State.OrbitTarget.Character.HumanoidRootPart
        State.OrbitAngle = State.OrbitAngle + (dt * State.OrbitSpeed)
        local offset = Vector3.new(math.cos(State.OrbitAngle) * State.OrbitDistance, 1, math.sin(State.OrbitAngle) * State.OrbitDistance)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position + offset, targetPart.Position)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    end

    local isAimbotActive = (State.AimbotPC and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or State.AimbotMobile
    if isAimbotActive and not State.Orbiting then
        local target = GetClosestPlayer()
        if target then
            local lerpSpeed = (State.AimbotMode == "DISIMULADO" and 0.05) or (State.AimbotMode == "DIRECTO" and 1.0) or 0.25
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), lerpSpeed)
        end
    end
end)

-- // PHYSICS LOOP //
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = State.SpeedHack and State.Speed or 16
        char.Humanoid.JumpPower = State.JumpHack and State.Jump or 50
        char.Humanoid.UseJumpPower = true
        if State.Wallhack then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if State.ESP then
                if not p.Character:FindFirstChild("ZelikaESP") then local h = Instance.new("Highlight", p.Character); h.Name = "ZelikaESP"; h.FillColor = THEME.Accent end
            elseif p.Character:FindFirstChild("ZelikaESP") then p.Character.ZelikaESP:Destroy() end
        end
    end
end)

-- // FLY LÓGICA //
local bv, bg
function ToggleFly(v)
    State.Fly = v; local char = LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end; FlyControls.Visible = v 
    if v then
        bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.new(0,0,0)
        bg = Instance.new("BodyGyro", char.HumanoidRootPart); bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9); bg.P = 10000; bg.CFrame = char.HumanoidRootPart.CFrame
        task.spawn(function()
            while State.Fly do RunService.RenderStepped:Wait(); if not bv or not bg then break end; bg.CFrame = Camera.CFrame
                local finalVelocity = char.Humanoid.MoveDirection * State.FlySpeed
                if State.FlyingUp then finalVelocity = finalVelocity + Vector3.new(0, State.FlySpeed, 0) end
                if State.FlyingDown then finalVelocity = finalVelocity + Vector3.new(0, -State.FlySpeed, 0) end
                bv.Velocity = finalVelocity; char.Humanoid.PlatformStand = true end
        end)
    else if bv then bv:Destroy() end; if bg then bg:Destroy() end; if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end end
end
