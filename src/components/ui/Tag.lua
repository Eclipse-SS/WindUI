local Tag = {}


local Creator = require("../../modules/Creator")
local New = Creator.New

local function Color3ToHSB(color)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min

	local h = 0
	if delta ~= 0 then
		if max == r then
			h = (g - b) / delta % 6
		elseif max == g then
			h = (b - r) / delta + 2
		else
			h = (r - g) / delta + 4
		end
		h = h * 60
	else
		h = 0
	end

	local s = (max == 0) and 0 or (delta / max)
	local v = max

	return {
		h = math.floor(h + 0.5),
		s = s,
		b = v
	}
end

local function GetPerceivedBrightness(color)
	local r = color.R
	local g = color.G
	local b = color.B
	return 0.299 * r + 0.587 * g + 0.114 * b
end

local function GetTextColorForHSB(color)
	local hsb = Color3ToHSB(color)
	local h, s, b = hsb.h, hsb.s, hsb.b
	if GetPerceivedBrightness(color) > 0.5 then
		return Color3.fromHSV(h / 360, 0, 0.05)
	else
		return Color3.fromHSV(h / 360, 0, 0.98)
	end
end


function Tag:New(TagConfig, Parent)
	local TagModule = {
		Title = TagConfig.Title or "Tag",
		Color = TagConfig.Color or Color3.fromHex("#315dff"),

		TagFrame = nil,
		Height = 30,
		Padding = 12,
		TextSize = 16,
	}

	local TagTitle = New("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = "XY",
		TextSize = TagModule.TextSize,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		Text = TagModule.Title,
		TextColor3 = GetTextColorForHSB(TagModule.Color)
	})

	local TagFrame = Creator.NewRoundFrame(999, "Squircle", {
		AutomaticSize = "X",
		Size = UDim2.new(0,0,0,TagModule.Height),
		Parent = Parent,
		ImageColor3 = TagModule.Color,
	}, {
		New("UIPadding", {
			PaddingLeft = UDim.new(0,TagModule.Padding),
			PaddingRight = UDim.new(0,TagModule.Padding),
		}),
		TagTitle,
		New("UIListLayout", {
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
		})
	})


	return TagModule
end


return Tag