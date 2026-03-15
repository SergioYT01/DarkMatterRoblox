--[[
    PANEL DARKMATTER v4.0 (CLEAN EDITION)
    Universal Script | Premium UI Edition (PC & Mobile)
    Modificación: ESP BOX + LINEA + VIDA + NOMBRE + DISTANCIA + X-RAY + RGB ESP.
    Update: ESP Highlight Separado (Bordes / Relleno) + Rapid Fire + Mobile Aim Fix + Silent Aim.
    Custom: Rivals Special Features + Aimbot Target Selection.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ScriptRunning = true 

-- Detección de Rivals
local IsRivals = (game.PlaceId == 17625359962 or game.PlaceId == 11349125045)

-- Variable global interna para el Hook de Aimbot
local CurrentTargetPart = nil

-- // VARIABLES DE ESTADO //
local State = {
    SavedCFrame = nil,
    Wallhack = false,
    ESP = false, -- Ahora es solo BORDES
    ESPRelleno = false, -- NUEVA OPCIÓN: Solo relleno
    ESPBox = false,
    ESPLine = false, 
    ESPInfo = false, 
    ESPHealth = false, 
    RGBESP = false,
    ESPVisibilityColor = false,
    XRay = false, 
    XRayTransparency = 0.5, 
    AimbotMobile = false,
    SilentAim = false, -- NUEVA OPCIÓN: Silent Aim
    AimbotMode = IsRivals and "DIRECTO" or "DISIMULADO", -- Por defecto directo en Rivals
    TargetPart = "CABEZA", -- NUEVA OPCIÓN: CABEZA, PECHO, ALEATORIO
    RapidFire = false, -- NUEVA OPCIÓN: Rapid Fire
    TeamCheck = false,
    WallCheck = true,
    DistanceCheck = true,
    ShowFOV = false,
    FOVSize = 150,
    FieldOfView = 70,
    Fly = false,
    FlySpeed = 50,
    SpeedHack = false,
    Speed = 50,
    JumpHack = false,
    MultiJump = false,
    Jump = 100,
    SpinHack = false,
    SpinSpeed = 10,
    IsMinimized = false,
    PanelVisible = true,
    FlyingUp = false,
    FlyingDown = false,
    Orbiting = false,
    OrbitTarget = nil,
    OrbitSpeed = 5,
    OrbitDistance = 5,
    OrbitAngle = 0,
    BackTP = false,
    BackTPTarget = nil,
    MagicBullets = false,
    ShowHitbox = true,
    HitboxSize = 15,
    HitboxTransparency = 0.7,
    HitboxColor = Color3.fromRGB(170, 0, 255)
}

-- // COLORES Y TEMA DARKMATTER //
local THEME = {
    Background = Color3.fromRGB(10, 10, 12),
    TopBar = Color3.fromRGB(20, 0, 40),
    Accent = Color3.fromRGB(170, 0, 255),
    Text = Color3.fromRGB(255, 255, 255),
    ElementBG = Color3.fromRGB(25, 25, 30),
    Danger = Color3.fromRGB(255, 0, 50),
    Success = Color3.fromRGB(0, 255, 100)
}

-- // FUNCIÓN DE COLOR RGB //
local function GetRGB()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

-- // TABLAS PARA LIBRERÍA DRAWING //
local Tracers = {}
local Labels = {}
local HealthBars = {}
local XRayParts = {} 
local OriginalFireRates = {} -- TABLA PARA RESTAURAR VELOCIDAD ORIGINAL

local function CreateDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

-- // CREACIÓN DE LA UI PRINCIPAL //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkMatter_V4"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local BoxFolder = Instance.new("Folder", ScreenGui)
BoxFolder.Name = "ESP_Boxes"

-- // BOTONES DE VUELO //
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
FOVFrame.Name = "DarkMatterFOV"
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
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = THEME.Accent; MainFrame.UIStroke.Thickness = 2

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = THEME.TopBar
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = THEME.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Text = "DARKMATTER v4.0"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -115, 0, 5)
MinBtn.BackgroundColor3 = THEME.ElementBG; MinBtn.TextColor3 = THEME.Accent; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18; MinBtn.Text = "▲"; MinBtn.Parent = TitleBar; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(1, -75, 0, 5)
HideBtn.BackgroundColor3 = THEME.ElementBG; HideBtn.TextColor3 = Color3.fromRGB(255, 255, 0); HideBtn.Font = Enum.Font.GothamBold; HideBtn.TextSize = 18; HideBtn.Text = "O"; HideBtn.Parent = TitleBar; Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = THEME.ElementBG; CloseBtn.TextColor3 = THEME.Danger; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.Text = "X"; CloseBtn.Parent = TitleBar; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local GhostBtn = Instance.new("TextButton")
GhostBtn.Size = UDim2.new(0, 30, 0, 30)
GhostBtn.Position = UDim2.new(0.5, 125, 0.5, -170)
GhostBtn.BackgroundTransparency = 1; GhostBtn.Text = ""; GhostBtn.ZIndex = 999
GhostBtn.Parent = ScreenGui

local function ToggleVisibility(visible)
    State.PanelVisible = visible
    MainFrame.Visible = visible
    if State.Fly then FlyControls.Visible = visible else FlyControls.Visible = false end
    GhostBtn.Visible = not visible
end

HideBtn.MouseButton1Click:Connect(function() ToggleVisibility(false) end)
GhostBtn.MouseButton1Click:Connect(function() ToggleVisibility(true) end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = THEME.Accent
Container.Parent = MainFrame
local UIList = Instance.new("UIListLayout"); UIList.Parent = Container; UIList.Padding = UDim.new(0, 8); UIList.SortOrder = Enum.SortOrder.LayoutOrder 

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

-- // SISTEMA DE CATEGORÍAS (TABS) //
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = THEME.TopBar
TabBar.Parent = MainFrame

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabBar

local currentActiveTab = "COMBATE"
local CategoryFrames = {}

local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.20, 0, 1, 0)
    btn.BackgroundColor3 = THEME.TopBar
    btn.Text = name
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = TabBar

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = THEME.Accent
    stroke.Thickness = 1

    btn.MouseButton1Click:Connect(function()
        currentActiveTab = name
        for tabName, tabBtn in pairs(CategoryFrames) do
            if tabName == name then
                tabBtn.BackgroundColor3 = THEME.Accent
                tabBtn.TextColor3 = THEME.TopBar
            else
                tabBtn.BackgroundColor3 = THEME.TopBar
                tabBtn.TextColor3 = THEME.Text
            end
        end
        if _G.UpdateCategoryVisibility then _G.UpdateCategoryVisibility() end
    end)

    CategoryFrames[name] = btn
    return btn
end

CreateTab("COMBATE", 1)
CreateTab("VISUALES", 2)
CreateTab("MOVIMIENTO", 3)
CreateTab("MISC", 4)
CreateTab("INFORMACIÓN", 5)

-- Ajustar el contenedor original sin borrar código
Container.Size = UDim2.new(1, -20, 1, -80)
Container.Position = UDim2.new(0, 10, 0, 75)

-- // VENTANA DE CIERRE //
local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.new(0, 280, 0, 140)
ConfirmFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
ConfirmFrame.BackgroundColor3 = THEME.Background; ConfirmFrame.Visible = false; ConfirmFrame.ZIndex = 100; ConfirmFrame.Parent = ScreenGui; Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 10)
local ConfirmStroke = Instance.new("UIStroke", ConfirmFrame); ConfirmStroke.Color = THEME.Accent; ConfirmStroke.Thickness = 2

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.Size = UDim2.new(1, 0, 0, 70); ConfirmTitle.BackgroundTransparency = 1; ConfirmTitle.Text = "¿Cerrar DARKMATTER?\n(Se desactivarán todos los procesos)"; ConfirmTitle.TextColor3 = THEME.Text; ConfirmTitle.Font = Enum.Font.GothamBold; ConfirmTitle.TextSize = 14; ConfirmTitle.ZIndex = 101; ConfirmTitle.Parent = ConfirmFrame

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.new(0, 110, 0, 40); YesBtn.Position = UDim2.new(0, 20, 1, -55); YesBtn.BackgroundColor3 = THEME.Accent; YesBtn.Text = "SÍ, CERRAR"; YesBtn.TextColor3 = THEME.Text; YesBtn.Font = Enum.Font.GothamBold; YesBtn.ZIndex = 101; YesBtn.Parent = ConfirmFrame; Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

