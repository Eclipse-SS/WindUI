local WindUI = {
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	LocalizationModule = require("./modules/Localization"),
	Themes = require("./themes/init"),
	Transparent = false,

	TransparencyValue = .15,

	UIScale = 1,

	ConfigManager = nil,
	Version = "1.6.4"
}

local Themes = WindUI.Themes
local Creator = WindUI.Creator

local New = Creator.New
local Tween = Creator.Tween

Creator.Themes = Themes

local LocalPlayer = game:GetService("Players") and game:GetService("Players").LocalPlayer or nil
WindUI.Themes = Themes

local GUIParent = game.Players.LocalPlayer.PlayerGui

WindUI.ScreenGui = New("ScreenGui", {
	Name = "WindUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
}, {
	New("UIScale", {
		Scale = WindUI.Scale,
	}),
	New("Folder", {
		Name = "Window"
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "Popups"
	}),
	New("Folder", {
		Name = "ToolTips"
	})
})

WindUI.NotificationGui = New("ScreenGui", {
	Name = "WindUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
WindUI.DropdownGui = New("ScreenGui", {
	Name = "WindUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})

Creator.Init(WindUI)

math.clamp(WindUI.TransparencyValue, 0, 1)

local Notify = require("./components/Notification")
local Holder = Notify.Init(WindUI.NotificationGui)

function WindUI:Notify(Config)
	Config.Holder = Holder.Frame
	Config.Window = WindUI.Window
	Config.WindUI = WindUI
	return Notify.New(Config)
end

function WindUI:SetNotificationLower(Val)
	Holder.SetLower(Val)
end

function WindUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function WindUI:AddTheme(LTheme)
	Themes[LTheme.Name] = LTheme
	return LTheme
end

function WindUI:SetTheme(Value)
	if Themes[Value] then
		WindUI.Theme = Themes[Value]
		Creator.SetTheme(Themes[Value])
		--Creator.UpdateTheme()

		return Themes[Value]
	end
	return nil
end

function WindUI:GetThemes()
	return Themes
end
function WindUI:GetCurrentTheme()
	return WindUI.Theme.Name
end
function WindUI:GetTransparency()
	return WindUI.Transparent or false
end
function WindUI:GetWindowSize()
	return Window.UIElements.Main.Size
end
function WindUI:Localization(LocalizationConfig)
	return WindUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function WindUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end


WindUI:SetTheme("Dark")
WindUI:SetLanguage(Creator.Language)


function WindUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)
			table.insert(colorSequence, ColorSequenceKeypoint.new(position, stop.Color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, stop.Transparency or 0))
		end
	end

	table.sort(colorSequence, function(a, b) return a.Time < b.Time end)
	table.sort(transparencySequence, function(a, b) return a.Time < b.Time end)


	if #colorSequence < 2 then
		error("ColorSequence requires at least 2 keypoints")
	end


	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end


function WindUI:Popup(PopupConfig)
	PopupConfig.WindUI = WindUI
	return require("./components/popup/Init").new(PopupConfig)
end


function WindUI:CreateWindow(Config)
	local CreateWindow = require("./components/window/Init")

	Config.WindUI = WindUI
	Config.Parent = WindUI.ScreenGui.Window

	if WindUI.Window then
		warn("You cannot create more than one window")
		return
	end

	local CanLoadWindow = true

	local Theme = Themes[Config.Theme or "Dark"]

	WindUI.Theme = Theme

	Creator.SetTheme(Theme)

	local hwid = function()
		return game:GetService("Players").LocalPlayer.UserId
	end
	local Window = CreateWindow(Config)

	WindUI.Transparent = Config.Transparent
	WindUI.Window = Window


	-- function Window:ToggleTransparency(Value)
	--     WindUI.Transparent = Value
	--     WindUI.Window.Transparent = Value

	--     Window.UIElements.Main.Background.BackgroundTransparency = Value and WindUI.TransparencyValue or 0
	--     Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and WindUI.TransparencyValue or 0
	--     Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
	--         NumberSequenceKeypoint.new(0, 1), 
	--         NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
	--     }
	-- end

	return Window
end

return WindUI