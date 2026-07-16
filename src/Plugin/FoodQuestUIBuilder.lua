--[[
	FoodQuest UI Builder — Studio Plugin
	======================================
	Installation:
	1. Open Roblox Studio
	2. Plugins → Open Plugins Folder
	3. Save this file as "FoodQuestUIBuilder.lua" inside that folder
	4. Restart Studio or close/reopen the Plugins window
	5. A "FoodQuest UI Builder" toolbar appears under the Plugins tab
]]

local Toolbar = plugin:CreateToolbar("FoodQuest UI Builder")
local CreateButton = Toolbar:CreateButton("Create MainUI", "Build the MainUI hierarchy in StarterGui", "")
local CleanupButton = Toolbar:CreateButton("Cleanup MainUI", "Delete the old MainUI and rebuild", "")

local StarterGui = game:GetService("StarterGui")

local COLORS = {
	Primary = Color3.fromRGB(255, 159, 28),
	DarkOrange = Color3.fromRGB(230, 126, 34),
	Yellow = Color3.fromRGB(255, 214, 10),
	Red = Color3.fromRGB(255, 77, 77),
	Background = Color3.fromRGB(17, 17, 17),
	CardBg = Color3.fromRGB(255, 247, 230),
	White = Color3.fromRGB(253, 255, 252),
	TextPrimary = Color3.fromRGB(17, 17, 17),
	TextSecondary = Color3.fromRGB(107, 107, 107),
	Stroke = Color3.fromRGB(232, 221, 207),
	SecondaryPanel = Color3.fromRGB(232, 221, 207),
	Success = Color3.fromRGB(78, 154, 81),
}

local FONTS = {
	FredokaOne = Enum.Font.FredokaOne,
	GothamBold = Enum.Font.GothamBold,
	GothamMedium = Enum.Font.GothamMedium,
}

local function new(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or COLORS.Stroke
	s.Thickness = thickness or 2
	s.Parent = parent
	return s
end

local function addListLayout(parent, padding)
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, padding or 10)
	layout.Parent = parent
	return layout
end

local function addSizeConstraint(parent, minW, minH, maxW, maxH)
	local sc = Instance.new("UISizeConstraint")
	sc.MinSize = Vector2.new(minW, minH)
	sc.MaxSize = Vector2.new(maxW, maxH)
	sc.Parent = parent
	return sc
end

local function createCard(parent, name, size, position, anchorPoint)
	return new("Frame", {
		Name = name,
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint or Vector2.new(0, 0),
		BackgroundColor3 = COLORS.CardBg,
		BorderSizePixel = 0,
		Parent = parent,
	})
end

local function createIconBadge(parent, name, size, position, bgColor, text, textColor, fontSize, font)
	local frame = new("Frame", {
		Name = name,
		Size = size,
		Position = position,
		BackgroundColor3 = bgColor or COLORS.Primary,
		BorderSizePixel = 0,
		Parent = parent,
	})
	addCorner(frame, 100)
	local label = new("TextLabel", {
		Name = "Icon",
		Text = text or "!",
		TextColor3 = textColor or COLORS.White,
		TextSize = fontSize or 20,
		Font = font or FONTS.FredokaOne,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = frame,
	})
	return frame, label
end

local function createLabel(parent, name, text, size, position, textColor, textSize, font)
	return new("TextLabel", {
		Name = name,
		Text = text,
		Size = size,
		Position = position,
		TextColor3 = textColor or COLORS.TextPrimary,
		TextSize = textSize or 16,
		Font = font or FONTS.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	})
end

local function createTextButton(parent, name, text, size, position, bgColor, textColor, textSize, font)
	local btn = new("TextButton", {
		Name = name,
		Text = text,
		Size = size,
		Position = position,
		BackgroundColor3 = bgColor or COLORS.SecondaryPanel,
		TextColor3 = textColor or COLORS.TextPrimary,
		TextSize = textSize or 20,
		Font = font or FONTS.GothamBold,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = parent,
	})
	return btn
end

local function createImageButton(parent, name, size, position, bgColor)
	return new("ImageButton", {
		Name = name,
		Size = size,
		Position = position,
		BackgroundColor3 = bgColor or COLORS.Primary,
		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		Image = "",
		Parent = parent,
	})
end

