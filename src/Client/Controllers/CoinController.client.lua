local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local networkFolder = ReplicatedStorage:WaitForChild("Network")

local RemoteNames = require(networkFolder:WaitForChild("RemoteNames"))
local CoinUI = require(script.Parent.Parent.UI:WaitForChild("CoinUI"))

local getCoinBalance = networkFolder:WaitForChild(RemoteNames.GetCoinBalance)
local coinBalanceUpdated = networkFolder:WaitForChild(RemoteNames.CoinBalanceUpdated)
local coinUI = CoinUI.new(playerGui)

local function renderCoins(coins)
	if typeof(coins) == "number" and coins >= 0 then
		coinUI:SetCoins(coins)
	end
end

renderCoins(getCoinBalance:InvokeServer())
coinBalanceUpdated.OnClientEvent:Connect(renderCoins)
