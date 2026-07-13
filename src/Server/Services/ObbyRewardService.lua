local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ingredients = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Ingredients"))
local Obbies = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Obbies"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local PlayerUIService = require(script.Parent:WaitForChild("PlayerUIService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))

local ObbyRewardService = {}

local START_TAG = "ObbyStart"
local FINISH_TAG = "ObbyFinish"
local MAX_RUN_DURATION_SECONDS = 30 * 60

local activeRuns = {}
local connections = {}

local function getPlayerFromHit(hitPart)
	local character = hitPart:FindFirstAncestorOfClass("Model")
	if character == nil then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

local function getValidObbyId(part)
	if not part:IsA("BasePart") or not part:IsDescendantOf(workspace) then
		return nil
	end

	local obbyId = part:GetAttribute("ObbyId")
	if typeof(obbyId) ~= "string" or obbyId == "" or Obbies[obbyId] == nil then
		return nil
	end

	return obbyId
end

local function startRun(part, player)
	local obbyId = getValidObbyId(part)
	if obbyId == nil or ProgressionService:HasCompletedObby(player, obbyId) then
		return
	end

	local playerRuns = activeRuns[player]
	if playerRuns == nil then
		playerRuns = {}
		activeRuns[player] = playerRuns
	end
	if playerRuns[obbyId] then
		return
	end

	playerRuns[obbyId] = os.clock()
	PlayerUIService:SendNotification(player, {
		kind = "ObbyStarted",
		obbyId = obbyId,
	})
end

local function finishRun(part, player)
	local obbyId = getValidObbyId(part)
	if obbyId == nil then
		return
	end

	local playerRuns = activeRuns[player]
	local startedAt = playerRuns and playerRuns[obbyId]
	if startedAt == nil then
		return
	end

	local definition = Obbies[obbyId]
	local elapsed = os.clock() - startedAt
	if elapsed < definition.minimumCompletionSeconds then
		return
	end

	if elapsed > MAX_RUN_DURATION_SECONDS then
		playerRuns[obbyId] = nil
		return
	end

	-- Validate every configured reward before taking the one-time completion lock.
	for ingredientId, amount in pairs(definition.rewards) do
		if typeof(ingredientId) ~= "string" or typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
			warn("Invalid reward configuration for obby:", obbyId)
			return
		end
	end

	local completed = ProgressionService:TryCompleteObby(player, obbyId)
	if not completed then
		return
	end

	local rewarded, rewardReason = InventoryService:AddIngredients(player, definition.rewards)
	if not rewarded then
		-- Configuration is checked during startup, so this indicates a programming error.
		warn("Completed obby could not award ingredients:", obbyId, rewardReason)
		return
	end

	playerRuns[obbyId] = nil
	PlayerUIService:SendNotification(player, {
		kind = "ObbyCompleted",
		obbyId = obbyId,
		rewards = definition.rewards,
	})
end

local function registerPart(part, tagName, handler)
	if connections[part] then
		return
	end

	if not part:IsA("BasePart") then
		warn(tagName .. " tag requires a BasePart:", part:GetFullName())
		return
	end

	connections[part] = part.Touched:Connect(function(hitPart)
		local player = getPlayerFromHit(hitPart)
		if player then
			handler(part, player)
		end
	end)
end

local function unregisterPart(part)
	local connection = connections[part]
	if connection then
		connection:Disconnect()
		connections[part] = nil
	end
end

local function validateDefinitions()
	for obbyId, definition in pairs(Obbies) do
		if typeof(obbyId) ~= "string" or typeof(definition) ~= "table" then
			error("Invalid obby definition")
		end

		if typeof(definition.minimumCompletionSeconds) ~= "number" or definition.minimumCompletionSeconds < 0 then
			error("Obby requires a non-negative minimumCompletionSeconds: " .. obbyId)
		end

		if typeof(definition.rewards) ~= "table" or next(definition.rewards) == nil then
			error("Obby requires at least one reward: " .. obbyId)
		end

		for ingredientId, amount in pairs(definition.rewards) do
			if Ingredients[ingredientId] == nil then
				error("Obby has an unknown reward ingredient: " .. tostring(ingredientId))
			end
			if typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
				error("Obby has an invalid reward amount: " .. obbyId)
			end
		end
	end
end

function ObbyRewardService:Init()
	validateDefinitions()

	for _, part in CollectionService:GetTagged(START_TAG) do
		registerPart(part, START_TAG, startRun)
	end
	for _, part in CollectionService:GetTagged(FINISH_TAG) do
		registerPart(part, FINISH_TAG, finishRun)
	end

	CollectionService:GetInstanceAddedSignal(START_TAG):Connect(function(part)
		registerPart(part, START_TAG, startRun)
	end)
	CollectionService:GetInstanceAddedSignal(FINISH_TAG):Connect(function(part)
		registerPart(part, FINISH_TAG, finishRun)
	end)
	CollectionService:GetInstanceRemovedSignal(START_TAG):Connect(unregisterPart)
	CollectionService:GetInstanceRemovedSignal(FINISH_TAG):Connect(unregisterPart)

	Players.PlayerRemoving:Connect(function(player)
		activeRuns[player] = nil
	end)
end

return ObbyRewardService
