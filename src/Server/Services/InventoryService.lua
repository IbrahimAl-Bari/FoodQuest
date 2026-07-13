local Players = game:GetService("Players")

local Foods = require(game:GetService("ReplicatedStorage"):WaitForChild("Config"):WaitForChild("Foods"))
local Ingredients = require(game:GetService("ReplicatedStorage"):WaitForChild("Config"):WaitForChild("Ingredients"))

local InventoryService = {}
InventoryService.InventoryChanged = Instance.new("BindableEvent")

local inventories = {}

local function getOrCreateInventory(player)
	local inventory = inventories[player]
	if inventory == nil then
		inventory = {
			ingredients = {},
			foods = {},
		}
		inventories[player] = inventory
	end

	return inventory
end

local function copyItemMap(items)
	local copy = {}
	for itemId, amount in pairs(items) do
		copy[itemId] = amount
	end
	return copy
end

local function copyInventory(inventory)
	if inventory == nil then
		return {
			ingredients = {},
			foods = {},
		}
	end

	return {
		ingredients = copyItemMap(inventory.ingredients),
		foods = copyItemMap(inventory.foods),
	}
end

function InventoryService:AddIngredient(player, ingredientId, amount)
	if not (player and player:IsA("Player")) then
		return false, "InvalidPlayer"
	end

	if Ingredients[ingredientId] == nil then
		return false, "UnknownIngredient"
	end

	if typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
		return false, "InvalidAmount"
	end

	local inventory = getOrCreateInventory(player)
	inventory.ingredients[ingredientId] = (inventory.ingredients[ingredientId] or 0) + amount
	InventoryService.InventoryChanged:Fire(player, copyInventory(inventory))

	return true, inventory.ingredients[ingredientId]
end

function InventoryService:GetIngredientCount(player, ingredientId)
	if Ingredients[ingredientId] == nil then
		return 0
	end

	local inventory = inventories[player]
	if inventory == nil then
		return 0
	end

	return inventory.ingredients[ingredientId] or 0
end

function InventoryService:GetInventorySnapshot(player)
	if not (player and player:IsA("Player")) then
		return {}
	end

	return copyInventory(inventories[player])
end

function InventoryService:AddIngredients(player, ingredients)
	if not (player and player:IsA("Player")) or typeof(ingredients) ~= "table" then
		return false, "InvalidRequest"
	end

	if next(ingredients) == nil then
		return false, "EmptyReward"
	end

	for ingredientId, amount in pairs(ingredients) do
		if Ingredients[ingredientId] == nil then
			return false, "UnknownIngredient"
		end
		if typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
			return false, "InvalidAmount"
		end
	end

	local inventory = getOrCreateInventory(player)
	for ingredientId, amount in pairs(ingredients) do
		inventory.ingredients[ingredientId] = (inventory.ingredients[ingredientId] or 0) + amount
	end
	InventoryService.InventoryChanged:Fire(player, copyInventory(inventory))

	return true
end

function InventoryService:ConsumeIngredientsAndAddFood(player, requiredIngredients, foodId, foodAmount)
	if not (player and player:IsA("Player")) or typeof(requiredIngredients) ~= "table" then
		return false, "InvalidRequest"
	end
	if Foods[foodId] == nil or typeof(foodAmount) ~= "number" or foodAmount <= 0 or foodAmount % 1 ~= 0 then
		return false, "InvalidFood"
	end
	if next(requiredIngredients) == nil then
		return false, "EmptyRecipe"
	end

	local inventory = getOrCreateInventory(player)
	for ingredientId, amount in pairs(requiredIngredients) do
		if Ingredients[ingredientId] == nil or typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
			return false, "InvalidIngredients"
		end
		if (inventory.ingredients[ingredientId] or 0) < amount then
			return false, "InsufficientIngredients"
		end
	end

	for ingredientId, amount in pairs(requiredIngredients) do
		local remaining = inventory.ingredients[ingredientId] - amount
		inventory.ingredients[ingredientId] = remaining > 0 and remaining or nil
	end
	inventory.foods[foodId] = (inventory.foods[foodId] or 0) + foodAmount
	InventoryService.InventoryChanged:Fire(player, copyInventory(inventory))

	return true
end

function InventoryService:Init()
	Players.PlayerRemoving:Connect(function(player)
		inventories[player] = nil
	end)
end

return InventoryService
