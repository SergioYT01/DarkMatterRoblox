local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuración
local fovRadius = 100
local showFov = false
local aimbotActive = false 
local wallCheck = true -- Nueva opción: Wall Check activado por defecto
local menuOpen = true
local aimMode = "DIRECTO" 

-- --- INTERFAZ ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatter_V4"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Círculo Visual
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = showFov
fovCircle.Parent = screenGui

local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(138, 43, 226)
fovStroke.Thickness = 1
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

-- MENU PRINCIPAL
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 300) -- Ajustado para el nuevo botón
mainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active = true 
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 43, 226); mainStroke.Thickness = 2

-- Barra de Título
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DARK MATTER SETTINGS"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.Font = Enum.Font.GothamBold
title.TextSize = 13

-- Flecha de Recoger
local collapseBtn = Instance.new("TextButton", mainFrame)
collapseBtn.Text = "▲"
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(1, -35, 0, 5)
collapseBtn.BackgroundTransparency = 1
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.TextSize = 18

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1

-- Lógica de Colapsar
collapseBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 300), "Out", "Quad", 0.3, true)
        collapseBtn.Text = "▲"
        contentFrame.Visible = true
    else
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 40), "Out", "Quad", 0.3, true)
        collapseBtn.Text = "▼"
        delay(0.3, function() if not menuOpen then contentFrame.Visible = false end end)
    end
end)

-- Función para botones
local function createButton(name, pos, defaultText)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = defaultText
    btn.TextColor3 = Color3.fromRGB(138, 43, 226)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    Instance.new("UICorner", btn)
    return btn
end

local aimbotBtn = createButton("AIMBOT", UDim2.new(0.05, 0, 0, 5), "AIMBOT: OFF")
local fovBtn = createButton("SHOW FOV", UDim2.new(0.05, 0, 0, 45), "SHOW FOV: OFF")

-- Slider
local sliderFrame = Instance.new("Frame", contentFrame)
sliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
sliderFrame.Position = UDim2.new(0.05, 0, 0, 95)
sliderFrame.BackgroundTransparency = 1
local sliderLabel = Instance.new("TextLabel", sliderFrame)
sliderLabel.Text = "RADIUS: " .. fovRadius; sliderLabel.Size = UDim2.new(1,0,0,20); sliderLabel.BackgroundTransparency = 1; sliderLabel.TextColor3 = Color3.new(0.8,0.8,0.8); sliderLabel.Font = Enum.Font.GothamMedium; sliderLabel.TextSize = 12
local sliderBack = Instance.new("Frame", sliderFrame); sliderBack.Size = UDim2.new(1,0,0,6); sliderBack.Position = UDim2.new(0,0,0,30); sliderBack.BackgroundColor3 = Color3.fromRGB(45,45,45); Instance.new("UICorner", sliderBack)
local sliderFill = Instance.new("Frame", sliderBack); sliderFill.Size = UDim2.new(fovRadius/200,0,1,0); sliderFill.BackgroundColor3 = Color3.fromRGB(138,43,226); Instance.new("UICorner", sliderFill)
local knob = Instance.new("TextButton", sliderBack); knob.Size = UDim2.new(0,18,0,18); knob.AnchorPoint = Vector2.new(0.5,0.5); knob.Position = UDim2.new(fovRadius/200,0,0.5,0); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Text = ""; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- Botones de Modo y WallCheck
local modeBtn = createButton("MODE", UDim2.new(0.05, 0, 0, 160), "MODO: DIRECTO")
local wallBtn = createButton("WALL", UDim2.new(0.05, 0, 0, 200), "WALL CHECK: ON")

-- LOGICA INTERACTIVA
modeBtn.MouseButton1Click:Connect(function()
    if aimMode == "DIRECTO" then aimMode = "DISIMULADO" elseif aimMode == "DISIMULADO" then aimMode = "MAGNETICO" else aimMode = "DIRECTO" end
    modeBtn.Text = "MODO: " .. aimMode
end)

wallBtn.MouseButton1Click:Connect(function()
    wallCheck = not wallCheck
    wallBtn.Text = "WALL CHECK: " .. (wallCheck and "ON" or "OFF")
end)

aimbotBtn.MouseButton1Click:Connect(function()
    aimbotActive = not aimbotActive
    aimbotBtn.Text = "AIMBOT: " .. (aimbotActive and "ON" or "OFF")
end)

fovBtn.MouseButton1Click:Connect(function()
    showFov = not showFov
    fovCircle.Visible = showFov
    fovBtn.Text = "SHOW FOV: " .. (showFov and "ON" or "OFF")
end)

-- Slider Drag
local draggingSlider = false
knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end end)

local function updateSlider()
    local mousePos = UserInputService:GetMouseLocation().X
    local relative = math.clamp((mousePos - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
    fovRadius = math.floor(relative * 200)
    sliderLabel.Text = "RADIUS: " .. fovRadius
    sliderFill.Size = UDim2.new(relative, 0, 1, 0)
    knob.Position = UDim2.new(relative, 0, 0.5, 0)
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end

-- FUNCIÓN VISIBILIDAD (WALL CHECK)
local function isVisible(targetPart)
    if not wallCheck then return true end
    local castPoints = {camera.CFrame.Position, targetPart.Position}
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, targetPart.Parent} -- Ignora al usuario y al objetivo mismo
    
    local result = workspace:Raycast(castPoints[1], castPoints[2] - castPoints[1], params)
    return result == nil -- Si no golpea nada, es visible
end

-- LÓGICA AIMBOT
local function getClosestToCenter()
    if not aimbotActive then return nil end
    local target = nil
    local shortestDist = fovRadius
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local head = p.Character.Head
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < shortestDist then
                        if isVisible(head) then
                            shortestDist = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

-- BUCLE RENDER
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = UDim2.new(0, center.X, 0, center.Y)
    
    if draggingSlider then updateSlider() end
    
    local target = getClosestToCenter()
    if target then
        local tPos = target.Position
        if aimMode == "DIRECTO" then
            camera.CFrame = CFrame.new(camera.CFrame.Position, tPos)
        elseif aimMode == "DISIMULADO" then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, tPos), 0.05)
        elseif aimMode == "MAGNETICO" then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, tPos), 0.15)
        end
    end
end)

-- DRAG MENU
local dStart, sPos, draggingMenu = nil, nil, false
mainFrame.InputBegan:Connect(function(i)
    if draggingSlider then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = true; dStart = i.Position; sPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if draggingMenu and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dStart
        mainFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) draggingMenu = false end)
