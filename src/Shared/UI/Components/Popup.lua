local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Animations = require(script.Parent.Parent:WaitForChild("Animations"))
local Panel = require(script.Parent:WaitForChild("Panel"))
local Button = require(script.Parent:WaitForChild("Button"))

local Popup = {}

function Popup.Create(parent, title, message)
	local selfObj = {}

	local overlay = Instance.new("Frame")
	overlay.Name = "PopupOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Position = UDim2.fromScale(0, 0)
	overlay.BackgroundColor3 = Theme.Colors.Overlay
	overlay.BackgroundTransparency = 0.6
	overlay.Active = true
	overlay.Parent = parent

	local panel = Panel.Create(overlay, UDim2.new(0, 420, 0, 220))
	panel.Name = "PopupPanel"
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Visible = false

	local content = panel:FindFirstChild("Content") or panel

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 36)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.Fonts.Title
	titleLabel.TextSize = Theme.TextSize.Title
	titleLabel.Text = title or ""
	titleLabel.TextColor3 = Theme.Colors.Text
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = content

	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Size = UDim2.new(1, 0, 1, -96)
	messageLabel.Position = UDim2.new(0, 0, 0, 44)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Font = Theme.Fonts.Body
	messageLabel.TextSize = Theme.TextSize.Large
	messageLabel.Text = message or ""
	messageLabel.TextColor3 = Theme.Colors.TextSecondary
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextYAlignment = Enum.TextYAlignment.Top
	messageLabel.TextWrapped = true
	messageLabel.Parent = content

	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "ButtonRow"
	buttonRow.Size = UDim2.new(1, 0, 0, 44)
	buttonRow.Position = UDim2.new(0, 0, 1, -44)
	buttonRow.BackgroundTransparency = 1
	buttonRow.Parent = content

	local cancelBtn = Button.Create(buttonRow, "Cancel", "Secondary")
	cancelBtn.Name = "CancelBtn"
	cancelBtn.Size = UDim2.new(0.5, -6, 1, 0)
	cancelBtn.Position = UDim2.new(0, 0, 0, 0)

	local confirmBtn = Button.Create(buttonRow, "Confirm", "Primary")
	confirmBtn.Name = "ConfirmBtn"
	confirmBtn.Size = UDim2.new(0.5, -6, 1, 0)
	confirmBtn.Position = UDim2.new(0.5, 6, 0, 0)

	local confirmConnection = nil

	cancelBtn.Activated:Connect(function()
		selfObj.Close()
	end)

	function selfObj.Open()
		overlay.Visible = true
		Panel.Open(panel)
	end

	function selfObj.Close()
		Panel.Close(panel)
		local closeTween = Animations.Tween(overlay, {
			BackgroundTransparency = 1
		}, Theme.Animation.Fast, Theme.Animation.EasingIn)
		if closeTween then
			closeTween.Completed:Once(function()
				overlay.Visible = false
				overlay.BackgroundTransparency = 0.6
			end)
		end
	end

	function selfObj.SetCallback(callback)
		if confirmConnection then
			confirmConnection:Disconnect()
			confirmConnection = nil
		end
		if callback then
			confirmConnection = confirmBtn.Activated:Connect(callback)
		end
	end

	return selfObj
end

return Popup
