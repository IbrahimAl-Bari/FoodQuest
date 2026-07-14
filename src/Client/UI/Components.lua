local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent:WaitForChild("Theme"))

local Components = {}

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or Theme.Radius.Medium
	corner.Parent = instance
	return corner
end

function Components.CreateScreenGui(playerGui, name)
	local existing = playerGui:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	return screenGui
end

function Components.CreateCard(parent, properties)
	properties = properties or {}
	local zIndex = properties.ZIndex or 1
	local radius = properties.Radius or Theme.Radius.Large

	local card = Instance.new("Frame")
	card.Name = properties.Name or "Card"
	card.Size = properties.Size or UDim2.fromOffset(200, 100)
	card.Position = properties.Position or UDim2.fromOffset(0, 0)
	card.AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0)
	card.BackgroundColor3 = properties.BackgroundColor3 or Theme.Colors.CardBackground
	card.BorderSizePixel = 0
	card.ZIndex = zIndex
	card.Parent = parent
	addCorner(card, radius)

	if not properties.NoShadow then
		local elevation = properties.Elevation or Theme.Shadow.Elevation.Medium
		local shadow = Instance.new("Frame")
		shadow.Name = "Shadow"
		shadow.Size = card.Size
		shadow.Position = card.Position + UDim2.fromOffset(0, elevation)
		shadow.AnchorPoint = card.AnchorPoint
		shadow.BackgroundColor3 = Theme.Colors.PrimaryText
		shadow.BackgroundTransparency = Theme.Shadow.Transparency
		shadow.BorderSizePixel = 0
		shadow.ZIndex = math.max(0, zIndex - 1)
		shadow.Parent = parent
		addCorner(shadow, radius)

		local shadowReference = Instance.new("ObjectValue")
		shadowReference.Name = "ShadowReference"
		shadowReference.Value = shadow
		shadowReference.Parent = card

		card:GetPropertyChangedSignal("Size"):Connect(function()
			shadow.Size = card.Size
		end)
		card:GetPropertyChangedSignal("Position"):Connect(function()
			shadow.Position = card.Position + UDim2.fromOffset(0, elevation)
		end)
	end

	local stroke = Instance.new("UIStroke")
	stroke.Color = properties.StrokeColor or Theme.Colors.CardBorder
	stroke.Transparency = Theme.StrokeTransparency
	stroke.Thickness = 1
	stroke.Parent = card

	return card
end

function Components.CreateImageLabel(parent, properties)
	properties = properties or {}
	local label = Instance.new("ImageLabel")
	label.Name = properties.Name or "ImageLabel"
	label.Size = properties.Size or UDim2.fromOffset(40, 40)
	label.Position = properties.Position or UDim2.fromOffset(0, 0)
	label.AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0)
	label.Image = properties.Image or ""
	label.ImageColor3 = properties.ImageColor3 or Color3.new(1, 1, 1)
	label.ImageTransparency = properties.ImageTransparency or 0
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.ZIndex = properties.ZIndex or 1
	label.Parent = parent
	if properties.Radius then
		addCorner(label, properties.Radius)
	end
	return label
end

function Components.CreateLabel(parent, properties)
	properties = properties or {}
	local label = Instance.new("TextLabel")
	label.Name = properties.Name or "Label"
	label.Size = properties.Size or UDim2.fromOffset(100, 24)
	label.Position = properties.Position or UDim2.fromOffset(0, 0)
	label.AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0)
	label.BackgroundTransparency = 1
	label.Text = properties.Text or ""
	label.TextColor3 = properties.TextColor3 or Theme.Colors.PrimaryText
	label.TextSize = properties.TextSize or Theme.TextSize.Body
	label.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
	label.TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center
	label.TextWrapped = properties.TextWrapped == true
	label.Font = properties.Font or Theme.Fonts.Body
	label.ZIndex = properties.ZIndex or 2
	label.Parent = parent
	return label
end

