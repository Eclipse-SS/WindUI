local ScrollSlider = {}

local UserInputService = game:GetService("UserInputService")

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween


function ScrollSlider.New(ScrollingFrame, Parent, Window, Thickness)
	local Slider = New("Frame", {
		Size = UDim2.new(0, Thickness, 1,0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		Parent = Parent,
		ZIndex = 999,
		Active = true,
	})

	local Thumb = Creator.NewRoundFrame(Thickness/2, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0),
		ImageTransparency = 0.85,
		ThemeTag = { ImageColor3 = "Text" },
		Parent = Slider,
	})

	local Hitbox = New("Frame", {
		Size = UDim2.new(1, 12, 1, 12),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Active = true,
		ZIndex = 999,
		Parent = Thumb,
	})

	local isDragging = false
	local dragOffset = 0

	local function updateSliderSize()
		local container = ScrollingFrame
		local canvasSize = container.AbsoluteCanvasSize.Y
		local windowSize = container.AbsoluteWindowSize.Y

		if canvasSize <= windowSize then
			Thumb.Visible = false
			return
		end

		local visibleRatio = math.clamp(windowSize / canvasSize, 0.1, 1)
		Thumb.Size = UDim2.new(1, 0, visibleRatio, 0)
		Thumb.Visible = true
	end

	local function updateScrollingFramePosition()        
		local thumbPositionY = Thumb.Position.Y.Scale
		local canvasSize = ScrollingFrame.AbsoluteCanvasSize.Y
		local windowSize = ScrollingFrame.AbsoluteWindowSize.Y
		local maxScroll = math.max(canvasSize - windowSize, 0)

		if maxScroll <= 0 then return end

		local maxThumbPos = math.max(1 - Thumb.Size.Y.Scale, 0)
		if maxThumbPos <= 0 then return end

		local scrollRatio = thumbPositionY / maxThumbPos

		ScrollingFrame.CanvasPosition = Vector2.new(
			ScrollingFrame.CanvasPosition.X,
			scrollRatio * maxScroll
		)
	end

	local function updateThumbPosition()
		if isDragging then return end 

		local canvasPosition = ScrollingFrame.CanvasPosition.Y
		local canvasSize = ScrollingFrame.AbsoluteCanvasSize.Y
		local windowSize = ScrollingFrame.AbsoluteWindowSize.Y
		local maxScroll = math.max(canvasSize - windowSize, 0)

		if maxScroll <= 0 then
			Thumb.Position = UDim2.new(0, 0, 0, 0)
			return
		end

		local scrollRatio = canvasPosition / maxScroll
		local maxThumbPos = math.max(1 - Thumb.Size.Y.Scale, 0)
		local newThumbPosition = math.clamp(scrollRatio * maxThumbPos, 0, maxThumbPos)

		Thumb.Position = UDim2.new(0, 0, newThumbPosition, 0)
	end

	Creator.AddSignal(Slider.InputBegan, function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			local thumbTop = Thumb.AbsolutePosition.Y
			local thumbBottom = thumbTop + Thumb.AbsoluteSize.Y

			if not (input.Position.Y >= thumbTop and input.Position.Y <= thumbBottom) then
				local sliderTop = Slider.AbsolutePosition.Y
				local sliderHeight = Slider.AbsoluteSize.Y
				local thumbHeight = Thumb.AbsoluteSize.Y

				local targetY = input.Position.Y - sliderTop - thumbHeight / 2
				local maxThumbPos = sliderHeight - thumbHeight

				local newThumbPosScale = math.clamp(targetY / maxThumbPos, 0, 1 - Thumb.Size.Y.Scale)

				Thumb.Position = UDim2.new(0, 0, newThumbPosScale, 0)
				updateScrollingFramePosition()
			end
		end
	end)

	Creator.AddSignal(Hitbox.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragOffset = input.Position.Y - Thumb.AbsolutePosition.Y

			local moveConnection
			local releaseConnection

			moveConnection = UserInputService.InputChanged:Connect(function(changedInput)
				if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
					local sliderTop = Slider.AbsolutePosition.Y
					local sliderHeight = Slider.AbsoluteSize.Y
					local thumbHeight = Thumb.AbsoluteSize.Y

					local newY = changedInput.Position.Y - sliderTop - dragOffset
					local maxThumbPos = sliderHeight - thumbHeight

					local newThumbPosScale = math.clamp(newY / maxThumbPos, 0, 1 - Thumb.Size.Y.Scale)

					Thumb.Position = UDim2.new(0, 0, newThumbPosScale, 0)
					updateScrollingFramePosition()
				end
			end)

			releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					isDragging = false
					if moveConnection then moveConnection:Disconnect() end
					if releaseConnection then releaseConnection:Disconnect() end
				end
			end)
		end
	end)

	Creator.AddSignal(ScrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"), function()
		updateSliderSize()
		updateThumbPosition()
	end)

	Creator.AddSignal(ScrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
		updateSliderSize()
		updateThumbPosition()
	end)

	Creator.AddSignal(ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"), function()
		if not isDragging then
			updateThumbPosition()
		end
	end)

	updateSliderSize()
	updateThumbPosition()

	return Slider
end


return ScrollSlider