local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function create()
	local modelsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models")
	local template = modelsFolder:FindFirstChild("CookingStationOven")
	if template then
		local model = template:Clone()
		model.Name = "CookingStation"
		CollectionService:AddTag(model, "CookingStation")
		return model
	end

	local part = Instance.new("Part")
	part.Name = "CookingStation"
	part.Size = Vector3.new(3.6, 1.8, 3.6)
	part.Shape = Enum.PartType.Block
	part.Color = Color3.fromRGB(180, 120, 80)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.CanTouch = false
	CollectionService:AddTag(part, "CookingStation")
	return part
end

return create
