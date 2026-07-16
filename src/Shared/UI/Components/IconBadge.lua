local Theme = require(script.Parent.Parent:WaitForChild("Theme"))

local IconBadge = {}
local ICON_NAME = "Icon"
local VALUE_NAME = "Value"

function IconBadge.Create(parent, icon, value)
	local badge = Instance.new("Frame")
	badge.Name = "IconBadge"
	badge.Size = UDim2.new(0, 48, 0, 48)
	badge.BackgroundColor3 = Theme.Colors.Primary
	badge.BorderSize = 0
	badge.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Radius.Round
	corner.Parent = badge

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = ICON_NAME
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.Position = UDim2.fromScale(0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 22
	iconLabel.Text = icon or ""
	iconLabel.TextColor3 = Theme.Colors.TextLight
	iconLabel.Parent = badge

	if value ~= nil then
		IconBadge.SetValue(badge, value)
	end

	return badge
end

function IconBadge.SetIcon(badge, icon)
	if not badge then
		return
	end

	local iconLabel = badge:FindFirstChild(ICON_NAME)
	if iconLabel then
		iconLabel.Text = icon or ""
	end
end

function IconBadge.SetValue(badge, value)
	if not badge then
		return
	end

	local valueLabel = badge:FindFirstChild(VALUE_NAME)
	if value == nil or value == "" then
		if valueLabel then
			valueLabel:Destroy()
		end
		return
	end

	if not valueLabel then
		valueLabel = Instance.new("TextLabel")
		valueLabel.Name = VALUE_NAME
		valueLabel.BackgroundTransparency = 1
		valueLabel.Font = Theme.Fonts.Number
		valueLabel.TextSize = Theme.TextSize.Tiny
		valueLabel.TextColor3 = Theme.Colors.TextLight
		valueLabel.TextXAlignment = Enum.TextXAlignment.Center
		valueLabel.TextYAlignment = Enum.TextYAlignment.Bottom
		valueLabel.Size = UDim2.new(1, -4, 1, -4)
		valueLabel.Position = UDim2.new(0, 2, 0, 2)
		valueLabel.Parent = badge

		local iconLabel = badge:FindFirstChild(ICON_NAME)
		if iconLabel then
			iconLabel.TextYAlignment = Enum.TextYAlignment.Top
			iconLabel.Position = UDim2.new(0, 0, 0, 4)
		end
	end

	valueLabel.Text = tostring(value)
end

function IconBadge.SetColor(badge, color)
	if not badge then
		return
	end

	badge.BackgroundColor3 = color or Theme.Colors.Primary
end

return IconBadge
