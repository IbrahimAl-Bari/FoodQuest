local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CookingStation = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Stations"):WaitForChild("CookingStation"))
local DisplayCounter = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Stations"):WaitForChild("DisplayCounter"))
local Cheese = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Ingredients"):WaitForChild("Cheese"))
local Flour = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Ingredients"):WaitForChild("Flour"))
local Tomato = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Ingredients"):WaitForChild("Tomato"))

local PrototypeWorldService = {}

local WORLD_FOLDER_NAME = "PrototypeWorld"

local function ensureFolder(name, parent)
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function placeUnique(assetFactory, name, cframe, parent)
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing
	end
	local instance = assetFactory()
	instance.Name = name
	instance.Parent = parent
	if instance:IsA("BasePart") then
		instance.CFrame = cframe
	elseif instance:IsA("Model") and instance.PrimaryPart then
		instance:SetPrimaryPartCFrame(cframe)
	end
	return instance
end

function PrototypeWorldService:Init()
	local worldFolder = ensureFolder(WORLD_FOLDER_NAME, workspace)
	local stationsFolder = ensureFolder("Stations", worldFolder)
	local pickupsFolder = ensureFolder("Pickups", worldFolder)
	local markersFolder = ensureFolder("Markers", worldFolder)

	placeUnique(CookingStation, "CookingStation",
		CFrame.new(0, 1.8 / 2, -12),
		stationsFolder)

	placeUnique(DisplayCounter, "DisplayCounter",
		CFrame.new(0, 1.4 / 2, -2),
		stationsFolder)

	local spawnPart = placeUnique(function()
		local part = Instance.new("Part")
		part.Name = "CustomerSpawn"
		part.Size = Vector3.new(1, 0.5, 1)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.Transparency = 1
		return part
	end, "CustomerSpawn", CFrame.new(0, 0.25, 5), markersFolder)

	CollectionService:AddTag(spawnPart, "CustomerSpawn")

	local function placeMarker(name, tagName, cframe)
		local marker = placeUnique(function()
			local part = Instance.new("Part")
			part.Name = name
			part.Size = Vector3.new(1, 0.5, 1)
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.Transparency = 1
			return part
		end, name, cframe, markersFolder)
		CollectionService:AddTag(marker, tagName)
		return marker
	end

	placeMarker("CustomerInspectPoint", "CustomerInspectPoint", CFrame.new(0, 0.25, -3))
	placeMarker("CustomerExit", "CustomerExit", CFrame.new(0, 0.25, 15))

	local function placeIngredientPickup(factory, name, x, z)
		local partHeight = 1.6
		local pickup = placeUnique(factory, name,
			CFrame.new(x, partHeight / 2, z),
			pickupsFolder)
		pickup.CanTouch = true
		CollectionService:AddTag(pickup, "IngredientPickup")
		pickup:SetAttribute("IngredientId", name)
		return pickup
	end

	placeIngredientPickup(Flour, "Flour", -7, -6)
	placeIngredientPickup(Tomato, "Tomato", -3, -6)
	placeIngredientPickup(Cheese, "Cheese", 1, -6)
end

return PrototypeWorldService
