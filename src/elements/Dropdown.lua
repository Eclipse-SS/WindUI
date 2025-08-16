local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local CreateLabel = require("../components/ui/Label").New

local Element = {
	UICorner = 10,
	UIPadding = 12,
	MenuCorner = 15,
	MenuPadding = 5,
	TabPadding = 10,
}

function Element:New(Config)
	local Dropdown = {
		__type = "Dropdown",
		Title = Config.Title or "Dropdown",
		Desc = Config.Desc or nil,
		Locked = Config.Locked or false,
		Values = Config.Values or {},
		MenuWidth = Config.MenuWidth or 170,
		Value = Config.Value,
		AllowNone = Config.AllowNone,
		Multi = Config.Multi,
		Callback = Config.Callback or function() end,

		UIElements = {},

		Opened = false,
		Tabs = {}
	}

	if Dropdown.Multi and not Dropdown.Value then
		Dropdown.Value = {}
	end

	local CanCallback = true

	Dropdown.DropdownFrame = require("../components/window/Element")({
		Title = Dropdown.Title,
		Desc = Dropdown.Desc,
		Parent = Config.Parent,
		TextOffset = 0,
		Hover = false,
	})


	Dropdown.UIElements.Dropdown = CreateLabel("", nil, Dropdown.DropdownFrame.UIElements.Container)

	Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.TextTruncate = "AtEnd"
	Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size = UDim2.new(1, Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size.X.Offset - 18 - 12 - 12,0,0)

	Dropdown.UIElements.Dropdown.Size = UDim2.new(1,0,0,40)

	-- New("UIScale", {
	--     Parent = Dropdown.UIElements.Dropdown,
	--     Scale = .85,
	-- })

	local DropdownIcon = New("ImageLabel", {
		Image = Creator.Icon("chevrons-up-down")[1],
		ImageRectOffset = Creator.Icon("chevrons-up-down")[2].ImageRectPosition,
		ImageRectSize = Creator.Icon("chevrons-up-down")[2].ImageRectSize,
		Size = UDim2.new(0,18,0,18),
		Position = UDim2.new(1,-12,0.5,0),
		ThemeTag = {
			ImageColor3 = "Icon"
		},
		AnchorPoint = Vector2.new(1,0.5),
		Parent = Dropdown.UIElements.Dropdown.Frame
	})

	Dropdown.UIElements.UIListLayout = New("UIListLayout", {
		Padding = UDim.new(0,Element.MenuPadding),
		FillDirection = "Vertical"
	})

	Dropdown.UIElements.Menu = Creator.NewRoundFrame(Element.MenuCorner, "Squircle", {
		ThemeTag = {
			ImageColor3 = "Background",
		},
		ImageTransparency = 0.05,
		Size = UDim2.new(1,0,1,0),
		AnchorPoint = Vector2.new(1,0),
		Position = UDim2.new(1,0,0,0),
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, Element.MenuPadding),
			PaddingLeft = UDim.new(0, Element.MenuPadding),
			PaddingRight = UDim.new(0, Element.MenuPadding),
			PaddingBottom = UDim.new(0, Element.MenuPadding),
		}),
		New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			--Name = "CanvasGroup",
			ClipsDescendants = true
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0,Element.MenuCorner - Element.MenuPadding),
			}),
			New("ScrollingFrame", {
				Size = UDim2.new(1,0,1,0),
				ScrollBarThickness = 0,
				ScrollingDirection = "Y",
				AutomaticCanvasSize = "Y",
				CanvasSize = UDim2.new(0,0,0,0),
				BackgroundTransparency = 1,
				ScrollBarImageTransparency = 1,
			}, {
				Dropdown.UIElements.UIListLayout,
			})
		})
	})

	Dropdown.UIElements.MenuCanvas = New("Frame", {
		Size = UDim2.new(0,Dropdown.MenuWidth,0,300),
		BackgroundTransparency = 1,
		Position = UDim2.new(-10,0,-10,0),
		Visible = false,
		Active = false,
		--GroupTransparency = 1, -- 0
		Parent = Config.WindUI.DropdownGui,
		AnchorPoint = Vector2.new(1,0),
	}, {
		Dropdown.UIElements.Menu,
		-- New("UIPadding", {
		--     PaddingTop = UDim.new(0,1),
		--     PaddingLeft = UDim.new(0,1),
		--     PaddingRight = UDim.new(0,1),
		--     PaddingBottom = UDim.new(0,1),
		-- }),
		New("UISizeConstraint", {
			MinSize = Vector2.new(170,0)
		})
	})

	function Dropdown:Lock()
		CanCallback = false
		return Dropdown.DropdownFrame:Lock()
	end
	function Dropdown:Unlock()
		CanCallback = true
		return Dropdown.DropdownFrame:Unlock()
	end

	if Dropdown.Locked then
		Dropdown:Lock()
	end

	local function RecalculateCanvasSize()
		Dropdown.UIElements.Menu.Frame.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, Dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y)
	end

	local function RecalculateListSize()
		if #Dropdown.Values > 10 then
			Dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(Dropdown.UIElements.MenuCanvas.AbsoluteSize.X, 392)
		else
			Dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(Dropdown.UIElements.MenuCanvas.AbsoluteSize.X, Dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y + (Element.MenuPadding*2))
		end
	end

	function UpdatePosition()
		local button = Dropdown.UIElements.Dropdown
		local menu = Dropdown.UIElements.MenuCanvas

		local availableSpaceBelow = Camera.ViewportSize.Y - (button.AbsolutePosition.Y + button.AbsoluteSize.Y) - Element.MenuPadding - 54
		local requiredSpace = menu.AbsoluteSize.Y + Element.MenuPadding

		local offset = -54 -- topbar offset
		if availableSpaceBelow < requiredSpace then
			offset = requiredSpace - availableSpaceBelow - 54
		end

		menu.Position = UDim2.new(
			0, 
			button.AbsolutePosition.X + button.AbsoluteSize.X,
			0, 
			button.AbsolutePosition.Y + button.AbsoluteSize.Y - offset + Element.MenuPadding 
		)
	end



	function Dropdown:Display()
		local Values = Dropdown.Values
		local Str = ""

		if Dropdown.Multi then
			for Idx, Value in next, Values do
				if table.find(Dropdown.Value, Value) then
					Str = Str .. Value .. ", "
				end
			end
			Str = Str:sub(1, #Str - 2)
		else
			Str = Dropdown.Value or ""
		end

		Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Text = (Str == "" and "--" or Str)
	end

	function Dropdown:Refresh(Values)
		for _, Elementt in next, Dropdown.UIElements.Menu.Frame.ScrollingFrame:GetChildren() do
			if not Elementt:IsA("UIListLayout") then
				Elementt:Destroy()
			end
		end

		Dropdown.Tabs = {}

		for Index,Tab in next, Values do
			--task.wait(0.012)
			local TabMain = {
				Name = Tab,
				Selected = false,
				UIElements = {},
			}
			TabMain.UIElements.TabItem = Creator.NewRoundFrame(Element.MenuCorner - Element.MenuPadding, "Squircle", {
				Size = UDim2.new(1,0,0,34),
				--AutomaticSize = "Y",
				ImageTransparency = 1, -- .95
				Parent = Dropdown.UIElements.Menu.Frame.ScrollingFrame,
				--Text = "",
				ImageColor3 = Color3.new(1,1,1),

			}, {
				Creator.NewRoundFrame(Element.MenuCorner - Element.MenuPadding, "SquircleOutline", {
					Size = UDim2.new(1,0,1,0),
					ImageColor3 = Color3.new(1,1,1),
					ImageTransparency = 1, -- .75
					Name = "Highlight",
				}, {
					New("UIGradient", {
						Rotation = 80,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
							ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
						}),
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0.0, 0.1),
							NumberSequenceKeypoint.new(0.5, 1),
							NumberSequenceKeypoint.new(1.0, 0.1),
						})
					}),
				}),
				New("Frame", {
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
				}, {
					New("UIPadding", {
						--PaddingTop = UDim.new(0,Element.TabPadding),
						PaddingLeft = UDim.new(0,Element.TabPadding),
						PaddingRight = UDim.new(0,Element.TabPadding),
						--PaddingBottom = UDim.new(0,Element.TabPadding),
					}),
					New("UICorner", {
						CornerRadius = UDim.new(0,Element.MenuCorner - Element.MenuPadding)
					}),
					-- New("ImageLabel", {
					--     Image = Creator.Icon("check")[1],
					--     ImageRectSize = Creator.Icon("check")[2].ImageRectSize,
					--     ImageRectOffset = Creator.Icon("check")[2].ImageRectPosition,
					--     ThemeTag = {
					--         ImageColor3 = "Text",
					--     },
					--     ImageTransparency = 1, -- .1
					--     Size = UDim2.new(0,18,0,18),
					--     AnchorPoint = Vector2.new(0,0.5),
					--     Position = UDim2.new(0,0,0.5,0),
					--     BackgroundTransparency = 1,
					-- }),
					New("TextLabel", {
						Text = Tab,
						TextXAlignment = "Left",
						FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
						ThemeTag = {
							TextColor3 = "Text",
							BackgroundColor3 = "Text"
						},
						TextSize = 15,
						BackgroundTransparency = 1,
						TextTransparency = .4,
						AutomaticSize = "Y",
						--TextTruncate = "AtEnd",
						Size = UDim2.new(1,0,0,0),
						AnchorPoint = Vector2.new(0,0.5),
						Position = UDim2.new(0,0,0.5,0), -- 0,18+Element.TabPadding,0.5,0
					})
				})
			}, true)


			if Dropdown.Multi then
				TabMain.Selected = table.find(Dropdown.Value or {}, TabMain.Name)
			else
				TabMain.Selected = Dropdown.Value == TabMain.Name
			end

			if TabMain.Selected then
				TabMain.UIElements.TabItem.ImageTransparency = .95
				TabMain.UIElements.TabItem.Highlight.ImageTransparency = .75
				--TabMain.UIElements.TabItem.ImageLabel.ImageTransparency = .1
				--TabMain.UIElements.TabItem.TextLabel.Position = UDim2.new(0,18+Element.TabPadding+2,0.5,0)
				TabMain.UIElements.TabItem.Frame.TextLabel.TextTransparency = 0.05
			end

			Dropdown.Tabs[Index] = TabMain

			Dropdown:Display()

			local function Callback()
				Dropdown:Display()
				task.spawn(function()
					Creator.SafeCallback(Dropdown.Callback, Dropdown.Value)
				end)
			end

			Creator.AddSignal(TabMain.UIElements.TabItem.MouseButton1Click, function()
				if Dropdown.Multi then
					if not TabMain.Selected then
						TabMain.Selected = true
						Tween(TabMain.UIElements.TabItem, 0.1, {ImageTransparency = .95}):Play()
						Tween(TabMain.UIElements.TabItem.Highlight, 0.1, {ImageTransparency = .75}):Play()
						--Tween(TabMain.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = .1}):Play()
						Tween(TabMain.UIElements.TabItem.Frame.TextLabel, 0.1, {TextTransparency = 0}):Play()
						table.insert(Dropdown.Value, TabMain.Name)
					else
						if not Dropdown.AllowNone and #Dropdown.Value == 1 then
							return
						end
						TabMain.Selected = false
						Tween(TabMain.UIElements.TabItem, 0.1, {ImageTransparency = 1}):Play()
						Tween(TabMain.UIElements.TabItem.Highlight, 0.1, {ImageTransparency = 1}):Play()
						--Tween(TabMain.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 1}):Play()
						Tween(TabMain.UIElements.TabItem.Frame.TextLabel, 0.1, {TextTransparency = .4}):Play()
						for i, v in ipairs(Dropdown.Value) do
							if v == TabMain.Name then
								table.remove(Dropdown.Value, i)
								break
							end
						end
					end
				else
					for Index, TabPisun in next, Dropdown.Tabs do
						-- pisun
						Tween(TabPisun.UIElements.TabItem, 0.1, {ImageTransparency = 1}):Play()
						Tween(TabPisun.UIElements.TabItem.Highlight, 0.1, {ImageTransparency = 1}):Play()
						--Tween(TabPisun.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 1}):Play()
						Tween(TabPisun.UIElements.TabItem.Frame.TextLabel, 0.1, {TextTransparency = .5}):Play()
						TabPisun.Selected = false
					end
					TabMain.Selected = true
					Tween(TabMain.UIElements.TabItem, 0.1, {ImageTransparency = .95}):Play()
					Tween(TabMain.UIElements.TabItem.Highlight, 0.1, {ImageTransparency = .75}):Play()
					--Tween(TabMain.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = .1}):Play()
					Tween(TabMain.UIElements.TabItem.Frame.TextLabel, 0.1, {TextTransparency = 0.05}):Play()
					Dropdown.Value = TabMain.Name
				end
				Callback()
			end)

			RecalculateCanvasSize()
			RecalculateListSize()
		end

		local maxWidth = 0
		for _, tabmain in next, Dropdown.Tabs do
			if tabmain.UIElements.TabItem.Frame.TextLabel then
				--local width = getTextWidth(tabmain.UIElements.TabItem.TextLabel.Text, tabmain.UIElements.TabItem.TextLabel.Font, tabmain.UIElements.TabItem.TextLabel.TextSize)
				local width = tabmain.UIElements.TabItem.Frame.TextLabel.TextBounds.X
				maxWidth = math.max(maxWidth, width)
			end
		end

		Dropdown.UIElements.MenuCanvas.Size = UDim2.new(0, maxWidth + 6 + 6 + 5 + 5 + 18 + 6 + 6, Dropdown.UIElements.MenuCanvas.Size.Y.Scale, Dropdown.UIElements.MenuCanvas.Size.Y.Offset)

	end


	Dropdown:Refresh(Dropdown.Values)

	function Dropdown:Select(Items)
		if Items then
			Dropdown.Value = Items
		else
			if Dropdown.Multi then
				Dropdown.Value = {}
			else
				Dropdown.Value = nil

			end
		end
		Dropdown:Refresh(Dropdown.Values)
	end

	--Dropdown:Display()
	RecalculateListSize()

	function Dropdown:Open()
		if CanCallback then
			Dropdown.UIElements.Menu.Visible = true
			Dropdown.UIElements.MenuCanvas.Visible = true
			Dropdown.UIElements.MenuCanvas.Active = true
			Dropdown.UIElements.Menu.Size = UDim2.new(
				1, 0,
				0, 0
			)
			Tween(Dropdown.UIElements.Menu, 0.1, {
				Size = UDim2.new(
					1, 0,
					1, 0
				)
			}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()

			task.spawn(function()
				task.wait(.1)
				Dropdown.Opened = true
			end)

			--Tween(DropdownIcon, .15, {Rotation = 180}):Play()
			--Tween(Dropdown.UIElements.MenuCanvas, .15, {GroupTransparency = 0}):Play()

			UpdatePosition()
		end
	end
	function Dropdown:Close()
		Dropdown.Opened = false

		Tween(Dropdown.UIElements.Menu, 0.25, {
			Size = UDim2.new(
				1, 0,
				0, 0
			)
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
		--Tween(DropdownIcon, .15, {Rotation = 0}):Play()
		--Tween(Dropdown.UIElements.MenuCanvas, .15, {GroupTransparency = 1}):Play()
		task.spawn(function()
			task.wait(.2)
			Dropdown.UIElements.Menu.Visible = false
		end)

		task.spawn(function()
			task.wait(.25)
			Dropdown.UIElements.MenuCanvas.Visible = false
			Dropdown.UIElements.MenuCanvas.Active = false
		end)
	end

	Creator.AddSignal(Dropdown.UIElements.Dropdown.MouseButton1Click, function()
		Dropdown:Open()
	end)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			local AbsPos, AbsSize = Dropdown.UIElements.MenuCanvas.AbsolutePosition, Dropdown.UIElements.MenuCanvas.AbsoluteSize
			if
				Config.Window.CanDropdown
				and Dropdown.Opened
				and (Mouse.X < AbsPos.X
					or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < (AbsPos.Y - 20 - 1)
					or Mouse.Y > AbsPos.Y + AbsSize.Y
				)
			then
				Dropdown:Close()
			end
		end
	end)

	Creator.AddSignal(Dropdown.UIElements.Dropdown:GetPropertyChangedSignal("AbsolutePosition"), UpdatePosition)

	return Dropdown.__type, Dropdown
end

return Element