local function createScrollingFrame(parent, name, size, position)
	local sf = new("ScrollingFrame", {
		Name = name,
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = COLORS.TextSecondary,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	addListLayout(sf, 10)
	return sf
end

local function createPanelHeader(panel, iconText, iconColor, title, subtitle, closeSize)
	createIconBadge(panel, "PanelIcon", UDim2.fromOffset(46, 46),
		UDim2.fromOffset(22, 20), iconColor, iconText, COLORS.White, 22, FONTS.FredokaOne)

	createLabel(panel, "PanelTitle", title,
		UDim2.new(1, -128, 0, 32), UDim2.fromOffset(80, 17),
		COLORS.TextPrimary, 28, FONTS.FredokaOne)

	if subtitle then
		createLabel(panel, "PanelSubtitle", subtitle,
			UDim2.new(1, -112, 0, 22), UDim2.fromOffset(80, 47),
			COLORS.TextSecondary, 14, FONTS.GothamMedium)
	end

	local closeBtn = createTextButton(panel, "CloseBtn", "×",
		closeSize or UDim2.fromOffset(36, 36),
		UDim2.new(1, -58, 0, 20),
		COLORS.SecondaryPanel, COLORS.TextPrimary, 22, FONTS.GothamBold)
	addCorner(closeBtn, 14)
	return closeBtn
end

local function createPanel(parent, name, size, position, anchorPoint)
	local panel = createCard(parent, name, size, position, anchorPoint)
	addCorner(panel, 22)
	addStroke(panel, COLORS.Stroke, 2)
	return panel
end

local function createFullScreenFrame(parent, name)
	return new("Frame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})
end

local function createOverlay(parent, name)
	return new("TextButton", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = COLORS.Background,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = parent,
	})
end

-- =================================================
-- BUILD FUNCTIONS
-- =================================================

local function buildHUD(mainUI)
	local hud = new("Frame", {
		Name = "HUD",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = mainUI,
	})

	-- CoinCard
	local coinCard = createCard(hud, "CoinCard", UDim2.fromOffset(196, 58), UDim2.fromOffset(18, 20))
	addCorner(coinCard, 22)
	addStroke(coinCard, COLORS.Stroke, 2)

	createIconBadge(coinCard, "CoinIcon", UDim2.fromOffset(38, 38),
		UDim2.fromOffset(10, 10), COLORS.Yellow, "$", COLORS.White, 20, FONTS.FredokaOne)

	createLabel(coinCard, "CoinLabel", "COINS",
		UDim2.fromOffset(110, 16), UDim2.fromOffset(58, 9),
		COLORS.TextSecondary, 14, FONTS.GothamBold)

	createLabel(coinCard, "CoinBalance", "0",
		UDim2.fromOffset(120, 27), UDim2.fromOffset(58, 23),
		COLORS.TextPrimary, 20, FONTS.FredokaOne)

	-- HUD Buttons
	local btnY = 20
	local btnSize = 48
	local btnGap = 10
	local btnXStart = 18

	-- We'll place them from right edge
	local totalWidth = 4 * btnSize + 3 * btnGap -- 222px for 4 buttons
	local function hudBtn(name, offsetX, color)
		local btn = createImageButton(hud, name, UDim2.fromOffset(btnSize, btnSize),
			UDim2.new(1, -totalWidth + offsetX, 0, btnY), color)
		addCorner(btn, 14)
		return btn
	end

	hudBtn("DisplayCounterBtn", 0, COLORS.Primary)
	hudBtn("InventoryBtn", btnSize + btnGap, COLORS.Primary)
	hudBtn("CookingBtn", (btnSize + btnGap) * 2, COLORS.Primary)
	hudBtn("SettingsBtn", (btnSize + btnGap) * 3, COLORS.SecondaryPanel)
end

local function buildCookingUI(mainUI)
	local cookingUI = createFullScreenFrame(mainUI, "CookingUI")

	local overlay = createOverlay(cookingUI, "CookingOverlay")

	local panel = createPanel(cookingUI, "CookingPanel",
		UDim2.fromOffset(480, 430),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5))
	addSizeConstraint(panel, 320, 310, 560, 520)

	createPanelHeader(panel, "~", COLORS.Primary, "Cooking Station", "Choose a recipe to place on your display counter")

	local recipeList = createScrollingFrame(panel, "RecipeList",
		UDim2.new(1, -44, 1, -114),
		UDim2.fromOffset(22, 88))
end

local function buildInventoryUI(mainUI)
	local inventoryUI = createFullScreenFrame(mainUI, "InventoryUI")

	local panel = createPanel(inventoryUI, "InventoryPanel",
		UDim2.fromOffset(390, 440),
		UDim2.fromOffset(184, 0),
		Vector2.new(0, 0.5))
	addSizeConstraint(panel, 310, 330, 460, 540)

	createPanelHeader(panel, "#", COLORS.Primary, "Pantry", "Ingredients collected on your adventure")

	local ingredientList = createScrollingFrame(panel, "IngredientList",
		UDim2.new(1, -40, 1, -114),
		UDim2.fromOffset(20, 92))
end

local function buildDisplayCounterUI(mainUI)
	local counterUI = createFullScreenFrame(mainUI, "DisplayCounterUI")

	local panel = createPanel(counterUI, "DisplayCounterPanel",
		UDim2.fromOffset(340, 360),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5))
	addSizeConstraint(panel, 280, 260, 420, 480)

	createPanelHeader(panel, "#", COLORS.Primary, "Display Counter", nil)

	local helperLabel = createLabel(panel, "CounterHelper", "0 of 0 spots stocked",
		UDim2.new(1, -110, 0, 22), UDim2.fromOffset(74, 48),
		COLORS.TextSecondary, 14, FONTS.GothamMedium)

	local slotList = createScrollingFrame(panel, "SlotList",
		UDim2.new(1, -40, 1, -114),
		UDim2.fromOffset(20, 92))
