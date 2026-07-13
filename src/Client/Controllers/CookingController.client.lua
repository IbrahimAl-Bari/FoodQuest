local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local networkFolder = ReplicatedStorage:WaitForChild("Network")

local Ingredients = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Ingredients"))
local Recipes = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Recipes"))
local RemoteNames = require(networkFolder:WaitForChild("RemoteNames"))
local CookingUI = require(script.Parent.Parent.UI:WaitForChild("CookingUI"))

local openCookingMenu = networkFolder:WaitForChild(RemoteNames.OpenCookingMenu)
local requestCook = networkFolder:WaitForChild(RemoteNames.RequestCook)

local function formatRequirements(ingredients)
	local requirements = {}
	for ingredientId, amount in pairs(ingredients) do
		local ingredient = Ingredients[ingredientId]
		if ingredient then
			table.insert(requirements, ingredient.displayName .. " x" .. amount)
		end
	end
	table.sort(requirements)
	return table.concat(requirements, ", ")
end

local recipeEntries = {}
for recipeId, recipe in pairs(Recipes) do
	table.insert(recipeEntries, {
		id = recipeId,
		name = recipe.displayName,
		requirements = formatRequirements(recipe.ingredients),
	})
end
table.sort(recipeEntries, function(left, right)
	return left.name < right.name
end)

local cookingUI = CookingUI.new(playerGui, function(recipeId)
	requestCook:FireServer(recipeId)
end)
cookingUI:SetRecipes(recipeEntries)

openCookingMenu.OnClientEvent:Connect(function()
	cookingUI:Show()
end)
