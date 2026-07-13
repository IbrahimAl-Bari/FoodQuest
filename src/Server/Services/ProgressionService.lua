local Players = game:GetService("Players")

local ProgressionService = {}

local completedObbies = {}

local function getOrCreateProgression(player)
	local progression = completedObbies[player]
	if progression == nil then
		progression = {}
		completedObbies[player] = progression
	end

	return progression
end

function ProgressionService:HasCompletedObby(player, obbyId)
	if not (player and player:IsA("Player")) or typeof(obbyId) ~= "string" then
		return false
	end

	local progression = completedObbies[player]
	return progression ~= nil and progression[obbyId] == true
end

function ProgressionService:TryCompleteObby(player, obbyId)
	if not (player and player:IsA("Player")) or typeof(obbyId) ~= "string" or obbyId == "" then
		return false, "InvalidCompletion"
	end

	local progression = getOrCreateProgression(player)
	if progression[obbyId] then
		return false, "AlreadyCompleted"
	end

	-- This assignment is the single server-side claim lock for this obby.
	progression[obbyId] = true
	player:SetAttribute("CompletedObby_" .. obbyId, true)

	return true
end

function ProgressionService:Init()
	Players.PlayerRemoving:Connect(function(player)
		completedObbies[player] = nil
	end)
end

return ProgressionService
