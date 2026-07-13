local NotificationUI = {}

function NotificationUI.new(playerGui)
	local existing = playerGui:FindFirstChild("FoodQuestNotifications")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoodQuestNotifications"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local banner = Instance.new("TextLabel")
	banner.Name = "NotificationBanner"
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Size = UDim2.fromOffset(460, 58)
	banner.Position = UDim2.new(0.5, 0, 0, 28)
	banner.BackgroundColor3 = Color3.fromRGB(45, 73, 49)
	banner.BorderSizePixel = 0
	banner.TextColor3 = Color3.new(1, 1, 1)
	banner.TextSize = 18
	banner.TextWrapped = true
	banner.Font = Enum.Font.GothamBold
	banner.Visible = false
	banner.Parent = screenGui

	local ui = {}
	local messageVersion = 0

	function ui:Show(message, duration)
		messageVersion += 1
		local thisVersion = messageVersion
		banner.Text = message
		banner.Visible = true

		task.delay(duration or 4, function()
			if messageVersion == thisVersion then
				banner.Visible = false
			end
		end)
	end

	return ui
end

return NotificationUI