end

local function buildNotifications(mainUI)
	local notifFrame = new("Frame", {
		Name = "Notifications",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = mainUI,
	})

	local holder = new("CanvasGroup", {
		Name = "NotificationHolder",
		Size = UDim2.fromOffset(480, 78),
		Position = UDim2.new(0.5, 0, 0, -100),
		AnchorPoint = Vector2.new(0.5, 0),
		GroupTransparency = 1,
		Parent = notifFrame,
	})

	local card = createCard(holder, "NotificationCard", UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0))
	addCorner(card, 22)
	addStroke(card, COLORS.Stroke, 2)

	createIconBadge(card, "StatusIcon", UDim2.fromOffset(42, 42),
		UDim2.fromOffset(16, 18), COLORS.Primary, "!", COLORS.White, 22, FONTS.FredokaOne)

	createLabel(card, "Message", "",
		UDim2.new(1, -92, 1, -18), UDim2.fromOffset(74, 9),
		COLORS.TextPrimary, 16, FONTS.GothamBold)
end

local function buildFutureContainers(mainUI)
	local future = { "ShopUI", "UpgradeUI", "RestaurantUI", "QuestUI", "ProfileUI" }
	for _, name in ipairs(future) do
		new("Frame", {
			Name = name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = mainUI,
		})
	end
end

-- =================================================
-- MAIN ENTRY POINTS
-- =================================================

local function createMainUI()
	if StarterGui:FindFirstChild("MainUI") then
		return false, "MainUI already exists. Use 'Cleanup MainUI' to rebuild."
	end

	local mainUI = new("ScreenGui", {
		Name = "MainUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = StarterGui,
	})

	buildHUD(mainUI)
	buildCookingUI(mainUI)
	buildInventoryUI(mainUI)
	buildDisplayCounterUI(mainUI)
	buildNotifications(mainUI)
	buildFutureContainers(mainUI)

	return true, "MainUI created successfully."
end

local function cleanupMainUI()
	local existing = StarterGui:FindFirstChild("MainUI")
	if existing then
		existing:Destroy()
	end
end

local function rebuildMainUI()
	cleanupMainUI()
	local success, msg = createMainUI()
	return success, msg
end

CreateButton.Click:Connect(function()
	local success, msg = createMainUI()
	if success then
		print("[FoodQuest UI Builder] " .. msg)
	else
		print("[FoodQuest UI Builder] " .. msg)
	end
end)

CleanupButton.Click:Connect(function()
	rebuildMainUI()
	print("[FoodQuest UI Builder] MainUI rebuilt.")
end)

plugin:SetSetting("FoodQuestUIBuilderVersion", 1)
