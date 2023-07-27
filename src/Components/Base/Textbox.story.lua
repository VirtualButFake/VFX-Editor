local Textbox = require(script.Parent.Textbox)

local Modules = script.Parent.Parent.Parent.Modules
local Fusion = require(Modules.fusion)

return {
	summary = "A generic text box component",
	story = function(a)
		local state = Fusion.Value("")

		local button = Textbox({
			frameProperties = {
				Color = Color3.fromRGB(33, 33, 33),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 50, 0, 24),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = Color3.fromRGB(60, 60, 60),
				Parent = a,
				PaddingSize = 4,
				CornerSize = UDim.new(0, 4),
			},
			textProperties = {
				Text = Fusion.Value("default text"),
				Font = Enum.Font.GothamMedium,
				TextColor = Color3.fromRGB(255, 255, 255),
			},
			HoverColor = Color3.fromRGB(20, 20, 20),
			HoverStroke = Color3.fromRGB(80, 80, 80),
			AutoSizeX = true,
			AutoSizeY = true,
			State = state
		})

		return function()
			button:Destroy()
		end
	end,
}
