local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Network"):WaitForChild("RemoteNames"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))

local PlayerUIService = {}

local remotes = {}

local function getOrCreateRemote(className, name)
	local networkFolder = ReplicatedStorage:WaitForChild("Network")
	local remote = networkFolder:FindFirstChild(name)
	if remote == nil then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = networkFolder
	end

	if not remote:IsA(className) then
		error(name .. " must be a " .. className)
	end

	return remote
end

function PlayerUIService:SendNotification(player, payload)
	if not (player and player:IsA("Player")) or typeof(payload) ~= "table" then
		return
	end

	remotes.gameNotification:FireClient(player, payload)
end

function PlayerUIService:Init()
	remotes.getInventorySnapshot = getOrCreateRemote("RemoteFunction", RemoteNames.GetInventorySnapshot)
	remotes.inventoryUpdated = getOrCreateRemote("RemoteEvent", RemoteNames.InventoryUpdated)
	remotes.gameNotification = getOrCreateRemote("RemoteEvent", RemoteNames.GameNotification)

	-- This remote exposes a copied, read-only view. It performs no mutations.
	remotes.getInventorySnapshot.OnServerInvoke = function(player)
		return InventoryService:GetInventorySnapshot(player)
	end

	InventoryService.InventoryChanged.Event:Connect(function(player, snapshot)
		remotes.inventoryUpdated:FireClient(player, snapshot)
	end)
end

return PlayerUIService
