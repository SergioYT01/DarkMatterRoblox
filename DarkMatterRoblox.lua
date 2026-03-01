-- DARK MATTER V5: INTERFAZ SCROLLING + ESP MASTER FIX + VUELO 3D REAL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================= ESTADOS =================
local states = {
    noclip = false, fly = false, 
    espMaster = false,
    espBox = false, -- Este ahora será el Contorno (Highlight)
    espSquare = false, -- Esta es la Hitbox cuadrada blanca
    espNames = false, espDist = false, espTracers = false
}
local flySpeed = 50

-- ================= GUI PROFESIONAL =================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DarkMatterFinal"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 250, 0, 300) -- Tamaño predeterminado fijo
main.Position = UDim2.new(0.1, 0, 0.2, 0)
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
title.TextSize = 18

-- CONTENEDOR CON SCROLL (Para ver todas las opciones sin bugs)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 450) -- Espacio para muchas opciones
scroll.ScrollBarThickness = 4

local function createToggle(name, y, stateKey, parent, isMaster)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
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
    end)
    return btn
end

-- BOTONES DENTRO DEL SCROLL
createToggle("NOCLIP", 10, "noclip", scroll)
createToggle("VUELO 3D", 60, "fly", scroll)
createToggle("ESP MASTER", 110, "espMaster", scroll)
createToggle("HITBOX CUADRADA", 160, "espSquare", scroll) -- La que faltaba
createToggle("CONTORNO (BOX)", 210, "espBox", scroll)
createToggle("NOMBRES", 260, "espNames", scroll)
createToggle("DISTANCIA", 310, "espDist", scroll)
createToggle("LINEAS", 360, "espTracers", scroll)

-- ================= LÓGICA DE VUELO 3D (REPARADA) =================
local bv = nil
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if states.fly and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        
        if not bv or bv.Parent ~= hrp then
            if bv then bv:Destroy() end
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end

        -- Vuelo intuitivo: El joystick ahora mueve relativo a donde mira la cámara
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            -- Esta fórmula corrige la inversión: Camina hacia donde miras
            bv.Velocity = (camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z * 1.5))) * flySpeed
        else
            bv.Velocity = Vector3.new(0, 0.1, 0) -- Mantiene altura
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

-- ================= LÓGICA ESP COMPLETA =================
local function applyESP(plr)
    local function setup(char)
        local root = char:WaitForChild("HumanoidRootPart", 10)
        
        -- 1. Hitbox Cuadrada Blanca (BoxHandleAdornment)
        local square = Instance.new("BoxHandleAdornment", gui)
        square.Size = Vector3.new(4, 5.5, 0.1)
        square.AlwaysOnTop = true
        square.Color3 = Color3.new(1, 1, 1) -- Blanco puro
        square.Transparency = 0.6
        square.Adornee = root

        -- 2. Contorno (Highlight)
        local highlight = Instance.new("Highlight", gui)
        highlight.Adornee = char
        highlight.OutlineColor = Color3.new(1, 0, 0) -- Rojo

        -- 3. Info Text
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

        RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not states.espMaster then
                square.Visible = false; highlight.Enabled = false; bill.Enabled = false
                return
            end

            square.Visible = states.espSquare
            highlight.Enabled = states.espBox
            
            local info = ""
            if states.espNames then info = info .. plr.Name .. "\n" end
            if states.espDist then 
                local d = math.floor((root.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                info = info .. d .. " Studs" 
            end
            label.Text = info
            bill.Enabled = (states.espNames or states.espDist)
        end)
    end
    plr.CharacterAdded:Connect(setup)
    if plr.Character then setup(plr.Character) end
end

Players.PlayerAdded:Connect(applyESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= player then applyESP(p) end end
