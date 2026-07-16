local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))

local Notification = {}

local NOTIF_WIDTH = 380
local NOTIF_HEIGHT = 64
local DEFAULT_DURATION = 3

local TYPE_COLORS = {
	Success = Theme.Colors.Success,
	Reward = Theme.Colors.Reward,
	Warning = Theme.Colors.Secondary,
	Error = Theme.Colors.Danger,
}

local TYPE_TEXT_COLORS = {
	Success = Theme.Colors.TextLight,
	Reward = Theme.Colors.Dark,
	Warning = Theme.Colors.Dark,
	Error = Theme.Colors.TextLight,
}

local TYPE_ICONS = {
	Success = "✓",
	Reward = "★",
	Warning = "!",
	Error = "✕",
}

local container = nil
local screenGui = nil

local function ensureContainer()
	if container and container.Parent then
		return container
	end

	local player = Players.LocalPlayer
	if not player then
		return
	end

	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoodQuestNotifications"
	screenGui.DisplayOrder = 100
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	container = Instance.new("Frame")
	container.Name = "NotificationContainer"
	container.Size = UDim2.new(0, NOTIF_WIDTH, 0, 0)
	container.Position = UDim2.new(0.5, 0, 0, 16)
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.BackgroundTransparency = 1
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = screenGui

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 8)
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = container

	return container
end

local function dismiss(frame)
	if not frame or not frame.Parent then
		return
	end

	local outY = frame.Position.Y.Offset - NOTIF_HEIGHT - 8
	local tween = Animations.Tween(frame, {
		Position = UDim2.new(0.5, 0, 0, outY),
		GroupTransparency = 1
	}, Theme.Animation.Fast, Theme.Animation.EasingIn)

	if tween then
		tween.Completed:Once(function()
			frame:Destroy()
		end)
	else
		frame:Destroy()
	end
end

function Notification.Show(message, notificationType, duration)
	notificationType = notificationType or "Success"
	duration = duration or DEFAULT_DURATION

	local cont = ensureContainer()
	if not cont then
		return
	end

	local bgColor = TYPE_COLORS[notificationType] or Theme.Colors.Success
	local textColor = TYPE_TEXT_COLORS[notificationType] or Theme.Colors.TextLight
	local icon = TYPE_ICONS[notificationType] or "✓"

	local frame = Instance.new("Frame")
	frame.Name = "Notification"
	frame.Size = UDim2.new(1, -16, 0, NOTIF_HEIGHT)
	frame.BackgroundColor3 = bgColor
	frame.BorderSize = 0
	frame.ClipsDescendants = true
	frame.Parent = cont

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.Radius.Medium
	corner.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = frame

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.new(0, 32, 0, 32)
	iconLabel.Position = UDim2.new(0, 0, 0.5, -16)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 22
	iconLabel.Text = icon
	iconLabel.TextColor3 = textColor
	iconLabel.Parent = frame

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Message"
	textLabel.Size = UDim2.new(1, -44, 1, 0)
	textLabel.Position = UDim2.new(0, 40, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Theme.Fonts.Body
	textLabel.TextSize = Theme.TextSize.Normal
	textLabel.Text = message
	textLabel.TextColor3 = textColor
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = frame

	task.wait(0)

	local finalPos = frame.Position
	frame.Position = UDim2.new(finalPos.X.Scale, finalPos.X.Offset, finalPos.Y.Scale, finalPos.Y.Offset - NOTIF_HEIGHT - 8)

	Animations.Tween(frame, {
		Position = finalPos
	}, Theme.Animation.Normal, Theme.Animation.EasingOut)

	Animations.Pop(frame)

	task.delay(duration, function()
		dismiss(frame)
	end)
end

return Notification
