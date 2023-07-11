local Frame = require(script.Parent.Frame)

return {
	summary = "A generic frame component",
	story = function(a)
		local frame = Frame({
			Color = Color3.fromRGB(33, 33, 33),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 400, 0, 200),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = Color3.fromRGB(60, 60, 60),
			Parent = a,
			CornerSize = UDim.new(0, 4),
		})

		return function()
			print("called")
			frame:Destroy()
		end
	end,
}
