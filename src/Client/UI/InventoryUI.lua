local InventoryUI = {}

function InventoryUI.new(playerGui)
	local existing = playerGui:FindFirstChild("FoodQuestInventory")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoodQuestInventory"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "InventoryButton"
	toggleButton.Size = UDim2.fromOffset(132, 44)
	toggleButton.Position = UDim2.new(0, 18, 0.5, -22)
	toggleButton.BackgroundColor3 = Color3.fromRGB(55, 86, 58)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "Inventory"
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.TextSize = 18
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Parent = screenGui

	local panel = Instance.new("Frame")
	panel.Name = "InventoryPanel"
	panel.Size = UDim2.fromOffset(300, 360)
	panel.Position = UDim2.new(0, 164, 0.5, -180)
	panel.BackgroundColor3 = Color3.fromRGB(35, 39, 45)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 48)
	title.Position = UDim2.fromOffset(16, 8)
	title.BackgroundTransparency = 1
	title.Text = "Ingredients"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.Parent = panel

	local list = Instance.new("Frame")
	list.Name = "IngredientList"
	list.Size = UDim2.new(1, -32, 1, -72)
	list.Position = UDim2.fromOffset(16, 64)
	list.BackgroundTransparency = 1
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = list

	toggleButton.Activated:Connect(function()
		panel.Visible = not panel.Visible
	end)

	local ui = {}

	function ui:SetIngredients(entries)
		for _, child in list:GetChildren() do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		if #entries == 0 then
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Size = UDim2.new(1, 0, 0, 30)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Text = "No ingredients yet."
			emptyLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			emptyLabel.TextSize = 16
			emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.Parent = list
			return
		end

		for _, entry in entries do
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, 32)
			row.BackgroundColor3 = Color3.fromRGB(52, 58, 65)
			row.BorderSizePixel = 0
			row.Text = entry.name .. " x" .. entry.amount
			row.TextColor3 = Color3.new(1, 1, 1)
			row.TextSize = 17
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.Font = Enum.Font.Gotham
			row.Parent = list
		end
	end

	return ui
end

return InventoryUI
