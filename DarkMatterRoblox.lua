local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local noclipActive = false
local espActive = false
local wallCheckActive = true 

-- Variables Aimbot
local aimbotActive = false
local showFov = false
local fovRadius = 100
local ignoreFriends = true
local ignoreDead = true

-- Variables Movimiento
local flyActive = false
local flySpeed = 50
local yDirection = 0 -- Dirección vertical para móvil

-- --- INTERFAZ BASE ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatter_V22"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.Parent = player:WaitForChild("PlayerGui")

-- BOTONES DE VUELO (ESPECÍFICOS PARA MÓVIL)
local flyControls = Instance.new("Frame", screenGui)
flyControls.Size = UDim2.new(0, 60, 0, 140)
flyControls.Position = UDim2.new(1, -70, 0.5, -70)
flyControls.BackgroundTransparency = 1
flyControls.Visible = false

local function createFlyBtn(text, pos, dir)
    local btn = Instance.new("TextButton", flyControls)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(138, 43, 226)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 30
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(138, 43, 226)
    stroke.Thickness = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    btn.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            yDirection = dir 
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end 
    end)
    btn.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            yDirection = 0 
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        end 
    end)
end

createFlyBtn("▲", UDim2.new(0,0,0,0), 1)
createFlyBtn("▼", UDim2.new(0,0,0,75), -1)

-- Círculo de FOV
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

-- MENÚ MINIMIZADO
local miniFrame = Instance.new("Frame")
miniFrame.Name = "MiniMenu"
miniFrame.Size = UDim2.new(0, 250, 0, 40)
miniFrame.Position = UDim2.new(0.5, -125, 0.1, 0)
miniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
miniFrame.Visible = false
miniFrame.Active = true
miniFrame.Parent = screenGui
Instance.new("UICorner", miniFrame).CornerRadius = UDim.new(0, 8)
local miniStroke = Instance.new("UIStroke", miniFrame)
miniStroke.Color = Color3.fromRGB(138, 43, 226); miniStroke.Thickness = 2

local miniLabel = Instance.new("TextLabel", miniFrame)
miniLabel.Text = "DARK MATTER"
miniLabel.Size = UDim2.new(0.7, 0, 1, 0)
miniLabel.Position = UDim2.new(0, 15, 0, 0)
miniLabel.BackgroundTransparency = 1
miniLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
miniLabel.Font = Enum.Font.GothamBold
miniLabel.TextSize = 16
miniLabel.TextXAlignment = Enum.TextXAlignment.Left

local expandBtn = Instance.new("TextButton", miniFrame)
expandBtn.Text = "+"
expandBtn.Size = UDim2.new(0, 30, 0, 30)
expandBtn.Position = UDim2.new(1, -35, 0.5, -15)
expandBtn.BackgroundTransparency = 1
expandBtn.TextColor3 = Color3.new(1, 1, 1)
expandBtn.Font = Enum.Font.GothamBold
expandBtn.TextSize = 25

-- FRAME PRINCIPAL
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 400) 
mainFrame.Position = UDim2.new(0.5, -200, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active = true 
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 43, 226); mainStroke.Thickness = 2

-- BARRA DE TÍTULO
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35); titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Text = "  DARK MATTER V22"; titleLabel.Size = UDim2.new(0.5, 0, 1, 0); titleLabel.BackgroundTransparency = 1; titleLabel.TextColor3 = Color3.fromRGB(138, 43, 226); titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Text = "-"; closeBtn.Size = UDim2.new(0, 35, 1, 0); closeBtn.Position = UDim2.new(1, -35, 0, 0); closeBtn.BackgroundTransparency = 1; closeBtn.TextColor3 = Color3.new(1, 1, 1); closeBtn.TextSize = 24

closeBtn.MouseButton1Click:Connect(function()
    miniFrame.Position = mainFrame.Position
    mainFrame.Visible = false; miniFrame.Visible = true
end)
expandBtn.MouseButton1Click:Connect(function()
    mainFrame.Position = miniFrame.Position
    miniFrame.Visible = false; mainFrame.Visible = true
end)

-- PESTAÑAS
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

-- FUNCIONES AUXILIARES
local function addToggle(name, parent)
    local row = Instance.new("Frame", parent); row.Size = UDim2.new(0.95, 0, 0, 35); row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row); label.Text = name; label.Size = UDim2.new(0.6, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(0.8,0.8,0.8); label.Font = Enum.Font.GothamMedium; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("TextButton", row); bg.Text = ""; bg.Size = UDim2.new(0, 40, 0, 20); bg.Position = UDim2.new(1, -45, 0.5, -10); bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local ind = Instance.new("Frame", bg); ind.Size = UDim2.new(0, 14, 0, 14); ind.Position = UDim2.new(0, 3, 0.5, -7); ind.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    return bg, ind
end

local function addSlider(name, parent, min, max, default, callback)
    local sliderFrame = Instance.new("Frame", parent); sliderFrame.Size = UDim2.new(0.95, 0, 0, 45); sliderFrame.BackgroundTransparency = 1
    local sliderLabel = Instance.new("TextLabel", sliderFrame); sliderLabel.Text = name .. ": " .. default; sliderLabel.Size = UDim2.new(1, 0, 0, 20); sliderLabel.BackgroundTransparency = 1; sliderLabel.TextColor3 = Color3.new(0.8,0.8,0.8); sliderLabel.Font = Enum.Font.GothamMedium; sliderLabel.TextSize = 12
    local sliderBack = Instance.new("Frame", sliderFrame); sliderBack.Size = UDim2.new(1, -10, 0, 6); sliderBack.Position = UDim2.new(0, 5, 0, 30); sliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", sliderBack)
    local sliderFill = Instance.new("Frame", sliderBack); sliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); sliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Instance.new("UICorner", sliderFill)
    local sliderBtn = Instance.new("TextButton", sliderBack); sliderBtn.Size = UDim2.new(0, 16, 0, 16); sliderBtn.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8); sliderBtn.BackgroundColor3 = Color3.new(1,1,1); sliderBtn.Text = ""; Instance.new("UICorner", sliderBtn)

    local dragging = false
    sliderBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local relativePos = math.clamp((mousePos - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0); sliderBtn.Position = UDim2.new(relativePos, -8, 0.5, -8)
            local val = math.floor(min + (relativePos * (max - min)))
            sliderLabel.Text = name .. ": " .. val
            callback(val)
        end
    end)