function Components.CreateIconBadge(parent, properties)
	properties = properties or {}
	local badge = Instance.new("Frame")
	badge.Name = properties.Name or "IconBadge"
	badge.Size = properties.Size or UDim2.fromOffset(40, 40)
	badge.Position = properties.Position or UDim2.fromOffset(0, 0)
	badge.BackgroundColor3 = properties.BackgroundColor3 or Theme.Colors.SecondaryPanel
	badge.BorderSizePixel = 0
	badge.ZIndex = properties.ZIndex or 3
	badge.Parent = parent
	addCorner(badge, Theme.Radius.Pill)

	if properties.Image then
		local icon = Components.CreateImageLabel(badge, {
			Name = "Icon",
			Size = UDim2.new(1, -8, 1, -8),
			Position = UDim2.fromOffset(4, 4),
			Image = properties.Image,
			ImageColor3 = properties.ImageColor3 or Color3.new(1, 1, 1),
			ZIndex = (properties.ZIndex or 3) + 1,
		})
		return badge, icon
	end

	local icon = Components.CreateLabel(badge, {
		Name = "Icon",
		Size = UDim2.fromScale(1, 1),
		Text = properties.Text or "•",
		TextColor3 = properties.TextColor3 or Theme.Colors.PrimaryText,
		TextSize = properties.TextSize or Theme.TextSize.Section,
		TextXAlignment = Enum.TextXAlignment.Center,
		Font = Theme.Fonts.Heading,
		ZIndex = (properties.ZIndex or 3) + 1,
	})

	return badge, icon
end

function Components.CreateButton(parent, properties)
	properties = properties or {}
	local zIndex = properties.ZIndex or 3
	local radius = properties.Radius or Theme.Radius.Medium

	local container = Instance.new("Frame")
	container.Name = (properties.Name or "Button") .. "Container"
	container.Size = properties.Size or UDim2.fromOffset(140, 44)
	container.Position = properties.Position or UDim2.fromOffset(0, 0)
	container.AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ZIndex = zIndex
	container.Parent = parent

	local button = Instance.new("TextButton")
	button.Name = properties.Name or "Button"
	button.Size = UDim2.fromScale(1, 1)
	button.BackgroundColor3 = properties.BackgroundColor3 or Theme.Colors.Primary
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = properties.Text or "Button"
	button.TextColor3 = properties.TextColor3 or Theme.Colors.White
	button.TextSize = properties.TextSize or Theme.TextSize.Body
	button.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Center
	button.TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center
	button.TextWrapped = properties.TextWrapped == true
	button.Font = properties.Font or Theme.Fonts.BodyBold
	button.Selectable = true
	button.ZIndex = zIndex + 1
	button.Parent = container
	addCorner(button, radius)

	local scale = Instance.new("UIScale")
	scale.Name = "InteractionScale"
	scale.Parent = container

	local baseColor = button.BackgroundColor3
	local hoverColor = properties.HoverColor or baseColor:Lerp(Theme.Colors.White, 0.13)

	button.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(Theme.Motion.Fast, Theme.Easing.Out), { Scale = 1.04 }):Play()
		TweenService:Create(button, TweenInfo.new(Theme.Motion.Fast, Theme.Easing.Out), { BackgroundColor3 = hoverColor }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(Theme.Motion.Fast, Theme.Easing.Out), { Scale = 1 }):Play()
		TweenService:Create(button, TweenInfo.new(Theme.Motion.Fast, Theme.Easing.Out), { BackgroundColor3 = baseColor }):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(Theme.Motion.Fast, Theme.Easing.Out), { Scale = 0.95 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(Theme.Motion.Fast, Theme.Easing.Out), { Scale = 1.04 }):Play()
	end)

	return button
end

function Components.ClearDynamicChildren(parent, predicate)
	for _, child in parent:GetChildren() do
		if predicate(child) then
			child:Destroy()
		end
	end
end

function Components.AnimatePanel(panel, isVisible)
	local shadowReference = panel:FindFirstChild("ShadowReference")
	local shadow = shadowReference and shadowReference.Value
	local scale = panel:FindFirstChild("PanelScale")
	if scale == nil then
		scale = Instance.new("UIScale")
		scale.Name = "PanelScale"
		scale.Parent = panel
	end

	if isVisible then
		if shadow then
			shadow.Visible = true
		end
		panel.Visible = true
		scale.Scale = 0.92
		TweenService:Create(scale, TweenInfo.new(Theme.Motion.Normal, Theme.Easing.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	else
		local tween = TweenService:Create(scale, TweenInfo.new(Theme.Motion.Fast, Theme.Easing.In), { Scale = 0.92 })
		tween:Play()
		tween.Completed:Once(function()
			panel.Visible = false
			if shadow then
				shadow.Visible = false
			end
		end)
	end
end

function Components.SetCardVisible(card, isVisible)
	card.Visible = isVisible
	local shadowReference = card:FindFirstChild("ShadowReference")
	if shadowReference and shadowReference.Value then
		shadowReference.Value.Visible = isVisible
	end
end

return Components
