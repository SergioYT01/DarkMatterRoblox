-- [[ DARKMATTER UI - VERSIÓN FUNCIONAL PARA DESARROLLADORES ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatterV2"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Variables de Estado
local noclipEnabled = false
local flyEnabled = false
local minimized = false
local flySpeed = 50

-- --- INTERFAZ GRÁFICA ---

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 180)
mainFrame.Position = UDim2.new(0.5, -140, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Permite moverlo
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Barra Superior
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(35, 15, 60)
header.BorderSizePixel = 0
header.Parent = mainFrame

local hCorner = Instance.new("UICorner")
hCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DARKMATTER"
title.TextColor3 = Color3.fromRGB(180, 100, 255)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 2)
minBtn.BackgroundTransparency = 1
minBtn.Text = "▼"
minBtn.TextColor3 = Color3.white
minBtn.Parent = header

-- Contenedor de Opciones
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -35)
container.Position = UDim2.new(0, 0, 0, 35)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Función para crear Switch
local function createSwitch(name, posY, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 150, 0, 30)
    label.Position = UDim2.new(0, 60, 0, posY)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bg = Instance.new("TextButton")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(0, 10, 0, posY + 5)
    bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bg.Text = ""
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 2, 0, 2)
    circle.BackgroundColor3 = Color3.white
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local active = false
    bg.MouseButton1Click:Connect(function()
        active = not active
        circle:TweenPosition(active and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.2)
        bg.BackgroundColor3 = active and Color3.fromRGB(140, 50, 255) or Color3.fromRGB(50, 50, 50)
        callback(active)
    end)
end

-- --- LÓGICA DE FUNCIONES ---

-- 1. Minimizar
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    container.Visible = not minimized
    mainFrame:TweenSize(minimized and UDim2.new(0, 280, 0, 35) or UDim2.new(0, 280, 0, 180), "Out", "Quad", 0.3)
    minBtn.Text = minimized and "▲" or "▼"
end)

-- 2. Modo Fantasma (Noclip)
createSwitch("Modo Fantasma", 20, function(state)
    noclipEnabled = state
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 3. Modo Vuelo (WASD / Joystick)
createSwitch("Modo Vuelo", 70, function(state)
    flyEnabled = state
    local hrp = character:WaitForChild("HumanoidRootPart")
    if state then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0,0,0)
    else
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
    end
end)

RunService.RenderStepped:Connect(function()
    if flyEnabled and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local moveDir = character.Humanoid.MoveDirection
        
        if hrp:FindFirstChild("FlyVelocity") then
            hrp.FlyVelocity.Velocity = moveDir * flySpeed
            -- Si no hay movimiento, mantener flotando
            if moveDir.Magnitude > 0 then
                hrp.FlyVelocity.Velocity = (camera.CFrame.LookVector * moveDir.Z + camera.CFrame.RightVector * moveDir.X) * flySpeed
            else
                hrp.FlyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            end
        end
    end
end)

-- Actualizar personaje al morir
player.CharacterAdded:Connect(function(newChar)
    character = newChar
end)
