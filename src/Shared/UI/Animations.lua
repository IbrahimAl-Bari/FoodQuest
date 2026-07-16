local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent:WaitForChild("Theme"))

local Animations = {}

-- Track active tweens per instance (weak keys = auto-cleanup on destroy)
local activeTweens = setmetatable({}, { __mode = "k" })

-- =================================================
-- CORE TWEEN UTILITY
-- =================================================

function Animations.Tween(instance, properties, duration, easingStyle, easingDirection)
	if not instance or not instance.Parent then
		return
	end

	if activeTweens[instance] then
		activeTweens[instance]:Cancel()
	end

	local info = TweenInfo.new(
		duration or Theme.Animation.Normal,
		easingStyle or Theme.Animation.EasingOut,
		easingDirection or Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(instance, info, properties)
	activeTweens[instance] = tween

	tween.Completed:Once(function()
		if activeTweens[instance] == tween then
			activeTweens[instance] = nil
		end
	end)

	tween:Play()
	return tween
end

-- =================================================
-- UISCALE HELPER
-- =================================================

function Animations.GetUIScale(guiObject)
	local existing = guiObject:FindFirstChildOfClass("UIScale")
	if existing then
		return existing
	end

	local uiScale = Instance.new("UIScale")
	uiScale.Name = "AnimationScale"
	uiScale.Parent = guiObject
	return uiScale
end

-- =================================================
-- FADE
-- =================================================

function Animations.FadeIn(guiObject)
	if not guiObject or not guiObject.Parent then
		return
	end

	guiObject.Visible = true
	guiObject.GroupTransparency = 1

	return Animations.Tween(guiObject, {
		GroupTransparency = 0
	}, Theme.Animation.Normal, Theme.Animation.EasingOut)
end

function Animations.FadeOut(guiObject)
	if not guiObject or not guiObject.Parent then
		return
	end

	local tween = Animations.Tween(guiObject, {
		GroupTransparency = 1
	}, Theme.Animation.Normal, Theme.Animation.EasingIn)

	if tween then
		tween.Completed:Once(function()
			guiObject.Visible = false
		end)
	end

	return tween
end

-- =================================================
-- PANEL OPEN / CLOSE
-- =================================================

function Animations.OpenPanel(guiObject)
	if not guiObject or not guiObject.Parent then
		return
	end

	local uiScale = Animations.GetUIScale(guiObject)

	uiScale.Scale = 0.8
	guiObject.Visible = true

	if guiObject:IsA("CanvasGroup") then
		guiObject.GroupTransparency = 1
		Animations.Tween(guiObject, {
			GroupTransparency = 0
		}, Theme.Animation.Normal, Theme.Animation.EasingOut)
	end

	Animations.Tween(uiScale, {
		Scale = 1
	}, Theme.Animation.Normal, Theme.Animation.EasingBack)
end

function Animations.ClosePanel(guiObject)
	if not guiObject or not guiObject.Parent then
		return
	end

	local uiScale = Animations.GetUIScale(guiObject)

	if guiObject:IsA("CanvasGroup") then
		Animations.Tween(guiObject, {
			GroupTransparency = 1
		}, Theme.Animation.Fast, Theme.Animation.EasingIn)
	end

	local scaleTween = Animations.Tween(uiScale, {
		Scale = 0.8
	}, Theme.Animation.Fast, Theme.Animation.EasingIn)

	if scaleTween then
		scaleTween.Completed:Once(function()
			guiObject.Visible = false
			uiScale.Scale = 1
			if guiObject:IsA("CanvasGroup") then
				guiObject.GroupTransparency = 0
			end
		end)
	end
end

-- =================================================
-- BUTTON
-- =================================================

function Animations.ButtonHover(button)
	if not button or not button.Parent then
		return
	end

	local uiScale = Animations.GetUIScale(button)
	Animations.Tween(uiScale, {
		Scale = 1.05
	}, Theme.Animation.Fast, Theme.Animation.EasingOut)
end

function Animations.ButtonLeave(button)
	if not button or not button.Parent then
		return
	end

	local uiScale = Animations.GetUIScale(button)
	Animations.Tween(uiScale, {
		Scale = 1
	}, Theme.Animation.Fast, Theme.Animation.EasingOut)
end

function Animations.ButtonPressed(button)
	if not button or not button.Parent then
		return
	end

	local uiScale = Animations.GetUIScale(button)
	uiScale.Scale = 1

	local down = Animations.Tween(uiScale, {
		Scale = 0.95
	}, Theme.Animation.Fast, Theme.Animation.EasingIn)

	if down then
		down.Completed:Once(function()
			Animations.Tween(uiScale, {
				Scale = 1
			}, Theme.Animation.Fast, Theme.Animation.EasingOut)
		end)
	end
end

-- =================================================
-- POP (for rewards, notifications, achievements)
-- =================================================

function Animations.Pop(guiObject)
	if not guiObject or not guiObject.Parent then
		return
	end

	local uiScale = Animations.GetUIScale(guiObject)
	uiScale.Scale = 0.5

	local overshoot = Animations.Tween(uiScale, {
		Scale = 1.1
	}, Theme.Animation.Normal, Theme.Animation.EasingBack)

	if overshoot then
		overshoot.Completed:Once(function()
			Animations.Tween(uiScale, {
				Scale = 1
			}, Theme.Animation.Fast, Theme.Animation.EasingOut)
		end)
	end
end

-- =================================================
-- SLIDE IN
-- =================================================

function Animations.SlideIn(guiObject, direction)
	if not guiObject or not guiObject.Parent then
		return
	end

	local originalPosition = guiObject.Position
	local absSize = guiObject.AbsoluteSize
	local startPosition

	if direction == "Top" then
		startPosition = UDim2.new(
			originalPosition.X.Scale, originalPosition.X.Offset,
			originalPosition.Y.Scale, originalPosition.Y.Offset - absSize.Y
		)
	elseif direction == "Bottom" then
		startPosition = UDim2.new(
			originalPosition.X.Scale, originalPosition.X.Offset,
			originalPosition.Y.Scale, originalPosition.Y.Offset + absSize.Y
		)
	elseif direction == "Left" then
		startPosition = UDim2.new(
			originalPosition.X.Scale, originalPosition.X.Offset - absSize.X,
			originalPosition.Y.Scale, originalPosition.Y.Offset
		)
	elseif direction == "Right" then
		startPosition = UDim2.new(
			originalPosition.X.Scale, originalPosition.X.Offset + absSize.X,
			originalPosition.Y.Scale, originalPosition.Y.Offset
		)
	else
		return
	end

	guiObject.Visible = true
	guiObject.Position = startPosition

	return Animations.Tween(guiObject, {
		Position = originalPosition
	}, Theme.Animation.Normal, Theme.Animation.EasingOut)
end

-- =================================================
-- PROGRESS BAR
-- =================================================

function Animations.ProgressBar(guiObject, value)
	if not guiObject or not guiObject.Parent then
		return
	end

	local clamped = math.clamp(value, 0, 1)

	local newSize = UDim2.new(
		clamped, 0,
		guiObject.Size.Y.Scale, guiObject.Size.Y.Offset
	)

	return Animations.Tween(guiObject, {
		Size = newSize
	}, Theme.Animation.Normal, Theme.Animation.EasingOut)
end

return Animations