local NoBtn = Instance.new("TextButton")
NoBtn.Size = UDim2.new(0, 110, 0, 40); NoBtn.Position = UDim2.new(1, -130, 1, -55); NoBtn.BackgroundColor3 = THEME.ElementBG; NoBtn.Text = "CANCELAR"; NoBtn.TextColor3 = THEME.Text; NoBtn.Font = Enum.Font.GothamBold; NoBtn.ZIndex = 101; NoBtn.Parent = ConfirmFrame; Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

-- // FUNCIÓN DE LIMPIEZA DE VISUALES //
local function ClearAllVisuals()
    BoxFolder:ClearAllChildren()
    for p, _ in pairs(Tracers) do if Tracers[p] then Tracers[p]:Remove(); Tracers[p] = nil end end
    for p, _ in pairs(Labels) do if Labels[p] then Labels[p]:Remove(); Labels[p] = nil end end
    for p, _ in pairs(HealthBars) do if HealthBars[p] then HealthBars[p]:Remove(); HealthBars[p] = nil end end
    FOVFrame.Visible = false
    for part, original in pairs(XRayParts) do
        if part then part.LocalTransparencyModifier = original end
    end
    XRayParts = {}
end

-- // FUNCIONES CORE FLY //
local bv, bg
local function ToggleFly(v)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        FlyControls.Visible = false
        return 
    end
    FlyControls.Visible = (v and State.PanelVisible)
    if v then
        bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0,0,0)
        bg = Instance.new("BodyGyro", char.HumanoidRootPart)
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 10000
        bg.CFrame = char.HumanoidRootPart.CFrame
        task.spawn(function()
            while State.Fly and ScriptRunning do 
                RunService.RenderStepped:Wait()
                if not bv or not bg or not char.HumanoidRootPart then break end
                bg.CFrame = Camera.CFrame
                local finalVelocity = char.Humanoid.MoveDirection * State.FlySpeed
                if State.FlyingUp then finalVelocity = finalVelocity + Vector3.new(0, State.FlySpeed, 0) end
                if State.FlyingDown then finalVelocity = finalVelocity + Vector3.new(0, -State.FlySpeed, 0) end
                bv.Velocity = finalVelocity
                char.Humanoid.PlatformStand = true 
            end
        end)
    else 
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end 
    end
end

UserInputService.JumpRequest:Connect(function()
    if State.MultiJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    if State.Fly then
        task.wait(0.5)
        ToggleFly(true)
    end
end)

