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

-- ===== FLY MEJORADO =====
local bv, bg

local function startFly()
	local char = player.Character
	if not char then return end
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")

	hum.PlatformStand = true

	bv = Instance.new("BodyVelocity", hrp)
	bv.MaxForce = Vector3.new(1e9,1e9,1e9)
	bv.Velocity = Vector3.zero

	bg = Instance.new("BodyGyro", hrp)
	bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
	bg.CFrame = hrp.CFrame
end

RunService.RenderStepped:Connect(function()
	if fly and bv and player.Character then
		local char = player.Character
		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end

		local move = hum.MoveDirection
		local up = 0

		if UIS:IsKeyDown(Enum.KeyCode.Space) then up = 1 end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = -1 end

		local dir = hrp.CFrame:VectorToWorldSpace(move)
		bv.Velocity = Vector3.new(dir.X, up, dir.Z) * flySpeed
		bg.CFrame = hrp.CFrame
	end
end)
-- ===== ESP REAL CON HIGHLIGHT =====
local espHighlights = {}

local function addESP(plr)
	if plr == player then return end

	local function apply(char)
		if espHighlights[plr] then
			espHighlights[plr]:Destroy()
		end

		local h = Instance.new("Highlight")
		h.Adornee = char
		h.FillTransparency = 1
		h.OutlineTransparency = 0
		h.OutlineColor = Color3.fromRGB(255,0,0)
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Enabled = esp
		h.Parent = gui

		espHighlights[plr] = h
	end

	if plr.Character then
		apply(plr.Character)
	end

	plr.CharacterAdded:Connect(apply)
end

for _,p in pairs(Players:GetPlayers()) do
	addESP(p)
end

Players.PlayerAdded:Connect(addESP)

espBtn.MouseButton1Click:Connect(function()
	esp = not esp
	espBtn.Text = esp and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = esp and Color3.fromRGB(50,170,50) or Color3.fromRGB(170,50,50)

	for _,h in pairs(espHighlights) do
		if h then h.Enabled = esp end
	end
end)
