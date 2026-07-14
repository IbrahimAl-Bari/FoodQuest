local DataService = require(script.Parent:WaitForChild("DataService"))

local ProgressionService = {}

function ProgressionService:HasCompletedObby(player, obbyId)
	if not (player and player:IsA("Player")) or typeof(obbyId) ~= "string" then
		return false
	end

	local data = DataService:GetData(player, "Progression")
	if not data then
		return false
	end

	return data.completedObbies[obbyId] == true
end

function ProgressionService:TryCompleteObby(player, obbyId)
	if not (player and player:IsA("Player")) or typeof(obbyId) ~= "string" or obbyId == "" then
		return false, "InvalidCompletion"
	end

	local data = DataService:GetData(player, "Progression")
	if not data then
		return false, "NoSession"
	end

	if data.completedObbies[obbyId] then
		return false, "AlreadyCompleted"
	end

	data.completedObbies[obbyId] = true
	DataService:SetDirty(player)
	player:SetAttribute("CompletedObby_" .. obbyId, true)

	return true
end

function ProgressionService:Init()
end

return ProgressionService
