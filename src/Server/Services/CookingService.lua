local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Foods = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Foods"))
local Ingredients = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Ingredients"))
local Recipes = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Recipes"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Network"):WaitForChild("RemoteNames"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local PlayerUIService = require(script.Parent:WaitForChild("PlayerUIService"))

local CookingService = {}

local STATION_TAG = "CookingStation"
local ACTIVE_STATION_SECONDS = 15
local DISTANCE_TOLERANCE = 3

local stations = {}
local activeStations = {}
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

local function isPlayerNearStation(player, station, maxDistance)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	return rootPart ~= nil and (rootPart.Position - station.Position).Magnitude <= maxDistance
end

local function sendFailure(player, message)
	PlayerUIService:SendNotification(player, {
		kind = "CookingFailed",
		message = message,
	})
end

local function openCookingMenu(player, station, prompt)
	if not station:IsDescendantOf(workspace) then
		return
	end

	if not isPlayerNearStation(player, station, prompt.MaxActivationDistance + DISTANCE_TOLERANCE) then
		return
	end

	activeStations[player] = {
		station = station,
		expiresAt = os.clock() + ACTIVE_STATION_SECONDS,
	}

	remotes.openCookingMenu:FireClient(player)
end

local function cookRecipe(player, recipeId)
	if typeof(recipeId) ~= "string" then
		return
	end

	local activeStation = activeStations[player]
	if activeStation == nil or activeStation.expiresAt < os.clock() then
		activeStations[player] = nil
		sendFailure(player, "Use a cooking station first.")
		return
	end

	local station = activeStation.station
	local stationState = stations[station]
	if stationState == nil or not station:IsDescendantOf(workspace)
		or not isPlayerNearStation(player, station, stationState.prompt.MaxActivationDistance + DISTANCE_TOLERANCE) then
		activeStations[player] = nil
		sendFailure(player, "Move closer to the cooking station.")
		return
	end

	local recipe = Recipes[recipeId]
	if recipe == nil then
		sendFailure(player, "That recipe is unavailable.")
		return
	end

	local success, reason = InventoryService:ConsumeIngredientsAndAddFood(
		player,
		recipe.ingredients,
		recipe.outputFoodId,
		recipe.outputAmount
	)
	if not success then
		if reason == "InsufficientIngredients" then
			sendFailure(player, "You do not have the required ingredients.")
		else
			sendFailure(player, "Cooking failed. Please try again.")
		end
		return
	end

	PlayerUIService:SendNotification(player, {
		kind = "CookingCompleted",
		foodId = recipe.outputFoodId,
		amount = recipe.outputAmount,
	})
end

local function registerStation(station)
	if stations[station] then
		return
	end

	if not station:IsA("BasePart") then
		warn("CookingStation tag requires a BasePart:", station:GetFullName())
		return
	end

	local prompt = station:FindFirstChild("CookingPrompt")
	local createdPrompt = false
	if prompt == nil then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "CookingPrompt"
		prompt.ActionText = "Cook"
		prompt.ObjectText = "Cooking Station"
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = station
		createdPrompt = true
	end

	if not prompt:IsA("ProximityPrompt") then
		warn("CookingPrompt must be a ProximityPrompt:", station:GetFullName())
		return
	end

	stations[station] = {
		prompt = prompt,
		createdPrompt = createdPrompt,
		connection = prompt.Triggered:Connect(function(player)
			openCookingMenu(player, station, prompt)
		end),
	}
end

local function unregisterStation(station)
	local state = stations[station]
	if state == nil then
		return
	end

	state.connection:Disconnect()
	if state.createdPrompt and state.prompt.Parent then
		state.prompt:Destroy()
	end
	stations[station] = nil
end

local function validateRecipes()
	for recipeId, recipe in pairs(Recipes) do
		if typeof(recipeId) ~= "string" or typeof(recipe) ~= "table" then
			error("Invalid recipe definition")
		end
		if typeof(recipe.displayName) ~= "string" or typeof(recipe.ingredients) ~= "table" then
			error("Recipe is missing its display name or ingredients: " .. recipeId)
		end
		if Foods[recipe.outputFoodId] == nil or typeof(recipe.outputAmount) ~= "number" or recipe.outputAmount <= 0
			or recipe.outputAmount % 1 ~= 0 then
			error("Recipe has an invalid food output: " .. recipeId)
		end
		if next(recipe.ingredients) == nil then
			error("Recipe must require ingredients: " .. recipeId)
		end
		for ingredientId, amount in pairs(recipe.ingredients) do
			if Ingredients[ingredientId] == nil or typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
				error("Recipe has an invalid ingredient requirement: " .. recipeId)
			end
		end
	end
end

function CookingService:Init()
	validateRecipes()

	remotes.openCookingMenu = getOrCreateRemote("RemoteEvent", RemoteNames.OpenCookingMenu)
	remotes.requestCook = getOrCreateRemote("RemoteEvent", RemoteNames.RequestCook)
	remotes.requestCook.OnServerEvent:Connect(cookRecipe)

	for _, station in CollectionService:GetTagged(STATION_TAG) do
		registerStation(station)
	end
	CollectionService:GetInstanceAddedSignal(STATION_TAG):Connect(registerStation)
	CollectionService:GetInstanceRemovedSignal(STATION_TAG):Connect(unregisterStation)

	Players.PlayerRemoving:Connect(function(player)
		activeStations[player] = nil
	end)
end

return CookingService
