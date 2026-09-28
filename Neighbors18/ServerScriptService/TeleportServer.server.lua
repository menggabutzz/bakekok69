local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EXPECTED_PLACE_ID = 14236925335
if game.PlaceId ~= EXPECTED_PLACE_ID then return end

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local teleportEvent = remotes:WaitForChild("TeleportPlayer")
local teleportResult = remotes:WaitForChild("TeleportResult")

teleportEvent.OnServerEvent:Connect(function(requester, targetUserId)
    if not requester or not requester.Parent then return end
    if typeof(targetUserId) ~= "number" then
        teleportResult:FireClient(requester, false, "Target tidak valid.")
        return
    end

    local target = Players:GetPlayerByUserId(targetUserId)
    if not target or target == requester then
        teleportResult:FireClient(requester, false, "Player target tidak ditemukan.")
        return
    end

    local requesterCharacter = requester.Character
    local targetCharacter = target.Character
    if not requesterCharacter or not targetCharacter then
        teleportResult:FireClient(requester, false, "Character belum siap.")
        return
    end

    local requesterRoot = requesterCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not requesterRoot or not targetRoot then
        teleportResult:FireClient(requester, false, "HumanoidRootPart belum siap.")
        return
    end

    requesterCharacter:PivotTo(targetRoot.CFrame * CFrame.new(0, 3, 0))
    teleportResult:FireClient(requester, true, target.DisplayName)
end)
