local Creator = require("../modules/Creator")
local New = Creator.New

local Element = {}

function Element:New(Config)
	local Button = {
		__type = "Button",
		Title = Config.Title or "Button",
		Desc = Config.Desc or nil,
		Locked = Config.Locked or false,
		Callback = Config.Callback or function() end,
		UIElements = {}
	}

	local CanCallback = true

	Button.ButtonFrame = require("../components/window/Element")({
		Title = Button.Title,
		Desc = Button.Desc,
		Parent = Config.Parent,
		-- Image = Config.Image,
		-- ImageSize = Config.ImageSize,  
		-- Thumbnail = Config.Thumbnail,
		-- ThumbnailSize = Config.ThumbnailSize,
		Window = Config.Window,
		TextOffset = 20,
		Hover = true,
		Scalable = true,
	})

	Button.UIElements.ButtonIcon = New("ImageLabel",{
		Image = Creator.Icon("mouse-pointer-click")[1],
		ImageRectOffset = Creator.Icon("mouse-pointer-click")[2].ImageRectPosition,
		ImageRectSize = Creator.Icon("mouse-pointer-click")[2].ImageRectSize,
		BackgroundTransparency = 1,
		Parent = Button.ButtonFrame.UIElements.Main,
		Size = UDim2.new(0,20,0,20),
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,0,0.5,0),
		ThemeTag = {
			ImageColor3 = "Text"
		}
	})

	function Button:Lock()
		CanCallback = false
		return Button.ButtonFrame:Lock()
	end
	function Button:Unlock()
		CanCallback = true
		return Button.ButtonFrame:Unlock()
	end

	if Button.Locked then
		Button:Lock()
	end

	Creator.AddSignal(Button.ButtonFrame.UIElements.Main.MouseButton1Click, function()
		if CanCallback then
			task.spawn(function()
				Creator.SafeCallback(Button.Callback)
			end)
		end
	end)
	return Button.__type, Button
end

return Element