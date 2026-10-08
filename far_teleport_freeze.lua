-- Universal Far Teleport Freeze (Delta / Roblox)
-- Teleport ke koordinat ekstrem supaya fisika & render di client lag/freeze.
-- Tekan tombol lagi untuk balik (kalau client belum hang total).

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local FAR = 1e20          -- jarak teleport. Naikkan (1e8, 1e9) kalau belum freeze
local AUTO_RETURN = nil  -- isi detik (misal 3) supaya balik otomatis, nil = manual

local active = false
local savedCF
local goBack

local function getHRP()
	local char = lp.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function goFar()
	local hrp = getHRP()
	if not hrp then return end
	savedCF = hrp.CFrame
	active = true
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(FAR, FAR, FAR)
	hrp.Anchored = true
	if AUTO_RETURN then
		task.delay(AUTO_RETURN, function()
			if active then goBack() end
		end)
	end
end

goBack = function()
	local hrp = getHRP()
	if hrp and savedCF then
		hrp.Anchored = false
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.CFrame = savedCF
	end
	active = false
end

-- GUI tombol toggle
local gui = Instance.new("ScreenGui")
gui.Name = "FarTPFreeze"
gui.ResetOnSpawn = false

local ok = pcall(function()
	gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ok or not gui.Parent then
	gui.Parent = lp:WaitForChild("PlayerGui")
end

local btn = Instance.new("TextButton")
btn.Size = UDim2.fromOffset(170, 46)
btn.Position = UDim2.new(0, 20, 0.5, 0)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 16
btn.Text = "Far TP: OFF"
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

btn.MouseButton1Click:Connect(function()
	if active then
		goBack()
		btn.Text = "Far TP: OFF"
	else
		btn.Text = "Far TP: ON"
		goFar()
	end
end)

lp.CharacterAdded:Connect(function()
	active = false
	btn.Text = "Far TP: OFF"
end)
