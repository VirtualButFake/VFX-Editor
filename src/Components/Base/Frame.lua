local root = script.Parent.Parent.Parent
local packages = root.Modules
local utility = root.Utility

local fusion = require(packages.fusion)
local types = require(utility.propertyTypes)

local new = fusion.New
local children = fusion.Children

type properties = {
	frameProperties: types.frameProperties,
	Children: fusion.CanBeState<{}>?,
	Name: string?,
	[string]: any,
}

return function(props: properties)
	local frameProperties = props.frameProperties

	return new("Frame")({
		Size = frameProperties.Size,
		Position = frameProperties.Position,
		BackgroundColor3 = frameProperties.Color,
		AnchorPoint = frameProperties.AnchorPoint,
		Parent = frameProperties.Parent,
		Name = props.Name,
		ZIndex = props.ZIndex,
		AutomaticSize = props.AutomaticSize,
		BackgroundTransparency = props.BackgroundTransparency,
		[children] = {
			-- or nil here neccessary to suppress fusion throwing a warning
			frameProperties.Stroke ~= nil
					and new("UIStroke")({
						Thickness = 1,
						Color = frameProperties.Stroke,
					})
				or nil,
			frameProperties.CornerSize ~= nil and new("UICorner")({
				CornerRadius = frameProperties.CornerSize,
			}) or nil,
			props.Children,
		},
	})
end
