-- This is an outdated version
-- Use new Main-v2.lua

local Icons = {
	["lucide"] = require("./lucide"),
	["craft"] = require("./craft")
}


local IconModule = {
	IconsType = "lucide" --
}

function IconModule.SetIconsType(iconType)
	IconModule.IconsType = iconType
end

function IconModule.Icon(Icon, Type)
	local iconType = Icons[Type or IconModule.IconsType]

	if iconType.Icons[Icon] then
		return { iconType.Spritesheets[tostring(iconType.Icons[Icon].Image)], iconType.Icons[Icon] }
	end
	return nil
end

return IconModule