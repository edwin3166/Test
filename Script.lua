--// Premium Chams GUI MOBILE + Aimbot (Lock Fuerte, Solo al Disparar) + Noclip + Team Check Toggle
--// 3 Fingers Single Tap Open/Close + SILENT AIM (Mouse Reposition)
--// Luau / Roblox

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Anti duplicate
if CoreGui:FindFirstChild("PremiumChamsGUI") then
	CoreGui.PremiumChamsGUI:Destroy()
end

-- Variables
local ChamsEnabled = false
local AimbotEnabled = false
local SilentAimEnabled = false    -- << NUEVO: Silent Aim
local NoclipEnabled = false
local TeamCheckEnabled = true
local GuiVisible = true
local ChamsTable = {}
local AimbotFOV = 100

-- Noclip connection
local NoclipConnection = nil

-- Touch gesture variables (single 3-finger tap)
local ActiveTouches = {}
local ThreeFingerToggled = false

-- Shooting detection
local function isShooting()
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		return true
	end
	local touchCount = 0
	for _ in pairs(ActiveTouches) do
		touchCount += 1
	end
	if touchCount > 0 and not ThreeFingerToggled then
		return true
	end
	return false
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumChamsGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 270, 0, 460)  -- más alto para nuevo botón
Main.Position = UDim2.new(0.5, -135, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Main
Stroke.Color = Color3.fromRGB(0,255,120)
Stroke.Thickness = 1.5

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "Premium Chams + Aimbot + Noclip + Silent Aim"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255,255,255)

-- Chams Toggle
local ToggleChams = Instance.new("TextButton")
ToggleChams.Parent = Main
ToggleChams.Size = UDim2.new(0,220,0,40)
ToggleChams.Position = UDim2.new(0.5,-110,0.1,0)
ToggleChams.BackgroundColor3 = Color3.fromRGB(25,25,25)
ToggleChams.Text = "Enable Chams"
ToggleChams.Font = Enum.Font.GothamBold
ToggleChams.TextSize = 15
ToggleChams.TextColor3 = Color3.fromRGB(255,255,255)
ToggleChams.BorderSizePixel = 0
Instance.new("UICorner", ToggleChams).CornerRadius = UDim.new(0,10)

local StatusChams = Instance.new("TextLabel")
StatusChams.Parent = Main
StatusChams.Size = UDim2.new(1,0,0,18)
StatusChams.Position = UDim2.new(0,0,0.22,0)
StatusChams.BackgroundTransparency = 1
StatusChams.Text = "Chams: OFF"
StatusChams.Font = Enum.Font.Gotham
StatusChams.TextSize = 13
StatusChams.TextColor3 = Color3.fromRGB(170,170,170)

-- Aimbot Toggle
local ToggleAimbot = Instance.new("TextButton")
ToggleAimbot.Parent = Main
ToggleAimbot.Size = UDim2.new(0,220,0,40)
ToggleAimbot.Position = UDim2.new(0.5,-110,0.28,0)
ToggleAimbot.BackgroundColor3 = Color3.fromRGB(25,25,25)
ToggleAimbot.Text = "Enable Aimbot"
ToggleAimbot.Font = Enum.Font.GothamBold
ToggleAimbot.TextSize = 15
ToggleAimbot.TextColor3 = Color3.fromRGB(255,255,255)
ToggleAimbot.BorderSizePixel = 0
Instance.new("UICorner", ToggleAimbot).CornerRadius = UDim.new(0,10)

local StatusAimbot = Instance.new("TextLabel")
StatusAimbot.Parent = Main
StatusAimbot.Size = UDim2.new(1,0,0,18)
StatusAimbot.Position = UDim2.new(0,0,0.4,0)
StatusAimbot.BackgroundTransparency = 1
StatusAimbot.Text = "Aimbot: OFF"
StatusAimbot.Font = Enum.Font.Gotham
StatusAimbot.TextSize = 13
StatusAimbot.TextColor3 = Color3.fromRGB(170,170,170)

-- SILENT AIM Toggle (nuevo)
local ToggleSilent = Instance.new("TextButton")
ToggleSilent.Parent = Main
ToggleSilent.Size = UDim2.new(0,220,0,40)
ToggleSilent.Position = UDim2.new(0.5,-110,0.46,0)
ToggleSilent.BackgroundColor3 = Color3.fromRGB(25,25,25)
ToggleSilent.Text = "Silent Aim"
ToggleSilent.Font = Enum.Font.GothamBold
ToggleSilent.TextSize = 15
ToggleSilent.TextColor3 = Color3.fromRGB(255,255,255)
ToggleSilent.BorderSizePixel = 0
Instance.new("UICorner", ToggleSilent).CornerRadius = UDim.new(0,10)

local StatusSilent = Instance.new("TextLabel")
StatusSilent.Parent = Main
StatusSilent.Size = UDim2.new(1,0,0,18)
StatusSilent.Position = UDim2.new(0,0,0.58,0)
StatusSilent.BackgroundTransparency = 1
StatusSilent.Text = "Silent Aim: OFF"
StatusSilent.Font = Enum.Font.Gotham
StatusSilent.TextSize = 13
StatusSilent.TextColor3 = Color3.fromRGB(170,170,170)

