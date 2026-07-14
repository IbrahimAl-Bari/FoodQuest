local function create()
	local part = Instance.new("Part")
	part.Name = "TomatoSoup"
	part.Size = Vector3.new(2.4, 1.2, 2.4)
	part.Shape = Enum.PartType.Cylinder
	part.Color = Color3.fromRGB(200, 80, 50)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	return part
end

return create
