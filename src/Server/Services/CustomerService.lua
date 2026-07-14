local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomerDummy = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("NPCs"):WaitForChild("CustomerDummy"))
local Customers = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Customers"))
local Foods = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Foods"))
local Recipes = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Recipes"))
local CurrencyService = require(script.Parent:WaitForChild("CurrencyService"))
local DisplayCounterService = require(script.Parent:WaitForChild("DisplayCounterService"))
local PlayerUIService = require(script.Parent:WaitForChild("PlayerUIService"))

local CustomerService = {}

CustomerService.CustomerChanged = Instance.new("BindableEvent")

local SPAWN_TAG = "CustomerSpawn"
local INSPECT_TAG = "CustomerInspectPoint"
local EXIT_TAG = "CustomerExit"

local HAPPY_ANIMATION_ID = "rbxassetid://5077706661"
local SAD_ANIMATION_ID = "rbxassetid://6871073697"

local activeCustomers = {}

local RECIPE_LIST
do
	local ids = {}
	for id in Recipes do
		ids[#ids + 1] = id
	end
	RECIPE_LIST = ids
end

local function getMarkerForPlayer(tagName, player)
	local fallback
	for _, marker in CollectionService:GetTagged(tagName) do
		if marker:IsA("BasePart") and marker:IsDescendantOf(workspace) then
			local ownerUserId = marker:GetAttribute("OwnerUserId")
			if ownerUserId == player.UserId then
				return marker
			end
			if ownerUserId == nil or ownerUserId == 0 then
				fallback = fallback or marker
			end
		end
	end
	return fallback
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

local function pickRandomRecipe()
	local id = RECIPE_LIST[math.random(1, #RECIPE_LIST)]
	return Recipes[id], id
end

local function getRootPart(model)
	return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
end

local function getHumanoid(model)
	return model:FindFirstChildWhichIsA("Humanoid")
end

local function createOrderBillboard(adornee, foodDisplayName)
	local gui = Instance.new("BillboardGui")
	gui.Name = "OrderGui"
	gui.Size = UDim2.new(0, 200, 0, 50)
	gui.StudsOffset = Vector3.new(0, 4.5, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = adornee

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	bg.BackgroundTransparency = 0.4
	bg.BorderSizePixel = 0
	bg.Parent = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "Wants: " .. foodDisplayName
	label.TextColor3 = Color3.fromRGB(255, 255, 200)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = bg

	return gui
end

local function createCoinEffect(adornee, coins)
	local gui = Instance.new("BillboardGui")
	gui.Name = "CoinEffect"
	gui.Size = UDim2.new(0, 120, 0, 40)
	gui.StudsOffset = Vector3.new(0, 5.5, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = adornee

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "+" .. coins
	label.TextColor3 = Color3.fromRGB(255, 215, 50)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui

	gui.Parent = adornee

	task.delay(2, function()
		if gui.Parent then
			gui:Destroy()
		end
	end)
end

local function createServePrompt(model, foodDisplayName)
	local rootPart = getRootPart(model)
	if not rootPart then
		return nil
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ServePrompt"
	prompt.ActionText = "Serve " .. foodDisplayName
	prompt.ObjectText = "Customer"
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = rootPart
	return prompt
end

local function playAnimation(humanoid, animId)
	if not humanoid then
		return nil
	end
	local animator = humanoid:FindFirstChildWhichIsA("Animator")
	if not animator then
		return nil
	end
	local success, animTrack = pcall(function()
		local animation = Instance.new("Animation")
		animation.AnimationId = animId
		return animator:LoadAnimation(animation)
	end)
	if success and animTrack then
		animTrack:Play()
		return animTrack
	end
	return nil
end

local function walkToPosition(model, targetPosition)
	local humanoid = getHumanoid(model)
	if not humanoid then
		return false
	end

	local rootPart = getRootPart(model)
	if not rootPart then
		return false
	end

	local success, path = pcall(function()
		local p = PathfindingService:CreatePath()
		p:ComputeAsync(rootPart.Position, targetPosition)
		return p
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		for _, waypoint in waypoints do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end
		end
	end

	humanoid:MoveTo(targetPosition)
	return true
end

local function onCustomerArrived(player)
	local customer = activeCustomers[player]
	if not customer or customer.isLeaving then
		return
	end

	local rootPart = getRootPart(customer.model)
	if not rootPart then
		return
	end

	local gui = createOrderBillboard(rootPart, customer.recipe.displayName)
	gui.Parent = rootPart
	customer.gui = gui

	local prompt = createServePrompt(customer.model, customer.recipe.displayName)
	if not prompt then
		gui:Destroy()
		customer.gui = nil
		return
	end
	customer.prompt = prompt

	prompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer ~= player then
			PlayerUIService:SendNotification(triggeringPlayer, {
				kind = "CustomerNotYours",
				message = "This customer is waiting for someone else.",
			})
			return
		end
		serveCustomer(player)
	end)

	CustomerService.CustomerChanged:Fire(player, customer.model, "Ordered", customer.recipe.outputFoodId)

	customer.patrolTimer = task.delay(Customers.patienceSeconds, function()
		if activeCustomers[player] == customer and not customer.isLeaving then
			customerLeaveUnhappy(player)
		end
	end)
end

local function sendCustomerToExit(player)
	local customer = activeCustomers[player]
	if not customer then
		return
	end
	customer.isLeaving = true

	if customer.patrolTimer then
		task.cancel(customer.patrolTimer)
		customer.patrolTimer = nil
	end

	if customer.gui then
		customer.gui:Destroy()
		customer.gui = nil
	end
	if customer.prompt then
		customer.prompt:Destroy()
		customer.prompt = nil
	end

	walkToPosition(customer.model, customer.exitMarker.Position)

	task.spawn(function()
		local deadline = os.clock() + 8
		while os.clock() < deadline do
			local c = activeCustomers[player]
			if not c or not c.model or not c.model.Parent then
				return
			end
			local rootPart = getRootPart(c.model)
			if rootPart then
				local dist = (rootPart.Position - customer.exitMarker.Position).Magnitude
				if dist < 4 then
					cleanupCustomer(player)
					return
				end
			end
			task.wait(0.3)
		end
		cleanupCustomer(player)
	end)
end

local function serveCustomer(player)
	local customer = activeCustomers[player]
	if not customer or customer.isLeaving then
		return
	end

	local counterId = DisplayCounterService:GetDefaultCounterId()
	local taken, reason = DisplayCounterService:TakeFoodById(player, counterId, customer.foodId)
	if not taken then
		PlayerUIService:SendNotification(player, {
			kind = "CustomerNotServed",
			message = "You don't have this order ready.",
		})
		return
	end

	CurrencyService:AddCoins(player, customer.saleValue)

	PlayerUIService:SendNotification(player, {
		kind = "CustomerPurchased",
		foodId = customer.foodId,
		coins = customer.saleValue,
		foodName = customer.foodDisplayName,
	})

	if customer.patrolTimer then
		task.cancel(customer.patrolTimer)
		customer.patrolTimer = nil
	end

	if customer.gui then
		customer.gui:Destroy()
		customer.gui = nil
	end
	if customer.prompt then
		customer.prompt:Destroy()
		customer.prompt = nil
	end

	local humanoid = getHumanoid(customer.model)
	if humanoid then
		playAnimation(humanoid, HAPPY_ANIMATION_ID)
	end

	local rootPart = getRootPart(customer.model)
	if rootPart then
		createCoinEffect(rootPart, customer.saleValue)
	end

	CustomerService.CustomerChanged:Fire(player, customer.model, "Served", customer.foodId)

	task.wait(1.5)
	sendCustomerToExit(player)
end

local function customerLeaveUnhappy(player)
	local customer = activeCustomers[player]
	if not customer then
		return
	end

	if customer.patrolTimer then
		task.cancel(customer.patrolTimer)
		customer.patrolTimer = nil
	end

	if customer.gui then
		customer.gui:Destroy()
		customer.gui = nil
	end
	if customer.prompt then
		customer.prompt:Destroy()
		customer.prompt = nil
	end

	customer.isLeaving = true

	PlayerUIService:SendNotification(player, {
		kind = "CustomerLeft",
		message = "A customer left because you took too long.",
	})

	CustomerService.CustomerChanged:Fire(player, customer.model, "LeftUnhappy", customer.foodId)

	local humanoid = getHumanoid(customer.model)
	if humanoid then
		playAnimation(humanoid, SAD_ANIMATION_ID)
	end

	task.wait(1)
	sendCustomerToExit(player)
end

local function cleanupCustomer(player)
	local customer = activeCustomers[player]
	if not customer then
		return
	end
	if customer.patrolTimer then
		task.cancel(customer.patrolTimer)
	end
	if customer.gui then
		customer.gui:Destroy()
	end
	if customer.prompt then
		customer.prompt:Destroy()
	end
	if customer.moveConnection then
		customer.moveConnection:Disconnect()
	end
	if customer.model and customer.model.Parent then
		customer.model:Destroy()
	end
	activeCustomers[player] = nil
end

local function spawnCustomer(player)
	if activeCustomers[player] then
		return
	end

	local spawnMarker, inspectMarker, exitMarker = getMarkers(player)
	if not spawnMarker then
		return
	end

	local recipe, recipeId = pickRandomRecipe()
	local foodDef = Foods[recipe.outputFoodId]
	if not foodDef then
		return
	end

	local model = CustomerDummy()
	model.Parent = workspace

	local rootPart = getRootPart(model)
	if rootPart then
		rootPart.CFrame = spawnMarker.CFrame * CFrame.new(0, 2, 0)
	end

	local humanoid = getHumanoid(model)
	if humanoid then
		humanoid.WalkSpeed = Customers.walkSpeed
	end

	local customer = {
		model = model,
		recipe = recipe,
		recipeId = recipeId,
		foodId = recipe.outputFoodId,
		foodDisplayName = recipe.displayName,
		saleValue = foodDef.saleValue,
		gui = nil,
		prompt = nil,
		patrolTimer = nil,
		isLeaving = false,
		moveConnection = nil,
		exitMarker = exitMarker,
	}

	activeCustomers[player] = customer

	walkToPosition(model, inspectMarker.Position)

	if humanoid then
		local connection
		connection = humanoid.MoveToFinished:Connect(function(reached)
			if reached and activeCustomers[player] == customer and not customer.isLeaving then
				connection:Disconnect()
				onCustomerArrived(player)
			end
		end)
		customer.moveConnection = connection
	end

	task.spawn(function()
		task.wait(3)
		local c = activeCustomers[player]
		if c == customer and not customer.gui and not customer.isLeaving then
			onCustomerArrived(player)
		end
	end)
end

local function validateConfig()
	for foodId, food in pairs(Foods) do
		if typeof(food.saleValue) ~= "number" or food.saleValue <= 0 or food.saleValue % 1 ~= 0 then
			error("Food requires a positive integer saleValue: " .. foodId)
		end
	end
end

function CustomerService:Init()
	validateConfig()

	Players.PlayerRemoving:Connect(function(player)
		cleanupCustomer(player)
	end)

	task.spawn(function()
		while true do
			task.wait(Customers.arrivalIntervalSeconds)
			for _, player in Players:GetPlayers() do
				spawnCustomer(player)
			end
		end
	end)
end

return CustomerService
