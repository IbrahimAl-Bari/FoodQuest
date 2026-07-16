local CoinUI = {}

function CoinUI.new(hudContainer)
	local coinCard = hudContainer:WaitForChild("CoinCard")
	local coinBalance = coinCard:WaitForChild("CoinBalance")

	local ui = {}

	function ui:SetCoins(coins)
		coinBalance.Text = tostring(coins)
	end

	return ui
end

return CoinUI
