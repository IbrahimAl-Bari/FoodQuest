local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DisplayCounterService = require(script.Parent:WaitForChild("DisplayCounterService"))

local DisplayCounterVisualService = {}

local COUNTER_MODEL_NAME = "DisplayCounter"

local slottedFoods = {}

local function getCounterModel()
	local worldFolder = workspace:FindFirstChild("PrototypeWorld")
	if not worldFolder then
		return nil
	end
	local stationsFolder = worldFolder:FindFirstChild("Stations")
	if not stationsFolder then
		return nil
	end
	local model = stationsFolder:FindFirstChild(COUNTER_MODEL_NAME)
	if model then
		if model:IsA("Model") or model:IsA("BasePart") then
			return model
		end
	end
	return nil
end

local function getSlotPart(counter, slotIndex)
	if counter:IsA("BasePart") then
		return nil
	end
	local part = counter:FindFirstChild("Slot" .. slotIndex)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end

local function getFoodVisualPosition(slotPart, counter, slotIndex)
	if slotPart then
		local topY = slotPart.Position.Y + slotPart.Size.Y / 2
		return CFrame.new(slotPart.Position.X, topY, slotPart.Position.Z)
	end
	if counter:IsA("Model") and counter.PrimaryPart then
		local base = counter.PrimaryPart
		local spacing = 2
		local offsetX = (slotIndex - 2) * spacing
		local topY = base.Position.Y + base.Size.Y / 2
		return CFrame.new(base.Position.X + offsetX, topY, base.Position.Z)
	end
	return CFrame.new(0, 2, 0)
end

local function getFoodParent(slotPart, counter)
	return slotPart or counter
end

local function createFoodVisual(foodId)
	local modelsFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Models")
	if modelsFolder then
		local foodsFolder = modelsFolder:FindFirstChild("Foods")
		if foodsFolder then
			local template = foodsFolder:FindFirstChild(foodId)
			if template then
				local instance = template:Clone()
				instance.Name = foodId
				return instance
			end
		end
	end

	local foodsFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Foods")
	if foodsFolder then
		local factoryModule = foodsFolder:FindFirstChild(foodId)
		if factoryModule and factoryModule:IsA("ModuleScript") then
			local factory = require(factoryModule)
			local instance = factory()
			instance.Name = foodId
			return instance
		end
	end

	return nil
end

local function removePlayerFoods(player)
	local playerFoods = slottedFoods[player]
	if not playerFoods then
		return
	end
	for slotIndex, foodModel in playerFoods do
		if foodModel and foodModel.Parent then
			foodModel:Destroy()
		end
	end
	slottedFoods[player] = nil
end

function DisplayCounterVisualService:Init()
	local counter = getCounterModel()
	if not counter then
		warn("[DisplayCounterVisual] No DisplayCounter model found in workspace")
		return
	end

	DisplayCounterService.FoodPlaced.Event:Connect(function(player, counterId, foodId, slotIndex)
		local visual = createFoodVisual(foodId)
		if not visual then
			warn("[DisplayCounterVisual] No visual model for food:", foodId)
			return
		end

		local slotPart = getSlotPart(counter, slotIndex)
		local cframe = getFoodVisualPosition(slotPart, counter, slotIndex)
		local parent = getFoodParent(slotPart, counter)

		visual.Anchored = true
		visual.CanCollide = false
		visual.CanTouch = false
		visual.CFrame = cframe
		visual.Parent = parent

		slottedFoods[player] = slottedFoods[player] or {}
		slottedFoods[player][slotIndex] = visual
	end)

	DisplayCounterService.FoodRemoved.Event:Connect(function(player, counterId, foodId, slotIndex)
		local playerFoods = slottedFoods[player]
		if not playerFoods then
			return
		end
		local foodModel = playerFoods[slotIndex]
		if foodModel and foodModel.Parent then
			foodModel:Destroy()
		end
		playerFoods[slotIndex] = nil
	end)

	Players.PlayerRemoving:Connect(function(player)
		removePlayerFoods(player)
	end)
end

return DisplayCounterVisualService
