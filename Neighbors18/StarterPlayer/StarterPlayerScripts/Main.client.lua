local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local EXPECTED_PLACE_ID = 14236925335
if game.PlaceId ~= EXPECTED_PLACE_ID then
	return
end

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local teleportEvent = remotes:WaitForChild("TeleportPlayer")
local teleportResult = remotes:WaitForChild("TeleportResult")
if not teleportEvent:IsA("RemoteEvent") or not teleportResult:IsA("RemoteEvent") then
	error("Neighbors18 remotes must be RemoteEvents")
end

local gui = Instance.new("ScreenGui")
gui.Name = "Neighbors18Teleport"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 360)
frame.Position = UDim2.new(0, 25, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "Neighbors 18+"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 28)
status.Position = UDim2.fromOffset(10, 48)
status.BackgroundTransparency = 1
status.Text = "Pilih player untuk teleport"
status.TextColor3 = Color3.fromRGB(180, 180, 185)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -88)
list.Position = UDim2.fromOffset(10, 78)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

local requestPending = false
local requestSerial = 0
local REQUEST_TIMEOUT_SECONDS = 8

local function requestTeleport(targetPlayer)
	if requestPending then
		return
	end

	requestPending = true
	requestSerial = requestSerial + 1
	local thisRequest = requestSerial
	status.Text = "Teleporting ke " .. targetPlayer.DisplayName .. "..."
	teleportEvent:FireServer(targetPlayer.UserId)

	task.delay(REQUEST_TIMEOUT_SECONDS, function()
		if requestPending and requestSerial == thisRequest then
			requestPending = false
			status.Text = "Server tidak merespons. Coba lagi."
		end
	end)
end

local function addPlayerButton(player)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -4, 0, 38)
	button.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
	button.BorderSizePixel = 0
	button.Text = player.DisplayName .. "  @" .. player.Name
	button.TextColor3 = Color3.fromRGB(240, 240, 240)
	button.TextSize = 14
	button.Font = Enum.Font.Gotham
	button.Parent = list
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

	button.Activated:Connect(function()
		requestTeleport(player)
	end)
end

local function refreshPlayerList()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local otherPlayers = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			otherPlayers = otherPlayers + 1
			addPlayerButton(player)
		end
	end

	if not requestPending then
		status.Text = otherPlayers > 0 and "Pilih player untuk teleport" or "Tidak ada player lain."
	end
end

local dragging = false
local dragStartInput
local dragStartPosition
local frameStartPosition

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStartInput = input
		dragStartPosition = input.Position
		frameStartPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging or not dragStartInput then
		return
	end

	local isMouseDrag = dragStartInput.UserInputType == Enum.UserInputType.MouseButton1
		and input.UserInputType == Enum.UserInputType.MouseMovement
	local isTouchDrag = dragStartInput.UserInputType == Enum.UserInputType.Touch
		and input == dragStartInput
	if not isMouseDrag and not isTouchDrag then
		return
	end

	local delta = input.Position - dragStartPosition
	frame.Position = UDim2.new(
		frameStartPosition.X.Scale,
		frameStartPosition.X.Offset + delta.X,
		frameStartPosition.Y.Scale,
		frameStartPosition.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if dragging and input == dragStartInput then
		dragging = false
		dragStartInput = nil
	end
end)

teleportResult.OnClientEvent:Connect(function(succeeded, message)
	requestPending = false
	requestSerial = requestSerial + 1
	if succeeded then
		status.Text = "Teleported ke " .. tostring(message)
	else
		status.Text = tostring(message or "Teleport gagal.")
	end
end)

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()
