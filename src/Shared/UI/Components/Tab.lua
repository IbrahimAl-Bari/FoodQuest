local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))

local Tab = {}

function Tab.Create(parent, text)
	local tab = Instance.new("TextButton")
	tab.Name = "Tab_" .. (text or "")
	tab.Text = text or ""
	tab.Font = Theme.Fonts.Header
	tab.TextSize = Theme.TextSize.Normal
	tab.BorderSize = 0
	tab.AutoButtonColor = false
	tab.Size = UDim2.new(0, 120, 1, 0)
	tab.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Radius.Medium
	corner.Parent = tab

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, Theme.Spacing.Medium)
	padding.PaddingRight = UDim.new(0, Theme.Spacing.Medium)
	padding.PaddingTop = UDim.new(0, Theme.Spacing.Small)
	padding.PaddingBottom = UDim.new(0, Theme.Spacing.Small)
	padding.Parent = tab

	tab:SetAttribute("Active", false)
	Tab.SetActive(tab, false)

	tab.MouseEnter:Connect(function()
		if not tab:GetAttribute("Active") then
			Animations.Tween(tab, {
				BackgroundColor3 = Theme.Colors.SecondaryPanel
			}, Theme.Animation.Fast, Theme.Animation.EasingOut)
		end
	end)

	tab.MouseLeave:Connect(function()
		if not tab:GetAttribute("Active") then
			Animations.Tween(tab, {
				BackgroundColor3 = Theme.Colors.Background
			}, Theme.Animation.Fast, Theme.Animation.EasingOut)
		end
	end)

	tab.MouseButton1Click:Connect(function()
		Animations.ButtonPressed(tab)
	end)

	return tab
end

function Tab.SetActive(tab, active)
	if not tab then
		return
	end

	tab:SetAttribute("Active", active)

	if active then
		tab.BackgroundColor3 = Theme.Colors.Primary
		tab.TextColor3 = Theme.Colors.TextLight
	else
		tab.BackgroundColor3 = Theme.Colors.Background
		tab.TextColor3 = Theme.Colors.Text
	end
end

function Tab.OnClick(tab, callback)
	if tab and callback then
		tab.Activated:Connect(callback)
	end
end

return Tab
