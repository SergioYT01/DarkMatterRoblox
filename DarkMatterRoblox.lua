-- [[ SERVICIOS ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- [[ CONFIGURACIÓN DE COLORES ]] --
local COLORS = {
	Background = Color3.fromRGB(15, 10, 25),
	Accent = Color3.fromRGB(140, 50, 255),
	Text = Color3.fromRGB(240, 240, 240),
	SwitchOff = Color3.fromRGB(40, 35, 50),
	SwitchOn = Color3.fromRGB(120, 40, 220)
}

-- [[ CREACIÓN DE UI ]] --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatterV2"
screenGui.Parent = playerGui

-- Marco Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 200) -- Tamaño compacto
mainFrame.Position = UDim2.new(0.5, -140, 0.4, 0)
mainFrame.BackgroundColor3 = COLORS.Background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Permite moverlo por la pantalla
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Barra de Título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.Text = "DARKMATTER"
titleLabel.TextColor3 = COLORS.Accent
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- Botón Minimizar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"
minBtn.TextColor3 = COLORS.Text
minBtn.BackgroundColor3 = COLORS.SwitchOff
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

-- Contenedor de Opciones
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, 0, 1, -40)
container.Position = UDim2.new(0, 0, 0, 40)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- [[ FUNCIÓN PARA CREAR SWITCHES ]] --
local function createSwitch(name, posY, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -30, 0, 40)
	row.Position = UDim2.new(0, 15, 0, posY)
	row.BackgroundTransparency = 1
	row.Parent = container

	local label = Instance.new("TextLabel")
	label.Text = name
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.TextColor3 = COLORS.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = row

	local switchBg = Instance.new("TextButton")
	switchBg.Size = UDim2.new(0, 45, 0, 22)
	switchBg.Position = UDim2.new(1, -45, 0.5, -11)
	switchBg.BackgroundColor3 = COLORS.SwitchOff
	switchBg.Text = ""
	switchBg.Parent = row
	
	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(1, 0)
	sCorner.Parent = switchBg

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 18, 0, 18)
	circle.Position = UDim2.new(0, 2, 0.5, -9)
	circle.BackgroundColor3 = Color3.new(1, 1, 1)
	circle.Parent = switchBg
	
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(1, 0)
	cCorner.Parent = circle

	local active = false
	switchBg.MouseButton1Click:Connect(function()
		active = not active
		local targetPos = active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
		local targetCol = active and COLORS.SwitchOn or COLORS.SwitchOff
		
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
		TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
		
		callback(active)
	end)
end

-- [[ LÓGICA DE MINIMIZAR ]] --
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	container.Visible = not minimized
	if minimized then
		mainFrame:TweenSize(UDim2.new(0, 280, 0, 40), "Out", "Quad", 0.3, true)
		minBtn.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 280, 0, 200), "Out", "Quad", 0.3, true)
		minBtn.Text = "-"
	end
end)

-- [[ ASIGNACIÓN DE FUNCIONES ]] --

createSwitch("Modo Fantasma (Noclip)", 10, function(state)
	if state then
		print("Noclip Activado")
		-- Aquí iría la lógica de colisión
	else
		print("Noclip Desactivado")
	end
end)

createSwitch("Modo Vuelo (WASD/Joy)", 60, function(state)
	if state then
		print("Vuelo Activado")
		-- Aquí iría la lógica de BodyVelocity
	else
		print("Vuelo Desactivado")
	end
end)
