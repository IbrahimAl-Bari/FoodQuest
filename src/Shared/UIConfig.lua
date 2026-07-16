local UIConfig = {}

UIConfig.Colors = {
	Primary = Color3.fromRGB(255, 159, 28),
	DarkOrange = Color3.fromRGB(230, 126, 34),
	Yellow = Color3.fromRGB(255, 214, 10),
	Red = Color3.fromRGB(255, 77, 77),
	Background = Color3.fromRGB(17, 17, 17),
	CardBackground = Color3.fromRGB(255, 247, 230),
	White = Color3.fromRGB(253, 255, 252),
	PrimaryText = Color3.fromRGB(17, 17, 17),
	SecondaryText = Color3.fromRGB(107, 107, 107),
	Success = Color3.fromRGB(78, 154, 81),
	SuccessHover = Color3.fromRGB(99, 179, 102),
	Danger = Color3.fromRGB(216, 74, 58),
	Disabled = Color3.fromRGB(163, 156, 147),
	Coins = Color3.fromRGB(244, 197, 66),
	Overlay = Color3.fromRGB(47, 43, 38),
	Stroke = Color3.fromRGB(232, 221, 207),
}

UIConfig.Fonts = {
	Title = Enum.Font.FredokaOne,
	Header = Enum.Font.GothamBold,
	Body = Enum.Font.GothamMedium,
	Number = Enum.Font.GothamBold,
}

UIConfig.TextSize = {
	LargeTitle = 42,
	Title = 32,
	Header = 26,
	Large = 20,
	Normal = 16,
	Small = 14,
	Tiny = 12,
}

UIConfig.Spacing = {
	XXSmall = 4,
	XSmall = 8,
	Small = 12,
	Medium = 16,
	Large = 24,
	XLarge = 32,
	XXLarge = 48,
}

UIConfig.Radius = {
	Small = UDim.new(0, 8),
	Medium = UDim.new(0, 14),
	Large = UDim.new(0, 22),
	Round = UDim.new(1, 0),
}

UIConfig.Stroke = {
	Color = Color3.fromRGB(232, 221, 207),
	Thickness = 2,
	Transparency = 0.78,
}

UIConfig.Shadow = {
	Transparency = 0.84,
	Elevation = {
		Low = 2,
		Medium = 4,
		High = 8,
	},
}

UIConfig.Motion = {
	Fast = 0.12,
	Normal = 0.22,
	Slow = 0.35,
}

UIConfig.Easing = {
	In = Enum.EasingStyle.Quad,
	Out = Enum.EasingStyle.Quart,
	InOut = Enum.EasingStyle.Sine,
	Back = Enum.EasingStyle.Back,
}

UIConfig.IconSize = {
	Small = 32,
	Medium = 48,
	Large = 80,
	Recipe = 96,
	HUD = 38,
	IngredientCard = 64,
}

return UIConfig
