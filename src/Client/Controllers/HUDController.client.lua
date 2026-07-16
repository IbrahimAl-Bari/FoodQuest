print("HUDController started")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.UI.Theme)
local Animations = require(ReplicatedStorage.UI.Animations)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local UIManager = require(ReplicatedStorage.UI.Components.UIManager)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
print("HUDController: PlayerGui found")

local mainUI = playerGui:WaitForChild("MainUI")
print("HUDController: MainUI found")

local hud = mainUI:FindFirstChild("HUD")
if not hud then
	warn("HUDController: HUD frame not found in MainUI")
	return
end
print("HUDController: HUD frame found")

local btnSize = 48
local btnGap = 10
local btnY = 20

-- Debug: print HUD frame properties
print(string.format("HUDController: HUD AbsoluteSize=%s, AbsolutePosition=%s",
	tostring(hud.AbsoluteSize), tostring(hud.AbsolutePosition)))

local function logBtn(btn, label)
	if not btn then
		warn(string.format("HUDController: %s is nil", label))
		return
	end
	print(string.format("HUDController: %s found — Visible=%s, Enabled=%s, Size=%s, Position=%s, AbsSize=%s, AbsPos=%s, Parent=%s",
		label,
		tostring(btn.Visible),
		tostring(btn.Active),
		tostring(btn.Size),
		tostring(btn.Position),
		tostring(btn.AbsoluteSize),
		tostring(btn.AbsolutePosition),
		btn.Parent and btn.Parent.Name or "nil"))
end

-- Find all buttons
local inventoryBtn = hud:FindFirstChild("InventoryBtn")
local cookingBtn = hud:FindFirstChild("CookingBtn")
local settingsBtn = hud:FindFirstChild("SettingsBtn")
local displayCounterBtn = hud:FindFirstChild("DisplayCounterBtn")

logBtn(inventoryBtn, "InventoryBtn")
logBtn(cookingBtn, "CookingBtn")
logBtn(settingsBtn, "SettingsBtn")
logBtn(displayCounterBtn, "DisplayCounterBtn")

-- Only reposition if DisplayCounterBtn exists (plugin created 4-button layout)
-- Otherwise leave original 3-button positions untouched
local has4ButtonLayout = displayCounterBtn ~= nil

if has4ButtonLayout then
	local function positionBtn(btn, index)
		btn.Position = UDim2.new(1, -(4 * btnSize + 3 * btnGap - index * (btnSize + btnGap)), 0, btnY)
	end
	positionBtn(displayCounterBtn, 0)
	positionBtn(inventoryBtn, 1)
	positionBtn(cookingBtn, 2)
	positionBtn(settingsBtn, 3)
	print("HUDController: All buttons repositioned for 4-button layout")
end

-- Wire InventoryBtn
if inventoryBtn then
	inventoryBtn.Activated:Connect(function()
		warn("HUDController: InventoryBtn clicked")
		UIManager.Toggle("Inventory")
	end)
	print("HUDController: Inventory button connected")
else
	warn("HUDController: Inventory button not found in HUD")
end

-- Wire CookingBtn
if cookingBtn then
	cookingBtn.Activated:Connect(function()
		print("HUDController: CookingBtn clicked — calling UIManager.Toggle")
		UIManager.Toggle("Cooking")
		print("HUDController: CookingBtn handler done")
	end)
	print("HUDController: Cooking button connected")
else
	warn("HUDController: Cooking button not found in HUD")
end

-- Wire DisplayCounterBtn
if displayCounterBtn then
	displayCounterBtn.Activated:Connect(function()
		warn("HUDController: DisplayCounterBtn clicked")
		UIManager.Toggle("DisplayCounter")
	end)
	print("HUDController: DisplayCounter button connected")
else
	warn("HUDController: DisplayCounter button not found in HUD (run plugin to create it)")
end

print("HUDController: wiring complete")
