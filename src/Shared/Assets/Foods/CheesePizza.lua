local function create()
	local part = Instance.new("Part")
	part.Name = "CheesePizza"
	part.Size = Vector3.new(2.8, 0.6, 2.8)
	part.Shape = Enum.PartType.Cylinder
	part.Color = Color3.fromRGB(255, 180, 50)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	return part
end

return create
