local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs

type action = {
	Title: Fusion.StateObject<string>,
	Icon: Fusion.StateObject<string>,
	Callback: (...any) -> ...any,
}

type properties = {
	Title: Fusion.StateObject<string>,
	Icon: Fusion.StateObject<string>,
	Actions: Fusion.StateObject<{ Fusion.StateObject<action> | Fusion.StateObject<PluginMenu> }>,
	Plugin: Plugin,
}

-- This is **extremely** scuffed. ROBLOX doesn't allow us to delete objects while retaining order so this is the only option. I'm by no means proud of this but it works.
return function(props: properties): Fusion.StateObject<PluginMenu>
	local menu: PluginMenu = props.Plugin:CreatePluginMenu(tostring(math.random()), props.Title:get(), props.Icon:get())

	-- this is neccessary because for some reason modification of tables inside of values are not detected
	local updatedActions = ForPairs(props.Actions, function(i, v)
		return i, v:get()
	end, Fusion.cleanup)

	return Computed(function()
		menu.Title = props.Title:get()
		menu.Icon = props.Icon:get()
		menu:Clear()

		-- import all actions & menus
		for _, value in updatedActions:get() do
			if typeof(value) == "Instance" then
				local addedMenu = value :: PluginMenu
				menu:AddMenu(addedMenu)
			else
				local action = value :: action
				local pluginAction = menu:AddNewAction(tostring(math.random()), action.Title, action.Icon)
				pluginAction.Triggered:Connect(action.Callback)
			end
		end

		return menu
	end, Fusion.doNothing)
end
