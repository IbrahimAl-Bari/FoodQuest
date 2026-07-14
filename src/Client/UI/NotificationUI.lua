local TweenService = game:GetService("TweenService")

local Components = require(script.Parent:WaitForChild("Components"))
local Theme = require(script.Parent:WaitForChild("Theme"))

local NotificationUI = {}

local notificationStyles = {
	primary = { color = Theme.Colors.Primary, icon = "!" },
	success = { color = Theme.Colors.Success, icon = "+" },
	warning = { color = Theme.Colors.Coins, icon = "!" },
	danger = { color = Theme.Colors.Danger, icon = "×" },
}

function NotificationUI.new(playerGui)
	local screenGui = Components.CreateScreenGui(playerGui, "FoodQuestNotifications")

	local holder = Instance.new("CanvasGroup")
	holder.Name = "NotificationHolder"
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.Size = UDim2.fromOffset(480, 78)
	holder.Position = UDim2.new(0.5, 0, 0, -100)
	holder.GroupTransparency = 1
	holder.Parent = screenGui

	local card = Components.CreateCard(holder, {
		Name = "NotificationCard",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Colors.Panel,
		ZIndex = 20,
	})
	Components.CreateIconBadge(card, {
		Name = "StatusIcon",
		Size = UDim2.fromOffset(42, 42),
		Position = UDim2.fromOffset(16, 18),
		BackgroundColor3 = Theme.Colors.Primary,
		Text = "!",
		TextColor3 = Theme.Colors.White,
		ZIndex = 22,
	})
	local messageLabel = Components.CreateLabel(card, {
		Name = "Message",
		Size = UDim2.new(1, -92, 1, -18),
		Position = UDim2.fromOffset(74, 9),
		TextColor3 = Theme.Colors.PrimaryText,
		TextSize = Theme.TextSize.Body,
		TextWrapped = true,
		Font = Theme.Fonts.BodyBold,
		ZIndex = 22,
	})

	local ui = {}
	local messageVersion = 0

	function ui:Show(message, duration, kind)
		messageVersion += 1
		local thisVersion = messageVersion
		local style = notificationStyles[kind] or notificationStyles.primary
		messageLabel.Text = message

		local statusIcon = card:FindFirstChild("StatusIcon")
		statusIcon.BackgroundColor3 = style.color
		statusIcon.Icon.Text = style.icon
		holder.GroupTransparency = 0
		holder.Position = UDim2.new(0.5, 0, 0, -100)
		TweenService:Create(holder, TweenInfo.new(Theme.Motion.Slow, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 0, 24),
		}):Play()

		task.delay(duration or 4, function()
			if messageVersion == thisVersion then
				local fade = TweenService:Create(holder, TweenInfo.new(Theme.Motion.Normal), {
					Position = UDim2.new(0.5, 0, 0, -100),
					GroupTransparency = 1,
				})
				fade:Play()
			end
		end)
	end

	return ui
end

return NotificationUI