local function ResetAllStates()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
        end
    end
    
    -- Restablecer Fire Rates al cerrar el panel
    local ItemsModule = game:GetService("ReplicatedStorage"):FindFirstChild("Modules") and game:GetService("ReplicatedStorage").Modules:FindFirstChild("ItemLibrary")
    if ItemsModule then
        local Items = require(ItemsModule).Items
        for id, data in pairs(Items) do
            if typeof(data) == "table" and OriginalFireRates[id] then
                data.ShootCooldown = OriginalFireRates[id].sc
                data.ShootBurstCooldown = OriginalFireRates[id].sbc
            end
        end
    end
    
    ClearAllVisuals()
    ToggleFly(false)
    Camera.FieldOfView = 70
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if hrp:FindFirstChild("MagicESP") then hrp.MagicESP:Destroy() end
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 1
        end
        if p.Character and p.Character:FindFirstChild("DarkESP") then
            p.Character.DarkESP:Destroy()
        end
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 16
        char.Humanoid.JumpPower = 50
        char.Humanoid.PlatformStand = false
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function ShutdownPanel()
    ScriptRunning = false 
    ResetAllStates()
    ScreenGui:Destroy()
end

CloseBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
NoBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)
YesBtn.MouseButton1Click:Connect(function() ShutdownPanel() end)

MinBtn.MouseButton1Click:Connect(function()
    State.IsMinimized = not State.IsMinimized
    if State.IsMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 400, 0, 40)}):Play()
        MinBtn.Text = "▼"; Container.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 400, 0, 350)}):Play()
        MinBtn.Text = "▲"; task.delay(0.1, function() Container.Visible = true end)
    end
end)

local function MakeDraggable(guiObject, target)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = target.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y); GhostBtn.Position = target.Position + UDim2.new(0, 325, 0, 5) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
MakeDraggable(TitleBar, MainFrame)

local layoutIdx = 0
local function getNextOrder() layoutIdx = layoutIdx + 1; return layoutIdx end

local function CreateToggle(text, stateKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40); Frame.BackgroundColor3 = THEME.ElementBG; Frame.Parent = Container; Frame.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Lbl = Instance.new("TextLabel"); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = THEME.Text; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
    local Switch = Instance.new("TextButton"); Switch.Text = ""; Switch.Size = UDim2.new(0, 40, 0, 20); Switch.Position = UDim2.new(1, -50, 0.5, -10); Switch.BackgroundColor3 = State[stateKey] and THEME.Accent or Color3.fromRGB(50,50,50); Switch.Parent = Frame; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0, 16, 0, 16); Dot.Position = State[stateKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); Dot.BackgroundColor3 = THEME.Text; Dot.Parent = Switch; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    Switch.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State[stateKey] and THEME.Accent or Color3.fromRGB(50,50,50)}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State[stateKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        if callback then callback(State[stateKey]) end
    end)
    return Frame
end

local function CreateSlider(text, min, max, default, callback, parent)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 55); Frame.BackgroundColor3 = THEME.ElementBG; Frame.Parent = parent or Container; Frame.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Lbl = Instance.new("TextLabel"); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(0.5, 0, 0, 25); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = THEME.Text; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
    local Val = Instance.new("TextLabel"); Val.Text = tostring(default); Val.Size = UDim2.new(0.5, -10, 0, 25); Val.Position = UDim2.new(0.5, 0, 0, 0); Val.BackgroundTransparency = 1; Val.TextColor3 = THEME.Accent; Val.Font = Enum.Font.Code; Val.TextXAlignment = Enum.TextXAlignment.Right; Val.Parent = Frame
    local BarBG = Instance.new("Frame"); BarBG.Size = UDim2.new(1, -20, 0, 6); BarBG.Position = UDim2.new(0, 10, 0, 35); BarBG.BackgroundColor3 = Color3.fromRGB(40,40,40); BarBG.Parent = Frame; Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)
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

local function CreateButton(text, callback, parent)
    local Btn = Instance.new("TextButton")
    Btn.Text = text; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.BackgroundColor3 = THEME.ElementBG; Btn.TextColor3 = THEME.Text; Btn.Font = Enum.Font.GothamBold; Btn.Parent = parent or Container; Btn.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() callback() end)
    return Btn
end

-- // SECCIONES DE INTERFAZ //
local Section1 = Instance.new("TextLabel"); Section1.Text = "  COMBATE & VISUALES"; Section1.Size = UDim2.new(1,0,0,20); Section1.TextColor3 = THEME.Accent; Section1.BackgroundTransparency = 1; Section1.Font = Enum.Font.GothamBlack; Section1.Parent = Container; Section1.LayoutOrder = getNextOrder()

CreateToggle("📦 ESP BOX (DARK)", "ESPBox", function(v) if not v then BoxFolder:ClearAllChildren() end end)
CreateToggle("📏 ESP DISTANCIA & NOMBRE", "ESPInfo", nil)
CreateToggle("❤️ ESP BARRA DE VIDA", "ESPHealth", nil)
CreateToggle("🚩 ESP LÍNEA (TOP)", "ESPLine", nil)
CreateToggle("👁️ ESP BORDES (HIGHLIGHT)", "ESP", nil)
CreateToggle("✨ ESP RELLENO (SIN BORDES)", "ESPRelleno", nil)
CreateToggle("👓 X-RAY (VER A TRAVÉS DE PAREDES)", "XRay", function(v) 
    if not v then ClearAllVisuals() end 
end)

