--// DarkMatter Roblox Mod Menu
--// Solo para pruebas / aprendizaje

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Esperar personaje
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DarkMatterGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 320)
main.Position = UDim2.new(0, 20, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ZIndex = 10

-- Corner
local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "MOD MENU"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.ZIndex = 11

-- Minimize Button
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
minBtn.ZIndex = 12
Instance.new("UICorner", minBtn)

-- Container
local container = Instance.new("Frame", main)
container.Position = UDim2.new(0, 0, 0, 40)
container.Size = UDim2.new(1, 0, 1, -40)
container.BackgroundTransparency = 1
container.ZIndex = 11

-- Layout
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Button creator
local function createButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 40)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.ZIndex = 12
    Instance.new("UICorner", b)
    b.Parent = container
    return b
end

-- Buttons
local noclipBtn = createButton("NOCLIP: OFF")
local flyBtn = createButton("FLY: OFF")
local espBtn = createButton("ESP: OFF")

--------------------------------------------------
-- NOCLIP
local noclip = false
RunService.Stepped:Connect(function()
    if noclip then
        for _,v in pairs(getChar():GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
end)

--------------------------------------------------
-- FLY
local flying = false
local bv, bg

local function stopFly()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    bv, bg = nil, nil
end

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY: ON" or "FLY: OFF"

    local hrp = getChar():WaitForChild("HumanoidRootPart")

    if flying then
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1e9,1e9,1e9)

        RunService.RenderStepped:Connect(function()
            if not flying then return end
            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 60
            bg.CFrame = workspace.CurrentCamera.CFrame
        end)
    else
        stopFly()
    end
end)

--------------------------------------------------
-- ESP
local espEnabled = false
local espObjects = {}

local function clearESP()
    for _,v in pairs(espObjects) do
        if v then v:Destroy() end
    end
    espObjects = {}
end

local function createESP(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = char:WaitForChild("HumanoidRootPart")
    box.Size = Vector3.new(4,6,2)
    box.Color3 = Color3.fromRGB(255,0,0)
    box.AlwaysOnTop = true
    box.ZIndex = 20
    box.Parent = gui
    table.insert(espObjects, box)
end

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"

    clearESP()
    if espEnabled then
        for _,p in pairs(Players:GetPlayers()) do
            createESP(p)
        end
    end
end)

--------------------------------------------------
-- MINIMIZE
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    container.Visible = not minimized
    main.Size = minimized and UDim2.new(0,260,0,40) or UDim2.new(0,260,0,320)
    minBtn.Text = minimized and "+" or "-"
end)