-- Team Check Toggle
local ToggleTeamCheck = Instance.new("TextButton")
ToggleTeamCheck.Parent = Main
ToggleTeamCheck.Size = UDim2.new(0,220,0,40)
ToggleTeamCheck.Position = UDim2.new(0.5,-110,0.64,0)
ToggleTeamCheck.BackgroundColor3 = Color3.fromRGB(0,140,70)
ToggleTeamCheck.Text = "Team Check: ON"
ToggleTeamCheck.Font = Enum.Font.GothamBold
ToggleTeamCheck.TextSize = 15
ToggleTeamCheck.TextColor3 = Color3.fromRGB(255,255,255)
ToggleTeamCheck.BorderSizePixel = 0
Instance.new("UICorner", ToggleTeamCheck).CornerRadius = UDim.new(0,10)

-- Noclip Toggle
local ToggleNoclip = Instance.new("TextButton")
ToggleNoclip.Parent = Main
ToggleNoclip.Size = UDim2.new(0,220,0,40)
ToggleNoclip.Position = UDim2.new(0.5,-110,0.82,0)
ToggleNoclip.BackgroundColor3 = Color3.fromRGB(25,25,25)
ToggleNoclip.Text = "Enable Noclip"
ToggleNoclip.Font = Enum.Font.GothamBold
ToggleNoclip.TextSize = 15
ToggleNoclip.TextColor3 = Color3.fromRGB(255,255,255)
ToggleNoclip.BorderSizePixel = 0
Instance.new("UICorner", ToggleNoclip).CornerRadius = UDim.new(0,10)

local StatusNoclip = Instance.new("TextLabel")
StatusNoclip.Parent = Main
StatusNoclip.Size = UDim2.new(1,0,0,18)
StatusNoclip.Position = UDim2.new(0,0,0.94,0)
StatusNoclip.BackgroundTransparency = 1
StatusNoclip.Text = "Noclip: OFF"
StatusNoclip.Font = Enum.Font.Gotham
StatusNoclip.TextSize = 13
StatusNoclip.TextColor3 = Color3.fromRGB(170,170,170)

-- Create Chams
local function ApplyChams(Player)
	if Player == LocalPlayer then return end

	local function Setup(Character)
		if Character:FindFirstChild("PremiumCham") then return end

		local Highlight = Instance.new("Highlight")
		Highlight.Name = "PremiumCham"
		Highlight.Parent = Character
		Highlight.FillTransparency = 0.2
		Highlight.OutlineTransparency = 0
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.Enabled = false

		table.insert(ChamsTable, Highlight)
	end

	if Player.Character then Setup(Player.Character) end
	Player.CharacterAdded:Connect(Setup)
end

for _, Player in ipairs(Players:GetPlayers()) do
	ApplyChams(Player)
end
Players.PlayerAdded:Connect(ApplyChams)

-- Aimbot target validation (con team check toggle)
local function isValidTarget(player)
	if player == LocalPlayer then return false end
	if TeamCheckEnabled then
		if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
			return false
		end
	end
	local char = player.Character
	if not char then return false end
	local head = char:FindFirstChild("Head")
	if not head then return false end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	return true
end

local function getClosestTarget()
	local camera = workspace.CurrentCamera
	if not camera then return nil end
	local camPos = camera.CFrame.Position
	local camLook = camera.CFrame.LookVector
	local closestAngle = AimbotFOV + 1
	local closestTarget = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if isValidTarget(player) then
			local head = player.Character.Head
			local dir = (head.Position - camPos).Unit
			local dot = camLook:Dot(dir)
			local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
			if angle <= AimbotFOV then
				local ray = Ray.new(camPos, dir * (head.Position - camPos).Magnitude)
				local ignoreList = {LocalPlayer.Character}
				local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
				if hit and hit:IsDescendantOf(player.Character) then
					if angle < closestAngle then
						closestAngle = angle
						closestTarget = head
					end
				end
			end
		end
	end
	return closestTarget
end

-- SILENT AIM: mueve el cursor a la cabeza del objetivo (sin mover cámara)
local function doSilentAim(targetHead)
	if not targetHead then return end
	local camera = workspace.CurrentCamera
	local viewportPoint = camera:WorldToViewportPoint(targetHead.Position)
	local onScreen = viewportPoint.Z > 0
	if onScreen then
		-- Mueve el mouse directamente a la cabeza del enemigo
		pcall(function()
			UserInputService:SetMouseLocation(Vector2.new(viewportPoint.X, viewportPoint.Y))
		end)
	end
end

