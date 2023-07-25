local Frame = require(script.Parent.Frame)

local ContextMenu = require(script.Parent.ContextMenu)
local PluginMenu = require(script.Parent.PluginMenu)
local PluginAction = require(script.Parent.PluginAction)

return {
	summary = "context menu",
	story = function(a)
		local hostFrame = Frame({
			frameProperties = {
				Color = Color3.fromRGB(33, 33, 33),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 400, 0, 200),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = Color3.fromRGB(60, 60, 60),
				Parent = a,
				CornerSize = UDim.new(0, 4),
			},
		})

		-- create context action menu
		local Context = ContextMenu({
			Options = PluginMenu({
				Icon = "rbxassetid://14065230124", -- empty img
				Title = "sussy menu",
				Plugin = workspace:FindFirstChildOfClass("Plugin"),
				Actions = {
					PluginAction({
						Title = "other sub action",
						Callback = function()
							print("clicked")
						end,
					}),
				},
			}),
			InputType = Enum.UserInputType.MouseButton2,
			Frame = hostFrame,
		})

		return function()
			hostFrame:Destroy()
			Context:Destroy()
		end
	end,
}
