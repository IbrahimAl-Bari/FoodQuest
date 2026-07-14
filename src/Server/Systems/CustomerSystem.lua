local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Customers = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Customers"))
local Foods = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Foods"))
local CurrencyService = require(script.Parent.Parent.Services:WaitForChild("CurrencyService"))
local DisplayCounterService = require(script.Parent.Parent.Services:WaitForChild("DisplayCounterService"))
local PlayerUIService = require(script.Parent.Parent.Services:WaitForChild("PlayerUIService"))

local CustomerSystem = {}

local SPAWN_TAG = "CustomerSpawn"
local INSPECT_TAG = "CustomerInspectPoint"
local EXIT_TAG = "CustomerExit"

local activeCustomers = {}
local customerFolder

local function getMarkerForPlayer(tagName, player)
	local fallbackMarker
	for _, marker in CollectionService:GetTagged(tagName) do
		if marker:IsA("BasePart") and marker:IsDescendantOf(workspace) then
			local ownerUserId = marker:GetAttribute("OwnerUserId")
			if ownerUserId == player.UserId then
				return marker
			end
			if ownerUserId == nil or ownerUserId == 0 then
				fallbackMarker = fallbackMarker or marker
			end
		end
	end

	return fallbackMarker
end

local function getMarkers(player)
	local spawnMarker = getMarkerForPlayer(SPAWN_TAG, player)
	local inspectMarker = getMarkerForPlayer(INSPECT_TAG, player)
	local exitMarker = getMarkerForPlayer(EXIT_TAG, player)
	if not (spawnMarker and inspectMarker and exitMarker) then
		return nil
	end

	return spawnMarker, inspectMarker, exitMarker
end

local function createPlaceholderCustomer(spawnMarker)
	local model = Instance.new("Model")
	model.Name = "PlaceholderCustomer"

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 4, 2)
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.CanTouch = false
	rootPart.Material = Enum.Material.SmoothPlastic
	rootPart.Color = Color3.fromRGB(84, 152, 222)
	rootPart.CFrame = spawnMarker.CFrame * CFrame.new(0, 2, 0)
	rootPart.Parent = model

	model.PrimaryPart = rootPart
	model.Parent = customerFolder
	return model
end

local function moveCustomer(customer, marker)
	if not (customer and customer.PrimaryPart and marker and marker:IsDescendantOf(workspace)) then
		return false
	end

	local tween = TweenService:Create(
		customer.PrimaryPart,
		TweenInfo.new(Customers.travelSeconds, Enum.EasingStyle.Linear),
		{ CFrame = marker.CFrame * CFrame.new(0, 2, 0) }
	)
	tween:Play()
	return tween.Completed:Wait() == Enum.PlaybackState.Completed
end

local function notifySale(player, foodId, coins)
	local food = Foods[foodId]
	PlayerUIService:SendNotification(player, {
		kind = "CustomerPurchased",
		foodId = foodId,
		coins = coins,
		foodName = food and food.displayName or foodId,
	})
end

local function runCustomer(player, spawnMarker, inspectMarker, exitMarker)
	local customer = createPlaceholderCustomer(spawnMarker)
	activeCustomers[player] = customer

	if moveCustomer(customer, inspectMarker) and player.Parent == Players then
		task.wait(Customers.inspectSeconds)

		local counterId = DisplayCounterService:GetDefaultCounterId()
		local purchased, foodId = DisplayCounterService:TakeFirstFood(player, counterId)
		if purchased then
			local food = Foods[foodId]
			local awarded = CurrencyService:AddCoins(player, food.saleValue)
			if awarded then
				notifySale(player, foodId, food.saleValue)
			end
		else
			PlayerUIService:SendNotification(player, {
				kind = "CustomerLeft",
				message = "A customer left because the display counter was empty.",
			})
			task.wait(Customers.noFoodWaitSeconds)
		end
	end

	moveCustomer(customer, exitMarker)
	if customer.Parent then
		customer:Destroy()
	end
	if activeCustomers[player] == customer then
		activeCustomers[player] = nil
	end
end

local function trySpawnCustomer(player)
	if activeCustomers[player] or player.Parent ~= Players then
		return
	end

	local spawnMarker, inspectMarker, exitMarker = getMarkers(player)
	if not spawnMarker then
		return
	end

	task.spawn(runCustomer, player, spawnMarker, inspectMarker, exitMarker)
end

local function validateConfig()
	for key, value in pairs(Customers) do
		if typeof(value) ~= "number" or value <= 0 then
			error("Customer configuration value must be positive: " .. key)
		end
	end

	for foodId, food in pairs(Foods) do
		if typeof(food) ~= "table" or typeof(food.saleValue) ~= "number" or food.saleValue <= 0 or food.saleValue % 1 ~= 0 then
			error("Food requires a positive integer saleValue: " .. foodId)
		end
	end
end

function CustomerSystem:Init()
	validateConfig()

	customerFolder = workspace:FindFirstChild("CustomerPlaceholders")
	if customerFolder == nil then
		customerFolder = Instance.new("Folder")
		customerFolder.Name = "CustomerPlaceholders"
		customerFolder.Parent = workspace
	end

	Players.PlayerRemoving:Connect(function(player)
		local customer = activeCustomers[player]
		if customer and customer.Parent then
			customer:Destroy()
		end
		activeCustomers[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(Customers.arrivalIntervalSeconds)
			for _, player in Players:GetPlayers() do
				trySpawnCustomer(player)
			end
		end
	end)
end

return CustomerSystem
