local Textbox = require(script.Parent.Textbox)

local Modules = script.Parent.Parent.Parent.Modules
local Fusion = require(Modules.fusion)

return {
	summary = "A generic text box component",
	story = function(a)
		local button = Textbox({
			Color = Color3.fromRGB(33, 33, 33),
			HoverColor = Color3.fromRGB(20, 20, 20),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 50, 0, 24),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = Color3.fromRGB(60, 60, 60),
			HoverStroke = Color3.fromRGB(80, 80, 80),
			Parent = a,
			CornerSize = UDim.new(0, 4),
			Text = Fusion.Value("default text"),
			PaddingSize = 4,
			Font = Enum.Font.GothamMedium,
			TextColor = Color3.fromRGB(255, 255, 255),
			AutoSizeX = true,
			AutoSizeY = true,
		})

		return function()
			button:Destroy()
		end
	end,
}
