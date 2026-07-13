local CookingUI = {}

function CookingUI.new(playerGui, onRecipeSelected)
	local existing = playerGui:FindFirstChild("FoodQuestCooking")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoodQuestCooking"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "CookingPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Size = UDim2.fromOffset(360, 300)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(47, 42, 37)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 52)
	title.Position = UDim2.fromOffset(16, 8)
	title.BackgroundTransparency = 1
	title.Text = "Cooking Station"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.Parent = panel

	local recipeList = Instance.new("Frame")
	recipeList.Name = "RecipeList"
	recipeList.Size = UDim2.new(1, -32, 1, -76)
	recipeList.Position = UDim2.fromOffset(16, 60)
	recipeList.BackgroundTransparency = 1
	recipeList.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = recipeList

	local ui = {}

	function ui:SetRecipes(recipes)
		for _, child in recipeList:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, recipe in recipes do
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 54)
			button.BackgroundColor3 = Color3.fromRGB(100, 71, 46)
			button.BorderSizePixel = 0
			button.Text = recipe.name .. "\n" .. recipe.requirements
			button.TextColor3 = Color3.new(1, 1, 1)
			button.TextSize = 15
			button.TextWrapped = true
			button.Font = Enum.Font.Gotham
			button.Parent = recipeList
			button.Activated:Connect(function()
				panel.Visible = false
				onRecipeSelected(recipe.id)
			end)
		end
	end

	function ui:Show()
		panel.Visible = true
	end

	return ui
end

return CookingUI
