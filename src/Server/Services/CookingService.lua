local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Foods = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Foods"))
local Ingredients = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Ingredients"))
local Recipes = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Recipes"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Network"):WaitForChild("RemoteNames"))
local DisplayCounterService = require(script.Parent:WaitForChild("DisplayCounterService"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local PlayerUIService = require(script.Parent:WaitForChild("PlayerUIService"))

local CookingService = {}

CookingService.CookingChanged = Instance.new("BindableEvent")

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
	if not rootPart then
		return false
	end
	local state = stations[station]
	local part = state and state.part or station
	return (rootPart.Position - part.Position).Magnitude <= maxDistance
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
		warn("[CookingService] Invalid recipeId:", recipeId)
		sendFailure(player, "That recipe is unavailable.")
		return
	end
	warn("[CookingService] Recipe found:", recipeId, "output:", recipe.outputFoodId)

	local counterId = DisplayCounterService:GetDefaultCounterId()
	warn("[CookingService] counterId:", counterId)

	local hasSpace, spaceReason = DisplayCounterService:CanPlaceFood(player, counterId, recipe.outputFoodId, recipe.outputAmount)
	warn("[CookingService] CanPlaceFood:", hasSpace, spaceReason)
	if not hasSpace then
		sendFailure(player, "Your display counter is full.")
		return
	end

	local success, reason = InventoryService:ConsumeIngredients(player, recipe.ingredients)
	warn("[CookingService] ConsumeIngredients:", success, reason)
	if not success then
		if reason == "InsufficientIngredients" then
			sendFailure(player, "You do not have the required ingredients.")
		else
			sendFailure(player, "Cooking failed. Please try again.")
		end
		return
	end

	-- Counter capacity was checked immediately before this non-yielding server operation.
	local placed, placeReason = DisplayCounterService:PlaceFood(player, counterId, recipe.outputFoodId, recipe.outputAmount)
	warn("[CookingService] PlaceFood:", placed, placeReason)
	if not placed then
		warn("Cooking consumed ingredients but could not place food:", placeReason)
		sendFailure(player, "Cooking failed. Please try again.")
		return
	end

	warn("[CookingService] Cook successful, food placed:", recipe.outputFoodId)
	PlayerUIService:SendNotification(player, {
		kind = "CookingCompleted",
		foodId = recipe.outputFoodId,
		amount = recipe.outputAmount,
	})

	CookingService.CookingChanged:Fire(player, recipeId, recipe.outputFoodId, recipe.outputAmount)
end

local function getStationPart(station)
	if station:IsA("BasePart") then
		return station
	end
	if station:IsA("Model") then
		return station.PrimaryPart or station:FindFirstChildWhichIsA("BasePart")
	end
	return nil
end

local function registerStation(station)
	if stations[station] then
		return
	end

	local part = getStationPart(station)
	if not part then
		warn("CookingStation tag requires a BasePart:", station:GetFullName())
		return
	end

	local prompt = part:FindFirstChild("CookingPrompt")
	local createdPrompt = false
	if prompt == nil then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "CookingPrompt"
		prompt.ActionText = "Cook"
		prompt.ObjectText = "Cooking Station"
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = part
		createdPrompt = true
	end

	if not prompt:IsA("ProximityPrompt") then
		warn("CookingPrompt must be a ProximityPrompt:", station:GetFullName())
		return
	end

	stations[station] = {
		prompt = prompt,
		part = part,
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
