local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))

local Slot = {}
local ICON_NAME = "Icon"
local AMOUNT_NAME = "Amount"

function Slot.Create(parent, icon, amount)
	local container = Instance.new("Frame")
	container.Name = "Slot"
	container.Size = UDim2.new(0, 80, 0, 100)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.Position = UDim2.new(0, Theme.Shadow.Small.Offset, 0, Theme.Shadow.Small.Offset)
	shadow.BackgroundColor3 = Color3.new(0, 0, 0)
	shadow.BackgroundTransparency = Theme.Shadow.Small.Transparency
	shadow.ZIndex = container.ZIndex
	shadow.Parent = container

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = Theme.Radius.Medium
	shadowCorner.Parent = shadow

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.fromScale(1, 1)
	card.Position = UDim2.fromScale(0, 0)
	card.BackgroundColor3 = Theme.Colors.Background
	card.ZIndex = container.ZIndex + 1
	card.Parent = container

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = Theme.Radius.Medium
	cardCorner.Parent = card

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = ICON_NAME
	iconLabel.Size = UDim2.new(1, 0, 1, -24)
	iconLabel.Position = UDim2.new(0, 0, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 28
	iconLabel.Text = icon or ""
	iconLabel.TextColor3 = Theme.Colors.Text
	iconLabel.Parent = card

	local amountLabel = Instance.new("TextLabel")
	amountLabel.Name = AMOUNT_NAME
	amountLabel.Size = UDim2.new(1, -8, 0, 20)
	amountLabel.Position = UDim2.new(0, 4, 1, -22)
	amountLabel.BackgroundTransparency = 1
	amountLabel.Font = Theme.Fonts.Number
	amountLabel.TextSize = Theme.TextSize.Small
	amountLabel.Text = tostring(amount or "")
	amountLabel.TextColor3 = Theme.Colors.TextSecondary
	amountLabel.TextXAlignment = Enum.TextXAlignment.Right
	amountLabel.TextTruncate = Enum.TextTruncate.AtEnd
	amountLabel.Parent = card

	local uiScale = Instance.new("UIScale")
	uiScale.Name = "SlotScale"
	uiScale.Scale = 1
	uiScale.Parent = container

	return container
end

function Slot.SetIcon(slot, image)
	if not slot then
		return
	end

	local card = slot:FindFirstChild("Card") or slot
	local icon = card:FindFirstChild(ICON_NAME)
	if icon then
		icon.Text = image or ""
	end
end

function Slot.SetAmount(slot, amount)
	if not slot then
		return
	end

	local card = slot:FindFirstChild("Card") or slot
	local amountLabel = card:FindFirstChild(AMOUNT_NAME)
	if amountLabel then
		amountLabel.Text = tostring(amount or "")
	end
end

function Slot.SetSelected(slot, selected)
	if not slot then
		return
	end

	local card = slot:FindFirstChild("Card")
	if not card then
		return
	end

	local stroke = card:FindFirstChildOfClass("UIStroke")
	if selected then
		if not stroke then
			stroke = Instance.new("UIStroke")
			stroke.Name = "SelectedStroke"
			stroke.Color = Theme.Colors.Reward
			stroke.Thickness = 3
			stroke.Transparency = 0
			stroke.Parent = card
		end

		local uiScale = slot:FindFirstChildOfClass("UIScale") or Animations.GetUIScale(slot)
		Animations.Tween(uiScale, { Scale = 1.08 }, Theme.Animation.Fast, Theme.Animation.EasingOut)
	else
		if stroke then
			stroke:Destroy()
		end

		local uiScale = slot:FindFirstChildOfClass("UIScale") or Animations.GetUIScale(slot)
		Animations.Tween(uiScale, { Scale = 1 }, Theme.Animation.Fast, Theme.Animation.EasingOut)
	end
end

return Slot
