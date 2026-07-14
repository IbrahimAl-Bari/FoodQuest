local function create()
	local part = Instance.new("Part")
	part.Name = "Tomato"
	part.Size = Vector3.new(1.8, 1.8, 1.8)
	part.Shape = Enum.PartType.Ball
	part.Color = Color3.fromRGB(220, 50, 50)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	return part
end

return create
