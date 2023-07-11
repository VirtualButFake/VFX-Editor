local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local Hydrate = Fusion.Hydrate
local Event = Fusion.OnEvent

type properties = {
	Options: Fusion.StateObject<PluginMenu>,
	Frame: GuiObject,
}

return function(props: properties)
	return Hydrate(props.Frame)({
		[Event("InputEnded")] = function(input: InputObject)
			if input.UserInputType and input.UserInputType == Enum.UserInputType.MouseButton2 then
				props.Options:get():ShowAsync()
			end
		end,
	})
end
