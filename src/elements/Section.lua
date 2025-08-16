local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {}

function Element:New(Config)
	local Section = {
		__type = "Section",
		Title = Config.Title or "Section",
		Icon = Config.Icon,
		TextXAlignment = Config.TextXAlignment or "Left",
		TextSize = Config.TextSize or 19,
		UIElements = {},
	}

	local Icon
	if Section.Icon then
		Icon = Creator.Image(
			Section.Icon,
			Section.Icon .. ":" .. Section.Title,
			0,
			Config.Window.Folder,
			Section.__type,
			true
		)
		Icon.Size = UDim2.new(0,24,0,24)
	end

	Section.UIElements.Main = New("TextLabel", {
		BackgroundTransparency = 1,
		TextXAlignment = "Left",
		AutomaticSize = "XY",
		TextSize = Section.TextSize,
		ThemeTag = {
			TextColor3 = "Text",
		},
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		--Parent = Config.Parent,
		--Size = UDim2.new(1,0,0,0),
		Text = Section.Title,
	})

	local Main = New("Frame", {
		Size = UDim2.new(1,0,0,0),
		BackgroundTransparency = 1,
		AutomaticSize = "Y",
		Parent = Config.Parent,
	}, {
		Icon,
		Section.UIElements.Main,
		New("UIListLayout", {
			Padding = UDim.new(0,8),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
			HorizontalAlignment = Section.TextXAlignment,
		}),
		New("UIPadding", {
			PaddingTop = UDim.new(0,4),
			PaddingBottom = UDim.new(0,2),
		})
	})

	-- Section.UIElements.Main:GetPropertyChangedSignal("TextBounds"):Connect(function()
	--     Section.UIElements.Main.Size = UDim2.new(1,0,0,Section.UIElements.Main.TextBounds.Y)
	-- end)

	function Section:SetTitle(Title)
		Section.UIElements.Main.Text = Title
	end
	function Section:Destroy()
		Section.UIElements.Main.AutomaticSize = "None"
		Section.UIElements.Main.Size = UDim2.new(1,0,0,Section.UIElements.Main.TextBounds.Y)

		Tween(Section.UIElements.Main, .1, {TextTransparency = 1}):Play()
		task.wait(.1)
		Tween(Section.UIElements.Main, .15, {Size = UDim2.new(1,0,0,0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
	end

	return Section.__type, Section
end

return Element