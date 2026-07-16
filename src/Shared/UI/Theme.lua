local Theme = {}

-- =================================================
-- COLORS
-- =================================================

local COLORS = {
	Primary = Color3.fromRGB(231, 29, 54),
	Secondary = Color3.fromRGB(255, 159, 28),
	Reward = Color3.fromRGB(255, 214, 10),
	Background = Color3.fromRGB(253, 255, 252),
	Danger = Color3.fromRGB(255, 77, 77),
	Dark = Color3.fromRGB(17, 17, 17),
	Text = Color3.fromRGB(17, 17, 17),
	TextLight = Color3.fromRGB(253, 255, 252),
	TextSecondary = Color3.fromRGB(119, 119, 119),
	Success = Color3.fromRGB(78, 154, 81),
	Disabled = Color3.fromRGB(119, 119, 119),
	Overlay = Color3.fromRGB(0, 0, 0),
	Stroke = Color3.fromRGB(220, 210, 195),
}

local function lighter(color, amount)
	return color:Lerp(Color3.new(1, 1, 1), amount or 0.15)
end

local function darker(color, amount)
	return color:Lerp(Color3.new(0, 0, 0), amount or 0.1)
end

-- =================================================
-- BUTTON STYLES
-- =================================================

local BUTTON_STYLES = {
	Primary = {
		Background = COLORS.Primary,
		Text = COLORS.TextLight,
		Hover = lighter(COLORS.Primary, 0.15),
		Pressed = darker(COLORS.Primary, 0.12),
	},
	Secondary = {
		Background = COLORS.Secondary,
		Text = COLORS.Dark,
		Hover = lighter(COLORS.Secondary, 0.12),
		Pressed = darker(COLORS.Secondary, 0.1),
	},
	Reward = {
		Background = COLORS.Reward,
		Text = COLORS.Dark,
		Hover = lighter(COLORS.Reward, 0.1),
		Pressed = darker(COLORS.Reward, 0.12),
	},
	Danger = {
		Background = COLORS.Danger,
		Text = COLORS.TextLight,
		Hover = lighter(COLORS.Danger, 0.12),
		Pressed = darker(COLORS.Danger, 0.1),
	},
	Disabled = {
		Background = COLORS.Disabled,
		Text = COLORS.TextLight,
		Hover = COLORS.Disabled,
		Pressed = COLORS.Disabled,
	},
	Ghost = {
		Background = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Text = COLORS.Text,
		Hover = lighter(Color3.fromRGB(0, 0, 0), 1),
		HoverTransparency = 0.9,
		Pressed = darker(Color3.fromRGB(0, 0, 0), 1),
		PressedTransparency = 0.85,
	},
}

-- =================================================
-- FONTS
-- =================================================

local FONTS = {
	Title = Enum.Font.FredokaOne,
	Header = Enum.Font.GothamBold,
	Body = Enum.Font.GothamMedium,
	Number = Enum.Font.GothamBold,
}

-- =================================================
-- TEXT SIZES
-- =================================================

local TEXT_SIZES = {
	LargeTitle = 40,
	Title = 32,
	Section = 24,
	Large = 18,
	Normal = 16,
	Small = 14,
	Tiny = 12,
}

-- =================================================
-- CORNER RADII
-- =================================================

local CORNER_RADII = {
	Small = UDim.new(0, 8),
	Medium = UDim.new(0, 14),
	Large = UDim.new(0, 24),
	XL = UDim.new(0, 32),
	Round = UDim.new(1, 0),
}

-- =================================================
-- SPACING / PADDING
-- =================================================

local SPACING = {
	XXSmall = 4,
	XSmall = 8,
	Small = 12,
	Medium = 16,
	Large = 24,
	XLarge = 32,
	XXLarge = 48,
}

-- =================================================
-- SHADOWS
-- =================================================

local SHADOWS = {
	Small = {
		Transparency = 0.86,
		Offset = 2,
		Thickness = 1,
	},
	Medium = {
		Transparency = 0.8,
		Offset = 4,
		Thickness = 2,
	},
	Large = {
		Transparency = 0.72,
		Offset = 8,
		Thickness = 3,
	},
}

-- =================================================
-- ANIMATION
-- =================================================

local ANIMATION = {
	Fast = 0.15,
	Normal = 0.25,
	Slow = 0.4,
	EasingIn = Enum.EasingStyle.Quad,
	EasingOut = Enum.EasingStyle.Quart,
	EasingInOut = Enum.EasingStyle.Sine,
	EasingBack = Enum.EasingStyle.Back,
}

