local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local Computed = Fusion.Computed

type properties = {
	Title: Fusion.StateObject<string>,
	Icon: Fusion.StateObject<string>,
	Callback: (...any) -> ...any,
}

return function(props: properties): Fusion.StateObject<{}>
	return Computed(function()
		return {
			Title = props.Title:get(),
			Icon = props.Icon:get(),
			Callback = props.Callback,
		}
	end)
end
