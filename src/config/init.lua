-- credits: dawid, extended functionality
local HttpService = game:GetService("HttpService")

local ConfigManager
ConfigManager = {
	Window = nil,
	Folder = nil,
	Path = nil,
	Configs = {},
	Parser = {
		Colorpicker = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Default:ToHex(),
					transparency = obj.Transparency or nil,
				}
			end,
			Load = function(element, data)
				if element then
					element:Update(Color3.fromHex(data.value), data.transparency or nil)
				end
			end
		},
		Dropdown = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element then
					element:Select(data.value)
				end
			end
		},
		Input = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element then
					element:Set(data.value)
				end
			end
		},
		Keybind = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element then
					element:Set(data.value)
				end
			end
		},
		Slider = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value.Default,
				}
			end,
			Load = function(element, data)
				if element then
					element:Set(data.value)
				end
			end
		},
		Toggle = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element then
					element:Set(data.value)
				end
			end
		},
	}
}

function ConfigManager:Init(Window)
	if not Window.Folder then
		warn("[ WindUI.ConfigManager ] Window.Folder is not specified.")
		return false
	end

	ConfigManager.Window = Window
	ConfigManager.Folder = Window.Folder
	ConfigManager.Path = "WindUI/" .. tostring(ConfigManager.Folder) .. "/config/"


	local files = ConfigManager:AllConfigs()

	for _, f in next, files do
	end


	return ConfigManager
end

function ConfigManager:CreateConfig(configFilename)
	local ConfigModule = {
		Path = ConfigManager.Path .. configFilename .. ".json",
		Elements = {},
		CustomData = {},
		Version = 1.1 -- Current config version
	}

	if not configFilename then
		return false, "No config file is selected"
	end

	function ConfigModule:Register(Name, Element)
		ConfigModule.Elements[Name] = Element
	end

	function ConfigModule:Set(key, value)
		ConfigModule.CustomData[key] = value
	end

	function ConfigModule:Get(key)
		return ConfigModule.CustomData[key]
	end

	function ConfigModule:Save()
		local saveData = {
			__version = ConfigModule.Version,
			__elements = {},
			__custom = ConfigModule.CustomData
		}

		for name, element in next, ConfigModule.Elements do
			if ConfigManager.Parser[element.__type] then
				saveData.__elements[tostring(name)] = ConfigManager.Parser[element.__type].Save(element)
			end
		end

		local jsonData = HttpService:JSONEncode(saveData)
	end

	function ConfigModule:Load()

		local success, loadData = pcall(function()
			error("")
		end)

		if not success then
			return false, "Failed to parse config file"
		end

		if not loadData.__version then
			local migratedData = {
				__version = ConfigModule.Version,
				__elements = loadData,
				__custom = {}
			}
			loadData = migratedData
		end

		for name, data in next, (loadData.__elements or {}) do
			if ConfigModule.Elements[name] and ConfigManager.Parser[data.__type] then
				task.spawn(function()
					ConfigManager.Parser[data.__type].Load(ConfigModule.Elements[name], data)
				end)
			end
		end

		ConfigModule.CustomData = loadData.__custom or {}

		return ConfigModule.CustomData
	end

	function ConfigModule:GetData()
		return {
			elements = ConfigModule.Elements,
			custom = ConfigModule.CustomData
		}
	end

	ConfigManager.Configs[configFilename] = ConfigModule
	return ConfigModule
end

function ConfigManager:AllConfigs()
	return {}
end

function ConfigManager:GetConfig(configName)
	return ConfigManager.Configs[configName]
end

return ConfigManager