local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent:WaitForChild("DataService"))
local DisplayCounters = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("DisplayCounters"))
local Foods = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Foods"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Network"):WaitForChild("RemoteNames"))

local DisplayCounterService = {}

DisplayCounterService.FoodPlaced = Instance.new("BindableEvent")
DisplayCounterService.FoodRemoved = Instance.new("BindableEvent")

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

local function getDefinition(counterId)
	return DisplayCounters.counters[counterId]
end

local function getOrCreateSlots(player, counterId)
	local playerCounters = DataService:GetData(player, "DisplayCounters")
	if playerCounters == nil then
		return nil
	end

	local slots = playerCounters[counterId]
	if slots == nil then
		slots = {}
		for slotIndex = 1, getDefinition(counterId).slotCount do
			slots[slotIndex] = false
		end
		playerCounters[counterId] = slots
	end

	return slots
end

local function createSnapshot(player, counterId)
	local definition = getDefinition(counterId)
	local slots = getOrCreateSlots(player, counterId)
	local slotCopy = {}
	if slots then
		for slotIndex = 1, definition.slotCount do
			slotCopy[slotIndex] = slots[slotIndex]
		end
	end

	return {
		counterId = counterId,
		displayName = definition.displayName,
		slotCount = definition.slotCount,
		slots = slotCopy,
	}
end

local function sendUpdate(player, counterId)
	remotes.counterUpdated:FireClient(player, createSnapshot(player, counterId))
end

function DisplayCounterService:GetDefaultCounterId()
	return DisplayCounters.defaultCounterId
end

function DisplayCounterService:GetCounterSnapshot(player, counterId)
	if not (player and player:IsA("Player")) then
		return {}
	end

	counterId = counterId or self:GetDefaultCounterId()
	if getDefinition(counterId) == nil then
		return {}
	end

	return createSnapshot(player, counterId)
end

function DisplayCounterService:CanPlaceFood(player, counterId, foodId, amount)
	if not (player and player:IsA("Player")) or getDefinition(counterId) == nil or Foods[foodId] == nil then
		return false, "InvalidRequest"
	end
	if typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
		return false, "InvalidAmount"
	end

	local slots = getOrCreateSlots(player, counterId)
	if not slots then
		return false, "NoSession"
	end

	local freeSlots = 0
	for _, foodInSlot in slots do
		if foodInSlot == false then
			freeSlots += 1
		end
	end

	if freeSlots < amount then
		return false, "CounterFull"
	end

	return true
end

function DisplayCounterService:PlaceFood(player, counterId, foodId, amount)
	local canPlace, reason = self:CanPlaceFood(player, counterId, foodId, amount)
	if not canPlace then
		return false, reason
	end

	local slots = getOrCreateSlots(player, counterId)
	if not slots then
		return false, "NoSession"
	end

	local remaining = amount
	for slotIndex, foodInSlot in slots do
		if foodInSlot == false then
			slots[slotIndex] = foodId
			remaining -= 1
			self.FoodPlaced:Fire(player, counterId, foodId, slotIndex)
			if remaining == 0 then
				break
			end
		end
	end

	DataService:SetDirty(player)
	sendUpdate(player, counterId)
	return true
end

function DisplayCounterService:TakeFirstFood(player, counterId)
	if not (player and player:IsA("Player")) or getDefinition(counterId) == nil then
		return false, "InvalidRequest"
	end

	local slots = getOrCreateSlots(player, counterId)
	if not slots then
		return false, "NoSession"
	end

	for slotIndex, foodId in slots do
		if foodId ~= false then
			slots[slotIndex] = false
			DataService:SetDirty(player)
			sendUpdate(player, counterId)
			self.FoodRemoved:Fire(player, counterId, foodId, slotIndex)
			return true, foodId
		end
	end

	return false, "NoFoodAvailable"
end

function DisplayCounterService:TakeFoodById(player, counterId, foodId)
	warn("[DisplayCounterService] TakeFoodById called: player=", player, "counterId=", counterId, "foodId=", foodId)

	if not (player and player:IsA("Player")) or getDefinition(counterId) == nil or typeof(foodId) ~= "string" then
		warn("[DisplayCounterService] InvalidRequest: player=", player, "counterDef=", getDefinition(counterId), "foodType=", typeof(foodId))
		return false, "InvalidRequest"
	end

	local slots = getOrCreateSlots(player, counterId)
	if not slots then
		warn("[DisplayCounterService] NoSession - getOrCreateSlots returned nil")
		return false, "NoSession"
	end

	warn("[DisplayCounterService] Slots dump:")
	for i, v in slots do
		warn("  slot", i, "=", v, "(", typeof(v), ")")
	end

	for slotIndex, slotFood in slots do
		if slotFood == foodId then
			warn("[DisplayCounterService] Found match at slot", slotIndex)
			slots[slotIndex] = false
			DataService:SetDirty(player)
			sendUpdate(player, counterId)
			self.FoodRemoved:Fire(player, counterId, foodId, slotIndex)
			return true
		end
	end

	warn("[DisplayCounterService] FoodNotFound - no slot contained", foodId)
	return false, "FoodNotFound"
end

local function validateDefinitions()
	if typeof(DisplayCounters.defaultCounterId) ~= "string" or getDefinition(DisplayCounters.defaultCounterId) == nil then
		error("DisplayCounters requires a valid defaultCounterId")
	end

	for counterId, definition in pairs(DisplayCounters.counters) do
		if typeof(counterId) ~= "string" or typeof(definition) ~= "table" then
			error("Invalid display counter definition")
		end
		if typeof(definition.displayName) ~= "string" or typeof(definition.slotCount) ~= "number"
			or definition.slotCount <= 0 or definition.slotCount % 1 ~= 0 then
			error("Display counter has invalid fields: " .. counterId)
		end
	end
end

function DisplayCounterService:Init()
	validateDefinitions()
	remotes.getCounterSnapshot = getOrCreateRemote("RemoteFunction", RemoteNames.GetDisplayCounterSnapshot)
	remotes.counterUpdated = getOrCreateRemote("RemoteEvent", RemoteNames.DisplayCounterUpdated)

	remotes.getCounterSnapshot.OnServerInvoke = function(player, counterId)
		return DisplayCounterService:GetCounterSnapshot(player, counterId)
	end
end

return DisplayCounterService
