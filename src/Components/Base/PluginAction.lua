local root = script.Parent.Parent.Parent
local packages = root.Packages
local fusion = require(packages.fusion)

local computed = fusion.Computed
local peek = fusion.peek

type properties = {
	Title: fusion.CanBeState<string>,
	Icon: fusion.CanBeState<string>?,
	Callback: (...any) -> ...any,
}

return function(props: properties): fusion.Computed<{}>
	return computed(function()
		return {
			Title = peek(props.Title),
			Icon = peek(props.Icon) or "rbxassetid://14065230124",
			Callback = props.Callback,
		}
	end)
end
