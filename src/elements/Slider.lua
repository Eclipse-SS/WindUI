local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {}

local HoldingSlider = false

function Element:New(Config)
	local Slider = {
		__type = "Slider",
		Title = Config.Title or "Slider",
		Desc = Config.Desc or nil,
		Locked = Config.Locked or nil,
		Value = Config.Value or {},
		Step = Config.Step or 1,
		Callback = Config.Callback or function() end,
		UIElements = {},
		IsFocusing = false,
	}
	local isTouch
	local moveconnection
	local releaseconnection
	local Value = Slider.Value.Default or Slider.Value.Min or 0

	local LastValue = Value
	local delta = (Value - (Slider.Value.Min or 0)) / ((Slider.Value.Max or 100) - (Slider.Value.Min or 0))

	local CanCallback = true
	local IsFloat = Slider.Step % 1 ~= 0

	local function FormatValue(val)
		if IsFloat then
			return string.format("%.2f", val)
		else
			return tostring(math.floor(val + 0.5))
		end
	end

	local function CalculateValue(rawValue)
		if IsFloat then
			return math.floor(rawValue / Slider.Step + 0.5) * Slider.Step
		else
			return math.floor(rawValue / Slider.Step + 0.5) * Slider.Step
		end
	end

	Slider.SliderFrame = require("../components/window/Element")({
		Title = Slider.Title,
		Desc = Slider.Desc,
		Parent = Config.Parent,
		TextOffset = 0,
		Hover = false,
	})

	Slider.UIElements.SliderIcon = Creator.NewRoundFrame(99, "Squircle", {
		ImageTransparency = .95,
		Size = UDim2.new(1, -60-8, 0, 4),
		Name = "Frame",
		ThemeTag = {
			ImageColor3 = "Text",
		},
	}, {
		Creator.NewRoundFrame(99, "Squircle", {
			Name = "Frame",
			Size = UDim2.new(delta, 0, 1, 0),
			ImageTransparency = .1,
			ThemeTag = {
				ImageColor3 = "Button",
			},
		}, {
			Creator.NewRoundFrame(99, "Squircle", {
				Size = UDim2.new(0, 13, 0, 13),
				Position = UDim2.new(1, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ThemeTag = {
					ImageColor3 = "Text",
				},
			})
		})
	})

	Slider.UIElements.SliderContainer = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = "Y",
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = Slider.SliderFrame.UIElements.Container,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 8),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
		}),
		Slider.UIElements.SliderIcon,
		New("TextBox", {
			Size = UDim2.new(0,60,0,0),
			TextXAlignment = "Left",
			Text = FormatValue(Value),
			ThemeTag = {
				TextColor3 = "Text"
			},
			TextTransparency = .4,
			AutomaticSize = "Y",
			TextSize = 15,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			BackgroundTransparency = 1,
			LayoutOrder = -1,
		})
	})

	function Slider:Lock()
		CanCallback = false
		return Slider.SliderFrame:Lock()
	end
	function Slider:Unlock()
		CanCallback = true
		return Slider.SliderFrame:Unlock()
	end

	if Slider.Locked then
		Slider:Lock()
	end

	function Slider:Set(Value, input)
		if CanCallback then
			if not Slider.IsFocusing and not HoldingSlider and (not input or (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)) then
				Value = math.clamp(Value, Slider.Value.Min or 0, Slider.Value.Max or 100)

				local delta = math.clamp((Value - (Slider.Value.Min or 0)) / ((Slider.Value.Max or 100) - (Slider.Value.Min or 0)), 0, 1)
				Value = CalculateValue(Slider.Value.Min + delta * (Slider.Value.Max - Slider.Value.Min))

				if Value ~= LastValue then
					Tween(Slider.UIElements.SliderIcon.Frame, 0.08, {Size = UDim2.new(delta,0,1,0)}):Play()
					Slider.UIElements.SliderContainer.TextBox.Text = FormatValue(Value)
					Slider.Value.Default = FormatValue(Value)
					LastValue = Value
					Creator.SafeCallback(Slider.Callback, FormatValue(Value))
				end

				if input then
					isTouch = (input.UserInputType == Enum.UserInputType.Touch)
					Slider.SliderFrame.Parent.ScrollingEnabled = false
					HoldingSlider = true
					moveconnection = game:GetService("RunService").RenderStepped:Connect(function()
						local inputPosition = isTouch and input.Position.X or game:GetService("UserInputService"):GetMouseLocation().X
						local delta = math.clamp((inputPosition - Slider.UIElements.SliderIcon.AbsolutePosition.X) / Slider.UIElements.SliderIcon.AbsoluteSize.X, 0, 1)
						Value = CalculateValue(Slider.Value.Min + delta * (Slider.Value.Max - Slider.Value.Min))

						if Value ~= LastValue then
							Tween(Slider.UIElements.SliderIcon.Frame, 0.08, {Size = UDim2.new(delta,0,1,0)}):Play()
							Slider.UIElements.SliderContainer.TextBox.Text = FormatValue(Value)
							Slider.Value.Default = FormatValue(Value)
							LastValue = Value
							Creator.SafeCallback(Slider.Callback, FormatValue(Value))
						end
					end)
					releaseconnection = game:GetService("UserInputService").InputEnded:Connect(function(endInput)
						if (endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch) and input == endInput then
							moveconnection:Disconnect()
							releaseconnection:Disconnect()
							HoldingSlider = false
							Slider.SliderFrame.Parent.ScrollingEnabled = true
						end
					end)
				end
			end
		end
	end

	Creator.AddSignal(Slider.UIElements.SliderContainer.TextBox.FocusLost, function(enterPressed)
		if enterPressed then
			local newValue = tonumber(Slider.UIElements.SliderContainer.TextBox.Text)
			if newValue then
				Slider:Set(newValue)
			else
				Slider.UIElements.SliderContainer.TextBox.Text = FormatValue(LastValue)
			end
		end
	end)

	Creator.AddSignal(Slider.UIElements.SliderContainer.InputBegan, function(input)
		Slider:Set(Value, input)
	end)

	return Slider.__type, Slider
end

return Element