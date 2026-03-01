-- DARK MATTER MOD MENU
-- NOCLIP + FLY (JOYSTICK / WASD) + ESP HIGHLIGHT
-- PC & MOBILE

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ================= STATES =================
local noclip = false
local fly = false
local esp = false
local flySpeed = 60

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "DarkMatterGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,230,0,200)
main.Position = UDim2.new(0,20,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-40,0,35)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "MOD MENU"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Left

-- MINIMIZE BUTTON
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-35,0,2)
minimize.Text = "-"
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 22
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)

local function makeButton(text, y)
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

local noclipBtn = makeButton("NOCLIP: OFF", 45)
local flyBtn = makeButton("FLY: OFF", 85)
local espBtn = makeButton("ESP: OFF", 125)

-- ================= NOCLIP =================
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

-- ================= FLY (JOYSTICK / WASD) =================
local bv, bg

local function startFly()
	local char = player.Character
	if not char then return end
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")

	hum.PlatformStand = false

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e9,1e9,1e9)
	bv.Velocity = Vector3.zero
	bv.Parent = hrp

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp
end

local function stopFly()
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
end

RunService.RenderStepped:Connect(function()
	if fly and bv and player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end

		local move = hum.MoveDirection
		local y = 0

		if UIS:IsKeyDown(Enum.KeyCode.Space) then y = 1 end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then y = -1 end

		bv.Velocity = Vector3.new(move.X, y, move.Z) * flySpeed
		bg.CFrame = hrp.CFrame
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = fly and "FLY: ON" or "FLY: OFF"
	flyBtn.BackgroundColor3 = fly and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)
	if fly then startFly() else stopFly() end
end)

-- ================= ESP (HIGHLIGHT REAL) =================
local espObjs = {}

local function addESP(plr)
	if plr == player then return end

	local function apply(char)
		if espObjs[plr] then espObjs[plr]:Destroy() end

		local h = Instance.new("Highlight")
		h.Adornee = char
		h.FillTransparency = 1
		h.OutlineTransparency = 0
		h.OutlineColor = Color3.fromRGB(255,0,0)
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Enabled = esp
		h.Parent = gui

		espObjs[plr] = h
	end

	if plr.Character then apply(plr.Character) end
	plr.CharacterAdded:Connect(apply)
end

for _,p in pairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)

espBtn.MouseButton1Click:Connect(function()
	esp = not esp
	espBtn.Text = esp and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = esp and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)
	for _,h in pairs(espObjs) do if h then h.Enabled = esp end end
end)

-- ================= MINIMIZE =================
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	noclipBtn.Visible = not minimized
	flyBtn.Visible = not minimized
	espBtn.Visible = not minimized
	main.Size = minimized and UDim2.new(0,230,0,40) or UDim2.new(0,230,0,200)
	minimize.Text = minimized and "+" or "-"
end)
