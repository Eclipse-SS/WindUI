--[[

Credits: dawid 

]]

local RunService = game:GetService("RunService")
local RenderStepped = RunService.Heartbeat
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalizationService = game:GetService("LocalizationService")

local Icons = require("../icons/init")
Icons.SetIconsType("lucide")

local Creator = {
	Font = "rbxassetid://12187365364", -- Inter
	Localization = nil,
	CanDraggable = true,
	Theme = nil,
	Themes = nil,
	WindUI = nil,
	Signals = {},
	Objects = {},
	LocalizationObjects = {},
	FontObjects = {},
	Language = string.match(LocalizationService.SystemLocaleId , "^[a-z]+"),
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling",
		},
		CanvasGroup = {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1,1,1),
		},
		Frame = {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1,1,1),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1,1,1),
			BorderSizePixel = 0,
			Text = "",
			RichText = true,
			TextColor3 = Color3.new(1,1,1),
			TextSize = 14,
		}, TextButton = {
			BackgroundColor3 = Color3.new(1,1,1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor= false,
			TextColor3 = Color3.new(1,1,1),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			AutoButtonColor = false,
		},
		UIListLayout = {
			SortOrder = "LayoutOrder",
		},
		ScrollingFrame = {
			ScrollBarImageTransparency = 1,
			BorderSizePixel = 0,
		},
		VideoFrame = {
			BorderSizePixel = 0,
		}
	},
	Colors = {
		Red = "#e53935",    -- Danger
		Orange = "#f57c00", -- Warning
		Green = "#43a047",  -- Success
		Blue = "#039be5",   -- Info
		White = "#ffffff",   -- White
		Grey = "#484848",   -- Grey
	},
}



function Creator.Init(WindUI)
	Creator.WindUI = WindUI
end


function Creator.AddSignal(Signal, Function)
	table.insert(Creator.Signals, Signal:Connect(Function))
end

function Creator.DisconnectAll()
	for idx, signal in next, Creator.Signals do
		local Connection = table.remove(Creator.Signals, idx)
		Connection:Disconnect()
	end
end

-- ↓ Debug mode
function Creator.SafeCallback(Function, ...)
	if not Function then
		return
	end

	local Success, Event = pcall(Function, ...)
	if not Success then
		local _, i = Event:find(":%d+: ")


		warn("[ WindUI: DEBUG Mode ] " .. Event)

		return Creator.WindUI:Notify({
			Title = "DEBUG Mode: Error",
			Content = not i and Event or Event:sub(i + 1),
			Duration = 8,
		})
	end
end

function Creator.SetTheme(Theme)
	Creator.Theme = Theme
	Creator.UpdateTheme(nil, true)
end

function Creator.AddFontObject(Object)
	table.insert(Creator.FontObjects, Object)
	Creator.UpdateFont(Creator.Font)
end

function Creator.UpdateFont(FontId)
	Creator.Font = FontId
	for _,Obj in next, Creator.FontObjects do
		Obj.FontFace = Font.new(FontId, Obj.FontFace.Weight, Obj.FontFace.Style)
	end
end

function Creator.GetThemeProperty(Property, Theme)
	return Theme[Property] or Creator.Themes["Dark"][Property]
end

function Creator.AddThemeObject(Object, Properties)
	Creator.Objects[Object] = { Object = Object, Properties = Properties }
	Creator.UpdateTheme(Object, false)
	return Object
end
function Creator.AddLangObject(idx)
	local currentObj = Creator.LocalizationObjects[idx]
	local Object = currentObj.Object
	local TranslationId = currentObjTranslationId
	Creator.UpdateLang(Object, TranslationId)
	return Object
end

function Creator.UpdateTheme(TargetObject, isTween)
	local function ApplyTheme(objData)
		for Property, ColorKey in pairs(objData.Properties or {}) do
			local Color = Creator.GetThemeProperty(ColorKey, Creator.Theme)
			if Color then
				if not isTween then
					objData.Object[Property] = Color3.fromHex(Color)
				else
					Creator.Tween(objData.Object, 0.08, { [Property] = Color3.fromHex(Color) }):Play()
				end
			end
		end
	end

	if TargetObject then
		local objData = Creator.Objects[TargetObject]
		if objData then
			ApplyTheme(objData)
		end
	else
		for _, objData in pairs(Creator.Objects) do
			ApplyTheme(objData)
		end
	end
end

function Creator.SetLangForObject(index)
	if Creator.Localization and Creator.Localization.Enabled then
		local data = Creator.LocalizationObjects[index]
		if not data then return end

		local obj = data.Object
		local translationId = data.TranslationId

		local translations = Creator.Localization.Translations[Creator.Language]
		if translations and translations[translationId] then
			obj.Text = translations[translationId]
		else
			local enTranslations = Creator.Localization and Creator.Localization.Translations and Creator.Localization.Translations.en or nil
			if enTranslations and enTranslations[translationId] then
				obj.Text = enTranslations[translationId]
			else
				obj.Text = "[" .. translationId .. "]"
			end
		end
	end
end


