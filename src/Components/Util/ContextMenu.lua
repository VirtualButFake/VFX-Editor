local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local Hydrate = Fusion.Hydrate
local Event = Fusion.OnEvent

local Value = Fusion.Value
local Computed = Fusion.Computed

type properties = {
	Options: Fusion.StateObject<PluginMenu>,
	Frame: GuiObject,
}

return function(props: properties)
	local isOpen = Value(false)

	return Hydrate(props.Frame)({
		[Event("InputEnded")] = function(input: InputObject, gp)
			if input.UserInputType and input.UserInputType == Enum.UserInputType.MouseButton2 then
				props.Options:get():ShowAsync()
			end
		end,
	})
end
