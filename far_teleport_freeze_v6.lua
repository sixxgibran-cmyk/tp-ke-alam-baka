-- Universal Far Teleport + Total Freeze (Delta / Roblox) - v6
-- Tombol ON : teleport ke tempat jauh sekaligus freeze total client.
-- Tombol OFF: kembali ke posisi awal (hanya bisa ditekan kalau client
--             sudah tidak freeze, misalnya script dihentikan oleh Roblox).
-- Kalau client hang total, jalan keluar = tutup paksa aplikasi Roblox.

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local FAR = 1e9  -- jarak teleport

local active = false
local savedCF

local function getHRP()
	local char = lp.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportFar()
	local hrp = getHRP()
	if not hrp then return false end
	savedCF = hrp.CFrame
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(FAR, FAR, FAR)
	hrp.Anchored = true
	active = true
	return true
end

local function returnBack()
	local hrp = getHRP()
	if hrp and savedCF then
		hrp.Anchored = false
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.CFrame = savedCF
	end
	active = false
end

local function freezeTotal()
	-- kasih waktu singkat supaya posisi baru terkirim ke server
	task.wait(0.3)
	if not active then return end

	-- freeze total: loop tanpa yield
	while true do end
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
btn.Text = "Freeze: OFF"
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

btn.MouseButton1Click:Connect(function()
	if active then
		returnBack()
		btn.Text = "Freeze: OFF"
	else
		if teleportFar() then
			btn.Text = "Freeze: ON"
			task.spawn(freezeTotal)
		end
	end
end)

-- Reset toggle kalau karakter mati / respawn
lp.CharacterAdded:Connect(function()
	active = false
	btn.Text = "Freeze: OFF"
end)
