-- DARK MATTER MOD MENU
-- NOCLIP + FLY (CONTROLABLE) + ESP HITBOX
-- PC + MÓVIL
-- LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ====== ESTADOS ======
local noclip = false
local fly = false
local esp = false
local flySpeed = 60

-- ====== GUI ======
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "DarkMatterGui"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,230,0,200)
main.Position = UDim2.new(0,20,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "DARK MATTER"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local function newButton(text, y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(0,190,0,35)
	b.Position = UDim2.new(0.5,-95,0,y)
	b.Text = text
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 15
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(170,50,50)
	Instance.new("UICorner", b)
	return b
end

local noclipBtn = newButton("NOCLIP: OFF", 45)
local flyBtn = newButton("FLY: OFF", 85)
local espBtn = newButton("ESP: OFF", 125)

-- ====== NOCLIP ======
RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _,v in pairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)
end)

-- ====== FLY REAL (CONTROLABLE) ======
local bv, bg

local function startFly()
	local char = player.Character
	if not char then return end
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")

	hum.PlatformStand = true

	bv = Instance.new("BodyVelocity", hrp)
	bv.MaxForce = Vector3.new(1e9,1e9,1e9)

	bg = Instance.new("BodyGyro", hrp)
	bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
end

local function stopFly()
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	if player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

RunService.RenderStepped:Connect(function()
	if fly and bv and player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end

		local moveDir = hum.MoveDirection
		local up = 0

		if UIS:IsKeyDown(Enum.KeyCode.Space) then up = 1 end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = -1 end

		bv.Velocity = (moveDir * flySpeed) + Vector3.new(0, up * flySpeed, 0)
		bg.CFrame = hrp.CFrame
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = fly and "FLY: ON" or "FLY: OFF"
	flyBtn.BackgroundColor3 = fly and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)
	if fly then startFly() else stopFly() end
end)

-- ====== ESP HITBOX ======
local espBoxes = {}

local function addESP(plr)
	if plr == player then return end

	plr.CharacterAdded:Connect(function(char)
		if not esp then return end
		local hrp = char:WaitForChild("HumanoidRootPart",5)
		if not hrp then return end

		local box = Instance.new("BoxHandleAdornment")
		box.Adornee = hrp
		box.Size = Vector3.new(4,6,2)
		box.Color3 = Color3.fromRGB(255,0,0)
		box.Transparency = 0.5
		box.AlwaysOnTop = true
		box.ZIndex = 5
		box.Parent = gui

		espBoxes[plr] = box
	end)
end

for _,p in pairs(Players:GetPlayers()) do
	addESP(p)
end
Players.PlayerAdded:Connect(addESP)

espBtn.MouseButton1Click:Connect(function()
	esp = not esp
	espBtn.Text = esp and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = esp and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)

	for _,v in pairs(espBoxes) do
		if v then v.Visible = esp end
	end
end)
