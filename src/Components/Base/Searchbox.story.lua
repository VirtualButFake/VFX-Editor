local Searchbox = require(script.Parent.Searchbox)

local Modules = script.Parent.Parent.Parent.Modules
local Fusion = require(Modules.fusion)

return {
	summary = "A generic search box component",
	story = function(a)
		local options = Fusion.Value({
			{
				value = "sus",
			},
			{
				value = "hi",
			},
		})

		local availableOptions = Fusion.Value({})

		local frame = Searchbox({
			Color = Color3.fromRGB(33, 33, 33),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 120, 0, 24),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = Color3.fromRGB(60, 60, 60),
			Parent = a,
			CornerSize = UDim.new(0, 4),
			PaddingSize = 4,
			Options = options,
			AvailableOptions = availableOptions,
			TextColor = Color3.fromRGB(255, 255, 255),
		})

		return function()
			frame:Destroy()
		end
	end,
}
