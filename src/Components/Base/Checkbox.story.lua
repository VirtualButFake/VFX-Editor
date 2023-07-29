local Checkbox = require(script.Parent.Checkbox)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local peek = Fusion.peek

return {
	summary = "A generic checkbox component",
	story = function(a)
		local selected = Fusion.Value(false)

		local frame = Checkbox({
			frameProperties = {
				Color = Color3.fromRGB(33, 33, 33),
				Stroke = Color3.fromRGB(60, 60, 60),
				Parent = a,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(0, 25, 0, 25),
				CornerSize = UDim.new(0, 4),
			},
			interactiveProperties = {
				ClickColor = Color3.fromRGB(200, 200, 200),
				HoverColor = Color3.fromRGB(20, 20, 20),
			},
			State = selected,
			OnClick = function(value)
				selected:set(not peek(selected))
			end,
		})

		return function()
			frame:Destroy()
		end
	end,
}
