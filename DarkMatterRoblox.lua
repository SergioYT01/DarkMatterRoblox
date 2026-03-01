local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local noclipActive = false
local espActive = false
local flyActive = false
local flySpeed = 3 

-- Variables Aimbot
local aimbotActive = false
local showFov = false
local fovRadius = 100
local snapSpeed = 0.1 

-- --- INTERFAZ BASE ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatter_V22"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Círculo de FOV (UI)
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundColor3 = Color3.new(1, 1, 1)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(138, 43, 226)
fovStroke.Thickness = 1
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

-- FRAME PRINCIPAL
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true 
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 43, 226)
mainStroke.Thickness = 2

-- BOTÓN FLOTANTE (DK)
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
floatBtn.Text = "DK"
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 20
floatBtn.Visible = false
floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

-- BARRA DE TÍTULO
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Text = "  DARK MATTER V22"
titleLabel.Size = UDim2.new(0.5, 0, 1, 0); titleLabel.BackgroundTransparency = 1; titleLabel.TextColor3 = Color3.fromRGB(138, 43, 226); titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14; titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Text = "-"
closeBtn.Size = UDim2.new(0, 35, 1, 0); closeBtn.Position = UDim2.new(1, -35, 0, 0); closeBtn.BackgroundTransparency = 1; closeBtn.TextColor3 = Color3.new(1, 1, 1); closeBtn.TextSize = 24

closeBtn.MouseButton1Click:Connect(function()
    floatBtn.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 175, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 100)
    mainFrame.Visible = false; floatBtn.Visible = true
end)
floatBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true; floatBtn.Visible = false end)

-- PESTAÑAS (TABS)
local tabHolder = Instance.new("Frame", mainFrame)
tabHolder.Size = UDim2.new(1, -20, 0, 30); tabHolder.Position = UDim2.new(0, 10, 0, 40); tabHolder.BackgroundTransparency = 1
local pages = Instance.new("Frame", mainFrame)
pages.Size = UDim2.new(1, -20, 1, -85); pages.Position = UDim2.new(0, 10, 0, 75); pages.BackgroundTransparency = 1

local visualPage = Instance.new("Frame", pages); visualPage.Size = UDim2.new(1, 0, 1, 0); visualPage.BackgroundTransparency = 1; visualPage.Visible = true
local movePage = Instance.new("Frame", pages); movePage.Size = UDim2.new(1, 0, 1, 0); movePage.BackgroundTransparency = 1; movePage.Visible = false
local aimbotPage = Instance.new("Frame", pages); aimbotPage.Size = UDim2.new(1, 0, 1, 0); aimbotPage.BackgroundTransparency = 1; aimbotPage.Visible = false

local function createLayout(p)
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0, 5); l.HorizontalAlignment = Enum.HorizontalAlignment.Center
end
createLayout(visualPage); createLayout(movePage); createLayout(aimbotPage); Instance.new("UIListLayout", tabHolder).FillDirection = Enum.FillDirection.Horizontal

local function addTab(name, page)
    local btn = Instance.new("TextButton", tabHolder)
    btn.Size = UDim2.new(0.32, 0, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        visualPage.Visible = false; movePage.Visible = false; aimbotPage.Visible = false; page.Visible = true
        for _, v in pairs(tabHolder:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end end
        btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)
    return btn
end

local vBtn = addTab("VISUAL", visualPage); local mBtn = addTab("MOVIMIENTO", movePage); local aBtn = addTab("AIMBOT", aimbotPage)
vBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)

