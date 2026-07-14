local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local networkFolder = ReplicatedStorage:WaitForChild("Network")

local Foods = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Foods"))
local RemoteNames = require(networkFolder:WaitForChild("RemoteNames"))
local DisplayCounterUI = require(script.Parent.Parent.UI:WaitForChild("DisplayCounterUI"))

local getCounterSnapshot = networkFolder:WaitForChild(RemoteNames.GetDisplayCounterSnapshot)
local counterUpdated = networkFolder:WaitForChild(RemoteNames.DisplayCounterUpdated)
local displayCounterUI = DisplayCounterUI.new(playerGui)

local function renderCounter(snapshot)
	if typeof(snapshot) ~= "table" or typeof(snapshot.slotCount) ~= "number" then
		return
	end

	local foodIds = {}
	local foodNames = {}
	local filledSlots = 0
	for slotIndex = 1, snapshot.slotCount do
		local foodId = snapshot.slots[slotIndex]
		local food = Foods[foodId]
		if food then
			foodIds[slotIndex] = foodId
			foodNames[slotIndex] = food.displayName
			filledSlots += 1
		else
			foodIds[slotIndex] = false
			foodNames[slotIndex] = nil
		end
	end

	displayCounterUI:SetCounter({
		displayName = snapshot.displayName,
		slotCount = snapshot.slotCount,
		filledSlots = filledSlots,
		slots = foodIds,
		foodNames = foodNames,
	})
end

renderCounter(getCounterSnapshot:InvokeServer())
counterUpdated.OnClientEvent:Connect(renderCounter)
