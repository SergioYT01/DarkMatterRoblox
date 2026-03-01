local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- --- CONFIGURACIÓN ---
local fovRadius = 100
local showFov = false
local aimbotActive = false 
local wallCheck = true
local menuOpen = true
local aimMode = "DIRECTO" 
local teamCheck = false 

-- Configuración ESP Individual
local espBoxActive = false
local espNameActive = false
local espDistActive = false

-- Configuración de Raycast
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

-- --- INTERFAZ ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatter_UltraFix_V2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.DisplayOrder = 999999
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Círculo de FOV
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
mainFrame.Size = UDim2.new(0, 250, 0, 380)
mainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active = true 
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 43, 226)
mainStroke.Thickness = 2

local title = Instance.new("TextLabel", mainFrame)
title.Text = "DARK MATTER"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local collapseBtn = Instance.new("TextButton", mainFrame)
collapseBtn.Text = "▲"
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(1, -35, 0, 5)
collapseBtn.BackgroundTransparency = 1
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.TextSize = 18

local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)

-- Layout para organizar automáticamente los botones
local layout = Instance.new("UIListLayout", scrollFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

collapseBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 380), "Out", "Quad", 0.3, true)
        collapseBtn.Text = "▲"
        scrollFrame.Visible = true
    else
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 40), "Out", "Quad", 0.3, true)
        collapseBtn.Text = "▼"
        task.delay(0.3, function() if not menuOpen then scrollFrame.Visible = false end end)
    end
end)

local function createButton(text)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(138, 43, 226)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- --- BOTONES ---
local aimbotBtn = createButton("AIMBOT: OFF")
local fovBtn = createButton("SHOW FOV: OFF")

-- Contenedor de Slider Organizado
local sliderFrame = Instance.new("Frame", scrollFrame)
sliderFrame.Size = UDim2.new(0.9, 0, 0, 45)
sliderFrame.BackgroundTransparency = 1
local sliderLabel = Instance.new("TextLabel", sliderFrame)
sliderLabel.Text = "RADIUS: " .. fovRadius; sliderLabel.Size = UDim2.new(1,0,0,15); sliderLabel.BackgroundTransparency = 1; sliderLabel.TextColor3 = Color3.new(0.8,0.8,0.8); sliderLabel.TextSize = 10; sliderLabel.Font = Enum.Font.Gotham
local sliderBack = Instance.new("Frame", sliderFrame); sliderBack.Size = UDim2.new(1,0,0,4); sliderBack.Position = UDim2.new(0,0,0,28); sliderBack.BackgroundColor3 = Color3.fromRGB(45,45,45); Instance.new("UICorner", sliderBack)
local sliderFill = Instance.new("Frame", sliderBack); sliderFill.Size = UDim2.new(fovRadius/200,0,1,0); sliderFill.BackgroundColor3 = Color3.fromRGB(138,43,226); Instance.new("UICorner", sliderFill)
local knob = Instance.new("TextButton", sliderBack); knob.Size = UDim2.new(0,14,0,14); knob.AnchorPoint = Vector2.new(0.5,0.5); knob.Position = UDim2.new(fovRadius/200,0,0.5,0); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Text = ""; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

local modeBtn = createButton("MODO: " .. aimMode)
local wallBtn = createButton("WALL CHECK: ON")
local boxBtn = createButton("ESP BOX: OFF")
local nameBtn = createButton("ESP NAME: OFF")
local distBtn = createButton("ESP DISTANCE: OFF")

-- --- LÓGICA DE ESP ---
local espData = {}

local function createESP(p)
    if espData[p] then return end
    
    local container = Instance.new("Frame", screenGui)
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 1, 0)
    container.Visible = false
    
    local box = Instance.new("Frame", container)
    box.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Color3.fromRGB(138, 43, 226)
    stroke.Thickness = 1.5

    local label = Instance.new("TextLabel", container)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.Size = UDim2.new(0, 200, 0, 20)
    label.AnchorPoint = Vector2.new(0.5, 0.5)

    espData[p] = {container = container, box = box, label = label}
end

