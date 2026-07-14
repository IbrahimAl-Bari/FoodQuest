local ICONS = {
	Tomato = "rbxassetid://PLACEHOLDER_Tomato",
	Flour = "rbxassetid://PLACEHOLDER_Flour",
	Cheese = "rbxassetid://PLACEHOLDER_Cheese",
	TomatoSoup = "rbxassetid://PLACEHOLDER_TomatoSoup",
	CheesePizza = "rbxassetid://PLACEHOLDER_CheesePizza",
}

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

function IconRegistry.GetIconImage(itemId)
	local icon = IconRegistry.GetIcon(itemId)
	if icon then
		return icon
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

return IconRegistry
