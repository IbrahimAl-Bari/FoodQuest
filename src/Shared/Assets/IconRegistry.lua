local ICONS = {
	-- Ingredients
	Tomato = "rbxassetid://PLACEHOLDER_Tomato",
	Flour = "rbxassetid://PLACEHOLDER_Flour",
	Cheese = "rbxassetid://PLACEHOLDER_Cheese",

	-- Foods
	TomatoSoup = "rbxassetid://PLACEHOLDER_TomatoSoup",
	CheesePizza = "rbxassetid://PLACEHOLDER_CheesePizza",

	-- UI
	Coin = "rbxassetid://PLACEHOLDER_Coin",
	Inventory = "rbxassetid://PLACEHOLDER_Inventory",
	Cooking = "rbxassetid://PLACEHOLDER_Cooking",
	Shop = "rbxassetid://PLACEHOLDER_Shop",
	Settings = "rbxassetid://PLACEHOLDER_Settings",
	Close = "rbxassetid://PLACEHOLDER_Close",
	Notification = "rbxassetid://PLACEHOLDER_Notification",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IconRegistry = {}

local function isPlaceholder(assetId)
	return assetId and assetId:find("PLACEHOLDER") ~= nil
end

function IconRegistry.GetIcon(itemId)
	local icon = ICONS[itemId]
	if icon and not isPlaceholder(icon) then
		return icon
	end
	return nil
end

function IconRegistry.HasIcon(itemId)
	local icon = ICONS[itemId]
	return icon ~= nil and not isPlaceholder(icon)
end

function IconRegistry.GetIngredientIcon(ingredientId)
	local icon = ICONS[ingredientId]
	if icon and not isPlaceholder(icon) then
		return icon
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local iconFolder = assets and assets:FindFirstChild("Icons")
	if iconFolder then
		local image = iconFolder:FindFirstChild(ingredientId .. "_Icon")
		if image then
			if image:IsA("Decal") then
				return image.Texture
			elseif image:IsA("ImageLabel") then
				return image.Image
			end
		end
	end

	return nil
end

function IconRegistry.GetKnownIds()
	local ids = {}
	for id in ICONS do
		table.insert(ids, id)
	end
	return ids
end

function IconRegistry.GetCategory(itemId)
	if ICONS[itemId] == nil then
		return nil
	end
	for category, ids in pairs(ICONS) do
		if type(category) == "string" and type(ids) == "table" then
			for _, id in ipairs(ids) do
				if id == itemId then
					return category
				end
			end
		end
	end
	return "UI"
end

return IconRegistry
