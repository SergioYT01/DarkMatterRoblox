-- DARK MATTER MOD MENU (FIXED)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================= ESTADOS =================
local noclip = false
local fly = false
local esp = false
local flySpeed = 50

-- ================= GUI PRINCIPAL =================
local gui = Instance.new("ScreenGui")
gui.Name = "DarkMatterGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 210)
main.Position = UDim2.new(0.05, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "DARK MATTER"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- BOTÓN MINIMIZAR
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -35, 0, 5)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1, 1, 1)

local function createBtn(text, y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(0, 200, 0, 40)
	b.Position = UDim2.new(0.5, -100, 0, y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1, 1, 1)
	b.BackgroundColor3 = Color3.fromRGB(170, 50, 50) -- Rojo por defecto
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local noclipBtn = createBtn("NOCLIP: OFF", 50)
local flyBtn = createBtn("VUELO: APAGADO", 100)
local espBtn = createBtn("ESP: OFF", 150)

-- ================= LÓGICA DE MINIMIZAR =================
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	noclipBtn.Visible = not minimized
	flyBtn.Visible = not minimized
	espBtn.Visible = not minimized
	
	if minimized then
		main:TweenSize(UDim2.new(0, 240, 0, 40), "Out", "Quad", 0.3, true)
		minimize.Text = "+"
	else
		main:TweenSize(UDim2.new(0, 240, 0, 210), "Out", "Quad", 0.3, true)
		minimize.Text = "-"
	end
end)

-- ================= LÓGICA NOCLIP =================
RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, v in pairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
end)

-- ================= LÓGICA VUELO (MEJORADA) =================
local velInstance

local function toggleFly()
	fly = not fly
	flyBtn.Text = fly and "VUELO: ENCENDIDO" or "VUELO: APAGADO"
	flyBtn.BackgroundColor3 = fly and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
	
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart

	if fly then
		velInstance = Instance.new("BodyVelocity")
		velInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		velInstance.Velocity = Vector3.new(0, 0, 0)
		velInstance.Parent = hrp
	else
		if velInstance then velInstance:Destroy() end
		char.Humanoid.PlatformStand = false
	end
end

RunService.RenderStepped:Connect(function()
	if fly and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = player.Character.HumanoidRootPart
		local hum = player.Character.Humanoid
		
		-- Movimiento basado en la dirección a la que mira la cámara
		local moveDir = hum.MoveDirection
		local camLook = camera.CFrame.LookVector
		
		if moveDir.Magnitude > 0 then
			velInstance.Velocity = camLook * flySpeed
		else
			velInstance.Velocity = Vector3.new(0, 0, 0)
		end
		
		hrp.Velocity = Vector3.new(0,0,0) -- Evita caídas por gravedad
	end
end)

flyBtn.MouseButton1Click:Connect(toggleFly)

-- ================= LÓGICA ESP (INFINITO) =================
local espContainers = {}

local function applyESP(plr)
	if plr == player then return end

	local function setupESP(character)
		if not character then return end
		
		-- Eliminar rastro anterior si existe
		if espContainers[plr] then espContainers[plr]:Destroy() end

		-- Creamos una caja visual (Adornment) que no tiene el límite de 31
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "ESP_Box_" .. plr.Name
		box.Size = Vector3.new(4, 6, 1) -- Tamaño aproximado de un personaje
		box.Color3 = Color3.fromRGB(255, 0, 0) -- Rojo
		box.Transparency = 0.6
		box.AlwaysOnTop = true
		box.ZIndex = 10
		box.Adornee = character:WaitForChild("HumanoidRootPart", 5)
		box.Visible = esp
		box.Parent = gui -- Guardado en tu menú para seguridad

		espContainers[plr] = box
	end

	-- Se activa al aparecer y al reaparecer
	plr.CharacterAdded:Connect(setupESP)
	if plr.Character then setupESP(plr.Character) end
end

-- Escuchar jugadores actuales y nuevos
Players.PlayerAdded:Connect(applyESP)
for _, p in pairs(Players:GetPlayers()) do applyESP(p) end

-- Botón del Menú
espBtn.MouseButton1Click:Connect(function()
	esp = not esp
	espBtn.Text = esp and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = esp and Color3.fromRGB(50, 170, 50) or Color3.fromRGB(170, 50, 50)
	
	-- Cambiar visibilidad de todas las cajas
	for _, box in pairs(espContainers) do
		if box then box.Visible = esp end
	end
end)
