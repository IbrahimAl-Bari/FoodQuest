local function create()
	local part = Instance.new("Part")
	part.Name = "Cheese"
	part.Size = Vector3.new(1.6, 1.2, 1.6)
	part.Shape = Enum.PartType.Cylinder
	part.Color = Color3.fromRGB(255, 215, 50)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	return part
end

return create