-- =================================================
-- ICON SIZES
-- =================================================

local ICON_SIZES = {
	Small = 32,
	Medium = 48,
	Large = 80,
	Recipe = 96,
	HUD = 38,
	Card = 64,
}

-- =================================================
-- STROKE
-- =================================================

local STROKE = {
	Color = COLORS.Stroke,
	Thickness = 2,
}

-- =================================================
-- EXPORTED THEME TABLE
-- =================================================

Theme.Colors = COLORS
Theme.Fonts = FONTS
Theme.TextSize = TEXT_SIZES
Theme.Spacing = SPACING
Theme.Radius = CORNER_RADII
Theme.Shadow = SHADOWS
Theme.Animation = ANIMATION
Theme.IconSize = ICON_SIZES
Theme.Stroke = STROKE
Theme.Buttons = BUTTON_STYLES

-- =================================================
-- HELPER FUNCTIONS
-- =================================================

function Theme.GetColor(name)
	return COLORS[name]
end

function Theme.GetButtonStyle(name)
	return BUTTON_STYLES[name]
end

function Theme.GetFont(name)
	return FONTS[name]
end

function Theme.GetTextSize(name)
	return TEXT_SIZES[name]
end

function Theme.GetRadius(name)
	return CORNER_RADII[name]
end

function Theme.GetShadow(name)
	return SHADOWS[name]
end

function Theme.GetSpacing(name)
	return SPACING[name]
end

-- =================================================
-- BACKWARDS-COMPATIBLE MAPPINGS
-- =================================================

-- UIConfig.lua compatibility aliases
Theme.Colors.DarkOrange = COLORS.Secondary
Theme.Colors.Yellow = COLORS.Reward
Theme.Colors.Red = COLORS.Danger
Theme.Colors.White = COLORS.TextLight
Theme.Colors.PrimaryText = COLORS.Text
Theme.Colors.SecondaryText = COLORS.TextSecondary
Theme.Colors.Coins = COLORS.Reward
Theme.Colors.CardBackground = COLORS.Background
Theme.Colors.Panel = COLORS.Background
Theme.Colors.SecondaryPanel = Color3.fromRGB(232, 221, 207)
Theme.Colors.SuccessHover = Color3.fromRGB(99, 179, 102)
Theme.Colors.PrimaryHover = lighter(COLORS.Primary, 0.15)

-- Old font aliases
Theme.Fonts.Heading = FONTS.Title
Theme.Fonts.BodyBold = FONTS.Header

-- Old radius aliases
Theme.Radius.Small = CORNER_RADII.Small
Theme.Radius.Medium = CORNER_RADII.Medium
Theme.Radius.Large = CORNER_RADII.Large
Theme.Radius.XLarge = CORNER_RADII.XL
Theme.Radius.Pill = CORNER_RADII.Round

-- Old shadow aliases
Theme.Shadow.Transparency = SHADOWS.Medium.Transparency
Theme.Shadow.Offset = SHADOWS.Medium.Offset
Theme.Shadow.Elevation = {
	Low = SHADOWS.Small.Offset,
	Medium = SHADOWS.Medium.Offset,
	High = SHADOWS.Large.Offset,
}
Theme.ShadowTransparency = SHADOWS.Medium.Transparency

-- Old spacing aliases
Theme.Spacing.XXSmall = SPACING.XXSmall
Theme.Spacing.XSmall = SPACING.XSmall
Theme.Spacing.Small = SPACING.Small
Theme.Spacing.Medium = SPACING.Medium
Theme.Spacing.Large = SPACING.Large
Theme.Spacing.XLarge = SPACING.XLarge
Theme.Spacing.XXLarge = SPACING.XXLarge

-- Old motion aliases
Theme.Motion = {
	Fast = ANIMATION.Fast,
	Normal = ANIMATION.Normal,
	Slow = ANIMATION.Slow,
}
Theme.Easing = {
	In = ANIMATION.EasingIn,
	Out = ANIMATION.EasingOut,
	InOut = ANIMATION.EasingInOut,
	Back = ANIMATION.EasingBack,
}

-- Old text size aliases
Theme.TextSize.Helper = TEXT_SIZES.Small
Theme.TextSize.Body = TEXT_SIZES.Normal
Theme.TextSize.Section = TEXT_SIZES.Large
Theme.TextSize.Title = TEXT_SIZES.Title
Theme.TextSize.Heading = TEXT_SIZES.LargeTitle

-- Old stroke alias
Theme.StrokeTransparency = 0.78

return Theme
