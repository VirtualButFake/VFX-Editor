local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

type properties = {
	CornerSize: Fusion.CanBeState<UDim>?,
	Color: Fusion.CanBeState<Color3>,
	Stroke: Fusion.CanBeState<Color3>?,
	Size: Fusion.CanBeState<UDim2>?,
	Position:  Fusion.CanBeState<UDim2>?,
	AnchorPoint: Vector2?,
	Parent: Instance?,
}

return function(props: properties)
	local children = {}

	if props.CornerSize then
		table.insert(
			children,
			New("UICorner")({
				CornerRadius = props.CornerSize
			})
		)
	end

	if props.Stroke then
		table.insert(
			children,
			New("UIStroke")({
				Thickness = 1,
				Color = props.Stroke,
			})
		)
	end

	return New("Frame")({
		Size = props.Size,
		Position = props.Position,
		BackgroundColor3 = props.Color,
		AnchorPoint = props.AnchorPoint,
		Parent = props.Parent,
		[Children] = children,
	})
end
