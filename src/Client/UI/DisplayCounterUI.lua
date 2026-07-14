local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(script.Parent:WaitForChild("Components"))
local Theme = require(script.Parent:WaitForChild("Theme"))
local IconRegistry = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("IconRegistry"))

local DisplayCounterUI = {}

function DisplayCounterUI.new(playerGui)
	local screenGui = Components.CreateScreenGui(playerGui, "FoodQuestDisplayCounter")

	local toggleButton = Components.CreateButton(screenGui, {
		Name = "DisplayCounterButton",
		Size = UDim2.fromOffset(150, 50),
		Position = UDim2.new(1, -168, 0.5, -25),
		Text = "  Counter",
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Theme.Colors.Primary,
		TextSize = Theme.TextSize.Body,
	})
	Components.CreateIconBadge(toggleButton, {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.fromOffset(10, 11),
		BackgroundColor3 = Theme.Colors.Panel,
		Text = "#",
		TextSize = Theme.TextSize.Helper,
		TextColor3 = Theme.Colors.PrimaryText,
		ZIndex = 4,
	})

	local panel = Components.CreateCard(screenGui, {
		Name = "DisplayCounterPanel",
		Size = UDim2.fromOffset(340, 360),
		Position = UDim2.new(0.5, -170, 0.5, -180),
		BackgroundColor3 = Theme.Colors.Panel,
		ZIndex = 5,
	})
	Components.SetCardVisible(panel, false)

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(280, 260)
	sizeConstraint.MaxSize = Vector2.new(420, 480)
	sizeConstraint.Parent = panel

	local headerBadge = Components.CreateIconBadge(panel, {
		Size = UDim2.fromOffset(42, 42),
		Position = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Theme.Colors.Primary,
		Text = "#",
		TextColor3 = Theme.Colors.White,
		ZIndex = 7,
	})
	Components.CreateLabel(panel, {
		Text = "Display Counter",
		Size = UDim2.new(1, -120, 0, 30),
		Position = UDim2.fromOffset(74, 18),
		TextSize = Theme.TextSize.Title,
		Font = Theme.Fonts.Heading,
		ZIndex = 7,
	})
	local helperLabel = Components.CreateLabel(panel, {
		Name = "Helper",
		Size = UDim2.new(1, -110, 0, 22),
		Position = UDim2.fromOffset(74, 48),
		TextColor3 = Theme.Colors.SecondaryText,
		TextSize = Theme.TextSize.Helper,
		ZIndex = 7,
	})

	local closeButton = Components.CreateButton(panel, {
		Name = "CloseButton",
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.new(1, -54, 0, 18),
		Text = "×",
		TextSize = Theme.TextSize.Section,
		BackgroundColor3 = Theme.Colors.SecondaryPanel,
		TextColor3 = Theme.Colors.PrimaryText,
		ZIndex = 8,
	})

	local slotList = Instance.new("ScrollingFrame")
	slotList.Name = "SlotList"
	slotList.Size = UDim2.new(1, -40, 1, -114)
	slotList.Position = UDim2.fromOffset(20, 92)
	slotList.BackgroundTransparency = 1
	slotList.BorderSizePixel = 0
	slotList.CanvasSize = UDim2.fromOffset(0, 0)
	slotList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	slotList.ScrollBarThickness = 4
	slotList.ScrollBarImageColor3 = Theme.Colors.Disabled
	slotList.ZIndex = 7
	slotList.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, Theme.Spacing.Small)
	layout.Parent = slotList

	local function setVisible(isVisible)
		Components.AnimatePanel(panel, isVisible)
	end

	toggleButton.Activated:Connect(function()
		setVisible(not panel.Visible)
	end)
	closeButton.Activated:Connect(function()
		setVisible(false)
	end)

	local ui = {}

	function ui:SetCounter(counter)
		Components.ClearDynamicChildren(slotList, function(child)
			return child:IsA("Frame")
		end)

		helperLabel.Text = (counter.filledSlots or 0) .. " of " .. (counter.slotCount or 0) .. " spots stocked"

		if counter.filledSlots == 0 or counter.filledSlots == nil then
			local emptyCard = Components.CreateCard(slotList, {
				Name = "EmptyState",
				Size = UDim2.new(1, -6, 0, 94),
				BackgroundColor3 = Theme.Colors.Background,
				NoShadow = true,
			})
			Components.CreateIconBadge(emptyCard, {
				Size = UDim2.fromOffset(38, 38),
				Position = UDim2.new(0.5, -19, 0, 14),
				BackgroundColor3 = Theme.Colors.SecondaryPanel,
				Text = "+",
				TextColor3 = Theme.Colors.SecondaryText,
			})
			Components.CreateLabel(emptyCard, {
				Size = UDim2.new(1, -20, 0, 24),
				Position = UDim2.new(0, 10, 1, -34),
				Text = "Cook food to stock your display counter.",
				TextColor3 = Theme.Colors.SecondaryText,
				TextSize = Theme.TextSize.Helper,
				TextXAlignment = Enum.TextXAlignment.Center,
			})
			return
		end

		for slotIndex = 1, counter.slotCount do
			local foodId = counter.slots and counter.slots[slotIndex]
			local foodName = foodId and counter.foodNames and counter.foodNames[slotIndex] or foodId
			local hasFood = foodId ~= false and foodId ~= nil

			local slot = Components.CreateCard(slotList, {
				Name = "Slot" .. slotIndex,
				Size = UDim2.new(1, -6, 0, 62),
				BackgroundColor3 = hasFood and Theme.Colors.Success or Theme.Colors.Background,
				Radius = Theme.Radius.Medium,
				NoShadow = true,
			})

			local iconAssetId = hasFood and IconRegistry.GetIcon(foodId) or nil
			local badgeColor = hasFood and Theme.Colors.Success or Theme.Colors.Disabled
			local badgeText = hasFood and (iconAssetId and nil or string.sub(foodName or "?", 1, 1)) or "+"

			Components.CreateIconBadge(slot, {
				Size = UDim2.fromOffset(42, 42),
				Position = UDim2.fromOffset(10, 10),
				BackgroundColor3 = badgeColor,
				Image = iconAssetId,
				Text = badgeText,
				TextColor3 = Theme.Colors.White,
			})

			Components.CreateLabel(slot, {
				Size = UDim2.new(1, -70, 0, 24),
				Position = UDim2.fromOffset(64, 10),
				Text = hasFood and (foodName or "Food") or "Empty spot",
				TextColor3 = hasFood and Theme.Colors.PrimaryText or Theme.Colors.Disabled,
				Font = hasFood and Theme.Fonts.BodyBold or Theme.Fonts.Body,
			})
			Components.CreateLabel(slot, {
				Size = UDim2.new(1, -70, 0, 18),
				Position = UDim2.fromOffset(64, 33),
				Text = hasFood and "Ready to serve" or "Cook something to place here",
				TextColor3 = Theme.Colors.SecondaryText,
				TextSize = Theme.TextSize.Helper,
			})
		end
	end

	return ui
end

return DisplayCounterUI