local SectionVisualConfig = Instance.new("TextLabel"); SectionVisualConfig.Text = "  CONFIGURACIÓN DE VISUALES"; SectionVisualConfig.Size = UDim2.new(1,0,0,20); SectionVisualConfig.TextColor3 = THEME.Accent; SectionVisualConfig.BackgroundTransparency = 1; SectionVisualConfig.Font = Enum.Font.GothamBlack; SectionVisualConfig.Parent = Container; SectionVisualConfig.LayoutOrder = getNextOrder()
CreateToggle("🌈 RGB ESP (MODO ARCOÍRIS)", "RGBESP", nil)
CreateToggle("🟢/🔴 VISIBILIDAD (VERDE/ROJO)", "ESPVisibilityColor", nil)

CreateSlider("TRANSPARENCIA X-RAY", 10, 100, State.XRayTransparency * 100, function(v) 
    State.XRayTransparency = v/100 
    if State.XRay then
        for part, _ in pairs(XRayParts) do
            if part then part.LocalTransparencyModifier = State.XRayTransparency end
        end
    end
end)

CreateSlider("CAMPO DE VISIÓN (FOV)", 30, 120, State.FieldOfView, function(v) 
    State.FieldOfView = v
    if Camera then Camera.FieldOfView = v end
end)

local SectionMagic = Instance.new("TextLabel"); SectionMagic.Text = "  DARK BULLETS (HITBOX)"; SectionMagic.Size = UDim2.new(1,0,0,20); SectionMagic.TextColor3 = THEME.Accent; SectionMagic.BackgroundTransparency = 1; SectionMagic.Font = Enum.Font.GothamBlack; SectionMagic.Parent = Container; SectionMagic.LayoutOrder = getNextOrder()
CreateToggle("🔮 ACTIVAR MAGIC BULLETS", "MagicBullets", nil)
CreateToggle("👁️ MOSTRAR HITBOX GIGANTE", "ShowHitbox", nil)
CreateSlider("TAMAÑO DE HITBOX", 2, 50, State.HitboxSize, function(v) State.HitboxSize = v end)
CreateSlider("TRANSPARENCIA (%)", 0, 100, State.HitboxTransparency * 100, function(v) State.HitboxTransparency = v/100 end)

-- AIMBOTS
CreateToggle("📱 AIMBOT (MOBILE - Auto Lock)", "AimbotMobile", nil)
CreateToggle("🎯 SILENT AIM (Sin Mover Cámara)", "SilentAim", nil)

-- SELECCIÓN DE PARTE DEL CUERPO
local BodyPartFrame = Instance.new("Frame"); BodyPartFrame.Size = UDim2.new(1, -10, 0, 40); BodyPartFrame.BackgroundColor3 = THEME.ElementBG; BodyPartFrame.Parent = Container; BodyPartFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", BodyPartFrame).CornerRadius = UDim.new(0, 6)
local BPLbl = Instance.new("TextLabel"); BPLbl.Text = " OBJETIVO:"; BPLbl.Size = UDim2.new(0.4, 0, 1, 0); BPLbl.BackgroundTransparency = 1; BPLbl.TextColor3 = THEME.Text; BPLbl.Font = Enum.Font.GothamSemibold; BPLbl.TextXAlignment = Enum.TextXAlignment.Left; BPLbl.Parent = BodyPartFrame
local BPBtn = Instance.new("TextButton"); BPBtn.Size = UDim2.new(0.55, 0, 0.7, 0); BPBtn.Position = UDim2.new(0.42, 0, 0.15, 0); BPBtn.BackgroundColor3 = THEME.TopBar; BPBtn.Text = State.TargetPart; BPBtn.TextColor3 = THEME.Accent; BPBtn.Font = Enum.Font.GothamBold; BPBtn.TextSize = 12; BPBtn.Parent = BodyPartFrame; Instance.new("UICorner", BPBtn).CornerRadius = UDim.new(0, 4)
local BPModes = {"CABEZA", "PECHO", "ALEATORIO"}
local currentBPIdx = 1
BPBtn.MouseButton1Click:Connect(function() currentBPIdx = currentBPIdx + 1; if currentBPIdx > #BPModes then currentBPIdx = 1 end; State.TargetPart = BPModes[currentBPIdx]; BPBtn.Text = State.TargetPart end)

-- OPCIÓN: Rapid Fire exclusiva de Rivals
if IsRivals then
    CreateToggle("🔥 RAPID FIRE", "RapidFire", nil)
end

-- Selección de modo para AIMBOT (SOLO SI NO ES RIVALS)
if not IsRivals then
    local ModeFrame = Instance.new("Frame"); ModeFrame.Size = UDim2.new(1, -10, 0, 40); ModeFrame.BackgroundColor3 = THEME.ElementBG; ModeFrame.Parent = Container; ModeFrame.LayoutOrder = getNextOrder()
    Instance.new("UICorner", ModeFrame).CornerRadius = UDim.new(0, 6)
    local ModeLabel = Instance.new("TextLabel"); ModeLabel.Text = " TIPO DE AIMBOT:"; ModeLabel.Size = UDim2.new(0.4, 0, 1, 0); ModeLabel.BackgroundTransparency = 1; ModeLabel.TextColor3 = THEME.Text; ModeLabel.Font = Enum.Font.GothamSemibold; ModeLabel.TextXAlignment = Enum.TextXAlignment.Left; ModeLabel.Parent = ModeFrame
    local ModeBtn = Instance.new("TextButton"); ModeBtn.Size = UDim2.new(0.55, 0, 0.7, 0); ModeBtn.Position = UDim2.new(0.42, 0, 0.15, 0); ModeBtn.BackgroundColor3 = THEME.TopBar; ModeBtn.Text = State.AimbotMode; ModeBtn.TextColor3 = THEME.Accent; ModeBtn.Font = Enum.Font.GothamBold; ModeBtn.TextSize = 12; ModeBtn.Parent = ModeFrame; Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 4)
    local AimModes = {"DISIMULADO", "DIRECTO", "SUAVE"}
    local currentModeIdx = 1
    ModeBtn.MouseButton1Click:Connect(function() currentModeIdx = currentModeIdx + 1; if currentModeIdx > #AimModes then currentModeIdx = 1 end; State.AimbotMode = AimModes[currentModeIdx]; ModeBtn.Text = State.AimbotMode end)
end

CreateToggle("🔍 WALL CHECK", "WallCheck", nil)
CreateToggle("📏 DISTANCE CHECK", "DistanceCheck", nil)
CreateToggle("🛡️ TEAM CHECK", "TeamCheck", nil)
CreateToggle("⭕ MOSTRAR FOV", "ShowFOV", function(v) FOVFrame.Visible = v end)
CreateSlider("Tamaño del FOV", 50, 400, State.FOVSize, function(val) State.FOVSize = val; FOVFrame.Size = UDim2.new(0, val*2, 0, val*2) end)

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
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then local pBtn = Instance.new("TextButton"); pBtn.Size = UDim2.new(1, 0, 0, 20); pBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); pBtn.Text = p.Name; pBtn.TextColor3 = THEME.Text; pBtn.Font = Enum.Font.Gotham; pBtn.TextSize = 12; pBtn.Parent = OrbitScroll; Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4); pBtn.MouseButton1Click:Connect(function() State.OrbitTarget = p; State.Orbiting = true; if _G.OrbitContainer then _G.OrbitContainer.Visible = true end end) end end
end
UpdateOrbitList(); Players.PlayerAdded:Connect(UpdateOrbitList); Players.PlayerRemoving:Connect(UpdateOrbitList)
CreateSlider("Distancia", 2, 50, State.OrbitDistance, function(v) State.OrbitDistance = v end, OrbitGroup)
CreateSlider("Velocidad Giro", 1, 50, State.OrbitSpeed, function(v) State.OrbitSpeed = v end, OrbitGroup)

