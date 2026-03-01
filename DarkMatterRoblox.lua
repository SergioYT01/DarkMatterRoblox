local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuración
local fovRadius = 100
local showFov = false
local aimbotActive = false 
local wallCheck = true
local espActive = false
local menuOpen = true
local aimMode = "DIRECTO" 

-- --- INTERFAZ ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatter_Universal"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.DisplayOrder = 999999999 
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
mainFrame.Size = UDim2.new(0, 250, 0, 260) 
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
title.Text = "DARK MATTER V6"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- Flecha de Recoger
local collapseBtn = Instance.new("TextButton", mainFrame)
collapseBtn.Text = "▲"
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(1, -35, 0, 5)
collapseBtn.BackgroundTransparency = 1
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.TextSize = 18

-- SCROLLING FRAME
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)

-- Función para colapsar
collapseBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    mainFrame:TweenSize(UDim2.new(0, 250, 0, menuOpen and 260 or 40), "Out", "Quad", 0.3, true)
    collapseBtn.Text = menuOpen and "▲" or "▼"
    scrollFrame.Visible = menuOpen
end)

-- Función para botones
local function createButton(text, pos)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(138, 43, 226)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    return btn
end

local aimbotBtn = createButton("AIMBOT: OFF", UDim2.new(0.05, 0, 0, 10))
local fovBtn = createButton("SHOW FOV: OFF", UDim2.new(0.05, 0, 0, 50))

-- Slider Radio
local sliderFrame = Instance.new("Frame", scrollFrame)
sliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
sliderFrame.Position = UDim2.new(0.05, 0, 0, 95)
sliderFrame.BackgroundTransparency = 1
local sliderLabel = Instance.new("TextLabel", sliderFrame)
sliderLabel.Text = "RADIUS: " .. fovRadius; sliderLabel.Size = UDim2.new(1,0,0,20); sliderLabel.BackgroundTransparency = 1; sliderLabel.TextColor3 = Color3.new(0.8,0.8,0.8); sliderLabel.TextSize = 12
local sliderBack = Instance.new("Frame", sliderFrame); sliderBack.Size = UDim2.new(1,0,0,6); sliderBack.Position = UDim2.new(0,0,0,30); sliderBack.BackgroundColor3 = Color3.fromRGB(45,45,45); Instance.new("UICorner", sliderBack)
local sliderFill = Instance.new("Frame", sliderBack); sliderFill.Size = UDim2.new(fovRadius/200,0,1,0); sliderFill.BackgroundColor3 = Color3.fromRGB(138,43,226); Instance.new("UICorner", sliderFill)
local knob = Instance.new("TextButton", sliderBack); knob.Size = UDim2.new(0,18,0,18); knob.AnchorPoint = Vector2.new(0.5,0.5); knob.Position = UDim2.new(fovRadius/200,0,0.5,0); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Text = ""; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

local modeBtn = createButton("MODO: DIRECTO", UDim2.new(0.05, 0, 0, 160))
local wallBtn = createButton("WALL CHECK: ON", UDim2.new(0.05, 0, 0, 200))
local espBtn = createButton("ESP: OFF", UDim2.new(0.05, 0, 0, 240))

-- --- LOGICA DE PROTECCIÓN Y DETECCIÓN ---

-- Función para obtener la cabeza de forma segura (sin importar el skin)
local function getTargetPart(character)
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

-- Función ESP mejorada (maneja cambios de skin y respawns)
local function applyESP(targetPlayer)
    if targetPlayer == player then return end
    
    local function setupHighlight(char)
        if not char then return end
        local highlight = char:FindFirstChild("DarkESP")
        if espActive then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "DarkESP"
                highlight.Parent = char
            end
            highlight.FillColor = Color3.fromRGB(138, 43, 226)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.5
            highlight.Enabled = true
        elseif highlight then
            highlight.Enabled = false
        end
    end

    setupHighlight(targetPlayer.Character)
    targetPlayer.CharacterAdded:Connect(setupHighlight)
end

-- Actualizar ESP para todos
local function refreshAllESP()
    for _, p in pairs(Players:GetPlayers()) do
        applyESP(p)
    end
end

-- INTERACCIONES
espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    espBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    refreshAllESP()
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

wallBtn.MouseButton1Click:Connect(function()
    wallCheck = not wallCheck
    wallBtn.Text = "WALL CHECK: " .. (wallCheck and "ON" or "OFF")
end)

modeBtn.MouseButton1Click:Connect(function()
    if aimMode == "DIRECTO" then aimMode = "DISIMULADO" elseif aimMode == "DISIMULADO" then aimMode = "MAGNETICO" else aimMode = "DIRECTO" end
    modeBtn.Text = "MODO: " .. aimMode
end)

-- Slider Logic
local draggingSlider = false
knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end end)

-- BUCLE PRINCIPAL
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = UDim2.new(0, center.X, 0, center.Y)
    
    if draggingSlider then
        local mousePos = UserInputService:GetMouseLocation().X
        local relative = math.clamp((mousePos - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        fovRadius = math.floor(relative * 200)
        sliderLabel.Text = "RADIUS: " .. fovRadius
        sliderFill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, 0, 0.5, 0)
        fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    end
    
    if aimbotActive then
        local targetPart = nil
        local shortestDist = fovRadius
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = getTargetPart(p.Character)
                    if part then
                        local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < shortestDist then
                                local isVis = true
                                if wallCheck then
                                    local params = RaycastParams.new()
                                    params.FilterType = Enum.RaycastFilterType.Exclude
                                    params.FilterDescendantsInstances = {player.Character, p.Character}
                                    local ray = workspace:Raycast(camera.CFrame.Position, (part.Position - camera.CFrame.Position).Unit * 500, params)
                                    if ray then isVis = false end
                                end
                                if isVis then shortestDist = dist; targetPart = part end
                            end
                        end
                    end
                end
            end
        end
        
        if targetPart then
            local targetPos = targetPart.Position
            if aimMode == "DIRECTO" then camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
            elseif aimMode == "DISIMULADO" then camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPos), 0.05)
            elseif aimMode == "MAGNETICO" then camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPos), 0.15) end
        end
    end
end)

-- Manejo de arrastre de menú
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
UserInputService.InputEnded:Connect(function() draggingMenu = false end)

-- Inicializar para jugadores actuales
refreshAllESP()
Players.PlayerAdded:Connect(applyESP)
