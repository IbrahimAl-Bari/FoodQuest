local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.UI.Theme)
local Animations = require(ReplicatedStorage.UI.Animations)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local Button = require(ReplicatedStorage.UI.Components.Button)
local Slot = require(ReplicatedStorage.UI.Components.Slot)
local ProgressBar = require(ReplicatedStorage.UI.Components.ProgressBar)
local Notification = require(ReplicatedStorage.UI.Components.Notification)
local UIManager = require(ReplicatedStorage.UI.Components.UIManager)

local CookingUI = {}

function CookingUI.new(playerGui, onRecipeSelected)
	local mainUI = playerGui:WaitForChild("MainUI")
	if not mainUI then
		warn("CookingUI: MainUI not found in PlayerGui")
		return { SetRecipes = function() end, Show = function() end }
	end

	local cookingUI = mainUI:FindFirstChild("CookingUI")
	if not cookingUI then
		warn("CookingUI: CookingUI frame not found in MainUI")
		return { SetRecipes = function() end, Show = function() end }
	end

	local overlay = cookingUI:FindFirstChild("CookingOverlay")
	local panel = cookingUI:FindFirstChild("CookingPanel")
	local recipeList = panel and panel:FindFirstChild("RecipeList")
	local closeBtn = panel and panel:FindFirstChild("CloseBtn")

	UIManager.Register("Cooking", panel or cookingUI)

	local function hide()
		if panel then
			Panel.Close(panel)
		end
		if overlay then
			local tween = Animations.Tween(overlay, {
				BackgroundTransparency = 1
			}, Theme.Animation.Fast, Theme.Animation.EasingIn)
			if tween then
				tween.Completed:Once(function()
					cookingUI.Visible = false
				end)
			else
				cookingUI.Visible = false
			end
		else
			cookingUI.Visible = false
		end
	end

	if closeBtn then
		closeBtn.Activated:Connect(hide)
	end
	if overlay then
		overlay.Activated:Connect(hide)
	end

	local ui = {}
	function ui:SetRecipes(recipes)
		if not recipeList then
			return
		end

		for _, child in pairs(recipeList:GetChildren()) do
			if child:IsA("TextButton") or child.Name == "RecipeRow" then
				child:Destroy()
			end
		end

		for _, recipe in ipairs(recipes) do
			local row = Instance.new("TextButton")
			row.Name = "RecipeRow"
			row.Size = UDim2.new(1, -6, 0, 76)
			row.BackgroundTransparency = 1
			row.Text = ""
			row.AutoButtonColor = false
			row.ZIndex = 15
			row.Parent = recipeListf

			local slot = Slot.Create(row, string.sub(recipe.name, 1, 1))
			slot.Name = "RecipeIcon"
			slot.Size = UDim2.new(0, 56, 0, 56)
			slot.Position = UDim2.new(0, 10, 0.5, -28)
			slot.ZIndex = 16

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Name = "RecipeName"
			nameLabel.Size = UDim2.new(1, -80, 0, 22)
			nameLabel.Position = UDim2.new(0, 76, 0.5, -24)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Theme.Fonts.Header
			nameLabel.TextSize = Theme.TextSize.Normal
			nameLabel.Text = recipe.name
			nameLabel.TextColor3 = Theme.Colors.Text
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.ZIndex = 16
			nameLabel.Parent = row

			local reqLabel = Instance.new("TextLabel")
			reqLabel.Name = "RecipeRequirements"
			reqLabel.Size = UDim2.new(1, -80, 0, 20)
			reqLabel.Position = UDim2.new(0, 76, 0.5, 2)
			reqLabel.BackgroundTransparency = 1
			reqLabel.Font = Theme.Fonts.Body
			reqLabel.TextSize = Theme.TextSize.Small
			reqLabel.Text = recipe.requirements
			reqLabel.TextColor3 = Theme.Colors.TextSecondary
			reqLabel.TextXAlignment = Enum.TextXAlignment.Left
			reqLabel.TextTruncate = Enum.TextTruncate.AtEnd
			reqLabel.ZIndex = 16
			reqLabel.Parent = row

			row.Activated:Connect(function()
				hide()
				if onRecipeSelected then
					onRecipeSelected(recipe.id)
				end
			end)
		end
	end

	function ui:Hide()
		hide()
	end

	function ui:Show()
		cookingUI.Visible = true
		if overlay then
			overlay.Visible = true
			overlay.BackgroundTransparency = 1
			Animations.Tween(overlay, {
				BackgroundTransparency = 0.45
			}, Theme.Animation.Normal, Theme.Animation.EasingOut)
		end
		if panel then
			Panel.Open(panel)
		end
	end

	return ui
end

return CookingUI
