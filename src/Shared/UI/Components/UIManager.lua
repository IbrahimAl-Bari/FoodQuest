local Panel = require(script.Parent:WaitForChild("Panel"))

local UIManager = {}
local registry = {}
local activeScreen = nil

function UIManager.Register(name, guiObject, onOpen, onClose)
	if not name or not guiObject then
		warn("UIManager.Register: skipped — name=" .. tostring(name) .. " guiObject=" .. tostring(guiObject))
		return
	end
	registry[name] = {
		obj = guiObject,
		onOpen = onOpen,
		onClose = onClose,
	}
	print("UIManager.Register: registered '" .. name .. "' — onOpen=" .. tostring(onOpen) .. " onClose=" .. tostring(onClose))
end

function UIManager.Open(name)
	local entry = registry[name]
	if not entry then
		warn("UIManager.Open: '" .. name .. "' not registered")
		return
	end
	print("UIManager.Open: opening '" .. name .. "' — has onOpen=" .. tostring(entry.onOpen))
	local success, err = pcall(function()
		if entry.onOpen then
			entry.onOpen()
		else
			entry.obj.Visible = true
			Panel.Open(entry.obj)
		end
	end)
	if not success then
		warn("UIManager.Open: failed to open '" .. name .. "': " .. tostring(err))
		if activeScreen == name then
			activeScreen = nil
		end
	end
	return entry.obj
end

function UIManager.Close(name)
	local entry = registry[name]
	if not entry then
		warn("UIManager.Close: '" .. name .. "' not registered")
		return
	end
	print("UIManager.Close: closing '" .. name .. "' — has onClose=" .. tostring(entry.onClose) .. " activeScreen=" .. tostring(activeScreen))
	local success, err = pcall(function()
		if entry.onClose then
			entry.onClose()
		else
			Panel.Close(entry.obj)
		end
	end)
	if not success then
		warn("UIManager.Close: failed to close '" .. name .. "': " .. tostring(err))
	end
	if activeScreen == name then
		print("UIManager.Close: clearing activeScreen (was '" .. name .. "')")
		activeScreen = nil
	end
	print("UIManager.Close: done — activeScreen=" .. tostring(activeScreen))
end

function UIManager.CloseAll()
	for name, entry in pairs(registry) do
		if entry.onClose then
			entry.onClose()
		else
			Panel.Close(entry.obj)
		end
	end
	activeScreen = nil
end

function UIManager.Toggle(name)
	local entry = registry[name]
	if not entry then
		warn("UIManager.Toggle: '" .. name .. "' not registered")
		return
	end
	print("UIManager.Toggle: toggling '" .. name .. "' — activeScreen=" .. tostring(activeScreen))
	if activeScreen == name then
		print("UIManager.Toggle: closing (same as active)")
		UIManager.Close(name)
	else
		if activeScreen then
			print("UIManager.Toggle: closing active '" .. activeScreen .. "' before opening '" .. name .. "'")
			UIManager.Close(activeScreen)
		end
		activeScreen = name
		print("UIManager.Toggle: activeScreen set to '" .. name .. "', now opening")
		UIManager.Open(name)
	end
	print("UIManager.Toggle: done — activeScreen=" .. tostring(activeScreen))
end

function UIManager.Get(name)
	local entry = registry[name]
	return entry and entry.obj
end

function UIManager.SetActive(name)
	if activeScreen == name then
		return
	end
	if activeScreen then
		UIManager.Close(activeScreen)
	end
	activeScreen = name
	UIManager.Open(name)
end

function UIManager.GetActive()
	return activeScreen
end

return UIManager
