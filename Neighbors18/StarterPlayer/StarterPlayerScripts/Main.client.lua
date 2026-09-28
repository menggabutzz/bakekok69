local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local EXPECTED_PLACE_ID = 14236925335
if game.PlaceId ~= EXPECTED_PLACE_ID then return end

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local teleportEvent = remotes:WaitForChild("TeleportPlayer")
local teleportResult = remotes:WaitForChild("TeleportResult")

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
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 28)
status.Position = UDim2.fromOffset(10, 48)
status.BackgroundTransparency = 1
status.Text = "Pilih player untuk teleport"
status.TextColor3 = Color3.fromRGB(180,180,185)
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

local function addPlayerButton(player)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(42,42,47)
    b.BorderSizePixel = 0
    b.Text = player.DisplayName .. "  @" .. player.Name
    b.TextColor3 = Color3.fromRGB(240,240,240)
    b.TextSize = 14
    b.Font = Enum.Font.Gotham
    b.Parent = list
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.Activated:Connect(function()
        status.Text = "Teleporting ke " .. player.DisplayName .. "..."
        teleportEvent:FireServer(player.UserId)
    end)
end

local function refresh()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then addPlayerButton(player) end
    end
    status.Text = (#Players:GetPlayers() > 1) and "Pilih player untuk teleport" or "Tidak ada player lain."
end

local dragging, dragStart, startPosition = false, nil, nil
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local d = input.Position - dragStart
    frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset+d.X, startPosition.Y.Scale, startPosition.Y.Offset+d.Y)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

teleportResult.OnClientEvent:Connect(function(success, name)
    status.Text = success and ("Teleported ke " .. tostring(name)) or tostring(name or "Teleport gagal.")
end)

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
refresh()
