local Components = require(script.Parent:WaitForChild("Components"))
local Theme = require(script.Parent:WaitForChild("Theme"))

local CoinUI = {}

function CoinUI.new(playerGui)
	local screenGui = Components.CreateScreenGui(playerGui, "FoodQuestCoins")
	local card = Components.CreateCard(screenGui, {
		Name = "CoinCard",
		Size = UDim2.fromOffset(196, 58),
		Position = UDim2.fromOffset(18, 20),
		BackgroundColor3 = Theme.Colors.Panel,
	})

	Components.CreateIconBadge(card, {
		Name = "CoinIcon",
		Size = UDim2.fromOffset(38, 38),
		Position = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Theme.Colors.Coins,
		Text = "$",
		TextColor3 = Theme.Colors.PrimaryText,
	})
	Components.CreateLabel(card, {
		Text = "COINS",
		Size = UDim2.fromOffset(110, 16),
		Position = UDim2.fromOffset(58, 9),
		TextColor3 = Theme.Colors.SecondaryText,
		TextSize = Theme.TextSize.Helper,
		Font = Theme.Fonts.BodyBold,
	})
	local label = Components.CreateLabel(card, {
		Name = "CoinBalance",
		Size = UDim2.fromOffset(120, 27),
		Position = UDim2.fromOffset(58, 23),
		Text = "0",
		TextSize = Theme.TextSize.Section,
		Font = Theme.Fonts.Heading,
	})

	local ui = {}

	function ui:SetCoins(coins)
		label.Text = tostring(coins)
	end

	return ui
end

return CoinUI
