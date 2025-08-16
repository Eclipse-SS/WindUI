local ToolTip = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween


function ToolTip.New(Title, Parent)
	local ToolTipModule = {
		Container = nil,
		ToolTipSize = 16,
	}

	local ToolTipTitle = New("TextLabel", {
		AutomaticSize = "XY",
		TextWrapped = true,
		BackgroundTransparency = 1,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		Text = Title,
		TextSize = 17,
		ThemeTag = {
			TextColor3 = "Text",
		}
	})

	local UIScale = New("UIScale", {
		Scale = .9 -- 1
	})

	local Container = New("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5,0),
		AutomaticSize = "XY",
		BackgroundTransparency = 1,
		Parent = Parent,
		GroupTransparency = 1, -- 0
		Visible = false -- true
	}, {
		New("UISizeConstraint", {
			MaxSize = Vector2.new(400, math.huge)
		}),
		New("Frame", {
			AutomaticSize = "XY",
			BackgroundTransparency = 1,
			LayoutOrder = 99,
			Visible = false
		}, {
			New("ImageLabel", {
				Size = UDim2.new(0,ToolTipModule.ToolTipSize,0,ToolTipModule.ToolTipSize/2),
				BackgroundTransparency = 1,
				Rotation = 180,
				Image = "rbxassetid://89524607682719",
				ThemeTag = {
					ImageColor3 = "Accent",
				},
			}, {
				New("ImageLabel", {
					Size = UDim2.new(0,ToolTipModule.ToolTipSize,0,ToolTipModule.ToolTipSize/2),
					BackgroundTransparency = 1,
					LayoutOrder = 99,
					ImageTransparency = .9,
					Image = "rbxassetid://89524607682719",
					ThemeTag = {
						ImageColor3 = "Text",
					},
				}),
			}),
		}),
		New("Frame", {
			AutomaticSize = "XY",
			ThemeTag = {
				BackgroundColor3 = "Accent",
			},

		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0,16),
			}),
			New("Frame", {
				ThemeTag = {
					BackgroundColor3 = "Text",
				},
				AutomaticSize = "XY",
				BackgroundTransparency = .9,
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(0,16),
				}),
				New("UIListLayout", {
					Padding = UDim.new(0,12),
					FillDirection = "Horizontal",
					VerticalAlignment = "Center"
				}),
				--ToolTipIcon, 
				ToolTipTitle,
				New("UIPadding", {
					PaddingTop = UDim.new(0,12),
					PaddingLeft = UDim.new(0,12),
					PaddingRight = UDim.new(0,12),
					PaddingBottom = UDim.new(0,12),
				}),
			})
		}),
		UIScale,
		New("UIListLayout", {
			Padding = UDim.new(0,0),
			FillDirection = "Vertical",
			VerticalAlignment = "Center",
			HorizontalAlignment = "Center",
		}),
	})
	ToolTipModule.Container = Container

	function ToolTipModule:Open() 
		Container.Visible = true

		Tween(Container, .16, { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		Tween(UIScale, .18, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
	end

	function ToolTipModule:Close() 
		Tween(Container, .2, { GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		Tween(UIScale, .2, { Scale = .9 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()

		task.wait(.25)

		Container.Visible = false
		Container:Destroy()
	end

	return ToolTipModule
end


return ToolTip