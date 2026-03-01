-- [[ DARKMATTER UI V3 - REVISIÓN TÉCNICA DE FUNCIONES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variables de Control
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 50
local c 

-- Asegurar referencia al personaje
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- --- INTERFAZ (Versión Compacta) ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatterFix"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 140)
mainFrame.Position = UDim2.new(0.5, -120, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 5, 25)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Título y Minimizar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = " DARKMATTER PRO"
title.TextColor3 = Color3.fromRGB(180, 100, 255)
title.BackgroundColor3 = Color3.fromRGB(30, 10, 50)
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title)

-- Botón de Minimizar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.Text = "X"
minBtn.TextColor3 = Color3.white
minBtn.BackgroundTransparency = 1
minBtn.Parent = mainFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -30)
container.Position = UDim2.new(0, 0, 0, 30)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Función para Switch (Lógica funcional)
local function createToggle(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = container
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = name .. (active and ": ON" or ": OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(120, 50, 255) or Color3.fromRGB(40, 20, 60)
        callback(active)
    end)
end

-- --- LÓGICA DE NOCLIP (FORZADO) ---
createToggle("Noclip", 10, function(state)
    noclipEnabled = state
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = getChar()
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)

-- --- LÓGICA DE VUELO (BODYVELOCITY) ---
local bv
createToggle("Vuelo", 55, function(state)
    flyEnabled = state
    local char = getChar()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    if state then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        char.Humanoid.PlatformStand = true -- Evita animaciones de caída
    else
        if bv then bv:Destroy() end
        char.Humanoid.PlatformStand = false
    end
end)

RunService.RenderStepped:Connect(function()
    if flyEnabled and bv then
        local char = getChar()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Control direccional
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            bv.Velocity = (cam.CFrame.LookVector * moveDir.Z + cam.CFrame.RightVector * moveDir.X).Unit * flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Mantener el personaje mirando hacia adelante
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    end
end)

-- Minimizar
minBtn.MouseButton1Click:Connect(function()
    container.Visible = not container.Visible
    mainFrame:TweenSize(container.Visible and UDim2.new(0, 240, 0, 140) or UDim2.new(0, 240, 0, 30), "Out", "Quad", 0.2)
    minBtn.Text = container.Visible and "X" or "O"
end)
