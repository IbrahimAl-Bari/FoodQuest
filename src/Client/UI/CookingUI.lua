local TweenService = game:GetService("TweenService")

local Components = require(script.Parent:WaitForChild("Components"))
local Theme = require(script.Parent:WaitForChild("Theme"))

local CookingUI = {}

function CookingUI.new(playerGui, onRecipeSelected)
	local screenGui = Components.CreateScreenGui(playerGui, "FoodQuestCooking")

	local overlay = Instance.new("TextButton")
	overlay.Name = "CookingOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Theme.Colors.Overlay
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Visible = false
	overlay.ZIndex = 10
	overlay.Parent = screenGui

	local panel = Components.CreateCard(overlay, {
		Name = "CookingPanel",
		Size = UDim2.fromOffset(480, 430),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Colors.Panel,
		ZIndex = 12,
	})
	Components.SetCardVisible(panel, false)

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(320, 310)
	sizeConstraint.MaxSize = Vector2.new(560, 520)
	sizeConstraint.Parent = panel

	Components.CreateIconBadge(panel, {
		Size = UDim2.fromOffset(46, 46),
		Position = UDim2.fromOffset(22, 20),
		BackgroundColor3 = Theme.Colors.Primary,
		Text = "~",
		TextColor3 = Theme.Colors.White,
		TextSize = Theme.TextSize.Section,
		ZIndex = 14,
	})
	Components.CreateLabel(panel, {
		Text = "Cooking Station",
		Size = UDim2.new(1, -128, 0, 32),
		Position = UDim2.fromOffset(80, 17),
		TextSize = Theme.TextSize.Title,
		Font = Theme.Fonts.Heading,
		ZIndex = 14,
	})
	Components.CreateLabel(panel, {
		Text = "Choose a recipe to place on your display counter",
		Size = UDim2.new(1, -112, 0, 22),
		Position = UDim2.fromOffset(80, 47),
		TextColor3 = Theme.Colors.SecondaryText,
		TextSize = Theme.TextSize.Helper,
		ZIndex = 14,
	})

	local closeButton = Components.CreateButton(panel, {
		Name = "CloseButton",
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.new(1, -58, 0, 20),
		Text = "×",
		TextSize = Theme.TextSize.Section,
		BackgroundColor3 = Theme.Colors.SecondaryPanel,
		TextColor3 = Theme.Colors.PrimaryText,
		ZIndex = 15,
	})

	local recipeList = Instance.new("ScrollingFrame")
	recipeList.Name = "RecipeList"
	recipeList.Size = UDim2.new(1, -44, 1, -114)
	recipeList.Position = UDim2.fromOffset(22, 88)
	recipeList.BackgroundTransparency = 1
	recipeList.BorderSizePixel = 0
	recipeList.CanvasSize = UDim2.fromOffset(0, 0)
	recipeList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	recipeList.ScrollBarThickness = 4
	recipeList.ScrollBarImageColor3 = Theme.Colors.Disabled
	recipeList.ZIndex = 14
	recipeList.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, Theme.Spacing.Small)
	layout.Parent = recipeList

	local function hide()
		Components.AnimatePanel(panel, false)
		TweenService:Create(overlay, TweenInfo.new(Theme.Motion.Fast), { BackgroundTransparency = 1 }):Play()
		task.delay(Theme.Motion.Fast, function()
			if not panel.Visible then
				overlay.Visible = false
			end
		end)
	end

	overlay.Activated:Connect(function()
		hide()
	end)
	closeButton.Activated:Connect(hide)

	local ui = {}

	function ui:SetRecipes(recipes)
		Components.ClearDynamicChildren(recipeList, function(child)
			return child:IsA("TextButton")
		end)

		for index, recipe in recipes do
			local accent = index % 2 == 0 and Theme.Colors.Success or Theme.Colors.Primary
			local button = Components.CreateButton(recipeList, {
				Name = "RecipeButton",
				Size = UDim2.new(1, -6, 0, 74),
				Text = "     " .. recipe.name .. "\n     " .. recipe.requirements,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				BackgroundColor3 = Theme.Colors.SecondaryPanel,
				TextColor3 = Theme.Colors.PrimaryText,
				ZIndex = 15,
			})
			Components.CreateIconBadge(button, {
				Size = UDim2.fromOffset(42, 42),
				Position = UDim2.fromOffset(12, 16),
				BackgroundColor3 = accent,
				Text = string.sub(recipe.name, 1, 1),
				TextColor3 = Theme.Colors.White,
				ZIndex = 16,
			})
			button.Activated:Connect(function()
				hide()
				onRecipeSelected(recipe.id)
			end)
		end
	end

	function ui:Show()
		overlay.Visible = true
		TweenService:Create(overlay, TweenInfo.new(Theme.Motion.Normal), { BackgroundTransparency = 0.45 }):Play()
		Components.AnimatePanel(panel, true)
	end

	return ui
end

return CookingUI
