local Button = require(script.Parent.Button)

return {
	summary = "A generic button component",
	story = function(a)
		local button = Button({
			Color = Color3.fromRGB(33, 33, 33),
			HoverColor = Color3.fromRGB(20, 20, 20),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 50, 0, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = Color3.fromRGB(60, 60, 60),
			Parent = a,
			CornerSize = UDim.new(0, 4),
			Callback = function()
				print("Click")
			end,
			Text = "a",
			PaddingSize = 4,
			Font = Enum.Font.GothamMedium,
			TextColor = Color3.fromRGB(255, 255, 255),
			AutoSize = true,
		})

		return function()
			button:Destroy()
		end
	end,
}
