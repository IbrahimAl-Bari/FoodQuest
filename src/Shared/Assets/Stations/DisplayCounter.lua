local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function create()
	local modelsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models")
	local template = modelsFolder:FindFirstChild("DisplayCounterStand")
	if template then
		local model = template:Clone()
		model.Name = "DisplayCounter"
		return model
	end

	local model = Instance.new("Model")
	model.Name = "DisplayCounter"

	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(5.6, 1, 2.8)
	base.Shape = Enum.PartType.Block
	base.Color = Color3.fromRGB(160, 120, 80)
	base.Material = Enum.Material.Wood
	base.Anchored = true
	base.CanCollide = true
	base.CanTouch = false
	base.Parent = model

	local function createSlot(index, xOffset)
		local slot = Instance.new("Part")
		slot.Name = "Slot" .. index
		slot.Size = Vector3.new(1.4, 0.3, 1.4)
		slot.Shape = Enum.PartType.Block
		slot.Color = Color3.fromRGB(200, 180, 140)
		slot.Material = Enum.Material.SmoothPlastic
		slot.Anchored = true
		slot.CanCollide = false
		slot.CanTouch = false
		slot.CFrame = CFrame.new(xOffset, 0.65, 0)
		slot.Parent = model
		return slot
	end

	createSlot(1, -1.5)
	createSlot(2, 0)
	createSlot(3, 1.5)

	model.PrimaryPart = base
	return model
end

return create
