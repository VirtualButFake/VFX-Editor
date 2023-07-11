local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local Hydrate = Fusion.Hydrate
local Event = Fusion.OnEvent
local Cleanup = Fusion.Cleanup

type properties = {
	Options: Fusion.StateObject<PluginMenu>,
	Frame: GuiObject,
}

return function(props: properties)
	return Hydrate(props.Frame)({
		[Cleanup] = {
			props.Options:get(),
		},
		[Event("InputEnded")] = function(input: InputObject)
			if input.UserInputType and input.UserInputType == Enum.UserInputType.MouseButton2 then
				props.Options:get():ShowAsync()
			end
		end,
	})
end
