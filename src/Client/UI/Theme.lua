local Theme = {}

Theme.Colors = {
	Background = Color3.fromRGB(246, 241, 231),
	Panel = Color3.fromRGB(255, 249, 241),
	SecondaryPanel = Color3.fromRGB(232, 221, 207),
	CardBackground = Color3.fromRGB(255, 249, 241),
	CardBorder = Color3.fromRGB(232, 221, 207),
	Primary = Color3.fromRGB(245, 158, 66),
	PrimaryHover = Color3.fromRGB(255, 180, 94),
	Success = Color3.fromRGB(78, 154, 81),
	SuccessHover = Color3.fromRGB(99, 179, 102),
	Danger = Color3.fromRGB(216, 74, 58),
	DangerHover = Color3.fromRGB(228, 90, 76),
	Coins = Color3.fromRGB(244, 197, 66),
	PrimaryText = Color3.fromRGB(47, 43, 38),
	SecondaryText = Color3.fromRGB(112, 106, 97),
	Disabled = Color3.fromRGB(163, 156, 147),
	White = Color3.fromRGB(255, 255, 255),
	Overlay = Color3.fromRGB(47, 43, 38),
}

Theme.Fonts = {
	Heading = Enum.Font.FredokaOne,
	Body = Enum.Font.GothamMedium,
	BodyBold = Enum.Font.GothamBold,
}

Theme.Radius = {
	Small = UDim.new(0, 10),
	Medium = UDim.new(0, 16),
	Large = UDim.new(0, 22),
	XLarge = UDim.new(0, 28),
	Pill = UDim.new(1, 0),
}

Theme.Shadow = {
	Transparency = 0.84,
	Offset = 4,
	Elevation = {
		Low = 2,
		Medium = 4,
		High = 8,
	},
}

Theme.Spacing = {
	XXSmall = 4,
	XSmall = 6,
	Small = 10,
	Medium = 16,
	Large = 24,
	XLarge = 32,
	XXLarge = 48,
}

Theme.Motion = {
	Fast = 0.12,
	Normal = 0.22,
	Slow = 0.35,
}

Theme.Easing = {
	In = Enum.EasingStyle.Quad,
	Out = Enum.EasingStyle.Quart,
	InOut = Enum.EasingStyle.Sine,
	Back = Enum.EasingStyle.Back,
}

Theme.TextSize = {
	Helper = 14,
	Body = 16,
	Section = 20,
	Title = 28,
	Heading = 34,
}

Theme.ShadowTransparency = 0.84
Theme.StrokeTransparency = 0.78

return Theme