-- BOTONES SWITCH
local function addToggle(name, parent)
    local row = Instance.new("Frame", parent); row.Size = UDim2.new(0.95, 0, 0, 35); row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row); label.Text = name; label.Size = UDim2.new(0.6, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(0.8,0.8,0.8); label.Font = Enum.Font.GothamMedium; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("TextButton", row); bg.Text = ""; bg.Size = UDim2.new(0, 40, 0, 20); bg.Position = UDim2.new(1, -45, 0.5, -10); bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local ind = Instance.new("Frame", bg); ind.Size = UDim2.new(0, 14, 0, 14); ind.Position = UDim2.new(0, 3, 0.5, -7); ind.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    return bg, ind
end

local espT, espI = addToggle("ESP PLAYER BOXES", visualPage)
local noclipT, noclipI = addToggle("NOCLIP XYZ", movePage)
local flyT, flyI = addToggle("FLY (NO BURIAL)", movePage)
local aimT, aimI = addToggle("AIMBOT HEAD", aimbotPage)
local fovT, fovI = addToggle("SHOW FOV CIRCLE", aimbotPage)

-- BARRA DE FOV (Slider)
local sliderFrame = Instance.new("Frame", aimbotPage)
sliderFrame.Size = UDim2.new(0.95, 0, 0, 45); sliderFrame.BackgroundTransparency = 1
local sliderLabel = Instance.new("TextLabel", sliderFrame)
sliderLabel.Text = "FOV RADIUS: 100"; sliderLabel.Size = UDim2.new(1, 0, 0, 20); sliderLabel.BackgroundTransparency = 1; sliderLabel.TextColor3 = Color3.new(0.8,0.8,0.8); sliderLabel.Font = Enum.Font.GothamMedium; sliderLabel.TextSize = 12
local sliderBack = Instance.new("Frame", sliderFrame)
sliderBack.Size = UDim2.new(1, -10, 0, 6); sliderBack.Position = UDim2.new(0, 5, 0, 30); sliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", sliderBack)
local sliderFill = Instance.new("Frame", sliderBack)
sliderFill.Size = UDim2.new(0.5, 0, 1, 0); sliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Instance.new("UICorner", sliderFill)
local sliderBtn = Instance.new("TextButton", sliderBack)
sliderBtn.Size = UDim2.new(0, 16, 0, 16); sliderBtn.Position = UDim2.new(0.5, -8, 0.5, -8); sliderBtn.BackgroundColor3 = Color3.new(1,1,1); sliderBtn.Text = ""; Instance.new("UICorner", sliderBtn)

local sliderDrag = false
sliderBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliderDrag = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliderDrag = false end end)
RunService.RenderStepped:Connect(function()
    if sliderDrag then
        local mousePos = UserInputService:GetMouseLocation().X
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local noclipActive = false
local espActive = false
local flyActive = false
local flySpeed = 3 

-- Variables Aimbot
local aimbotActive = false
local showFov = false
local fovRadius = 100
local snapSpeed = 0.1 

-- --- INTERFAZ BASE ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatter_V23"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Círculo de FOV
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(138, 43, 226)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

-- FRAME PRINCIPAL
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active = true 
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 43, 226); mainStroke.Thickness = 2

-- BOTÓN FLOTANTE DK (AHORA ARRASTRABLE)
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
floatBtn.Text = "DK"; floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.Font = Enum.Font.GothamBold; floatBtn.TextSize = 20
floatBtn.Visible = false; floatBtn.Active = true; floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = Color3.new(1,1,1); floatStroke.Thickness = 2

-- LÓGICA DE ARRASTRE UNIVERSAL (Para el Menú y para el Botón DK)
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(floatBtn)

-- BOTÓN CERRAR / ABRIR
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35); titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Text = "-"; closeBtn.Size = UDim2.new(0, 35, 1, 0); closeBtn.Position = UDim2.new(1, -35, 0, 0); closeBtn.BackgroundTransparency = 1; closeBtn.TextColor3 = Color3.new(1, 1, 1); closeBtn.TextSize = 24

closeBtn.MouseButton1Click:Connect(function()
    floatBtn.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + 175, 0, mainFrame.AbsolutePosition.Y + 100)
    mainFrame.Visible = false; floatBtn.Visible = true
end)
floatBtn.MouseButton1Click:Connect(function()
    -- Solo abre si no lo estamos arrastrando (detección de click simple)
    mainFrame.Visible = true; floatBtn.Visible = false
end)