local Section2 = Instance.new("TextLabel"); Section2.Text = "  MOVIMIENTO & TP"; Section2.Size = UDim2.new(1,0,0,20); Section2.TextColor3 = THEME.Accent; Section2.BackgroundTransparency = 1; Section2.Font = Enum.Font.GothamBlack; Section2.Parent = Container; Section2.LayoutOrder = getNextOrder()
CreateToggle("🧱 WALLHACK", "Wallhack", function(v)
    if not v and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)
CreateToggle("🕊️ FLY HACK", "Fly", function(v) ToggleFly(v) end)
CreateSlider("Vel. Vuelo", 10, 300, State.FlySpeed, function(val) State.FlySpeed = val end)
CreateToggle("⚡ SPEED HACK", "SpeedHack", nil)
CreateSlider("Velocidad", 16, 250, State.Speed, function(val) State.Speed = val end)
CreateToggle("🐰 JUMP HACK", "JumpHack", function(v)
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)
CreateToggle("⏫ MULTI-JUMP", "MultiJump", nil)
CreateSlider("Salto", 50, 500, State.Jump, function(val) State.Jump = val end)
CreateToggle("🌀 SPIN HACK", "SpinHack", nil)
CreateSlider("Vel. Spin", 1, 50, State.SpinSpeed, function(val) State.SpinSpeed = val end)
CreateToggle("🔙 TELETRANSPORTAR TRASERO", "BackTP", function(v) if not v then State.BackTPTarget = nil end end)
CreateButton("📍 GUARDAR POSICIÓN", function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then State.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end end)
CreateButton("🚀 TELETRANSPORTAR", function() if State.SavedCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = State.SavedCFrame end end)

-- // SECCIÓN DE INFORMACIÓN //
local SectionInfo = Instance.new("TextLabel"); SectionInfo.Text = "  ESTADÍSTICAS DEL PANEL"; SectionInfo.Size = UDim2.new(1,0,0,20); SectionInfo.TextColor3 = THEME.Accent; SectionInfo.BackgroundTransparency = 1; SectionInfo.Font = Enum.Font.GothamBlack; SectionInfo.Parent = Container; SectionInfo.LayoutOrder = getNextOrder()

local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, -10, 0, 40); InfoFrame.BackgroundColor3 = THEME.ElementBG; InfoFrame.Parent = Container; InfoFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 6)

local KeysLabel = Instance.new("TextLabel"); KeysLabel.Text = "KEYS ACTIVAS: Cargando..."; KeysLabel.Size = UDim2.new(1, -20, 1, 0); KeysLabel.Position = UDim2.new(0, 10, 0, 0); KeysLabel.BackgroundTransparency = 1; KeysLabel.TextColor3 = THEME.Success; KeysLabel.Font = Enum.Font.GothamBold; KeysLabel.TextXAlignment = Enum.TextXAlignment.Left; KeysLabel.Parent = InfoFrame

local function parseDate(str)
    local Y, M, D, h, m, s = str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if Y then return os.time({year=Y, month=M, day=D, hour=h, min=m, sec=s}) end
    return 0
end

