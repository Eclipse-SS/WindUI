local Label = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween


function Label.New(Text, Icon, Parent)
	local Radius = 10
	local IconLabelFrame
	if Icon and Icon ~= "" then
		IconLabelFrame = New("ImageLabel", {
			Image = Creator.Icon(Icon)[1],
			ImageRectSize = Creator.Icon(Icon)[2].ImageRectSize,
			ImageRectOffset = Creator.Icon(Icon)[2].ImageRectPosition,
			Size = UDim2.new(0,24-3,0,24-3),
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = "Icon",
			}
		})
	end

	local TextLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		TextSize = 16,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
		Size = UDim2.new(1,IconLabelFrame and -29 or 0,1,0),
		TextXAlignment = "Left",
		ThemeTag = {
			TextColor3 = "Text",
		},
		Text = Text,
	})

	local LabelFrame = New("TextButton", {
		Size = UDim2.new(1,0,0,42),
		Parent = Parent,
		BackgroundTransparency = 1,
		Text = "",
	}, {
		New("Frame", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
		}, {
			Creator.NewRoundFrame(Radius, "Squircle", {
				ThemeTag = {
					ImageColor3 = "Accent",
				},
				Size = UDim2.new(1,0,1,0),
				ImageTransparency = .85,
			}),
			Creator.NewRoundFrame(Radius, "SquircleOutline", {
				ThemeTag = {
					ImageColor3 = "Outline",
				},
				Size = UDim2.new(1,0,1,0),
				ImageTransparency = .9,
			}),
			Creator.NewRoundFrame(Radius, "Squircle", {
				Size = UDim2.new(1,0,1,0),
				Name = "Frame",
				ImageColor3 = Color3.new(1,1,1),
				ImageTransparency = .95
			}, {
				New("UIPadding", {
					PaddingLeft = UDim.new(0,12),
					PaddingRight = UDim.new(0,12),
				}),
				New("UIListLayout", {
					FillDirection = "Horizontal",
					Padding = UDim.new(0,8),
					VerticalAlignment = "Center",
					HorizontalAlignment = "Left",
				}),
				IconLabelFrame,
				TextLabel,
			})
		})
	})

	return LabelFrame
end


return Label