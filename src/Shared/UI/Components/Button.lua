local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))

local Button = {}

function Button.Create(parent, text, styleName, callback)
	styleName = styleName or "Primary"
	local style = Theme.GetButtonStyle(styleName)
	if not style then
		style = Theme.GetButtonStyle("Primary")
	end

	local isGhost = styleName == "Ghost"

	local button = Instance.new("TextButton")
	button.Name = "Button_" .. styleName
	button.Text = text or ""
	button.Font = Theme.Fonts.Header
	button.TextSize = Theme.TextSize.Normal
	button.BorderSize = 0
	button.AutoButtonColor = false
	button.Parent = parent

	if isGhost then
		button.BackgroundTransparency = 1
	else
		button.BackgroundColor3 = style.Background
	end
	button.TextColor3 = style.Text

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Radius.Medium
	corner.Parent = button

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, Theme.Spacing.Large)
	padding.PaddingRight = UDim.new(0, Theme.Spacing.Large)
	padding.PaddingTop = UDim.new(0, Theme.Spacing.Small)
	padding.PaddingBottom = UDim.new(0, Theme.Spacing.Small)
	padding.Parent = button

	if styleName ~= "Disabled" then
		button.MouseEnter:Connect(function()
			Animations.ButtonHover(button)
			if isGhost then
				Animations.Tween(button, { BackgroundTransparency = style.HoverTransparency }, Theme.Animation.Fast, Theme.Animation.EasingOut)
			else
				Animations.Tween(button, { BackgroundColor3 = style.Hover }, Theme.Animation.Fast, Theme.Animation.EasingOut)
			end
		end)

		button.MouseLeave:Connect(function()
			Animations.ButtonLeave(button)
			if isGhost then
				Animations.Tween(button, { BackgroundTransparency = 1 }, Theme.Animation.Fast, Theme.Animation.EasingOut)
			else
				Animations.Tween(button, { BackgroundColor3 = style.Background }, Theme.Animation.Fast, Theme.Animation.EasingOut)
			end
		end)

		button.MouseButton1Click:Connect(function()
			Animations.ButtonPressed(button)
		end)

		if callback then
			button.Activated:Connect(callback)
		end
	end

	return button
end

function Button.SetText(button, text)
	if button then
		button.Text = text
	end
end

function Button.SetEnabled(button, enabled)
	if not button then
		return
	end

	local styleName = "Disabled"
	if enabled then
		local currentBg = button.BackgroundColor3
		if currentBg == Theme.Colors.Primary then
			styleName = "Primary"
		elseif currentBg == Theme.Colors.Secondary then
			styleName = "Secondary"
		elseif currentBg == Theme.Colors.Reward then
			styleName = "Reward"
		elseif currentBg == Theme.Colors.Danger then
			styleName = "Danger"
		else
			styleName = "Primary"
		end
	end

	local style = Theme.GetButtonStyle(styleName)
	if not style then
		return
	end

	button.Active = enabled
	button.AutoButtonColor = false

	if enabled then
		button.BackgroundColor3 = style.Background
		button.BackgroundTransparency = 0
	else
		button.BackgroundColor3 = style.Background
		button.BackgroundTransparency = 0.5
	end

	button.TextColor3 = style.Text
end

return Button