-- Noclip functions
local function Noclip(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

local function RemoveNoclip(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = true
		end
	end
end

-- Main loop
RunService.RenderStepped:Connect(function()
	local camera = workspace.CurrentCamera
	if not camera then return end

	-- Chams rainbow
	if ChamsEnabled then
		local Hue = (tick() % 5) / 5
		local Color = Color3.fromHSV(Hue,1,1)
		for _, Cham in ipairs(ChamsTable) do
			if Cham and Cham.Parent then
				Cham.Enabled = true
				Cham.FillColor = Color
				Cham.OutlineColor = Color
			end
		end
	end

	-- SILENT AIM (prioridad sobre aimbot visible)
	if SilentAimEnabled and isShooting() then
		local targetHead = getClosestTarget()
		if targetHead then
			doSilentAim(targetHead)
		end
	-- AIMBOT VISIBLE (solo si Silent Aim está apagado)
	elseif AimbotEnabled and not SilentAimEnabled and isShooting() then
		local targetHead = getClosestTarget()
		if targetHead then
			camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
		end
	end
end)

-- Toggle Chams
ToggleChams.MouseButton1Click:Connect(function()
	ChamsEnabled = not ChamsEnabled
	if ChamsEnabled then
		ToggleChams.Text = "Disable Chams"
		StatusChams.Text = "Chams: ON"
		TweenService:Create(ToggleChams, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0,170,90) }):Play()
	else
		ToggleChams.Text = "Enable Chams"
		StatusChams.Text = "Chams: OFF"
		TweenService:Create(ToggleChams, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(25,25,25) }):Play()
		for _, Cham in ipairs(ChamsTable) do
			if Cham then Cham.Enabled = false end
		end
	end
end)

-- Toggle Aimbot (visible)
ToggleAimbot.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	if AimbotEnabled then
		ToggleAimbot.Text = "Disable Aimbot"
		StatusAimbot.Text = "Aimbot: ON (al disparar)"
		TweenService:Create(ToggleAimbot, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0,170,90) }):Play()
	else
		ToggleAimbot.Text = "Enable Aimbot"
		StatusAimbot.Text = "Aimbot: OFF"
		TweenService:Create(ToggleAimbot, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(25,25,25) }):Play()
	end
end)

-- Toggle Silent Aim
ToggleSilent.MouseButton1Click:Connect(function()
	SilentAimEnabled = not SilentAimEnabled
	if SilentAimEnabled then
		ToggleSilent.Text = "Disable Silent Aim"
		StatusSilent.Text = "Silent Aim: ON (sin mover cámara)"
		TweenService:Create(ToggleSilent, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0,170,90) }):Play()
	else
		ToggleSilent.Text = "Silent Aim"
		StatusSilent.Text = "Silent Aim: OFF"
		TweenService:Create(ToggleSilent, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(25,25,25) }):Play()
	end
end)

-- Toggle Team Check
ToggleTeamCheck.MouseButton1Click:Connect(function()
	TeamCheckEnabled = not TeamCheckEnabled
	if TeamCheckEnabled then
		ToggleTeamCheck.Text = "Team Check: ON"
		TweenService:Create(ToggleTeamCheck, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0,140,70) }):Play()
	else
		ToggleTeamCheck.Text = "Team Check: OFF"
		TweenService:Create(ToggleTeamCheck, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(170,0,0) }):Play()
	end
end)

-- Toggle Noclip
ToggleNoclip.MouseButton1Click:Connect(function()
	NoclipEnabled = not NoclipEnabled
	if NoclipEnabled then
		ToggleNoclip.Text = "Disable Noclip"
		StatusNoclip.Text = "Noclip: ON"
		TweenService:Create(ToggleNoclip, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0,170,90) }):Play()

		local currentChar = LocalPlayer.Character
		if currentChar then Noclip(currentChar) end

		NoclipConnection = LocalPlayer.CharacterAdded:Connect(function(char)
			if NoclipEnabled then Noclip(char) end
		end)
	else
		ToggleNoclip.Text = "Enable Noclip"
		StatusNoclip.Text = "Noclip: OFF"
		TweenService:Create(ToggleNoclip, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(25,25,25) }):Play()

		if NoclipConnection then
			NoclipConnection:Disconnect()
			NoclipConnection = nil
		end

		local currentChar = LocalPlayer.Character
		if currentChar then RemoveNoclip(currentChar) end
	end
end)

-- 3 Fingers Single Tap Open/Close
UserInputService.TouchStarted:Connect(function(Input)
	ActiveTouches[Input] = true
	local fingerCount = 0
	for _ in pairs(ActiveTouches) do fingerCount += 1 end

	if fingerCount >= 3 and not ThreeFingerToggled then
		ThreeFingerToggled = true
		GuiVisible = not GuiVisible
		Main.Visible = GuiVisible

		if GuiVisible then
			Main.BackgroundTransparency = 1
			TweenService:Create(Main, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
		end
	end
end)

UserInputService.TouchEnded:Connect(function(Input)
	ActiveTouches[Input] = nil
	local fingerCount = 0
	for _ in pairs(ActiveTouches) do fingerCount += 1 end
	if fingerCount == 0 then
		ThreeFingerToggled = false
	end
end)
