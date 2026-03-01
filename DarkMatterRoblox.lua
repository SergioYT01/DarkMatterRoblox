-- ==========================================
-- Interfaz DarkMatter (Plantilla Visual)
-- ==========================================

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear la pantalla principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMatterGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Crear el marco principal (Fondo)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 5, 25) -- Morado muy oscuro (casi negro)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Borde redondeado para el marco principal
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Barra de Título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 10, 50) -- Morado oscuro
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- Arreglar las esquinas inferiores de la barra de título
local titleBottom = Instance.new("Frame")
titleBottom.Size = UDim2.new(1, 0, 0, 10)
titleBottom.Position = UDim2.new(0, 0, 1, -10)
titleBottom.BackgroundColor3 = Color3.fromRGB(30, 10, 50)
titleBottom.BorderSizePixel = 0
titleBottom.Parent = titleBar

-- Texto del Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(180, 100, 255) -- Morado neón/brillante
titleLabel.Text = "DARKMATTER"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

-- Función para crear botones estéticos
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 15, 75)
    btn.TextColor3 = Color3.fromRGB(220, 200, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    -- Efecto hover (Al pasar el ratón)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(65, 25, 105)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(45, 15, 75)
    end)
    
    return btn
end

-- Añadir botones (Sin funcionalidad de exploit)
local noclipBtn = createButton("Modo Fantasma (Solo UI)", 70)
local flyBtn = createButton("Modo Vuelo (Solo UI)", 125)

-- Función para cerrar el menú
local closeBtn = createButton("Cerrar Menú", 380)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 40) -- Un tono más rojizo/magenta para cerrar
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(110, 30, 50) end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 40) end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
