local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))
local IconBadge = require(script.Parent:WaitForChild("IconBadge"))

local CurrencyDisplay = {}
local VALUE_NAME = "Value"

function CurrencyDisplay.Create(parent, icon, value)
	local display = Instance.new("Frame")
	display.Name = "CurrencyDisplay"
	display.Size = UDim2.new(0, 140, 0, 44)
	display.BackgroundColor3 = Theme.Colors.Background
	display.BorderSize = 0
	display.Parent = parent

	local displayCorner = Instance.new("UICorner")
	displayCorner.CornerRadius = Theme.Radius.Medium
	displayCorner.Parent = display

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.Position = UDim2.new(0, Theme.Shadow.Small.Offset, 0, Theme.Shadow.Small.Offset)
	shadow.BackgroundColor3 = Color3.new(0, 0, 0)
	shadow.BackgroundTransparency = Theme.Shadow.Small.Transparency
	shadow.ZIndex = display.ZIndex - 1
	shadow.Parent = display

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = Theme.Radius.Medium
	shadowCorner.Parent = shadow

	local badge = IconBadge.Create(display, icon)
	badge.Name = "IconBadge"
	badge.Size = UDim2.new(0, 32, 0, 32)
	badge.Position = UDim2.new(0, 6, 0.5, -16)

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = VALUE_NAME
	valueLabel.Size = UDim2.new(1, -48, 1, 0)
	valueLabel.Position = UDim2.new(0, 44, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Theme.Fonts.Number
	valueLabel.TextSize = Theme.TextSize.Large
	valueLabel.Text = tostring(value or 0)
	valueLabel.TextColor3 = Theme.Colors.Text
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
	valueLabel.Parent = display

	return display
end

function CurrencyDisplay.SetIcon(display, icon)
	if not display then
		return
	end

	local badge = display:FindFirstChild("IconBadge")
	if badge then
		IconBadge.SetIcon(badge, icon)
	end
end

local function animateNumber(label, targetValue)
	if not label then
		return
	end

	local currentText = label.Text
	local currentValue = tonumber(currentText:match("[%-]?[%d,]+")) or 0

	if currentValue == targetValue then
		return
	end

	local numVal = Instance.new("NumberValue")
	numVal.Value = currentValue

	local tween = TweenService:Create(numVal, TweenInfo.new(
		Theme.Animation.Normal,
		Theme.Animation.EasingOut
	), { Value = targetValue })

	numVal.Changed:Connect(function(newValue)
		label.Text = tostring(math.floor(newValue + 0.5))
	end)

	tween.Completed:Once(function()
		label.Text = tostring(targetValue)
		numVal:Destroy()
	end)

	tween:Play()
end

function CurrencyDisplay.SetValue(display, value)
	if not display then
		return
	end

	local valueLabel = display:FindFirstChild(VALUE_NAME)
	if valueLabel then
		animateNumber(valueLabel, value or 0)
	end

	local uiScale = Animations.GetUIScale(display)
	local popTween = Animations.Tween(uiScale, { Scale = 1.08 }, Theme.Animation.Fast, Theme.Animation.EasingOut)
	if popTween then
		popTween.Completed:Once(function()
			Animations.Tween(uiScale, { Scale = 1 }, Theme.Animation.Fast, Theme.Animation.EasingOut)
		end)
	end
end

return CurrencyDisplay
