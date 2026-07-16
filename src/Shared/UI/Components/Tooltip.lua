local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))

local Tooltip = {}

function Tooltip.Create(parent, text)
	local tooltip = Instance.new("Frame")
	tooltip.Name = "Tooltip"
	tooltip.Size = UDim2.new(0, 0, 0, 0)
	tooltip.AutomaticSize = Enum.AutomaticSize.XY
	tooltip.BackgroundColor3 = Theme.Colors.Dark
	tooltip.BorderSize = 0
	tooltip.Visible = false
	tooltip.ZIndex = 1000
	tooltip.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Radius.Small
	corner.Parent = tooltip

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, Theme.Spacing.Small)
	padding.PaddingRight = UDim.new(0, Theme.Spacing.Small)
	padding.PaddingTop = UDim.new(0, Theme.Spacing.XSmall)
	padding.PaddingBottom = UDim.new(0, Theme.Spacing.XSmall)
	padding.Parent = tooltip

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(0, 0, 0, 0)
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Theme.Fonts.Body
	textLabel.TextSize = Theme.TextSize.Small
	textLabel.Text = text or ""
	textLabel.TextColor3 = Theme.Colors.TextLight
	textLabel.TextWrapped = true
	textLabel.Parent = tooltip

	return tooltip
end

function Tooltip.Show(tooltip)
	if not tooltip then
		return
	end

	tooltip.Visible = true
	Animations.FadeIn(tooltip)
end

function Tooltip.Hide(tooltip)
	if not tooltip then
		return
	end

	Animations.FadeOut(tooltip)
end

function Tooltip.SetText(tooltip, text)
	if not tooltip then
		return
	end

	local textLabel = tooltip:FindFirstChild("Text")
	if textLabel then
		textLabel.Text = text or ""
	end
end

return Tooltip
