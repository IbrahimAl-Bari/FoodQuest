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
local inventoryUI = InventoryUI.new(playerGui)

local function renderInventory(snapshot)
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
	inventoryUI:SetIngredients(entries)
end

renderInventory(getInventorySnapshot:InvokeServer())
inventoryUpdated.OnClientEvent:Connect(renderInventory)
