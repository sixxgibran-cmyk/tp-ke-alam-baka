-- Universal Underground Hide (Delta / Roblox)
-- Badan karakter ditenggelamkan ke bawah tanah (jadi tidak kelihatan),
-- sementara kamera tetap di atas tanah supaya kamu masih bisa lihat map.
-- Kedalaman bisa diatur dengan tombol - dan +.
-- Jalan di R6 maupun R15.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local depth = 8          -- kedalaman awal (studs)
local MIN_DEPTH = 0
local MAX_DEPTH = 40
local STEP = 1

local active = false
local state = {}         -- { motor = Motor6D, c0 = CFrame }
local noclipConn
local savedCollide = {}  -- [BasePart] = CanCollide asli

local function getRoot(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	-- cari Motor6D yang menyambung HumanoidRootPart ke badan
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("Motor6D") and d.Part0 == hrp then
			return d, hrp
		end
	end
end

local function apply()
	local char = lp.Character
	if not char then return false end
	local motor = getRoot(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not (motor and hum) then return false end

	if state.motor ~= motor then
		state.motor = motor
		state.c0 = motor.C0
	end

	-- geser badan ke bawah relatif terhadap HumanoidRootPart
	motor.C0 = CFrame.new(0, -depth, 0) * state.c0
	-- naikkan kamera supaya tidak ikut masuk ke bawah tanah
	hum.CameraOffset = Vector3.new(0, depth, 0)
	return true
end

local function restore()
	if state.motor and state.motor.Parent and state.c0 then
		state.motor.C0 = state.c0
	end
	state = {}

	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.CameraOffset = Vector3.zero
	end

	for part, was in pairs(savedCollide) do
		if part.Parent then
			part.CanCollide = was
		end
	end
	savedCollide = {}
end

local function startNoclip()
	if noclipConn then return end
	-- badan (selain HumanoidRootPart) dimatikan tabrakannya,
	-- supaya tidak bentrok dengan tanah saat berada di bawahnya
	noclipConn = RunService.Stepped:Connect(function()
		local char = lp.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p ~= hrp then
				if savedCollide[p] == nil then
					savedCollide[p] = p.CanCollide
				end
				p.CanCollide = false
			end
		end
	end)
end

local function stopNoclip()
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "UndergroundHide"
gui.ResetOnSpawn = false

local ok = pcall(function()
	gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ok or not gui.Parent then
	gui.Parent = lp:WaitForChild("PlayerGui")
end

local function makeButton(text, x, y, w, h)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(w, h)
	b.Position = UDim2.new(0, x, 0.5, y)
	b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = text
	b.Parent = gui
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	return b
end

local toggleBtn = makeButton("Underground: OFF", 20, 0, 170, 46)
local minusBtn = makeButton("-", 20, 54, 46, 40)
local plusBtn = makeButton("+", 144, 54, 46, 40)

local label = Instance.new("TextLabel")
label.Size = UDim2.fromOffset(66, 40)
label.Position = UDim2.new(0, 72, 0.5, 54)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = gui

local function refreshLabel()
	label.Text = "Depth: " .. depth
end
refreshLabel()

local function changeDepth(delta)
	depth = math.clamp(depth + delta, MIN_DEPTH, MAX_DEPTH)
	refreshLabel()
	if active then
		apply()
	end
end

minusBtn.MouseButton1Click:Connect(function()
	changeDepth(-STEP)
end)
plusBtn.MouseButton1Click:Connect(function()
	changeDepth(STEP)
end)

toggleBtn.MouseButton1Click:Connect(function()
	if active then
		stopNoclip()
		restore()
		active = false
		toggleBtn.Text = "Underground: OFF"
	else
		if apply() then
			startNoclip()
			active = true
			toggleBtn.Text = "Underground: ON"
		end
	end
end)

-- Reset kalau karakter mati / respawn
lp.CharacterAdded:Connect(function()
	stopNoclip()
	state = {}
	savedCollide = {}
	active = false
	toggleBtn.Text = "Underground: OFF"
end)
