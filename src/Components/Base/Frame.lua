local root = script.Parent.Parent.Parent
local packages = root.Packages
local utility = root.Utility

local fusion = require(packages.fusion)
local types = require(utility.propertyTypes)

local new = fusion.New
local children = fusion.Children

type properties = {
	frameProperties: types.frameProperties,
	otherProperties: { [string]: any }?,
	Children: fusion.CanBeState<{}>?,
}

return function(props: properties)
	local frameProperties = props.frameProperties
	local properties = {
		Size = frameProperties.Size,
		Position = frameProperties.Position,
		BackgroundColor3 = frameProperties.Color,
		AnchorPoint = frameProperties.AnchorPoint,
		Parent = frameProperties.Parent,
		[children] = {
			-- or nil here neccessary to suppress fusion throwing a warning
			frameProperties.Stroke
					and new("UIStroke")({
						Thickness = 1,
						Color = frameProperties.Stroke,
					})
				or nil,
			frameProperties.CornerSize and new("UICorner")({
				CornerRadius = frameProperties.CornerSize,
			}) or nil,
			frameProperties.PaddingSize and new("UIPadding")({
				PaddingBottom = UDim.new(0, frameProperties.PaddingSize),
				PaddingTop = UDim.new(0, frameProperties.PaddingSize),
				PaddingLeft = UDim.new(0, frameProperties.PaddingSize),
				PaddingRight = UDim.new(0, frameProperties.PaddingSize),
			}),
			props.Children,
		},
	}

	-- merge properties with otherproperties
	if props.otherProperties then
		for i, v in props.otherProperties do
			properties[i] = v
		end
	end

	return new("Frame")(properties)
end
