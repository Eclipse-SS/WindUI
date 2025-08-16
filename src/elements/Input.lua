local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {
	UICorner = 8,
	UIPadding = 8,
}


local CreateButton = require("../components/ui/Button").New
local CreateInput = require("../components/ui/Input").New

function Element:New(Config)
	local Input = {
		__type = "Input",
		Title = Config.Title or "Input",
		Desc = Config.Desc or nil,
		Type = Config.Type or "Input", -- Input or Textarea
		Locked = Config.Locked or false,
		InputIcon = Config.InputIcon or false,
		Placeholder = Config.Placeholder or "Enter Text...",
		Value = Config.Value or "",
		Callback = Config.Callback or function() end,
		ClearTextOnFocus = Config.ClearTextOnFocus or false,
		UIElements = {},
	}

	local CanCallback = true

	Input.InputFrame = require("../components/window/Element")({
		Title = Input.Title,
		Desc = Input.Desc,
		Parent = Config.Parent,
		TextOffset = 0,
		Hover = false,
	})

	local InputComponent = CreateInput(Input.Placeholder, Input.InputIcon, Input.InputFrame.UIElements.Container, Input.Type, function(v)
		Input:Set(v)
	end)
	InputComponent.Size = UDim2.new(1,0,0,Input.Type == "Input" and 42 or 42+56+50)

	New("UIScale", {
		Parent = InputComponent,
		Scale = 1,
	})

	function Input:Lock()
		CanCallback = false
		return Input.InputFrame:Lock()
	end
	function Input:Unlock()
		CanCallback = true
		return Input.InputFrame:Unlock()
	end


	function Input:Set(v)
		if CanCallback then
			Creator.SafeCallback(Input.Callback, v)

			InputComponent.Frame.Frame.TextBox.Text = v
			Input.Value = v
		end
	end
	function Input:SetPlaceholder(v)
		InputComponent.Frame.Frame.TextBox.PlaceholderText = v
		Input.Placeholder = v
	end

	Input:Set(Input.Value)

	if Input.Locked then
		Input:Lock()
	end

	return Input.__type, Input
end

return Element