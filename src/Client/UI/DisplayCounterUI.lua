local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.UI.Theme)
local Slot = require(ReplicatedStorage.UI.Components.Slot)
local Tooltip = require(ReplicatedStorage.UI.Components.Tooltip)
local UIManager = require(ReplicatedStorage.UI.Components.UIManager)

local DisplayCounterUI = {}

function DisplayCounterUI.new(playerGui)
	local mainUI = playerGui:WaitForChild("MainUI")
	if not mainUI then
		warn("DisplayCounterUI: MainUI not found in PlayerGui")
		return { SetCounter = function() end }
	end

	local dcUI = mainUI:FindFirstChild("DisplayCounterUI")
	if not dcUI then
		warn("DisplayCounterUI: DisplayCounterUI frame not found in MainUI")
		return { SetCounter = function() end }
	end

	local panel = dcUI:FindFirstChild("DisplayCounterPanel")
	local closeBtn = panel and panel:FindFirstChild("CloseBtn")
	local slotList = panel and panel:FindFirstChild("SlotList")
	local helperLabel = panel and (panel:FindFirstChild("CounterHelper") or panel:FindFirstChild("Helper"))

	for _, layout in pairs(slotList and slotList:GetChildren() or {}) do
		if layout:IsA("UIListLayout") or layout:IsA("UIGridLayout") then
			layout:Destroy()
		end
	end

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 88, 0, 108)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = slotList

	if slotList then
		slotList.AutomaticCanvasSize = Enum.AutomaticSize.Y
		slotList.ScrollBarThickness = 4
		slotList.ScrollBarImageColor3 = Theme.Colors.Disabled
	end

	UIManager.Register("DisplayCounter", dcUI)

	if closeBtn then
		closeBtn.Activated:Connect(function()
			UIManager.Close("DisplayCounter")
		end)
	end

	local function positionTooltip(tooltip, slotObj, mouseX, mouseY)
		local absPos = slotObj.AbsolutePosition
		local screenX = absPos.X + (mouseX or 0) + 16
		local screenY = absPos.Y + (mouseY or 0) + 16
		tooltip.Position = UDim2.fromOffset(screenX, screenY)
	end

	local ui = {}

	function ui:SetCounter(counter)
		if not slotList then
			return
		end

		for _, child in pairs(slotList:GetChildren()) do
			if not child:IsA("UIGridLayout") then
				child:Destroy()
			end
		end

		if helperLabel then
			helperLabel.Text = (counter.filledSlots or 0) .. " of " .. (counter.slotCount or 0) .. " spots stocked"
		end

		if not counter.filledSlots or counter.filledSlots == 0 then
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Name = "EmptyState"
			emptyLabel.Size = UDim2.new(1, -20, 0, 40)
			emptyLabel.Position = UDim2.new(0, 10, 0, 20)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Font = Theme.Fonts.Body
			emptyLabel.TextSize = Theme.TextSize.Normal
			emptyLabel.Text = "Cook food to stock your display counter."
			emptyLabel.TextColor3 = Theme.Colors.TextSecondary
			emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
			emptyLabel.Parent = slotList
			return
		end

		for slotIndex = 1, counter.slotCount do
			local foodId = counter.slots and counter.slots[slotIndex]
			local foodName = foodId and counter.foodNames and counter.foodNames[slotIndex] or foodId
			local hasFood = foodId ~= false and foodId ~= nil

			local icon = hasFood and string.sub(foodName or "?", 1, 1) or "+"
			local slotObj = Slot.Create(slotList, icon)
			slotObj.Name = "Slot" .. slotIndex

			if not hasFood then
				local card = slotObj:FindFirstChild("Card")
				if card then
					card.BackgroundColor3 = Theme.Colors.SecondaryPanel
				end
			end

			local tooltip = Tooltip.Create(dcUI, "")
			tooltip.ZIndex = 50

			local moveConnection = nil

			slotObj.MouseEnter:Connect(function()
				local text = hasFood and (foodName or "Food") or "Empty spot"
				Tooltip.SetText(tooltip, text)
				positionTooltip(tooltip, slotObj)
				Tooltip.Show(tooltip)

				moveConnection = slotObj.MouseMoved:Connect(function(x, y)
					positionTooltip(tooltip, slotObj, x, y)
				end)
			end)

			slotObj.MouseLeave:Connect(function()
				Tooltip.Hide(tooltip)
				if moveConnection then
					moveConnection:Disconnect()
					moveConnection = nil
				end
			end)
		end
	end

	return ui
end

return DisplayCounterUI
