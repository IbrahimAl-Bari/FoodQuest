print("InventoryController: started")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local networkFolder = ReplicatedStorage:WaitForChild("Network")

local Ingredients = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Ingredients"))
local RemoteNames = require(networkFolder:WaitForChild("RemoteNames"))
local InventoryUI = require(script.Parent.Parent.UI:WaitForChild("InventoryUI"))

local getInventorySnapshot = networkFolder:WaitForChild(RemoteNames.GetInventorySnapshot)
local inventoryUpdated = networkFolder:WaitForChild(RemoteNames.InventoryUpdated)

print("InventoryController: creating InventoryUI")
local inventoryUI = InventoryUI.new(playerGui)
print("InventoryController: InventoryUI created")

local function renderInventory(snapshot)
	print("InventoryController: renderInventory called with", snapshot and typeof(snapshot))
	local ingredients = snapshot.ingredients or {}
	local entries = {}
	for ingredientId, amount in pairs(ingredients) do
		local definition = Ingredients[ingredientId]
		if definition and typeof(amount) == "number" and amount > 0 then
			table.insert(entries, {
				name = definition.displayName,
				amount = amount,
			})
		end
	end

	table.sort(entries, function(left, right)
		return left.name < right.name
	end)
	print("InventoryController: setting", #entries, "ingredients in UI")
	inventoryUI:SetIngredients(entries)
end

local snapshot = getInventorySnapshot:InvokeServer()
print("InventoryController: initial snapshot received", snapshot and typeof(snapshot))
renderInventory(snapshot)

inventoryUpdated.OnClientEvent:Connect(function(snapshot)
	print("InventoryController: inventory updated event received")
	renderInventory(snapshot)
end)
