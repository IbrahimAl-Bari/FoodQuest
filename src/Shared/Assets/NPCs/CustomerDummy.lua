local Players = game:GetService("Players")

local function create()
	local model = Players:CreateHumanoidModelFromUserId(1)
	if model then
		model.Name = "CustomerDummy"
		for _, child in model:GetChildren() do
			if child:IsA("Tool") or child:IsA("Accessory") then
				child:Destroy()
			end
		end
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.CanCollide = true
				part.CanTouch = true
			end
		end
		local humanoid = model:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			humanoid.AutoRotate = true
		end
		return model
	end

	local model = Instance.new("Model")
	model.Name = "CustomerDummy"

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1.4)
	torso.Shape = Enum.PartType.Block
	torso.Color = Color3.fromRGB(84, 152, 222)
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = true
	torso.CanCollide = false
	torso.CanTouch = false
	torso.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Shape = Enum.PartType.Ball
	head.Color = Color3.fromRGB(255, 200, 150)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.CanTouch = false
	head.Position = Vector3.new(0, 1.6, 0)
	head.Parent = model

	model.PrimaryPart = torso

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.Parent = model

	return model
end

return create
