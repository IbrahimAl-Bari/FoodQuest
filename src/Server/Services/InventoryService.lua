local DataService = require(script.Parent:WaitForChild("DataService"))

local Ingredients = require(game:GetService("ReplicatedStorage"):WaitForChild("Config"):WaitForChild("Ingredients"))

local InventoryService = {}
InventoryService.InventoryChanged = Instance.new("BindableEvent")

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

	local data = DataService:GetData(player, "Inventory")
	if not data then
		return false, "NoSession"
	end

	data.ingredients[ingredientId] = (data.ingredients[ingredientId] or 0) + amount
	DataService:SetDirty(player)
	InventoryService.InventoryChanged:Fire(player, copyInventory(data))

	return true, data.ingredients[ingredientId]
end

function InventoryService:GetIngredientCount(player, ingredientId)
	if Ingredients[ingredientId] == nil then
		return 0
	end

	local data = DataService:GetData(player, "Inventory")
	if not data then
		return 0
	end

	return data.ingredients[ingredientId] or 0
end

function InventoryService:GetInventorySnapshot(player)
	if not (player and player:IsA("Player")) then
		return {}
	end

	local data = DataService:GetData(player, "Inventory")
	return copyInventory(data)
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

	local data = DataService:GetData(player, "Inventory")
	if not data then
		return false, "NoSession"
	end

	for ingredientId, amount in pairs(ingredients) do
		data.ingredients[ingredientId] = (data.ingredients[ingredientId] or 0) + amount
	end
	DataService:SetDirty(player)
	InventoryService.InventoryChanged:Fire(player, copyInventory(data))

	return true
end

function InventoryService:ConsumeIngredients(player, requiredIngredients)
	if not (player and player:IsA("Player")) or typeof(requiredIngredients) ~= "table" then
		return false, "InvalidRequest"
	end
	if next(requiredIngredients) == nil then
		return false, "EmptyRecipe"
	end

	local data = DataService:GetData(player, "Inventory")
	if not data then
		return false, "NoSession"
	end

	for ingredientId, amount in pairs(requiredIngredients) do
		if Ingredients[ingredientId] == nil or typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
			return false, "InvalidIngredients"
		end
		if (data.ingredients[ingredientId] or 0) < amount then
			return false, "InsufficientIngredients"
		end
	end

	for ingredientId, amount in pairs(requiredIngredients) do
		local remaining = data.ingredients[ingredientId] - amount
		data.ingredients[ingredientId] = remaining > 0 and remaining or nil
	end
	DataService:SetDirty(player)
	InventoryService.InventoryChanged:Fire(player, copyInventory(data))

	return true
end

function InventoryService:Init()
end

return InventoryService
