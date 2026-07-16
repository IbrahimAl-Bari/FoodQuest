local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.UI.Theme)
local Slot = require(ReplicatedStorage.UI.Components.Slot)
local Tooltip = require(ReplicatedStorage.UI.Components.Tooltip)
local UIManager = require(ReplicatedStorage.UI.Components.UIManager)

local InventoryUI = {}

function InventoryUI.new(playerGui)
	local mainUI = playerGui:WaitForChild("MainUI")
	if not mainUI then
		warn("InventoryUI: MainUI not found in PlayerGui")
		return { SetIngredients = function() end }
	end

	local invUI = mainUI:FindFirstChild("InventoryUI")
	if not invUI then
		warn("InventoryUI: InventoryUI frame not found in MainUI")
		return { SetIngredients = function() end }
	end

	local panel = invUI:FindFirstChild("InventoryPanel")
	local closeBtn = panel and panel:FindFirstChild("CloseBtn")
	local ingredientList = panel and panel:FindFirstChild("IngredientList")

	for _, layout in pairs(ingredientList and ingredientList:GetChildren() or {}) do
		if layout:IsA("UIListLayout") or layout:IsA("UIGridLayout") then
			layout:Destroy()
		end
	end

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 88, 0, 108)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = ingredientList

	UIManager.Register("Inventory", invUI)

	if closeBtn then
		closeBtn.Activated:Connect(function()
			UIManager.Close("Inventory")
		end)
	end

	local function positionTooltip(tooltip, slot, mouseX, mouseY)
		local absPos = slot.AbsolutePosition
		local screenX = absPos.X + (mouseX or 0) + 16
		local screenY = absPos.Y + (mouseY or 0) + 16

		tooltip.Position = UDim2.fromOffset(screenX, screenY)
	end

	local ui = {}

	function ui:Show()
		if invUI then
			invUI.Visible = true
		end
	end

	function ui:SetIngredients(entries)
		if not ingredientList then
			return
		end

		for _, child in pairs(ingredientList:GetChildren()) do
			if not child:IsA("UIGridLayout") then
				child:Destroy()
			end
		end

		if #entries == 0 then
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Name = "EmptyState"
			emptyLabel.Size = UDim2.new(1, -20, 0, 40)
			emptyLabel.Position = UDim2.new(0, 10, 0, 30)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Font = Theme.Fonts.Body
			emptyLabel.TextSize = Theme.TextSize.Normal
			emptyLabel.Text = "Complete an obby to stock your pantry."
			emptyLabel.TextColor3 = Theme.Colors.TextSecondary
			emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
			emptyLabel.Parent = ingredientList
			return
		end

		for _, entry in ipairs(entries) do
			local slot = Slot.Create(ingredientList, string.sub(entry.name, 1, 1))
			slot.Name = "IngredientSlot"
			Slot.SetAmount(slot, entry.amount)

			local tooltip = Tooltip.Create(invUI, entry.name)
			tooltip.ZIndex = 50

			local moveConnection = nil

			slot.MouseEnter:Connect(function()
				Tooltip.SetText(tooltip, entry.name)
				positionTooltip(tooltip, slot)
				Tooltip.Show(tooltip)

				moveConnection = slot.MouseMoved:Connect(function(x, y)
					positionTooltip(tooltip, slot, x, y)
				end)
			end)

			slot.MouseLeave:Connect(function()
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

return InventoryUI