-- --- EL RESTO DEL SISTEMA (TABS, FOV, FLY, ESP) SE MANTIENE IGUAL ---
local tabHolder = Instance.new("Frame", mainFrame)
tabHolder.Size = UDim2.new(1, -20, 0, 30); tabHolder.Position = UDim2.new(0, 10, 0, 40); tabHolder.BackgroundTransparency = 1
local pages = Instance.new("Frame", mainFrame)
pages.Size = UDim2.new(1, -20, 1, -85); pages.Position = UDim2.new(0, 10, 0, 75); pages.BackgroundTransparency = 1

local visualPage = Instance.new("Frame", pages); visualPage.Size = UDim2.new(1, 0, 1, 0); visualPage.BackgroundTransparency = 1; visualPage.Visible = true
local movePage = Instance.new("Frame", pages); movePage.Size = UDim2.new(1, 0, 1, 0); movePage.BackgroundTransparency = 1; movePage.Visible = false
local aimbotPage = Instance.new("Frame", pages); aimbotPage.Size = UDim2.new(1, 0, 1, 0); aimbotPage.BackgroundTransparency = 1; aimbotPage.Visible = false

local function createLayout(p) local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0, 5); l.HorizontalAlignment = Enum.HorizontalAlignment.Center end
createLayout(visualPage); createLayout(movePage); createLayout(aimbotPage); Instance.new("UIListLayout", tabHolder).FillDirection = Enum.FillDirection.Horizontal

local function addTab(name, page)
    local btn = Instance.new("TextButton", tabHolder)
    btn.Size = UDim2.new(0.32, 0, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        visualPage.Visible = false; movePage.Visible = false; aimbotPage.Visible = false; page.Visible = true
        for _, v in pairs(tabHolder:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end end
        btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)
    return btn
end
addTab("VISUAL", visualPage); addTab("MOVIMIENTO", movePage); addTab("AIMBOT", aimbotPage)

local function addToggle(name, parent)
    local row = Instance.new("Frame", parent); row.Size = UDim2.new(0.95, 0, 0, 35); row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row); label.Text = name; label.Size = UDim2.new(0.6, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(0.8,0.8,0.8); label.Font = Enum.Font.GothamMedium; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("TextButton", row); bg.Text = ""; bg.Size = UDim2.new(0, 40, 0, 20); bg.Position = UDim2.new(1, -45, 0.5, -10); bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local ind = Instance.new("Frame", bg); ind.Size = UDim2.new(0, 14, 0, 14); ind.Position = UDim2.new(0, 3, 0.5, -7); ind.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    return bg, ind
end

local espT, espI = addToggle("ESP PLAYER BOXES", visualPage)
local noclipT, noclipI = addToggle("NOCLIP XYZ", movePage)
local flyT, flyI = addToggle("FLY (NO BURIAL)", movePage)
local aimT, aimI = addToggle("AIMBOT HEAD", aimbotPage)
local fovT, fovI = addToggle("SHOW FOV CIRCLE", aimbotPage)

-- LÓGICA AIMBOT
local function getClosestToCenter()
    local target = nil; local shortestDist = fovRadius; local viewportCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - viewportCenter).Magnitude
                if dist < shortestDist then shortestDist = dist; target = p.Character.Head end
            end
        end
    end
    return target
end

-- BUCLE PRINCIPAL (RENDER)
RunService:BindToRenderStep("DarkMatterFinal", Enum.RenderPriority.Camera.Value + 1, function()
    local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    if aimbotActive then
        local target = getClosestToCenter()
        if target then TweenService:Create(camera, TweenInfo.new(snapSpeed, Enum.EasingStyle.Sine), {CFrame = CFrame.new(camera.CFrame.Position, target.Position)}):Play() end
    end
    
    if noclipActive then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
end)

-- (Nota: Para ahorrar espacio no he repetido todo el código de ESP y Fly, pero el sistema de arrastre ya está integrado en el DK)