local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p == player then continue end
        if not espData[p] then createESP(p) end
        
        local data = espData[p]
        local char = p.Character
        local head = char and char:FindFirstChild("Head")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if char and head and root and (not teamCheck or p.Team ~= player.Team) and (hum and hum.Health > 0) then
            local hrpPos, onScreen = camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.6
                
                -- Box
                data.box.Visible = espBoxActive
                data.box.Size = UDim2.new(0, width, 0, height)
                data.box.Position = UDim2.new(0, hrpPos.X - (width/2), 0, hrpPos.Y - (height/2))
                
                -- Text
                local dist = math.floor((camera.CFrame.Position - root.Position).Magnitude)
                local text = ""
                if espNameActive then text = p.Name end
                if espDistActive then text = text .. (espNameActive and "\n" or "") .. "[" .. dist .. "m]" end
                
                data.label.Text = text
                data.label.Visible = (espNameActive or espDistActive)
                data.label.Position = UDim2.new(0, hrpPos.X, 0, hrpPos.Y + (height/2) + 12)
                
                data.container.Visible = true
            else
                data.container.Visible = false
            end
        else
            if data then data.container.Visible = false end
        end
    end
end

-- Limpieza
Players.PlayerRemoving:Connect(function(p)
    if espData[p] then
        espData[p].container:Destroy()
        espData[p] = nil
    end
end)

-- --- EVENTOS DE BOTONES ---
boxBtn.MouseButton1Click:Connect(function() espBoxActive = not espBoxActive; boxBtn.Text = "ESP BOX: "..(espBoxActive and "ON" or "OFF") end)
nameBtn.MouseButton1Click:Connect(function() espNameActive = not espNameActive; nameBtn.Text = "ESP NAME: "..(espNameActive and "ON" or "OFF") end)
distBtn.MouseButton1Click:Connect(function() espDistActive = not espDistActive; distBtn.Text = "ESP DISTANCE: "..(espDistActive and "ON" or "OFF") end)
aimbotBtn.MouseButton1Click:Connect(function() aimbotActive = not aimbotActive; aimbotBtn.Text = "AIMBOT: "..(aimbotActive and "ON" or "OFF") end)
fovBtn.MouseButton1Click:Connect(function() showFov = not showFov; fovCircle.Visible = showFov; fovBtn.Text = "SHOW FOV: "..(showFov and "ON" or "OFF") end)
wallBtn.MouseButton1Click:Connect(function() wallCheck = not wallCheck; wallBtn.Text = "WALL CHECK: "..(wallCheck and "ON" or "OFF") end)
modeBtn.MouseButton1Click:Connect(function()
    if aimMode == "DIRECTO" then aimMode = "DISIMULADO" elseif aimMode == "DISIMULADO" then aimMode = "MAGNETICO" else aimMode = "DIRECTO" end
    modeBtn.Text = "MODO: " .. aimMode
end)

-- Slider Logic Corregido
local draggingSlider = false
local function updateSlider()
    local mousePos = UserInputService:GetMouseLocation().X
    local relative = math.clamp((mousePos - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
    fovRadius = math.floor(relative * 200)
    sliderLabel.Text = "RADIUS: " .. fovRadius
    sliderFill.Size = UDim2.new(relative, 0, 1, 0)
    knob.Position = UDim2.new(relative, 0, 0.5, 0)
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end

knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end end)
UserInputService.InputChanged:Connect(function(i) if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider() end end)

-- --- BUCLE PRINCIPAL (MAIN LOOP) ---
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = UDim2.new(0, center.X, 0, center.Y)
    
    updateESP()
    
    if aimbotActive then
        local target = nil
        local shortestDist = fovRadius
        rayParams.FilterDescendantsInstances = {player.Character, camera, screenGui}

        for _, p in pairs(Players:GetPlayers()) do
            if p == player or (teamCheck and p.Team == player.Team) then continue end
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or (hum and hum.Health <= 0) then continue end

            local aimPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if aimPart then
                local pos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
                if onScreen and pos.Z > 0 then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortestDist then
                        local isVis = true
                        if wallCheck then
                            local rayResult = workspace:Raycast(camera.CFrame.Position, (aimPart.Position - camera.CFrame.Position), rayParams)
                            if rayResult and not rayResult.Instance:IsDescendantOf(char) then isVis = false end
                        end
                        if isVis then shortestDist = dist; target = aimPart end
                    end
                end
            end
        end
        
        if target then
            local targetCF = CFrame.new(camera.CFrame.Position, target.Position)
            if aimMode == "DIRECTO" then 
                camera.CFrame = targetCF
            elseif aimMode == "DISIMULADO" then 
                camera.CFrame = camera.CFrame:Lerp(targetCF, 0.05)
            elseif aimMode == "MAGNETICO" then 
                camera.CFrame = camera.CFrame:Lerp(targetCF, 0.15) 
            end
        end
    end
end)

-- Arrastrar Menu
local dStart, sPos, draggingMenu = nil, nil, false
mainFrame.InputBegan:Connect(function(i)
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
