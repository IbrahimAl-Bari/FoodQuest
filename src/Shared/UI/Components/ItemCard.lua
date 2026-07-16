local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))
local Button = require(script.Parent:WaitForChild("Button"))
local IconBadge = require(script.Parent:WaitForChild("IconBadge"))

local ItemCard = {}

function ItemCard.Create(parent, data)
	data = data or {}

	local container = Instance.new("Frame")
	container.Name = "ItemCard"
	container.Size = UDim2.new(0, 200, 0, 280)
	container.BackgroundTransparency = 1
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

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.fromScale(1, 1)
	card.Position = UDim2.fromScale(0, 0)
	card.BackgroundColor3 = Theme.Colors.Background
	card.ZIndex = container.ZIndex + 1
	card.Parent = container

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = Theme.Radius.Large
	cardCorner.Parent = card

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(1, 0, 0, 100)
	icon.Position = UDim2.fromScale(0, 0)
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 48
	icon.Text = data.Icon or ""
	icon.TextColor3 = Theme.Colors.Text
	icon.Parent = card

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, -16, 0, 24)
	nameLabel.Position = UDim2.new(0, 12, 0, 108)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Theme.Fonts.Header
	nameLabel.TextSize = Theme.TextSize.Normal
	nameLabel.Text = data.Name or ""
	nameLabel.TextColor3 = Theme.Colors.Text
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = card

	local desc = Instance.new("TextLabel")
	desc.Name = "Description"
	desc.Size = UDim2.new(1, -24, 0, 40)
	desc.Position = UDim2.new(0, 12, 0, 136)
	desc.BackgroundTransparency = 1
	desc.Font = Theme.Fonts.Body
	desc.TextSize = Theme.TextSize.Small
	desc.Text = data.Description or ""
	desc.TextColor3 = Theme.Colors.TextSecondary
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextWrapped = true
	desc.Parent = card

	local priceBadge = IconBadge.Create(card, "★", data.Price or 0)
	priceBadge.Name = "PriceBadge"
	priceBadge.Size = UDim2.new(0, 80, 0, 32)
	priceBadge.Position = UDim2.new(0, 12, 1, -44)
	priceBadge.ZIndex = card.ZIndex + 1
	IconBadge.SetColor(priceBadge, Theme.Colors.Reward)

	local actionBtn = Button.Create(card, "Buy", "Primary")
	actionBtn.Name = "ActionBtn"
	actionBtn.Size = UDim2.new(0, 90, 0, 34)
	actionBtn.Position = UDim2.new(1, -102, 1, -40)
	actionBtn.ZIndex = card.ZIndex + 1

	return container
end

function ItemCard.SetPrice(card, price)
	if not card then
		return
	end

	local cardFrame = card:FindFirstChild("Card") or card
	local badge = cardFrame:FindFirstChild("PriceBadge")
	if badge then
		IconBadge.SetValue(badge, price)
	end
end

function ItemCard.SetData(card, data)
	if not card or not data then
		return
	end

	local cardFrame = card:FindFirstChild("Card") or card

	local icon = cardFrame:FindFirstChild("Icon")
	if icon and data.Icon then
		icon.Text = data.Icon
	end

	local nameLabel = cardFrame:FindFirstChild("Name")
	if nameLabel and data.Name then
		nameLabel.Text = data.Name
	end

	local desc = cardFrame:FindFirstChild("Description")
	if desc and data.Description then
		desc.Text = data.Description
	end

	if data.Price ~= nil then
		ItemCard.SetPrice(card, data.Price)
	end
end

function ItemCard.SetSelected(card, selected)
	if not card then
		return
	end

	local cardFrame = card:FindFirstChild("Card") or card
	local stroke = cardFrame:FindFirstChildOfClass("UIStroke")

	if selected then
		if not stroke then
			stroke = Instance.new("UIStroke")
			stroke.Name = "SelectedStroke"
			stroke.Color = Theme.Colors.Reward
			stroke.Thickness = 3
			stroke.Transparency = 0
			stroke.Parent = cardFrame
		end

		local uiScale = card:FindFirstChildOfClass("UIScale") or Animations.GetUIScale(card)
		Animations.Tween(uiScale, { Scale = 1.05 }, Theme.Animation.Fast, Theme.Animation.EasingOut)
	else
		if stroke then
			stroke:Destroy()
		end

		local uiScale = card:FindFirstChildOfClass("UIScale") or Animations.GetUIScale(card)
		Animations.Tween(uiScale, { Scale = 1 }, Theme.Animation.Fast, Theme.Animation.EasingOut)
	end
end

return ItemCard
