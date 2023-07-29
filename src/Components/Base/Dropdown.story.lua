local Dropdown = require(script.Parent.Dropdown)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

return {
	summary = "A generic dropdown component",
	story = function(a)
		local selectedOption = Fusion.Value({})
		local Options = Fusion.Value({
			{
				value = "dropdown",
				icon = "rbxassetid://14019947723",
			},
			{
				value = "",
			},
		})

		local frame = Dropdown({
			frameProperties = {
				Color = Color3.fromRGB(33, 33, 33),
				Stroke = Color3.fromRGB(60, 60, 60),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 132, 0, 26),
				AnchorPoint = Vector2.new(0.5, 0),
				CornerSize = UDim.new(0, 4),
				Parent = a,
			},
			arrowProperties = {
				HoverColor = Color3.fromRGB(200, 200, 200),
			},
			cellProperties = {
				HoverColor = Color3.fromRGB(20, 20, 20),
				ClickColor = Color3.fromRGB(25, 25, 25),
			},
			TextColor = Color3.fromRGB(255, 255, 255),
			SelectedOption = selectedOption,
			Options = Options,
			IsOpen = Fusion.Value(false),
			MultiSelect = true,
			AutoSize = true,
			OnSelection = function(option, value)
				print(option, value)
			end,
		})

		return function()
			frame:Destroy()
		end
	end,
}
