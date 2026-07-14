local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DataService = {}

local DATASTORE_NAME = "FoodQuest_PlayerData"
local CURRENT_SCHEMA_VERSION = 1
local AUTOSAVE_INTERVAL = 60
local MAX_SAVE_RETRIES = 3
local SAVE_RETRY_DELAY = 1
local PERSIST_DISPLAY_COUNTERS = true

local profiles = {}
local dataStore

local function getKey(userId)
	return "PlayerProfile_" .. userId
end

local function createDefaultData()
	return {
		Currency = {
			balance = 0,
		},
		Inventory = {
			ingredients = {},
			foods = {},
		},
		Progression = {
			completedObbies = {},
		},
		DisplayCounters = {},
	}
end

local function createProfile(player)
	return {
		data = createDefaultData(),
		dirty = false,
		loaded = false,
	}
end

local function buildSaveData(profile)
	local saveData = {}
	for scope, scopeData in pairs(profile.data) do
		if scope == "DisplayCounters" and not PERSIST_DISPLAY_COUNTERS then
			continue
		end
		saveData[scope] = scopeData
	end
	return saveData
end

local function migrateEnvelope(envelope)
	local version = envelope.version or 0
	local data = envelope.data or {}

	if version < 1 then
	end

	envelope.version = CURRENT_SCHEMA_VERSION
	envelope.data = data
	return envelope
end

local function saveProfileToDataStore(userId, envelope)
	if not dataStore then
		return true
	end

	local key = getKey(userId)
	local encoded = HttpService:JSONEncode(envelope)

	local success, result = pcall(function()
		return dataStore:UpdateAsync(key, function()
			return encoded
		end)
	end)

	if not success then
		warn("DataStore save failed for user", userId, ":", result)
	end

	return success
end

local function loadProfileFromDataStore(userId)
	if not dataStore then
		return nil
	end

	local key = getKey(userId)
	local success, result = pcall(function()
		return dataStore:GetAsync(key)
	end)

	if not success then
		warn("DataStore load failed for user", userId, ":", result)
		return nil
	end

	if result == nil then
		return nil
	end

	local decodeSuccess, envelope = pcall(function()
		return HttpService:JSONDecode(result)
	end)

	if not decodeSuccess then
		warn("DataStore data corruption for user", userId)
		return nil
	end

	return envelope
end

local function mergeIntoProfile(profile, envelope)
	if not envelope or not envelope.data then
		return
	end

	for scope, scopeData in pairs(envelope.data) do
		if scope == "DisplayCounters" and not PERSIST_DISPLAY_COUNTERS then
			continue
		end

		if type(scopeData) == "table" then
			if scope == "DisplayCounters" then
				local normalized = {}
				for counterId, slots in pairs(scopeData) do
					normalized[counterId] = {}
					for slotKey, foodId in pairs(slots) do
						local numKey = tonumber(slotKey)
						if numKey then
							normalized[counterId][numKey] = foodId
						else
							normalized[counterId][slotKey] = foodId
						end
					end
				end
				profile.data[scope] = normalized
			else
				profile.data[scope] = scopeData
			end
		end
	end
end

function DataService:LoadPlayer(player)
	local profile = createProfile(player)
	profiles[player] = profile

	local envelope = loadProfileFromDataStore(player.UserId)
	if envelope then
		if envelope.jobId and envelope.jobId ~= game.JobId then
			warn("Player", player.UserId, "data was last saved on server", envelope.jobId)
		end

		envelope = migrateEnvelope(envelope)
		mergeIntoProfile(profile, envelope)
	end

	profile.loaded = true
end

function DataService:UnloadPlayer(player)
	local profile = profiles[player]
	if not profile then
		return
	end

	if profile.dirty then
		self:ForceSave(player)
	end

	profiles[player] = nil
end

function DataService:ForceSave(player)
	local profile = profiles[player]
	if not profile or not profile.dirty then
		return true
	end

	local userId = player.UserId
	local envelope = {
		version = CURRENT_SCHEMA_VERSION,
		jobId = game.JobId,
		savedAt = os.time(),
		data = buildSaveData(profile),
	}

	for attempt = 1, MAX_SAVE_RETRIES do
		if saveProfileToDataStore(userId, envelope) then
			profile.dirty = false
			return true
		end
		if attempt < MAX_SAVE_RETRIES then
			task.wait(SAVE_RETRY_DELAY)
		end
	end

	warn("Failed to save data for player after", MAX_SAVE_RETRIES, "attempts:", player.UserId, player.Name)
	return false
end

function DataService:GetData(player, scope)
	local profile = profiles[player]
	if not profile then
		return nil
	end

	profile.data[scope] = profile.data[scope] or {}
	return profile.data[scope]
end

function DataService:SetDirty(player)
	local profile = profiles[player]
	if profile then
		profile.dirty = true
	end
end

function DataService:AutosaveLoop()
	if not dataStore then
		return
	end

	while true do
		task.wait(AUTOSAVE_INTERVAL)

		for player, profile in profiles do
			if profile.dirty and profile.loaded then
				local userId = player.UserId
				local envelope = {
					version = CURRENT_SCHEMA_VERSION,
					jobId = game.JobId,
					savedAt = os.time(),
					data = buildSaveData(profile),
				}

				if saveProfileToDataStore(userId, envelope) then
					profile.dirty = false
				end
			end
		end
	end
end

function DataService:OnShutdown()
	for player, profile in profiles do
		if profile.dirty then
			local userId = player.UserId
			local envelope = {
				version = CURRENT_SCHEMA_VERSION,
				jobId = game.JobId,
				savedAt = os.time(),
				data = buildSaveData(profile),
			}
			saveProfileToDataStore(userId, envelope)
			profile.dirty = false
		end
	end
end

function DataService:Init()
	local success, store = pcall(function()
		return DataStoreService:GetDataStore(DATASTORE_NAME)
	end)

	if success then
		dataStore = store
	else
		warn("Failed to create DataStore, running without persistence:", store)
	end

	for _, player in Players:GetPlayers() do
		self:LoadPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:LoadPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:UnloadPlayer(player)
	end)

	task.spawn(function()
		self:AutosaveLoop()
	end)

	game:BindToClose(function()
		self:OnShutdown()
	end)
end

function DataService:GetSaveInterval()
	return AUTOSAVE_INTERVAL
end

return DataService
