local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

type properties = {
	CornerSize: Fusion.CanBeState<UDim>?,
	Color: Fusion.CanBeState<Color3>,
	Stroke: Fusion.CanBeState<Color3>?,
	Size: Fusion.CanBeState<UDim2>?,
	Position: Fusion.CanBeState<UDim2>?,
	AnchorPoint: Vector2?,
	Parent: Instance?,
}

return function(props: properties)
	return New("Frame")({
		Size = props.Size,
		Position = props.Position,
		BackgroundColor3 = props.Color,
		AnchorPoint = props.AnchorPoint,
		Parent = props.Parent,
		[Children] = {
			props.Stroke ~= nil and New("UIStroke")({
				Thickness = 1,
				Color = props.Stroke,
			}),
			props.CornerSize ~= nil and New("UICorner")({
				CornerRadius = props.CornerSize,
			}),
		},
	})
end
