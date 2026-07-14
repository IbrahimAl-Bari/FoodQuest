local DataService = require(script.Parent:WaitForChild("DataService"))

local CurrencyService = {}
CurrencyService.CurrencyChanged = Instance.new("BindableEvent")

function CurrencyService:AddCoins(player, amount)
	if not (player and player:IsA("Player")) or typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
		return false, "InvalidAward"
	end

	local data = DataService:GetData(player, "Currency")
	if not data then
		return false, "NoSession"
	end

	data.balance = data.balance + amount
	DataService:SetDirty(player)
	CurrencyService.CurrencyChanged:Fire(player, data.balance)
	return true, data.balance
end

function CurrencyService:GetCoins(player)
	if not (player and player:IsA("Player")) then
		return 0
	end

	local data = DataService:GetData(player, "Currency")
	if not data then
		return 0
	end

	return data.balance
end

function CurrencyService:CanAfford(player, amount)
	if not (player and player:IsA("Player")) or typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
		return false
	end

	return self:GetCoins(player) >= amount
end

function CurrencyService:SpendCoins(player, amount)
	if not (player and player:IsA("Player")) or typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
		return false, "InvalidCost"
	end
	if not self:CanAfford(player, amount) then
		return false, "InsufficientCoins"
	end

	local data = DataService:GetData(player, "Currency")
	if not data then
		return false, "NoSession"
	end

	data.balance = data.balance - amount
	DataService:SetDirty(player)
	CurrencyService.CurrencyChanged:Fire(player, data.balance)
	return true, data.balance
end

function CurrencyService:Init()
end

return CurrencyService
