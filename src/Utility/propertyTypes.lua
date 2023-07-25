local types = {}
-- generic types that are used throughout a lot of components, aimed specifically at reducing duplicate code
-- might look useless for now but it felt horrible to keep copy pasting the same shit for properties like size and position
local Modules = script.Parent.Parent.Modules
local Fusion = require(Modules.fusion)

export type frameProperties = {
	Color: Fusion.CanBeState<Color3>,
	Size: Fusion.CanBeState<UDim2>?,
	Position: Fusion.CanBeState<UDim2>?,
	AnchorPoint: Fusion.CanBeState<Vector2>?,
	Parent: Fusion.CanBeState<Instance>?,
	-- more dynamic properties
	PaddingSize: Vector2?,
	Stroke: Color3?,
	CornerSize: UDim?,
}

export type textProperties = {
	Text: Fusion.CanBeState<string>,
	TextColor: Fusion.CanBeState<Color3>,
	TextSize: Fusion.CanBeState<number>?,
	Font: Enum.Font?, -- no Font object support (yet)
	-- textbox properties
	PlaceholderColor: Fusion.CanBeState<Color3>?,
	PlaceholderText: Fusion.CanBeState<string>?,
}

export type interactiveProperties = {
	HoverColor: Fusion.CanBeState<Color3>,
	ClickColor: Fusion.CanBeState<Color3>?, -- not all components have a click interaction
}

return types
