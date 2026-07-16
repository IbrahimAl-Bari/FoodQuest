local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))

local Panel = {}

function Panel.Create(parent, size)
	size = size or UDim2.fromScale(0.5, 0.5)

	local container = Instance.new("Frame")
	container.Name = "Panel"
	container.Size = size
	container.BackgroundTransparency = 1
	container.ClipsDescendants = false
	container.Parent = parent

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.Position = UDim2.new(0, Theme.Shadow.Medium.Offset, 0, Theme.Shadow.Medium.Offset)
	shadow.BackgroundColor3 = Color3.new(0, 0, 0)
	shadow.BackgroundTransparency = Theme.Shadow.Medium.Transparency
	shadow.ZIndex = container.ZIndex
	shadow.Parent = container

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = Theme.Radius.Large
	shadowCorner.Parent = shadow

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.Position = UDim2.fromScale(0, 0)
	content.BackgroundColor3 = Theme.Colors.Background
	content.ZIndex = container.ZIndex + 1
	content.Parent = container

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = Theme.Radius.Large
	contentCorner.Parent = content

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, Theme.Spacing.Large)
	padding.PaddingBottom = UDim.new(0, Theme.Spacing.Large)
	padding.PaddingLeft = UDim.new(0, Theme.Spacing.Large)
	padding.PaddingRight = UDim.new(0, Theme.Spacing.Large)
	padding.Parent = content

	local uiScale = Instance.new("UIScale")
	uiScale.Name = "PanelScale"
	uiScale.Scale = 1
	uiScale.Parent = container

	return container
end

function Panel.Open(panel)
	if not panel then
		return
	end
	Animations.OpenPanel(panel)
end

function Panel.Close(panel)
	if not panel then
		return
	end
	Animations.ClosePanel(panel)
end

return Panel
