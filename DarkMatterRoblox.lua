-- DARK MATTER FIX: VUELO MULTIDIRECCIONAL + ESP DE CONTORNO + MENÚ COMPLETO
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================= ESTADOS =================
local states = {
    noclip = false,
    fly = false,
    esp = false,
    names = false,
    dist = false,
    tracers = false,
    health = false
}
local flySpeed = 50

-- ================= GUI PRINCIPAL =================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DarkMatterV3"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 310) -- Tamaño ajustado para todas las opciones
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "DARK MATTER"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- FUNCIÓN PARA CREAR SWITCHES (BOTONES)
local function createToggle(name, y, stateKey)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = name .. ": OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = states[stateKey] and name .. ": ON" or name .. ": OFF"
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
    end)
    return btn
end

-- CREACIÓN DE BOTONES
createToggle("NOCLIP", 45, "noclip")
createToggle("VUELO", 80, "fly")
createToggle("ESP CONTORNO", 115, "esp")
createToggle("MOSTRAR NOMBRES", 150, "names")
createToggle("MOSTRAR DISTANCIA", 185, "dist")
createToggle("MOSTRAR VIDA", 220, "health")
createToggle("LINEAS (TRACERS)", 255, "tracers")

-- ================= LÓGICA DE VUELO (JOYSTICK FIX) =================
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

        -- FIX: Ahora usa MoveDirection del Humanoid para que el Joystick funcione a los lados
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            bv.Velocity = moveDir * flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        hrp.Velocity = Vector3.new(0,0,0) -- Evita rebotes
    elseif bv then
        bv:Destroy()
        bv = nil
    end

    -- NOCLIP
    if states.noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ================= LÓGICA ESP PROFESIONAL =================
local function applyESP(plr)
    local function setup(char)
        local root = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        
        -- El Contorno (Highlight)
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 0, 0) -- Rojo
        highlight.Parent = gui

        -- Billboard para Nombre, Vida y Distancia
        local bill = Instance.new("BillboardGui", gui)
        bill.Adornee = root
        bill.Size = UDim2.new(0, 150, 0, 60)
        bill.AlwaysOnTop = true
        bill.StudsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel", bill)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14

        -- Línea (Tracer)
        local tracer = Drawing.new("Line")
        tracer.Color = Color3.new(1, 1, 1)
        tracer.Thickness = 1

        RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not root then 
                highlight:Destroy() bill:Destroy() tracer:Remove() return 
            end

            -- Control de visibilidad
            highlight.Enabled = states.esp
            
            local info = ""
            if states.names then info = info .. plr.Name .. "\n" end
            if states.health then info = info .. "HP: " .. math.floor(hum.Health) .. "\n" end
            if states.dist then 
                local d = math.floor((root.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                info = info .. d .. " Studs" 
            end
            label.Text = info
            bill.Enabled = (states.names or states.health or states.dist)

            -- Tracers desde arriba
            if states.tracers then
                local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    tracer.From = Vector2.new(camera.ViewportSize.X / 2, 0)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Visible = true
                else tracer.Visible = false end
            else tracer.Visible = false end
        end)
    end
    plr.CharacterAdded:Connect(setup)
    if plr.Character then setup(plr.Character) end
end

Players.PlayerAdded:Connect(applyESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= player then applyESP(p) end end

-- MINIMIZAR (BOTÓN "-")
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.BackgroundTransparency = 1
local minimized = false

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, v in pairs(main:GetChildren()) do
        if v:IsA("TextButton") and v ~= minBtn then v.Visible = not minimized end
    end
    main.Size = minimized and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 310)
    minBtn.Text = minimized and "+" or "-"
end)
