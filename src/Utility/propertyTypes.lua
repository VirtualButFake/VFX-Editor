local types = {}
-- generic types that are used throughout a lot of components, aimed specifically at reducing duplicate code
-- might look useless for now but it felt horrible to keep copy pasting the same shit for properties like size and position
local packages = script.Parent.Parent.Modules
local fusion = require(packages.fusion)

export type frameProperties = {
	Color: fusion.CanBeState<Color3>,
	Size: fusion.CanBeState<UDim2>?,
	Position: fusion.CanBeState<UDim2>?,
	AnchorPoint: fusion.CanBeState<Vector2>?,
	Parent: fusion.CanBeState<Instance>?,
	-- more dynamic properties
	PaddingSize: number?,
	Stroke: Color3?,
	CornerSize: UDim?,
}

export type textProperties = {
	Text: fusion.CanBeState<string>?,
	TextColor: fusion.CanBeState<Color3>?,
	TextSize: fusion.CanBeState<number>?,
	Font: Enum.Font?, -- no Font object support (yet)
	-- textbox properties
	PlaceholderColor: fusion.CanBeState<Color3>?,
	PlaceholderText: fusion.CanBeState<string>?,
}

export type interactiveProperties = {
	HoverColor: fusion.CanBeState<Color3>,
	ClickColor: fusion.CanBeState<Color3>?, -- not all components have a click interaction
}

return types