task.spawn(function()
    while ScriptRunning do
        local success, result = pcall(function()
            local url = "https://key-sistem-roblox-dm-default-rtdb.firebaseio.com/keys.json"
            local HttpService = game:GetService("HttpService")
            local req = game:HttpGet(url)
            local data = HttpService:JSONDecode(req)
            local activeCount = 0
            local currentTime = os.time()
            for k, v in pairs(data) do
                if type(v) == "table" and v.expira then
                    local expTime = parseDate(v.expira)
                    if expTime > currentTime then
                        activeCount = activeCount + 1
                    end
                end
            end
            return activeCount
        end)
        
        if success then
            KeysLabel.Text = "KEYS ACTIVAS: " .. tostring(result)
        else
            KeysLabel.Text = "KEYS ACTIVAS: Error..."
        end
        task.wait(5)
    end
end)

-- // ASIGNACIÓN DE ELEMENTOS A CATEGORÍAS //
local ElementCategoryMap = {}

local function AssignCat(matchText, category)
    for _, child in pairs(Container:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            local itemText = ""
            if child:IsA("TextButton") then
                itemText = child.Text
            else
                local lbl = child:FindFirstChildOfClass("TextLabel")
                if lbl then itemText = lbl.Text end
            end

            if itemText ~= "" and string.find(itemText, matchText, 1, true) then
                ElementCategoryMap[child] = category
            end
        end
    end
end

AssignCat("ESP BOX", "VISUALES")
AssignCat("ESP DISTANCIA", "VISUALES")
AssignCat("ESP BARRA", "VISUALES")
AssignCat("ESP LÍNEA", "VISUALES")
AssignCat("ESP BORDES", "VISUALES")
AssignCat("ESP RELLENO", "VISUALES")
AssignCat("X-RAY", "VISUALES")
AssignCat("RGB ESP", "VISUALES")
AssignCat("VISIBILIDAD", "VISUALES")
AssignCat("TRANSPARENCIA X-RAY", "VISUALES")
AssignCat("CAMPO DE VISIÓN", "VISUALES")

AssignCat("MAGIC BULLETS", "COMBATE")
AssignCat("MOSTRAR HITBOX", "COMBATE")
AssignCat("TAMAÑO DE HITBOX", "COMBATE")
AssignCat("TRANSPARENCIA (%)", "COMBATE")
AssignCat("AIMBOT (MOBILE", "COMBATE")
AssignCat("SILENT AIM", "COMBATE")
AssignCat("OBJETIVO:", "COMBATE")
AssignCat("RAPID FIRE", "COMBATE")
AssignCat("TIPO DE AIMBOT", "COMBATE")
AssignCat("MOSTRAR FOV", "COMBATE")
AssignCat("Tamaño del FOV", "COMBATE")

AssignCat("WALLHACK", "MOVIMIENTO")
AssignCat("FLY HACK", "MOVIMIENTO")
AssignCat("Vel. Vuelo", "MOVIMIENTO")
AssignCat("SPEED HACK", "MOVIMIENTO")
AssignCat("Velocidad", "MOVIMIENTO")
AssignCat("JUMP HACK", "MOVIMIENTO")
AssignCat("MULTI-JUMP", "MOVIMIENTO")
AssignCat("Salto", "MOVIMIENTO")
AssignCat("SPIN HACK", "MOVIMIENTO")
AssignCat("Vel. Spin", "MOVIMIENTO")

AssignCat("TELETRANSPORTAR TRASERO", "MISC")
AssignCat("GUARDAR POSICIÓN", "MISC")
AssignCat("🚀 TELETRANSPORTAR", "MISC")
AssignCat("WALL CHECK", "MISC")
AssignCat("DISTANCE CHECK", "MISC")
AssignCat("TEAM CHECK", "MISC")
AssignCat("ACTIVAR ÓRBITA", "MISC")

AssignCat("KEYS ACTIVAS", "INFORMACIÓN")

if Container:FindFirstChild("OrbitGroup") then 
    ElementCategoryMap[Container.OrbitGroup] = "MISC" 
end

for _, child in pairs(Container:GetChildren()) do
    if child:IsA("TextLabel") and (string.find(child.Text, "COMBATE & VISUALES") or string.find(child.Text, "CONFIGURACIÓN DE VISUALES") or string.find(child.Text, "DARK BULLETS") or string.find(child.Text, "SISTEMA DE ÓRBITA") or string.find(child.Text, "MOVIMIENTO & TP") or string.find(child.Text, "ESTADÍSTICAS DEL PANEL")) then
        child.Visible = false
    end
end

_G.UpdateCategoryVisibility = function()
    for element, category in pairs(ElementCategoryMap) do
        if category == currentActiveTab then
            if element == _G.OrbitContainer then
                element.Visible = State.Orbiting
            else
                element.Visible = true
            end
        else
            element.Visible = false
        end
    end
end

if CategoryFrames["COMBATE"] then
    CategoryFrames["COMBATE"].BackgroundColor3 = THEME.Accent
    CategoryFrames["COMBATE"].TextColor3 = THEME.TopBar
end
_G.UpdateCategoryVisibility()

-- // FUNCIONES CORE //
local function IsVisible(part)
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return not result
end

-- Determinar parte de cuerpo dinámicamente
local function GetTargetPart(char)
    if not char then return nil end
    if State.TargetPart == "CABEZA" then return char:FindFirstChild("Head")
    elseif State.TargetPart == "PECHO" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else -- ALEATORIO
        local parts = {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")}
        return parts[math.random(1, 2)]
    end
end

local function GetClosestPlayer()
    local closest, shortestMetric = nil, math.huge
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if State.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if State.WallCheck and not IsVisible(v.Character.Head) then continue end
            local part = GetTargetPart(v.Character) or v.Character.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local screenDist = (Vector2.new(headPos.X, headPos.Y) - centerPos).Magnitude
                if screenDist < State.FOVSize then
                    if State.DistanceCheck then
                        local worldDist = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if worldDist < shortestMetric then shortestMetric = worldDist; closest = part end
                    else
                        if screenDist < shortestMetric then shortestMetric = screenDist; closest = part end
                    end
                end
            end
        end
    end
    return closest
end

-- // RENDER LOOP //
RunService.RenderStepped:Connect(function(dt)
    if not ScriptRunning then return end 
    
    local target = GetClosestPlayer()

    local fovColorTarget = nil
    local anyVisiblePlayer = false
    
    if State.ESPVisibilityColor then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                if State.TeamCheck and v.Team == LocalPlayer.Team then continue end
                
                local isPlayerVisible = IsVisible(v.Character.Head)
                if isPlayerVisible then
                    anyVisiblePlayer = true
                end
                
                local headPos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                    if screenDist < State.FOVSize then
                        fovColorTarget = v.Character.Head
                    end
                end
            end
        end
    end
    
    local function GetESPColor(targetPart)
        if State.RGBESP then return GetRGB() end
        if State.ESPVisibilityColor then
            return IsVisible(targetPart) and THEME.Success or THEME.Danger
        end
        return THEME.Accent
    end
    
    FOVFrame.Visible = State.ShowFOV and State.PanelVisible
    FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local currentFOVColor = THEME.Accent
    if State.RGBESP then 
        currentFOVColor = GetRGB() 
    elseif State.ESPVisibilityColor then
        if anyVisiblePlayer then
            currentFOVColor = THEME.Success
        else
            currentFOVColor = THEME.Danger
        end
    end
    FOVStroke.Color = currentFOVColor
    
    if State.XRay then
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Camera) then
                local isCharacter = obj.Parent and obj.Parent:FindFirstChild("Humanoid")
                if not isCharacter and not XRayParts[obj] then
                    XRayParts[obj] = obj.LocalTransparencyModifier
                    obj.LocalTransparencyModifier = State.XRayTransparency
                end
            end
        end
    else
        for part, original in pairs(XRayParts) do
            if part then part.LocalTransparencyModifier = original end
        end
        XRayParts = {}
    end
    
    for p, _ in pairs(Tracers) do
        if not p or not p.Parent then
            if Tracers[p] then Tracers[p]:Remove(); Tracers[p] = nil end
            if Labels[p] then Labels[p]:Remove(); Labels[p] = nil end
            if HealthBars[p] then HealthBars[p]:Remove(); HealthBars[p] = nil end
        end
    end
    
    for _, box in pairs(BoxFolder:GetChildren()) do
        local playerName = box.Name:gsub("_DarkBox", "")
        if not Players:FindFirstChild(playerName) then box:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local char = p.Character
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local espColor = GetESPColor(hrp)
            
            local currentDist = (Camera.CFrame.Position - hrp.Position).Magnitude
            local withinRange = currentDist <= 500
            
            local espVisual = hrp:FindFirstChild("MagicESP")
            if State.MagicBullets then
                hrp.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                hrp.Transparency = 1
                if not espVisual then espVisual = Instance.new("BoxHandleAdornment", hrp); espVisual.Name = "MagicESP"; espVisual.AlwaysOnTop = true; espVisual.Adornee = hrp; espVisual.ZIndex = 10 end
                espVisual.Visible = State.ShowHitbox; espVisual.Size = hrp.Size; espVisual.Color3 = espColor; espVisual.Transparency = State.HitboxTransparency
            else
                hrp.Size = Vector3.new(2, 2, 1)
                if espVisual then espVisual:Destroy() end
            end

            if onScreen and hum.Health > 0 and State.PanelVisible and withinRange then
                if State.TeamCheck and p.Team == LocalPlayer.Team then 
                    if Tracers[p] then Tracers[p].Visible = false end
                    continue 
                end

                local topWorld = (hrp.CFrame * CFrame.new(0, 3, 0)).Position
                local bottomWorld = (hrp.CFrame * CFrame.new(0, -3.5, 0)).Position
                local topPtr = Camera:WorldToViewportPoint(topWorld)
                local bottomPtr = Camera:WorldToViewportPoint(bottomWorld)
                local h = math.abs(topPtr.Y - bottomPtr.Y)
                local w = h / 2

                local boxName = p.Name .. "_DarkBox"
                local box = BoxFolder:FindFirstChild(boxName)
                if State.ESPBox then
                    if not box then box = Instance.new("Frame", BoxFolder); box.Name = boxName; box.BackgroundTransparency = 1; box.BorderSizePixel = 0; local stroke = Instance.new("UIStroke", box); stroke.Thickness = 1.0 end
                    box.UIStroke.Color = espColor
                    box.Position = UDim2.new(0, vector.X - (w/2), 0, vector.Y - (h/2)); box.Size = UDim2.new(0, w, 0, h); box.Visible = true
                elseif box then box.Visible = false end

                if State.ESPLine then
                    local line = Tracers[p] or CreateDrawing("Line", {Thickness = 1})
                    line.Color = espColor
                    Tracers[p] = line
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, 0); line.To = Vector2.new(vector.X, topPtr.Y); line.Visible = true
                elseif Tracers[p] then Tracers[p].Visible = false end

                if State.ESPInfo then
                    local label = Labels[p] or CreateDrawing("Text", {Size = 14, Center = true, Outline = true})
                    label.Color = espColor
                    Labels[p] = label
                    label.Text = string.format("%s\n[%d m]", p.Name, math.floor(currentDist))
                    label.Position = Vector2.new(vector.X, vector.Y - (h/2) - 30); label.Visible = true
                elseif Labels[p] then Labels[p].Visible = false end

                if State.ESPHealth then
                    local bar = HealthBars[p] or CreateDrawing("Line", {Thickness = 2})
                    HealthBars[p] = bar
                    local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    bar.From = Vector2.new(vector.X - (w/2) - 5, vector.Y + (h/2))
                    bar.To = Vector2.new(vector.X - (w/2) - 5, bar.From.Y - (h * hpPct))
                    bar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hpPct); bar.Visible = true
                elseif HealthBars[p] then HealthBars[p].Visible = false end
            else
                if Tracers[p] then Tracers[p].Visible = false end
                if Labels[p] then Labels[p].Visible = false end
                if HealthBars[p] then HealthBars[p].Visible = false end
                local box = BoxFolder:FindFirstChild(p.Name .. "_DarkBox")
                if box then box.Visible = false end
            end
        end
    end

    if State.Orbiting and State.OrbitTarget and State.OrbitTarget.Character and State.OrbitTarget.Character:FindFirstChild("HumanoidRootPart") and State.OrbitTarget.Character.Humanoid.Health > 0 then
        local targetPart = State.OrbitTarget.Character.HumanoidRootPart
        State.OrbitAngle = State.OrbitAngle + (dt * State.OrbitSpeed)
        local offset = Vector3.new(math.cos(State.OrbitAngle) * State.OrbitDistance, 1, math.sin(State.OrbitAngle) * State.OrbitDistance)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position + offset, targetPart.Position)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    elseif State.BackTP then
        if not State.BackTPTarget or not State.BackTPTarget.Character or State.BackTPTarget.Character.Humanoid.Health <= 0 then
            local closest, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; closest = p end
                end
            end
            State.BackTPTarget = closest
        elseif State.BackTPTarget and State.BackTPTarget.Character and State.BackTPTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = State.BackTPTarget.Character.HumanoidRootPart
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 5)
        end
    end

    -- LÓGICA DE AIMBOT (MOBILE) Y SILENT AIM
    if (State.AimbotMobile or State.SilentAim) and not State.Orbiting then
        if target then
            CurrentTargetPart = target
            if State.AimbotMobile then
                local lerpSpeed = (State.AimbotMode == "DISIMULADO" and 0.05) or (State.AimbotMode == "DIRECTO" and 1.0) or 0.25
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), lerpSpeed)
            end
        else
            CurrentTargetPart = nil
        end
    else
        CurrentTargetPart = nil
    end
    
    if State.SpinHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(State.SpinSpeed), 0)
    end
