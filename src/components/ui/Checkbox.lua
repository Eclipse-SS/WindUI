local Checkbox = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween


function Checkbox.New(Value, Icon, Parent, Callback)
	local Checkbox = {}

	Icon = Icon or "check"

	local Radius = 10
	local IconCheckboxFrame = New("ImageLabel", {
		Size = UDim2.new(1,-10,1,-10),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0.5,0,0.5,0),
		Image = Creator.Icon(Icon)[1],
		ImageRectOffset = Creator.Icon(Icon)[2].ImageRectPosition,
		ImageRectSize = Creator.Icon(Icon)[2].ImageRectSize,
		ImageTransparency = 1,
		ImageColor3 = Color3.new(1,1,1),
	})

	local CheckboxFrame = Creator.NewRoundFrame(Radius, "Squircle",{
		ImageTransparency = .95, -- 0
		ThemeTag = {
			ImageColor3 = "Text"
		},
		Parent = Parent,
		Size = UDim2.new(0,27,0,27),
	}, {
		Creator.NewRoundFrame(Radius, "Squircle", {
			Size = UDim2.new(1,0,1,0),
			Name = "Layer",
			ThemeTag = {
				ImageColor3 = "Button",
			},
			ImageTransparency = 1, -- 0
		}),
		Creator.NewRoundFrame(Radius, "SquircleOutline", {
			Size = UDim2.new(1,0,1,0),
			Name = "Stroke",
			ImageColor3 = Color3.new(1,1,1),
			ImageTransparency = 1, -- .95
		}, {
			New("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				})
			})
		}),

		IconCheckboxFrame,
	})

	function Checkbox:Set(Toggled)
		if Toggled then
			Tween(CheckboxFrame.Layer, 0.06, {
				ImageTransparency = 0,
			}):Play()
			Tween(CheckboxFrame.Stroke, 0.06, {
				ImageTransparency = 0.95,
			}):Play()
			Tween(IconCheckboxFrame, 0.06, {
				ImageTransparency = 0,
			}):Play()
		else
			Tween(CheckboxFrame.Layer, 0.05, {
				ImageTransparency = 1,
			}):Play()
			Tween(CheckboxFrame.Stroke, 0.05, {
				ImageTransparency = 1,
			}):Play()
			Tween(IconCheckboxFrame, 0.06, {
				ImageTransparency = 1,
			}):Play()
		end

		task.spawn(function()
			if Callback then
				Creator.SafeCallback(Callback, Toggled)
			end
		end)
	end

	return CheckboxFrame, Checkbox
end


return Checkbox