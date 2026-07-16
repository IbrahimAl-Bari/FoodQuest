local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CustomerService = require(script.Parent:WaitForChild("CustomerService"))

local RestaurantService = {}

local SLOTS_FOLDER_NAME = "RestaurantSlots"
local SPAWN_TAG = "CustomerSpawn"
local INSPECT_TAG = "CustomerInspectPoint"
local EXIT_TAG = "CustomerExit"

local playerToPlot = {}

function RestaurantService:GetPlayerPlot(player)
	return playerToPlot[player]
end

function RestaurantService:IsPlayerOwnerOfObject(player, object)
	if not (player and player:IsA("Player")) or not object then
		return false
	end

	local current = object
	while current do
		if current:IsA("Model") and current.Parent
			and current.Parent.Name == SLOTS_FOLDER_NAME
			and current.Parent:IsDescendantOf(Workspace) then
			return current:GetAttribute("OwnerUserId") == player.UserId
		end
		current = current.Parent
	end

	return false
end

-- Shared objects (not in any plot) are usable by everyone.
-- Objects inside a plot require ownership.
function RestaurantService:CanPlayerUseObject(player, object)
	if not (player and player:IsA("Player")) or not object then
		return false
	end

	local current = object
	while current do
		if current:IsA("Model") and current.Parent
			and current.Parent.Name == SLOTS_FOLDER_NAME
			and current.Parent:IsDescendantOf(Workspace) then
			return current:GetAttribute("OwnerUserId") == player.UserId
		end
		current = current.Parent
	end

	return true
end

local function setMarkerOwner(slot, tagName, userId)
	for _, marker in CollectionService:GetTagged(tagName) do
		if marker:IsDescendantOf(slot) then
			marker:SetAttribute("OwnerUserId", userId)
		end
	end
end

function RestaurantService:AssignPlot(player)
	if playerToPlot[player] then
		return playerToPlot[player]
	end

	local slotsFolder = Workspace:FindFirstChild(SLOTS_FOLDER_NAME)
	if not slotsFolder then
		return nil
	end

	for _, slot in slotsFolder:GetChildren() do
		if not slot:IsA("Model") then
			continue
		end
		if slot:GetAttribute("OwnerUserId") == 0 then
			slot:SetAttribute("OwnerUserId", player.UserId)

			setMarkerOwner(slot, SPAWN_TAG, player.UserId)
			setMarkerOwner(slot, INSPECT_TAG, player.UserId)
			setMarkerOwner(slot, EXIT_TAG, player.UserId)

			local spawnLocation = slot:FindFirstChildWhichIsA("SpawnLocation")
			if spawnLocation then
				player.RespawnLocation = spawnLocation
			end

			playerToPlot[player] = slot

			if player.Character then
				local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if rootPart and spawnLocation then
					rootPart.CFrame = spawnLocation.CFrame * CFrame.new(0, 3, 0)
				end
			end

			return slot
		end
	end

	return nil
end

function RestaurantService:ReleasePlot(player)
	local slot = playerToPlot[player]
	if not slot then
		return
	end

	CustomerService:CleanupPlayer(player)

	setMarkerOwner(slot, SPAWN_TAG, 0)
	setMarkerOwner(slot, INSPECT_TAG, 0)
	setMarkerOwner(slot, EXIT_TAG, 0)

	slot:SetAttribute("OwnerUserId", 0)
	playerToPlot[player] = nil

	if player.RespawnLocation and player.RespawnLocation:IsDescendantOf(slot) then
		player.RespawnLocation = nil
	end
end

function RestaurantService:Init()
	local slotsFolder = Workspace:FindFirstChild(SLOTS_FOLDER_NAME)
	if not slotsFolder then
		warn("[RestaurantService] No RestaurantSlots folder found in Workspace")
		return
	end

	for _, slot in slotsFolder:GetChildren() do
		if slot:IsA("Model") then
			slot:SetAttribute("OwnerUserId", 0)
			setMarkerOwner(slot, SPAWN_TAG, 0)
			setMarkerOwner(slot, INSPECT_TAG, 0)
			setMarkerOwner(slot, EXIT_TAG, 0)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		RestaurantService:AssignPlot(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		RestaurantService:ReleasePlot(player)
	end)

	for _, player in Players:GetPlayers() do
		RestaurantService:AssignPlot(player)
	end
end

return RestaurantService
