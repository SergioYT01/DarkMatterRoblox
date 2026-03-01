-- [[ DARKMATTER UI V2 - CORREGIDO ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Eliminar versión anterior si existe
if player.PlayerGui:FindFirstChild("DarkMatterV2") then
    player.PlayerGui.DarkMatterV2:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatterV2"
screenGui.IgnoreGuiInset = true -- Evita que se mueva por la barra de Roblox
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Variables de Estado
local noclipEnabled = false
local flyEnabled = false
local minimized = false
local flySpeed = 50

-- --- MARCO PRINCIPAL ---
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 160)
mainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Barra Superior (Header)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(40, 20, 70)
header.BorderSizePixel = 0
header.Parent = mainFrame

local hCorner = Instance.new("UICorner")
hCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DARKMATTER"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Botón Minimizar (Flecha)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 2)
minBtn.BackgroundTransparency = 1
minBtn.Text = "▼"
minBtn.TextColor3 = Color3.white
minBtn.TextSize = 18
minBtn.ZIndex = 5
minBtn.Parent = header

-- Contenedor de Opciones
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, 0, 1, -35)
container.Position = UDim2.new(0, 0, 0, 35)
container.BackgroundTransparency = 1
container.ClipsDescendants = true
container.Parent = mainFrame

-- Función para crear Switch Estético
local function createSwitch(name, posY, callback)
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(1, 0, 0, 40)
    switchFrame.Position = UDim2.new(0, 0, 0, posY)
    switchFrame.BackgroundTransparency = 1
    switchFrame.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 55, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = switchFrame

    local bg = Instance.new("TextButton")
    bg.Size = UDim2.new(0, 35, 0, 18)
    bg.Position = UDim2.new(0, 10, 0.5, -9)
    bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bg.Text = ""
    bg.AutoButtonColor = false
    bg.Parent = switchFrame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.white
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local active = false
    bg.MouseButton1Click:Connect(function()
        active = not active
        bg.BackgroundColor3 = active and Color3.fromRGB(160, 80, 255) or Color3.fromRGB(60, 60, 60)
        circle:TweenPosition(active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.15)
        callback(active)
    end)
end

-- --- LÓGICA DE INTERFAZ ---

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        container.Visible = false
        mainFrame:TweenSize(UDim2.new(0, 260, 0, 35), "Out", "Quad", 0.2)
        minBtn.Text = "▲"
    else
        mainFrame:TweenSize(UDim2.new(0, 260, 0, 160), "Out", "Quad", 0.2)
        task.wait(0.2)
        container.Visible = true
        minBtn.Text = "▼"
    end
end)

-- --- LÓGICA DE FUNCIONES ---

createSwitch("Modo Fantasma (Noclip)", 10, function(state)
    noclipEnabled = state
end)

createSwitch("Modo Vuelo (WASD/Joy)", 55, function(state)
    flyEnabled = state
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not state and hrp and hrp:FindFirstChild("FlyVelocity") then
        hrp.FlyVelocity:Destroy()
    end
end)

-- Bucle Noclip
RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Bucle Vuelo
RunService.RenderStepped:Connect(function()
    if flyEnabled and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        local bv = hrp:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            -- Calcula dirección basada en la cámara para subir/bajar
            local lookVec = camera.CFrame.LookVector
            local rightVec = camera.CFrame.RightVector
            bv.Velocity = (lookVec * moveDir.Z + rightVec * moveDir.X).Unit * flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Resetear referencia al morir
player.CharacterAdded:Connect(function(newChar)
    character = newChar
end)
