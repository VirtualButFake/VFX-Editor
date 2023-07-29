local themeHandler = {}

local packages = script.Parent.Parent.Packages
local fusion = require(packages.fusion)

local value = fusion.Value
local computed = fusion.Computed

local studio = settings():GetService("Studio")
local currentTheme = value(studio.Theme)

local themeColors: { [Enum.StudioStyleGuideColor]: fusion.Computed<Color3> } = {}

function themeHandler.get(color: Enum.StudioStyleGuideColor): fusion.Computed<Color3>
	if not themeColors[color] then
		themeColors[color] = computed(function(use)
			return use(currentTheme):GetColor(color)
		end)
	end

	return themeColors[color]
end

studio.ThemeChanged:Connect(function()
	currentTheme:set(studio.Theme)
end)

return themeHandler
