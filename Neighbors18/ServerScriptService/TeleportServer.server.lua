local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EXPECTED_PLACE_ID = 14236925335
local REQUEST_COOLDOWN_SECONDS = 1.25

if game.PlaceId ~= EXPECTED_PLACE_ID then
	return
end

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if remotes then
	if not remotes:IsA("Folder") then
		error("ReplicatedStorage.Remotes must be a Folder")
	end
else
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end

local function getOrCreateRemoteEvent(name)
	local existing = remotes:FindFirstChild(name)
	if existing then
		if not existing:IsA("RemoteEvent") then
			error(("ReplicatedStorage.Remotes.%s must be a RemoteEvent"):format(name))
		end
		return existing
	end

	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = remotes
	return remoteEvent
end

local teleportEvent = getOrCreateRemoteEvent("TeleportPlayer")
local teleportResult = getOrCreateRemoteEvent("TeleportResult")
local lastRequestAt = {}

local function sendResult(player, succeeded, message)
	if player.Parent == Players then
		teleportResult:FireClient(player, succeeded, message)
	end
end

teleportEvent.OnServerEvent:Connect(function(requester, targetUserId)
	if typeof(requester) ~= "Instance" or not requester:IsA("Player") or requester.Parent ~= Players then
		return
	end

	local now = os.clock()
	local previousRequestAt = lastRequestAt[requester]
	if previousRequestAt and now - previousRequestAt < REQUEST_COOLDOWN_SECONDS then
		return
	end
	lastRequestAt[requester] = now

	if typeof(targetUserId) ~= "number"
		or targetUserId ~= targetUserId
		or targetUserId < 1
		or targetUserId % 1 ~= 0 then
		sendResult(requester, false, "Target tidak valid.")
		return
	end

	local target = Players:GetPlayerByUserId(targetUserId)
	if not target or target == requester then
		sendResult(requester, false, "Player target tidak ditemukan.")
		return
	end

	local requesterCharacter = requester.Character
	local targetCharacter = target.Character
	if not requesterCharacter or not targetCharacter then
		sendResult(requester, false, "Character belum siap.")
		return
	end

	local requesterHumanoid = requesterCharacter:FindFirstChildOfClass("Humanoid")
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	local requesterRoot = requesterCharacter:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not requesterHumanoid
		or requesterHumanoid.Health <= 0
		or not targetHumanoid
		or targetHumanoid.Health <= 0
		or not requesterRoot
		or not requesterRoot:IsA("BasePart")
		or not targetRoot
		or not targetRoot:IsA("BasePart") then
		sendResult(requester, false, "Character belum siap.")
		return
	end

	requesterCharacter:PivotTo(targetRoot.CFrame * CFrame.new(0, 3, 0))
	sendResult(requester, true, target.DisplayName)
end)

Players.PlayerRemoving:Connect(function(player)
	lastRequestAt[player] = nil
end)
