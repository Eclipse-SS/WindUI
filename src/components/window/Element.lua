local Creator = require("../../modules/Creator")
local New = Creator.New
local NewRoundFrame = Creator.NewRoundFrame
local Tween = Creator.Tween

local UserInputService = game:GetService("UserInputService")


return function(Config)
	local Element = {
		Title = Config.Title,
		Desc = Config.Desc or nil,
		Hover = Config.Hover,
		Thumbnail = Config.Thumbnail,
		ThumbnailSize = Config.ThumbnailSize or 80,
		Image = Config.Image,
		IconThemed = Config.IconThemed or false,
		ImageSize = Config.ImageSize or 30,
		Color = Config.Color,
		Scalable = Config.Scalable,
		Parent = Config.Parent,
		UIPadding = 14,
		UICorner = 14,
		UIElements = {}
	}

	local ImageSize = Element.ImageSize
	local ThumbnailSize = Element.ThumbnailSize
	local CanHover = true
	local Hovering = false

	local IconOffset = 0

	local ThumbnailFrame
	local ImageFrame
	if Element.Thumbnail then
		ThumbnailFrame = Creator.Image(
			Element.Thumbnail, 
			Element.Title, 
			Element.UICorner-3, 
			Config.Window.Folder,
			"Thumbnail",
			false,
			Element.IconThemed
		)
		ThumbnailFrame.Size = UDim2.new(1,0,0,ThumbnailSize)
	end
	if Element.Image then
		ImageFrame = Creator.Image(
			Element.Image, 
			Element.Title, 
			Element.UICorner-3, 
			Config.Window.Folder,
			"Image",
			Element.Color and true or false
		)
		if Element.Color == "White" then
			ImageFrame.ImageLabel.ImageColor3 = Color3.new(0,0,0)
		elseif Element.Color then
			ImageFrame.ImageLabel.ImageColor3 = Color3.new(1,1,1)
		end
		ImageFrame.Size = UDim2.new(0,ImageSize,0,ImageSize)

		IconOffset = ImageSize
	end

	local function CreateText(Title, Type)
		return New("TextLabel", {
			BackgroundTransparency = 1,
			Text = Title or "",
			TextSize = Type == "Desc" and 15 or 17,
			TextXAlignment = "Left",
			ThemeTag = {
				TextColor3 = not Element.Color and (Type == "Desc" and "Icon" or "Text") or nil,
			},
			TextColor3 = Element.Color and (Element.Color == "White" and Color3.new(0,0,0) or Element.Color ~= "White" and Color3.new(1,1,1)) or nil,
			TextTransparency = Element.Color and (Type == "Desc" and .3 or 0),
			TextWrapped = true,
			Size = UDim2.new(1,0,0,0),
			AutomaticSize = "Y",
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium)
		})
	end

	local Title = CreateText(Element.Title, "Title")
	local Desc = CreateText(Element.Desc, "Desc")
	if not Element.Desc or Element.Desc == "" then
		Desc.Visible = false
	end

	Element.UIElements.Container = New("Frame", {
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0,Element.UIPadding),
			FillDirection = "Vertical",
			VerticalAlignment = "Top",
			HorizontalAlignment = "Left",
		}),
		ThumbnailFrame,
		New("Frame", {
			Size = UDim2.new(1,-Config.TextOffset,0,0),
			AutomaticSize = "Y",
			BackgroundTransparency = 1,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0,Element.UIPadding),
				FillDirection = "Horizontal",
				VerticalAlignment = "Top",
				HorizontalAlignment = "Left",
			}),
			ImageFrame,
			New("Frame", {
				BackgroundTransparency = 1,
				AutomaticSize = "Y",
				Size = UDim2.new(1,-IconOffset,0,(50-(Element.UIPadding*2)))
			}, {
				New("UIListLayout", {
					Padding = UDim.new(0,4),
					FillDirection = "Vertical",
					VerticalAlignment = "Center",
					HorizontalAlignment = "Left",
				}),
				Title,
				Desc
			}),
		})
	})

	Element.UIElements.Locked = NewRoundFrame(Element.UICorner, "Squircle", {
		Size = UDim2.new(1,Element.UIPadding*2,1,Element.UIPadding*2),
		ImageTransparency = .4,
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0.5,0,0.5,0),
		ImageColor3 = Color3.new(0,0,0),
		Visible = false,
		Active = false,
		ZIndex = 9999999,
	})

	Element.UIElements.Main = NewRoundFrame(Element.UICorner, "Squircle", {
		Size = UDim2.new(1,0,0,50),
		AutomaticSize = "Y",
		ImageTransparency = Element.Color and .1 or .95,
		--Text = "",
		--TextTransparency = 1,
		--AutoButtonColor = false,
		Parent = Config.Parent,
		ThemeTag = {
			ImageColor3 = not Element.Color and "Text" or nil
		},
		ImageColor3 = Element.Color and Color3.fromHex(Creator.Colors[Element.Color]) or nil
	}, {
		Element.UIElements.Container,
		Element.UIElements.Locked,
		New("UIPadding", {
			PaddingTop = UDim.new(0,Element.UIPadding),
			PaddingLeft = UDim.new(0,Element.UIPadding),
			PaddingRight = UDim.new(0,Element.UIPadding),
			PaddingBottom = UDim.new(0,Element.UIPadding),
		}),
	}, true)

	if Element.Hover then
		Creator.AddSignal(Element.UIElements.Main.MouseEnter, function()
			if CanHover then
				Tween(Element.UIElements.Main, .05, {ImageTransparency = Element.Color and .15 or .9}):Play()
			end
		end)
		Creator.AddSignal(Element.UIElements.Main.InputEnded, function()
			if CanHover then
				Tween(Element.UIElements.Main, .05, {ImageTransparency = Element.Color and .1 or .95}):Play()
			end
		end)
	end

	function Element:SetTitle(text)
		Title.Text = text
	end

	function Element:SetDesc(text)
		Desc.Text = text or ""
		if not text then
			Desc.Visible = false
		elseif not Desc.Visible then
			Desc.Visible = true
		end
	end


	-- function Element:Show()

	-- end

	function Element:Destroy()
		Element.UIElements.Main:Destroy()
	end


	function Element:Lock()
		CanHover = false
		Element.UIElements.Locked.Active = true
		Element.UIElements.Locked.Visible = true
	end

	function Element:Unlock()
		CanHover = true
		Element.UIElements.Locked.Active = false
		Element.UIElements.Locked.Visible = false
	end

	--task.wait(.015)

	--Element:Show()

	return Element
end