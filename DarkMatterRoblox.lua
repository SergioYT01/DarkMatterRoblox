-- DARK MATTER: ESP SYSTEM & 3D FLY FIX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================= ESTADOS =================
local states = {
    noclip = false, fly = false, 
    espMaster = false, -- Interruptor Principal
    espBox = false, espNames = false, 
    espDist = false, espTracers = false
}
local flySpeed = 50

-- ================= GUI PRINCIPAL =================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DarkMatterV4"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 180) 
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "DARK MATTER"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

-- CONTENEDOR DE SUB-OPCIONES (Se expande hacia abajo)
local subMenu = Instance.new("Frame", main)
subMenu.Size = UDim2.new(1, 0, 0, 150)
subMenu.Position = UDim2.new(0, 0, 1, 5)
subMenu.BackgroundTransparency = 1
subMenu.Visible = false

local function createToggle(name, y, stateKey, parent, isMaster)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = name .. ": OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = states[stateKey] and name .. ": ON" or name .. ": OFF"
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
        
        if isMaster then
            subMenu.Visible = states[stateKey]
            main.Size = states[stateKey] and UDim2.new(0, 240, 0, 340) or UDim2.new(0, 240, 0, 180)
        end
    end)
    return btn
end

-- Botones Base
createToggle("NOCLIP", 45, "noclip", main, false)
createToggle("VUELO", 85, "fly", main, false)
createToggle("ESP MASTER", 125, "espMaster", main, true)

-- Botones Sub-Menú (Solo visibles si ESP MASTER esta ON)
createToggle("ESP CAJA (BOX)", 0, "espBox", subMenu, false)
createToggle("NOMBRES", 40, "espNames", subMenu, false)
createToggle("DISTANCIA", 80, "espDist", subMenu, false)
createToggle("LINEAS", 120, "espTracers", subMenu, false)

-- ================= LÓGICA DE VUELO 3D (CORREGIDA) =================
local bv = nil
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if states.fly and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end

        -- Vuelo 3D: Sigue la dirección de la cámara (incluyendo arriba/abajo)
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            -- Calculamos la dirección relativa a la cámara
            local camCF = camera.CFrame
            local direction = (camCF.RightVector * moveDir.X) + (camCF.LookVector * -moveDir.Z)
            bv.Velocity = direction.Unit * flySpeed
        else
            bv.Velocity = Vector3.zero
        end
        hrp.Velocity = Vector3.zero
    elseif bv then
        bv:Destroy()
        bv = nil
    end

    if states.noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ================= LÓGICA ESP DINÁMICO =================
local function applyESP(plr)
    local function setup(char)
        local root = char:WaitForChild("HumanoidRootPart", 10)
        
        -- Caja (Box Adornment) - Se ve a través de paredes
        local box = Instance.new("BoxHandleAdornment", gui)
        box.Size = Vector3.new(4, 5.5, 1)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.7
        box.Color3 = Color3.new(1, 1, 1) -- Blanco como en tu imagen
        box.Adornee = root

        -- Billboard (Nombre y Distancia)
        local bill = Instance.new("BillboardGui", gui)
        bill.Size = UDim2.new(0, 100, 0, 40)
        bill.AlwaysOnTop = true
        bill.Adornee = root
        bill.StudsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel", bill)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13

        -- Tracer (Línea)
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1

        RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not states.espMaster then
                box.Visible = false; bill.Enabled = false; line.Visible = false
                return
            end

            box.Visible = states.espBox
            
            local info = ""
            if states.espNames then info = info .. plr.Name .. "\n" end
            if states.espDist then 
                local d = math.floor((root.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                info = info .. d .. " Studs" 
            end
            label.Text = info
            bill.Enabled = (states.espNames or states.espDist)

            if states.espTracers then
                local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    line.From = Vector2.new(camera.ViewportSize.X / 2, 0)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else line.Visible = false end
            else line.Visible = false end
        end)
    end
    plr.CharacterAdded:Connect(setup)
    if plr.Character then setup(plr.Character) end
end

Players.PlayerAdded:Connect(applyESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= player then applyESP(p) end end