function Creator:ChangeTranslationKey(object, newKey)
	if Creator.Localization then
		local ParsedKey = string.match(newKey, "^" .. Creator.Localization.Prefix .. "(.+)")
		for i, data in ipairs(Creator.LocalizationObjects) do
			if data.Object == object then
				data.TranslationId = ParsedKey
				Creator.SetLangForObject(i)
				return
			end
		end

		table.insert(Creator.LocalizationObjects, {
			TranslationId = ParsedKey,
			Object = object
		})
		Creator.SetLangForObject(#Creator.LocalizationObjects)
	end
end


function Creator.UpdateLang(newLang)
	if newLang then
		Creator.Language = newLang
	end

	for i = 1, #Creator.LocalizationObjects do
		local data = Creator.LocalizationObjects[i]
		if data.Object and data.Object.Parent ~= nil then
			Creator.SetLangForObject(i)
		else
			Creator.LocalizationObjects[i] = nil
		end
	end
end

function Creator.SetLanguage(lang)
	Creator.Language = lang
	Creator.UpdateLang()
end

function Creator.Icon(Icon)
	return Icons.Icon(Icon)
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" then
			Object[Name] = Value
		end
		if Creator.Localization and Creator.Localization.Enabled and Name == "Text" then
			local TranslationId = string.match(Value, "^" .. Creator.Localization.Prefix .. "(.+)")
			if TranslationId then
				local currentId = #Creator.LocalizationObjects + 1
				Creator.LocalizationObjects[currentId] = { TranslationId = TranslationId, Object = Object }

				Creator.SetLangForObject(currentId)
			end
		end
	end

	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	if Properties and Properties.ThemeTag then
		Creator.AddThemeObject(Object, Properties.ThemeTag)
	end
	if Properties and Properties.FontFace then
		Creator.AddFontObject(Object)
	end
	return Object
end

function Creator.Tween(Object, Time, Properties, ...)
	return TweenService:Create(Object, TweenInfo.new(Time, ...), Properties)
end

function Creator.NewRoundFrame(Radius, Type, Properties, Children, isButton)
	-- local ThemeTags = {}
	-- if Properties.ThemeTag then
	--     for k, v in next, Properties.ThemeTag do
	--         ThemeTags[k] = v
	--     end
	-- end
	local Image = Creator.New(isButton and "ImageButton" or "ImageLabel", {
		Image = Type == "Squircle" and "rbxassetid://80999662900595"
			or Type == "SquircleOutline" and "rbxassetid://117788349049947" 
			or Type == "SquircleOutline2" and "rbxassetid://117817408534198" 
			or Type == "Shadow-sm" and "rbxassetid://84825982946844"
			or Type == "Squircle-TL-TR" and "rbxassetid://73569156276236",
		ScaleType = "Slice",
		SliceCenter = Type ~= "Shadow-sm" and Rect.new(
			512/2,
			512/2,
			512/2,
			512/2
		) or Rect.new(512,512,512,512),
		SliceScale = 1,
		BackgroundTransparency = 1,
		ThemeTag = Properties.ThemeTag
	}, Children)

	for k, v in pairs(Properties or {}) do
		if k ~= "ThemeTag" then
			Image[k] = v
		end
	end

	local function UpdateSliceScale(newRadius)
		local sliceScale = Type ~= "Shadow-sm" and (newRadius / (512/2)) or (newRadius/512)
		Image.SliceScale = sliceScale
	end

	UpdateSliceScale(Radius)

	return Image
end

local New = Creator.New
local Tween = Creator.Tween

function Creator.SetDraggable(can)
	Creator.CanDraggable = can
end

function Creator.Drag(mainFrame, dragFrames, ondrag)
	local currentDragFrame = nil
	local dragging, dragInput, dragStart, startPos
	local DragModule = {
		CanDraggable = true
	}

	if not dragFrames or type(dragFrames) ~= "table" then
		dragFrames = {mainFrame}
	end

	local function update(input)
		local delta = input.Position - dragStart
		Creator.Tween(mainFrame, 0.02, {Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)}):Play()
	end

	for _, dragFrame in pairs(dragFrames) do
		dragFrame.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and DragModule.CanDraggable then
				if currentDragFrame == nil then
					currentDragFrame = dragFrame
					dragging = true
					dragStart = input.Position
					startPos = mainFrame.Position

					if ondrag and type(ondrag) == "function" then 
						ondrag(true, currentDragFrame)
					end

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							currentDragFrame = nil

							if ondrag and type(ondrag) == "function" then 
								ondrag(false, currentDragFrame)
							end
						end
					end)
				end
			end
		end)

		dragFrame.InputChanged:Connect(function(input)
			if currentDragFrame == dragFrame and dragging then
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and currentDragFrame ~= nil then
			if DragModule.CanDraggable then 
				update(input)
			end
		end
	end)

	function DragModule:Set(v)
		DragModule.CanDraggable = v
	end

	return DragModule
end

function Creator.Image(Img, Name, Corner, Folder, Type, IsThemeTag, Themed)
	local function SanitizeFilename(str)
		str = str:gsub("[%s/\\:*?\"<>|]+", "-")
		str = str:gsub("[^%w%-_%.]", "")
		return str
	end

	Folder = Folder or "Temp"
	Name = SanitizeFilename(Name)

	local ImageFrame = New("Frame", {
		Size = UDim2.new(0,0,0,0),
		BackgroundTransparency = 1,
	}, {
		New("ImageLabel", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Image  = Img,
			ScaleType = "Crop",
			ThemeTag = (Creator.Icon(Img) or Themed) and {
				ImageColor3 = IsThemeTag and "Icon" 
			} or nil,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0,Corner)
			})
		})
	})
	if Creator.Icon(Img) then
		ImageFrame.ImageLabel.Image = Creator.Icon(Img)[1]
		ImageFrame.ImageLabel.ImageRectOffset = Creator.Icon(Img)[2].ImageRectPosition
		ImageFrame.ImageLabel.ImageRectSize = Creator.Icon(Img)[2].ImageRectSize
	end

	return ImageFrame
end

return Creator