end

-- CONTROLES
local espT, espI = addToggle("ESP PLAYER BOXES", visualPage)

local noclipT, noclipI = addToggle("NOCLIP XYZ", movePage)
local flyT, flyI = addToggle("FLY MODE", movePage)
addSlider("FLY SPEED", movePage, 10, 300, 50, function(v) flySpeed = v end)

local aimT, aimI = addToggle("AIMBOT HEAD", aimbotPage)
local fovT, fovI = addToggle("SHOW FOV CIRCLE", aimbotPage)
local wallT, wallI = addToggle("WALL CHECK", aimbotPage)
local friendT, friendI = addToggle("IGNORE FRIENDS", aimbotPage)
local deadT, deadI = addToggle("IGNORE DEAD", aimbotPage)
addSlider("FOV RADIUS", aimbotPage, 10, 400, 100, function(v) 
    fovRadius = v 
    fovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

-- ANIMACIONES TOGGLE
local function toggleAn(act, b, i)
    TweenService:Create(i, TweenInfo.new(0.2), {Position = act and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = act and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(45, 45, 45)}):Play()
end

-- LOGICA BOTONES
espT.MouseButton1Click:Connect(function() espActive = not espActive toggleAn(espActive, espT, espI) end)
noclipT.MouseButton1Click:Connect(function() noclipActive = not noclipActive toggleAn(noclipActive, noclipT, noclipI) end)
aimT.MouseButton1Click:Connect(function() aimbotActive = not aimbotActive toggleAn(aimbotActive, aimT, aimI) end)
fovT.MouseButton1Click:Connect(function() showFov = not showFov toggleAn(showFov, fovT, fovI); fovCircle.Visible = showFov end)
wallT.MouseButton1Click:Connect(function() wallCheckActive = not wallCheckActive toggleAn(wallCheckActive, wallT, wallI) end)
friendT.MouseButton1Click:Connect(function() ignoreFriends = not ignoreFriends toggleAn(ignoreFriends, friendT, friendI) end)
deadT.MouseButton1Click:Connect(function() ignoreDead = not ignoreDead toggleAn(ignoreDead, deadT, deadI) end)

flyT.MouseButton1Click:Connect(function()
    flyActive = not flyActive
    toggleAn(flyActive, flyT, flyI)
    flyControls.Visible = flyActive
    if not flyActive and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if root:FindFirstChild("FlyVel") then root.FlyVel:Destroy() end
            if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
        end
        player.Character.Humanoid.PlatformStand = false
    end
end)

-- BUCLE RENDER
local espObjects = {}
RunService:BindToRenderStep("DarkMatterFinal", Enum.RenderPriority.Camera.Value + 1, function()
    local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = char.Humanoid
    
    if noclipActive then 
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end

    if flyActive then
        local vel = root:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", root)
        local gyro = root:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", root)
        vel.Name = "FlyVel"; gyro.Name = "FlyGyro"
        vel.MaxForce = Vector3.new(1,1,1) * math.huge
        gyro.MaxTorque = Vector3.new(1,1,1) * math.huge
        gyro.CFrame = camera.CFrame
        
        -- Movimiento combinado: Joystick + Botones Verticales
        local moveDir = hum.MoveDirection
        local dir = (moveDir * flySpeed) + (Vector3.new(0, yDirection, 0) * flySpeed)
        
        -- Soporte teclado PC
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, flySpeed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, flySpeed, 0) end
        
        vel.Velocity = dir
    end

    if aimbotActive then
        local target = nil
        local shortestDist = fovRadius
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local h = p.Character.Head
                local pos, onScreen = camera:WorldToViewportPoint(h.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then shortestDist = dist; target = h end
                end
            end
        end
        if target then camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position) end
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if espActive then
                if not espObjects[plr] then
                    local b = Instance.new("BillboardGui", screenGui); b.AlwaysOnTop = true; b.Size = UDim2.new(4, 0, 5.5, 0)
                    local f = Instance.new("Frame", b); f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; Instance.new("UIStroke", f).Color = Color3.new(1,1,1)
                    local t = Instance.new("TextLabel", b); t.Size = UDim2.new(1, 0, 0, 20); t.Position = UDim2.new(0, 0, 0, -25); t.TextColor3 = Color3.new(1,1,1); t.BackgroundTransparency = 1; t.TextSize = 12; espObjects[plr] = {gui = b, label = t}
                end
                espObjects[plr].gui.Adornee = plr.Character.HumanoidRootPart; espObjects[plr].gui.Enabled = true; espObjects[plr].label.Text = plr.Name
            elseif espObjects[plr] then espObjects[plr].gui.Enabled = false end
        end
    end
end)

-- DRAGGABLE
local function makeDraggable(frame)
    local drag, dStart, sPos
    frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = input.Position; sPos = frame.Position end end)
    frame.InputChanged:Connect(function(input) if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dStart; frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end
makeDraggable(mainFrame); makeDraggable(miniFrame)
