local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local networkFolder = ReplicatedStorage:WaitForChild("Network")

local Ingredients = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Ingredients"))
local Foods = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Foods"))
local RemoteNames = require(networkFolder:WaitForChild("RemoteNames"))
local NotificationUI = require(script.Parent.Parent.UI:WaitForChild("NotificationUI"))

local gameNotification = networkFolder:WaitForChild(RemoteNames.GameNotification)
local notificationUI = NotificationUI.new(playerGui)

local function formatRewards(rewards)
	local entries = {}
	for ingredientId, amount in pairs(rewards or {}) do
		local definition = Ingredients[ingredientId]
		if definition and typeof(amount) == "number" then
			table.insert(entries, definition.displayName .. " x" .. amount)
		end
	end

	table.sort(entries)
	return table.concat(entries, ", ")
end

gameNotification.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	if payload.kind == "ObbyStarted" then
		notificationUI:Show("Obby started! Reach the finish.", nil, "primary")
	elseif payload.kind == "ObbyCompleted" then
		notificationUI:Show("Obby complete! Rewards: " .. formatRewards(payload.rewards), 6, "success")
	elseif payload.kind == "CookingCompleted" then
		local food = Foods[payload.foodId]
		if food then
			notificationUI:Show("Cooked " .. food.displayName .. " x" .. payload.amount .. "!", nil, "success")
		end
	elseif payload.kind == "CookingFailed" and typeof(payload.message) == "string" then
		notificationUI:Show(payload.message, nil, "danger")
	elseif payload.kind == "CustomerPurchased" and typeof(payload.foodName) == "string" and typeof(payload.coins) == "number" then
		notificationUI:Show("Customer bought " .. payload.foodName .. " for " .. payload.coins .. " coins!", nil, "success")
	elseif payload.kind == "CustomerLeft" and typeof(payload.message) == "string" then
		notificationUI:Show(payload.message, nil, "warning")
	end
end)
