local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))

local ProgressBar = {}
local FILL_NAME = "Fill"

function ProgressBar.Create(parent)
	local bar = Instance.new("Frame")
	bar.Name = "ProgressBar"
	bar.Size = UDim2.new(1, 0, 0, 14)
	bar.BackgroundColor3 = Theme.Colors.Background
	bar.BorderSize = 0
	bar.Parent = parent

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = Theme.Radius.Small
	barCorner.Parent = bar

	local fill = Instance.new("Frame")
	fill.Name = FILL_NAME
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Theme.Colors.Secondary
	fill.BorderSize = 0
	fill.Parent = bar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = Theme.Radius.Small
	fillCorner.Parent = fill

	return bar
end

function ProgressBar.SetProgress(bar, value, color)
	if not bar then
		return
	end

	local fill = bar:FindFirstChild(FILL_NAME)
	if not fill then
		return
	end

	local clamped = math.clamp(value, 0, 1)

	if color then
		fill.BackgroundColor3 = color
	end

	Animations.ProgressBar(fill, clamped)
end

return ProgressBar
