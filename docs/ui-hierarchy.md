# MainUI — StarterGui Hierarchy

Build this in `StarterGui` in Roblox Studio.

```
StarterGui
└── MainUI (ScreenGui)
    ├── ResetOnSpawn = false
    ├── IgnoreGuiInset = false
    ├── ZIndexBehavior = Sibling
    │
    ├── [HUD] (Frame)
    │   ├── Name = "HUD"
    │   ├── BackgroundTransparency = 1
    │   ├── Size = UDim2.fromScale(1, 1)
    │   │
    │   ├── [CoinCard] (Frame)
    │   │   ├── Name = "CoinCard"
    │   │   ├── Size = UDim2.fromOffset(196, 58)
    │   │   ├── Position = UDim2.fromOffset(18, 20)
    │   │   ├── BackgroundColor3 = Color3.fromRGB(255, 247, 230)
    │   │   ├── BorderSizePixel = 0
    │   │   ├── UICorner → CornerRadius = UDim.new(0, 22)
    │   │   ├── UIStroke → Color = RGB(232, 221, 207), Thickness = 2
    │   │   │
    │   │   ├── [CoinIcon] (Frame)
    │   │   │   ├── Name = "CoinIcon"
    │   │   │   ├── Size = UDim2.fromOffset(38, 38)
    │   │   │   ├── Position = UDim2.fromOffset(10, 10)
    │   │   │   ├── BackgroundColor3 = Color3.fromRGB(244, 197, 66)
    │   │   │   ├── UICorner → CornerRadius = UDim.new(1, 0)
    │   │   │   └── [Icon] (TextLabel)
    │   │   │       ├── Name = "Icon"
    │   │   │       ├── Text = "$"
    │   │   │       ├── TextColor3 = RGB(255, 255, 255)
    │   │   │       ├── Font = FredokaOne
    │   │   │       ├── TextSize = 20
    │   │   │       └── BackgroundTransparency = 1
    │   │   │
    │   │   ├── [CoinLabel] (TextLabel)
    │   │   │   ├── Name = "CoinLabel"
    │   │   │   ├── Text = "COINS"
    │   │   │   ├── Size = UDim2.fromOffset(110, 16)
    │   │   │   ├── Position = UDim2.fromOffset(58, 9)
    │   │   │   ├── TextColor3 = RGB(107, 107, 107)
    │   │   │   ├── TextSize = 14
    │   │   │   ├── Font = GothamBold
    │   │   │   └── BackgroundTransparency = 1
    │   │   │
    │   │   └── [CoinBalance] (TextLabel)
    │   │       ├── Name = "CoinBalance"
    │   │       ├── Text = "0"
    │   │       ├── Size = UDim2.fromOffset(120, 27)
    │   │       ├── Position = UDim2.fromOffset(58, 23)
    │   │       ├── TextColor3 = RGB(17, 17, 17)
    │   │       ├── TextSize = 20
    │   │       ├── Font = FredokaOne
    │   │       └── BackgroundTransparency = 1
    │   │
    │   ├── [InventoryBtn] (ImageButton) — 48×48, top-left group
    │   │   ├── Name = "InventoryBtn"
    │   │   ├── Size = UDim2.fromOffset(48, 48)
    │   │   ├── Position = UDim2.new(1, -174, 0, 20)
    │   │   ├── BackgroundColor3 = RGB(255, 159, 28)
    │   │   ├── UICorner → CornerRadius = UDim.new(0, 14)
    │   │   └── Image = placeholder (will use IconRegistry.Inventory)
    │   │
    │   ├── [CookingBtn] (ImageButton) — 48×48
    │   │   ├── Name = "CookingBtn"
    │   │   ├── Size = UDim2.fromOffset(48, 48)
    │   │   ├── Position = UDim2.new(1, -116, 0, 20)
    │   │   ├── BackgroundColor3 = RGB(255, 159, 28)
    │   │   ├── UICorner → CornerRadius = UDim.new(0, 14)
    │   │   └── Image = placeholder (will use IconRegistry.Cooking)
    │   │
    │   └── [SettingsBtn] (ImageButton) — 48×48
    │       ├── Name = "SettingsBtn"
    │       ├── Size = UDim2.fromOffset(48, 48)
    │       ├── Position = UDim2.new(1, -58, 0, 20)
    │       ├── BackgroundColor3 = RGB(232, 221, 207)
    │       ├── UICorner → CornerRadius = UDim.new(0, 14)
    │       └── Image = placeholder (will use IconRegistry.Settings)
    │
    ├── [CookingUI] (Frame)
    │   ├── Name = "CookingUI"
    │   ├── Size = UDim2.fromScale(1, 1)
    │   ├── Visible = false
    │   ├── BackgroundTransparency = 1
    │   │
    │   ├── [CookingOverlay] (TextButton)
    │   │   ├── Name = "CookingOverlay"
    │   │   ├── Size = UDim2.fromScale(1, 1)
    │   │   ├── BackgroundColor3 = RGB(47, 43, 38)
    │   │   ├── BackgroundTransparency = 1
    │   │   ├── Text = ""
    │   │   └── AutoButtonColor = false
    │   │
    │   └── [CookingPanel] (Frame)
    │       ├── Name = "CookingPanel"
    │       ├── Size = UDim2.fromOffset(480, 430)
    │       ├── Position = UDim2.fromScale(0.5, 0.5)
    │       ├── AnchorPoint = Vector2.new(0.5, 0.5)
    │       ├── BackgroundColor3 = RGB(255, 247, 230)
    │       ├── UICorner → CornerRadius = UDim.new(0, 22)
    │       ├── UIStroke → Color = RGB(232, 221, 207), Thickness = 2
    │       ├── UISizeConstraint → MinSize = (320, 310), MaxSize = (560, 520)
    │       │
    │       ├── [CookingIcon] (Frame)
    │       │   ├── Name = "CookingIcon"
    │       │   ├── Size = UDim2.fromOffset(46, 46)
    │       │   ├── Position = UDim2.fromOffset(22, 20)
    │       │   ├── BackgroundColor3 = RGB(255, 159, 28)
    │       │   ├── UICorner → CornerRadius = UDim.new(1, 0)
    │       │   └── [Icon] (TextLabel) — "~", FredokaOne, white, 20px
    │       │
    │       ├── [CookingTitle] (TextLabel)
    │       │   ├── Name = "CookingTitle"
    │       │   ├── Text = "Cooking Station"
    │       │   ├── Size = UDim2.new(1, -128, 0, 32)
    │       │   ├── Position = UDim2.fromOffset(80, 17)
    │       │   ├── TextSize = 28, Font = FredokaOne
    │       │   ├── TextColor3 = RGB(17, 17, 17)
    │       │   └── BackgroundTransparency = 1
    │       │
    │       ├── [CookingSubtitle] (TextLabel)
    │       │   ├── Name = "CookingSubtitle"
    │       │   ├── Text = "Choose a recipe to place on your display counter"
    │       │   ├── Size = UDim2.new(1, -112, 0, 22)
    │       │   ├── Position = UDim2.fromOffset(80, 47)
    │       │   ├── TextSize = 14, TextColor3 = RGB(107, 107, 107)
    │       │   └── BackgroundTransparency = 1
    │       │
    │       ├── [CloseBtn] (ImageButton)
    │       │   ├── Name = "CloseBtn"
    │       │   ├── Size = UDim2.fromOffset(36, 36)
    │       │   ├── Position = UDim2.new(1, -58, 0, 20)
    │       │   ├── BackgroundColor3 = RGB(232, 221, 207)
    │       │   ├── UICorner → CornerRadius = UDim.new(0, 14)
    │       │   └── Text = "×" (or Image = IconRegistry.Close)
    │       │
    │       └── [RecipeList] (ScrollingFrame)
    │           ├── Name = "RecipeList"
    │           ├── Size = UDim2.new(1, -44, 1, -114)
    │           ├── Position = UDim2.fromOffset(22, 88)
    │           ├── BackgroundTransparency = 1
    │           ├── ScrollBarThickness = 4
    │           ├── AutomaticCanvasSize = Y
    │           └── UIListLayout → Padding = UDim.new(0, 10)
    │
    ├── [InventoryUI] (Frame)
    │   ├── Name = "InventoryUI"
    │   ├── Size = UDim2.fromScale(1, 1)
    │   ├── Visible = false
    │   ├── BackgroundTransparency = 1
    │   │
    │   └── [InventoryPanel] (Frame)
    │       ├── Name = "InventoryPanel"
    │       ├── Size = UDim2.fromOffset(390, 440)
    │       ├── Position = UDim2.fromOffset(184, 0.5)
    │       ├── AnchorPoint = Vector2.new(0, 0.5)
    │       ├── BackgroundColor3 = RGB(255, 247, 230)
    │       ├── UICorner → CornerRadius = UDim.new(0, 22)
    │       ├── UIStroke → Color = RGB(232, 221, 207), Thickness = 2
    │       ├── UISizeConstraint → MinSize = (310, 330), MaxSize = (460, 540)
    │       │
    │       ├── [InventoryIcon] (Frame) — 42×42 pill, Primary
    │       ├── [InventoryTitle] (TextLabel) — "Pantry", 28px, FredokaOne
    │       ├── [InventorySubtitle] (TextLabel) — "Ingredients collected", 14px
    │       ├── [CloseBtn] (ImageButton) — 34×34, SecondaryPanel
    │       └── [IngredientList] (ScrollingFrame)
    │           ├── Name = "IngredientList"
    │           ├── Size = UDim2.new(1, -40, 1, -114)
    │           ├── Position = UDim2.fromOffset(20, 92)
    │           ├── BackgroundTransparency = 1
    │           ├── AutomaticCanvasSize = Y
    │           └── UIListLayout → Padding = UDim.new(0, 10)
    │
    ├── [DisplayCounterUI] (Frame)
    │   ├── Name = "DisplayCounterUI"
    │   ├── Size = UDim2.fromScale(1, 1)
    │   ├── Visible = false
    │   ├── BackgroundTransparency = 1
    │   │
    │   └── [DisplayCounterPanel] (Frame)
    │       ├── Name = "DisplayCounterPanel"
    │       ├── Size = UDim2.fromOffset(340, 360)
    │       ├── Position = UDim2.fromScale(0.5, 0.5)
    │       ├── AnchorPoint = Vector2.new(0.5, 0.5)
    │       ├── BackgroundColor3 = RGB(255, 247, 230)
    │       ├── UICorner → CornerRadius = UDim.new(0, 22)
    │       ├── UIStroke → Color = RGB(232, 221, 207), Thickness = 2
    │       ├── UISizeConstraint → MinSize = (280, 260), MaxSize = (420, 480)
    │       │
    │       ├── [CounterIcon] (Frame) — 42×42 pill, Primary
    │       ├── [CounterTitle] (TextLabel) — "Display Counter", 28px
    │       ├── [CounterHelper] (TextLabel) — "X of Y spots stocked", 14px
    │       ├── [CloseBtn] (ImageButton) — 34×34
    │       └── [SlotList] (ScrollingFrame)
    │           ├── Name = "SlotList"
    │           ├── Size = UDim2.new(1, -40, 1, -114)
    │           ├── Position = UDim2.fromOffset(20, 92)
    │           └── UIListLayout → Padding = UDim.new(0, 10)
    │
    ├── [ShopUI] (Frame)
    │   ├── Name = "ShopUI"
    │   ├── Visible = false
    │   └── (future)
    │
    ├── [UpgradeUI] (Frame)
    │   ├── Name = "UpgradeUI"
    │   ├── Visible = false
    │   └── (future)
    │
    └── [Notifications] (Frame)
        ├── Name = "Notifications"
        ├── Size = UDim2.fromScale(1, 1)
        ├── BackgroundTransparency = 1
        │
        └── [NotificationHolder] (CanvasGroup)
            ├── Name = "NotificationHolder"
            ├── Size = UDim2.fromOffset(480, 78)
            ├── Position = UDim2.new(0.5, 0, 0, -100)
            ├── AnchorPoint = Vector2.new(0.5, 0)
            ├── GroupTransparency = 1
            │
            └── [NotificationCard] (Frame)
                ├── Name = "NotificationCard"
                ├── Size = UDim2.fromScale(1, 1)
                ├── BackgroundColor3 = RGB(255, 247, 230)
                ├── UICorner → CornerRadius = UDim.new(0, 22)
                ├── UIStroke → Color = RGB(232, 221, 207), Thickness = 2
                │
                ├── [StatusIcon] (Frame)
                │   ├── Name = "StatusIcon"
                │   ├── Size = UDim2.fromOffset(42, 42)
                │   ├── Position = UDim2.fromOffset(16, 18)
                │   ├── BackgroundColor3 = RGB(255, 159, 28)
                │   ├── UICorner → CornerRadius = UDim.new(1, 0)
                │   └── [Icon] (TextLabel) — "!", FredokaOne, white
                │
                └── [Message] (TextLabel)
                    ├── Name = "Message"
                    ├── Size = UDim2.new(1, -92, 1, -18)
                    ├── Position = UDim2.fromOffset(74, 9)
                    ├── TextColor3 = RGB(17, 17, 17)
                    ├── TextSize = 16
                    ├── Font = GothamBold
                    ├── TextWrapped = true
                    └── BackgroundTransparency = 1
```

## Notes for Studio

- All `Name` values are case-sensitive — scripts use these exact names.
- Every panel has a `CloseBtn` — wire `Activated` to hide the parent panel.
- The `HUD` buttons (InventoryBtn, CookingBtn) should toggle their respective panels' visibility.
- `UISizeConstraint` prevents panels from becoming too small/large on different screens.
- Background transparency = 1 on containers that should be invisible (HUD, overlay frames).
- The UI submodules in `src/Client/UI/` will be updated one at a time to use these pre-built elements.
