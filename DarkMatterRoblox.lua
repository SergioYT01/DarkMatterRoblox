-- DARK MATTER PRO EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================= ESTADOS Y CONFIGURACIÓN =================
local noclip, fly, esp = false, false, false
local showDistance, showTracers, showHealth, showNames = false, false, false, false
local flySpeed = 50
local storage = {} -- Guardar objetos visuales

-- ================= GUI MEJORADA =================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DarkMatterPro"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 210)
main.Position = UDim2.new(0.05, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "DARK MATTER"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

-- CONTENEDOR DE OPCIONES EXTRA (SUBMENÚ)
local extraPanel = Instance.new("Frame", main)
extraPanel.Size = UDim2.new(0, 180, 0, 180)
extraPanel.Position = UDim2.new(1, 10, 0, 0)
extraPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
extraPanel.Visible = false
Instance.new("UICorner", extraPanel)

-- Función para crear botones rápidos
local function createBtn(name, y, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
    return b
end

-- BOTONES PRINCIPALES
createBtn("NOCLIP: OFF", 45, main, function(b)
    noclip = not noclip
    b.Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
    b.BackgroundColor3 = noclip and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
end)

createBtn("VUELO: OFF", 90, main, function(b)
    fly = not fly
    b.Text = fly and "VUELO: ON" or "VUELO: OFF"
    b.BackgroundColor3 = fly and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
    if not fly and player.Character then player.Character.Humanoid.PlatformStand = false end
end)

createBtn("ESP: OFF", 135, main, function(b)
    esp = not esp
    extraPanel.Visible = esp
    b.Text = esp and "ESP: ON" or "ESP: OFF"
    b.BackgroundColor3 = esp and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
end)

-- BOTONES DEL SUBMENÚ ESP
createBtn("DISTANCIA", 10, extraPanel, function(b) 
    showDistance = not showDistance
    b.BackgroundColor3 = showDistance and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
end)
createBtn("LINEAS (TRACERS)", 50, extraPanel, function(b)
    showTracers = not showTracers
    b.BackgroundColor3 = showTracers and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
end)
createBtn("VIDA", 90, extraPanel, function(b)
    showHealth = not showHealth
    b.BackgroundColor3 = showHealth and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
end)
createBtn("NOMBRES", 130, extraPanel, function(b)
    showNames = not showNames
    b.BackgroundColor3 = showNames and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
end)

-- ================= LÓGICA ESP PRO =================
local function createESP(plr)
    local function setup(char)
        local root = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if not root or not hum then return end

        -- 1. CONTORNO (Highlight)
        local highlight = Instance.new("Highlight", gui)
        highlight.Adornee = char
        highlight.OutlineColor = Color3.new(1, 0, 0)
        
        -- 2. TRACER (Línea)
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1

        -- 3. INFO (Nombre, Distancia, Vida)
        local billboard = Instance.new("BillboardGui", gui)
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        
        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 14

        RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not esp then
                highlight.Enabled = false
                line.Visible = false
                billboard.Enabled = false
                return
            end

            -- Actualizar Highlight
            highlight.Enabled = esp

            -- Actualizar Texto (Vida, Distancia, Nombre)
            local dist = math.floor((root.Position - player.Character.HumanoidRootPart.Position).Magnitude)
            local infoText = ""
            if showNames then infoText = infoText .. plr.Name .. "\n" end
            if showHealth then infoText = infoText .. "HP: " .. math.floor(hum.Health) .. "\n" end
            if showDistance then infoText = infoText .. dist .. " Studs" end
            textLabel.Text = infoText
            billboard.Enabled = true

            -- Actualizar Líneas (Tracers desde arriba)
            if showTracers then
                local vector, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    line.From = Vector2.new(camera.ViewportSize.X / 2, 0) -- Sale de arriba al centro
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end)
    end
    plr.CharacterAdded:Connect(setup)
    if plr.Character then setup(plr.Character) end
end

Players.PlayerAdded:Connect(createESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= player then createESP(p) end end

-- ================= VUELO Y NOCLIP =================
local bv
RunService.RenderStepped:Connect(function()
    if fly and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        if not bv or bv.Parent ~= hrp then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
        bv.Velocity = camera.CFrame.LookVector * (UIS:IsKeyDown(Enum.KeyCode.W) and flySpeed or 0)
        if UIS:GetFocusedTextBox() then bv.Velocity = Vector3.zero end
        -- Soporte Joystick móvil simplificado
        if player.Character.Humanoid.MoveDirection.Magnitude > 0 then
            bv.Velocity = player.Character.Humanoid.MoveDirection * flySpeed
        end
    elseif bv then
        bv:Destroy()
        bv = nil
    end
    
    if noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- BOTÓN MINIMIZAR
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1
local minState = false
minBtn.MouseButton1Click:Connect(function()
    minState = not minState
    extraPanel.Visible = false
    for _, v in pairs(main:GetChildren()) do
        if v:IsA("TextButton") and v ~= minBtn then v.Visible = not minState end
    end
    main.Size = minState and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 210)
    minBtn.Text = minState and "+" or "-"
end)
