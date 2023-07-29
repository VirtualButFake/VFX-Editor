local root = script.Parent.Parent.Parent
local packages = root.Packages
local fusion = require(packages.fusion)

local hydrate = fusion.Hydrate

local event = fusion.OnEvent
local cleanup = fusion.Cleanup

local peek = fusion.peek

type properties = {
	Options: fusion.StateObject<PluginMenu>,
	Frame: GuiObject,
	InputType: fusion.CanBeState<Enum.UserInputType>,
}

return function(props: properties)
	return hydrate(props.Frame)({
		[cleanup] = {
			peek(props.Options),
		},
		[event("InputEnded")] = function(input: InputObject)
			if input.UserInputType and input.UserInputType == peek(props.InputType) then
				peek(props.Options):ShowAsync()
			end
		end,
	})
end
