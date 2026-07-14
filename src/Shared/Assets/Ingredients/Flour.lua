local function create()
	local part = Instance.new("Part")
	part.Name = "Flour"
	part.Size = Vector3.new(1.6, 1.6, 1.6)
	part.Shape = Enum.PartType.Block
	part.Color = Color3.fromRGB(245, 235, 220)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	return part
end

return create
