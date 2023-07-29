local Searchbar = require(script.Parent.Searchbar)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

return {
	summary = "A generic search box component",
	story = function(a)
		local options = Fusion.Value({
			{
				value = "sus13",
			},
			{
				value = "cum",
				aliases = {
					"sus23",
				},
			},
			{
				value = "hi",
			},
		})

		local availableOptions = Fusion.Value({})
		Fusion.Computed(function(use)
			print(use(availableOptions))
		end)

		local frame = Searchbar({
			frameProperties = {
				Color = Color3.fromRGB(33, 33, 33),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 120, 0, 24),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = Color3.fromRGB(60, 60, 60),
				Parent = a,
				CornerSize = UDim.new(0, 4),
				PaddingSize = 4,
			},
			textProperties = {
				TextColor = Color3.fromRGB(255, 255, 255),
				PlaceholderText = "Search..",
				PlaceholderColor = Color3.fromRGB(150, 150, 150),
			},
			HoverColor = Color3.fromRGB(20, 20, 20),
			HoverStroke = Color3.fromRGB(80, 80, 80),
			Options = options,
			AvailableOptions = availableOptions,
			Autocomplete = true,
			AutocompleteColor = Color3.fromRGB(200, 200, 200),
		})

		return function()
			frame:Destroy()
		end
	end,
}
