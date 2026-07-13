local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ingredients = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Ingredients"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))

local IngredientPickupService = {}

local PICKUP_TAG = "IngredientPickup"
local RESPAWN_SECONDS = 10

local pickupStates = {}

local function getTouchPart(pickup)
	if pickup:IsA("BasePart") then
		return pickup
	end

	if pickup:IsA("Model") then
		return pickup.PrimaryPart or pickup:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

local function getPlayerFromHit(hitPart)
	local character = hitPart:FindFirstAncestorOfClass("Model")
	if character == nil then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

local function playerMeetsObbyRequirement(player, pickup)
	local requiredObbyId = pickup:GetAttribute("RequiredObbyId")
	if requiredObbyId == nil or requiredObbyId == "" then
		return true
	end

	if typeof(requiredObbyId) ~= "string" then
		return false
	end

	return ProgressionService:HasCompletedObby(player, requiredObbyId)
end

local function setPickupAvailable(state, isAvailable)
	state.available = isAvailable
	for _, part in state.parts do
		if part.Parent then
			part.Transparency = isAvailable and state.originalTransparency[part] or 1
			part.CanCollide = isAvailable and state.originalCanCollide[part] or false
			part.CanTouch = isAvailable and state.originalCanTouch[part] or false
		end
	end
end

local function awardPickup(pickup, player)
	local state = pickupStates[pickup]
	if state == nil or not state.available then
		return
	end

	if not pickup:IsDescendantOf(workspace) then
		return
	end

	local ingredientId = pickup:GetAttribute("IngredientId")
	local ingredient = Ingredients[ingredientId]
	if ingredient == nil then
		warn("Ingredient pickup has an unknown IngredientId:", pickup:GetFullName())
		return
	end

	if not playerMeetsObbyRequirement(player, pickup) then
		return
	end

	-- Lock before adding inventory so simultaneous touches cannot double-award.
	setPickupAvailable(state, false)

	local success, result = InventoryService:AddIngredient(player, ingredientId, ingredient.pickupAmount)
	if not success then
		warn("Failed to award ingredient pickup:", result)
		setPickupAvailable(state, true)
		return
	end

	task.delay(RESPAWN_SECONDS, function()
		if pickupStates[pickup] == state and pickup.Parent then
			setPickupAvailable(state, true)
		end
	end)
end

local function registerPickup(pickup)
	if pickupStates[pickup] then
		return
	end

	local touchPart = getTouchPart(pickup)
	if touchPart == nil then
		warn("IngredientPickup tag requires a BasePart or Model with a BasePart:", pickup:GetFullName())
		return
	end

	local parts = pickup:IsA("Model") and pickup:GetDescendants() or { pickup }
	local state = {
		available = true,
		parts = {},
		originalTransparency = {},
		originalCanCollide = {},
		originalCanTouch = {},
	}

	for _, instance in parts do
		if instance:IsA("BasePart") then
			table.insert(state.parts, instance)
			state.originalTransparency[instance] = instance.Transparency
			state.originalCanCollide[instance] = instance.CanCollide
			state.originalCanTouch[instance] = instance.CanTouch
		end
	end

	pickupStates[pickup] = state
	state.touchConnection = touchPart.Touched:Connect(function(hitPart)
		local player = getPlayerFromHit(hitPart)
		if player then
			awardPickup(pickup, player)
		end
	end)
end

function IngredientPickupService:Init()
	for _, pickup in CollectionService:GetTagged(PICKUP_TAG) do
		registerPickup(pickup)
	end

	CollectionService:GetInstanceAddedSignal(PICKUP_TAG):Connect(registerPickup)
	CollectionService:GetInstanceRemovedSignal(PICKUP_TAG):Connect(function(pickup)
		local state = pickupStates[pickup]
		if state and state.touchConnection then
			state.touchConnection:Disconnect()
		end
		pickupStates[pickup] = nil
	end)
end

return IngredientPickupService