end)

-- // PHYSICS LOOP //
RunService.Stepped:Connect(function()
    if not ScriptRunning then return end 
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = State.SpeedHack and State.Speed or 16
        if State.JumpHack then char.Humanoid.JumpPower = State.Jump; char.Humanoid.UseJumpPower = true end
        if State.Wallhack then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
    end
    
    local ItemsModule = game:GetService("ReplicatedStorage"):FindFirstChild("Modules") and game:GetService("ReplicatedStorage").Modules:FindFirstChild("ItemLibrary")
    if ItemsModule then
        local Items = require(ItemsModule).Items
        if State.RapidFire and IsRivals then
            for id, data in pairs(Items) do
                if typeof(data) == "table" then
                    if not OriginalFireRates[id] then
                        OriginalFireRates[id] = {
                            sc = data.ShootCooldown or 0.6,
                            sbc = data.ShootBurstCooldown or 0.8
                        }
                    end
                    if data.ShootCooldown then data.ShootCooldown = 0.05 end
                    if data.ShootBurstCooldown then data.ShootBurstCooldown = 0.05 end
                end
            end
        else
            for id, data in pairs(Items) do
                if typeof(data) == "table" and OriginalFireRates[id] then
                    data.ShootCooldown = OriginalFireRates[id].sc
                    data.ShootBurstCooldown = OriginalFireRates[id].sbc
                end
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
            local distance = root and (Camera.CFrame.Position - root.Position).Magnitude or 1000
            
            local showHighlight = (State.ESP or State.ESPRelleno) and State.PanelVisible and (distance <= 500)
            
            if showHighlight then
                local espColor = (State.RGBESP and GetRGB()) or (State.ESPVisibilityColor and (IsVisible(p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart) and THEME.Success or THEME.Danger)) or THEME.Accent
                local h = p.Character:FindFirstChild("DarkESP")
                if not h then h = Instance.new("Highlight", p.Character); h.Name = "DarkESP" end
                h.OutlineColor = espColor
                h.FillColor = espColor
                h.OutlineTransparency = State.ESP and 0 or 1
                h.FillTransparency = State.ESPRelleno and 0.5 or 1
            elseif p.Character:FindFirstChild("DarkESP") then 
                p.Character:FindFirstChild("DarkESP"):Destroy() 
            end
        end
    end
end)

-- // IMPLEMENTACIÓN DEL HOOK (MOBILE AIM FIX & SILENT AIM) //
local _idx
_idx = hookmetamethod(game, "__index", newcclosure(function(self, idx, ...)
    if (State.AimbotMobile or State.SilentAim) and CurrentTargetPart and not checkcaller() and idx == "ViewportSize" and self == Camera then
        local pos, on = Camera:WorldToViewportPoint(CurrentTargetPart.Position)
        if on then
            return Vector2.new(pos.X * 2, pos.Y * 2)
        end
    end
    return _idx(self, idx, ...)
end))
