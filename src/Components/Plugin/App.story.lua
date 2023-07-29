local App = require(script.Parent.App)

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

return {
	summary = "Main window of the application",
	story = function(a)
		local selectedObjects = Fusion.Value({})
		local app = Fusion.New("Frame")({
			Parent = a,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.339, 0, 0.8, 0),
			[Fusion.Children] = {
				Fusion.New("UIPadding")({
					PaddingTop = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
				}),
				App({
					Parent = a,
					State = {
						settingsOpen = Fusion.Value(false),
						selectedObjects = selectedObjects,
					},
				}),
			},
		})

		return function()
			app:Destroy()
		end
	end,
}
