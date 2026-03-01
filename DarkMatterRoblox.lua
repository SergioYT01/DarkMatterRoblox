-- MOD MENU COMPLETO: NOCLIP + FLY + ESP
-- Compatible PC y MÓVIL
-- LocalScript

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local userInput = game:GetService("UserInputService")

local noclip = false
local fly = false
local esp = false
local flySpeed = 50

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "ModMenuGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 230, 0, 200)
mainFrame.Position = UDim2.new(0, 20, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

-- ===== DRAG (MOVER MENÚ) =====
local dragging, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

mainFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

userInput.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- ===== TÍTULO =====
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MOD MENU"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Left

-- MINIMIZAR
local minimize = Instance.new("TextButton", mainFrame)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-35,0,2)
minimize.Text = "-"
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 22
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundTransparency = 1

-- ===== BOTONES =====
local function makeButton(text, y)
	local b = Instance.new("TextButton", mainFrame)
	b.Size = UDim2.new(0,190,0,35)
	b.Position = UDim2.new(0.5,-95,0,y)
	b.Text = text
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(170,50,50)
	Instance.new("UICorner", b)
	return b
end

local noclipBtn = makeButton("NOCLIP: OFF", 45)
local flyBtn = makeButton("FLY: OFF", 85)
local espBtn = makeButton("ESP: OFF", 125)

-- ================= NOCLIP =================
runService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, p in pairs(player.Character:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)
end)

-- ================= FLY (PC + MÓVIL) =================
local bodyGyro, bodyVelocity

local function startFly()
	local char = player.Character
	if not char then return end
	local hrp = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")

	humanoid.PlatformStand = true

	bodyGyro = Instance.new("BodyGyro", hrp)
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)

	bodyVelocity = Instance.new("BodyVelocity", hrp)
	bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
end

local function stopFly()
	local char = player.Character
	if char then
		local humanoid = char:FindFirstChild("Humanoid")
		if humanoid then humanoid.PlatformStand = false end
	end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

runService.RenderStepped:Connect(function()
	if fly and bodyVelocity and player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			bodyVelocity.Velocity = humanoid.MoveDirection * flySpeed
			bodyGyro.CFrame = workspace.CurrentCamera.CFrame
		end
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = fly and "FLY: ON" or "FLY: OFF"
	flyBtn.BackgroundColor3 = fly and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)
	if fly then startFly() else stopFly() end
end)

-- ================= ESP =================
local espObjects = {}

local function addESP(plr)
	if plr == player then return end
	plr.CharacterAdded:Connect(function(char)
		if not esp then return end
		local head = char:WaitForChild("Head",5)
		if not head then return end

		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.new(0,100,0,40)
		bill.AlwaysOnTop = true
		bill.Adornee = head

		local txt = Instance.new("TextLabel", bill)
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.Text = plr.Name
		txt.TextColor3 = Color3.fromRGB(255,0,0)
		txt.Font = Enum.Font.SourceSansBold
		txt.TextSize = 14

		bill.Parent = gui
		espObjects[plr] = bill
	end)
end

for _, plr in pairs(players:GetPlayers()) do
	addESP(plr)
end
players.PlayerAdded:Connect(addESP)

espBtn.MouseButton1Click:Connect(function()
	esp = not esp
	espBtn.Text = esp and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = esp and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)

	for _, v in pairs(espObjects) do
		if v then v.Enabled = esp end
	end
end)

-- ================= MINIMIZAR =================
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	noclipBtn.Visible = not minimized
	flyBtn.Visible = not minimized
	espBtn.Visible = not minimized
	mainFrame.Size = minimized and UDim2.new(0,230,0,40) or UDim2.new(0,230,0,200)
	minimize.Text = minimized and "+" or "-"
end)
