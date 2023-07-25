local Modules = script.Parent.Parent.Parent.Modules
local Fusion = require(Modules.fusion)

local Frame = require(script.Parent.Frame)

local New = Fusion.New
local Children = Fusion.Children

type option = {
	value: string, -- text that is displayed,
	alias: { string }?, -- alternative names that will count w/ search but not display
}

type properties = {
	-- appearance
	Size: UDim2,
	Position: Fusion.CanBeState<UDim2>,
	Color: Color3,
	Stroke: Fusion.CanBeState<Color3>?,
	Parent: GuiObject,
	AnchorPoint: Fusion.CanBeState<Vector2>,
	CornerSize: Fusion.CanBeState<UDim>?,
	PaddingSize: number?,
	-- custom properties
	Placeholder: string?,
	PlaceholderColor: Fusion.CanBeState<Color3>?,
	TextColor: Fusion.CanBeState<Color3>,
	Autocomplete: boolean?, -- autocompletes text when it's found only 1 match
	AutocompleteColor: Fusion.CanBeState<Color3>?,
	Options: Fusion.StateObject<{ option }>, -- a table of the options that are available in the search menu.
	AvailableOptions: Fusion.Value<{ option }>, -- value object that holds the options that meet the current text. this is also the **only** way to access found values. the text is not exposed to make sure behaviour is consistent
}

return function(props: properties)
	return Frame({
		Size = props.Size,
		Position = props.Position,
		Color = props.Color,
		Stroke = props.Stroke,
		Parent = props.Parent,
		AnchorPoint = props.AnchorPoint,
		CornerSize = props.CornerSize,
		Children = {
			props.PaddingSize and New("UIPadding")({
				PaddingBottom = UDim.new(0, props.PaddingSize),
				PaddingTop = UDim.new(0, props.PaddingSize),
				PaddingLeft = UDim.new(0, props.PaddingSize),
				PaddingRight = UDim.new(0, props.PaddingSize),
			}),
			-- create search icon
			New("ImageLabel")({
				BackgroundTransparency = 1,
				Image = "rbxassetid://10734943674",
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				ImageColor3 = props.TextColor,
				[Children] = {
					New("UIAspectRatioConstraint")({}),
				},
			}),
		},
	})
end
