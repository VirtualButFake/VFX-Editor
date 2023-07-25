local packages = script.Parent.Parent.Parent.Modules
local fusion = require(packages.fusion)

local computed = fusion.Computed
local forPairs = fusion.ForPairs
local peek = fusion.peek

type action = {
	Title: fusion.CanBeState<string>,
	Icon: fusion.CanBeState<string>,
	Callback: (...any) -> (),
}

type properties = {
	Title: fusion.CanBeState<string>,
	Icon: fusion.CanBeState<string>,
	Actions: fusion.CanBeState<{ fusion.CanBeState<action> | fusion.CanBeState<PluginMenu> }>,
	Plugin: Plugin,
}

-- This is **extremely** scuffed. ROBLOX doesn't allow us to delete objects while retaining order so this is the only option. I'm by no means proud of this but it works.
return function(props: properties): fusion.CanBeState<PluginMenu>
	local menu: PluginMenu = props.Plugin:CreatePluginMenu(tostring(math.random()), peek(props.Title), peek(props.Icon))

	-- this is neccessary because for some reason modification of tables inside of values are not detected
	local updatedActions = forPairs(props.Actions, function(use, i, v)
		return i, v
	end, fusion.cleanup)

	return computed(function(use)
		menu.Title = use(props.Title)
		menu.Icon = use(props.Icon)
		menu:Clear()

		-- import all actions & menus
		for _, value in use(updatedActions) do
			if typeof(value) == "Instance" then
				local addedMenu = value :: PluginMenu
				menu:AddMenu(addedMenu)
			else
				local action = use(value) :: action
				local pluginAction = menu:AddNewAction(tostring(math.random()), action.Title, action.Icon)
				pluginAction.Triggered:Connect(action.Callback)
			end
		end

		return menu
	end, fusion.doNothing)
end
