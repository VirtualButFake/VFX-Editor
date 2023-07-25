local root = script.Parent.Parent.Parent
local packages = root.Modules
local utility = root.Utility

local fusion = require(packages.fusion)
local types = require(utility.propertyTypes)
local ripple = require(utility.ripple)

local new = fusion.New
local children = fusion.Children

local event = fusion.OnEvent
local out = fusion.Out
local ref = fusion.Ref

local value = fusion.Value
local computed = fusion.Computed
local peek = fusion.peek

local tween = fusion.Tween

type properties = {
	frameProperties: types.frameProperties,
	textProperties: types.textProperties,
	interactiveProperties: types.interactiveProperties,
	AutoSize: boolean?,
	Icon: string?,
	IconInFront: boolean?,
	Callback: (InputObject) -> (),
}

return function(props: properties)
	local isHovering = value(false)
	local parentFrame = value()
	local absoluteSize = value(Vector2.new(0, 0))

	local frameProperties = props.frameProperties
	local textProperties = props.textProperties
	local interactiveProperties = props.interactiveProperties

	local button = new("Frame")({
		Name = "Container",
		BackgroundTransparency = 1,
		Parent = props.frameProperties.Parent,
		Size = tween(
			computed(function(use)
				local parent = use(parentFrame)

				if parent then
					local minSize = use(frameProperties.Size)
					local offsetXMin = minSize.X.Scale * parent.AbsoluteSize.X + minSize.X.Offset
					local size = use(absoluteSize).X

					return UDim2.new(0, math.clamp(size, offsetXMin, math.huge), minSize.Y.Scale, minSize.Y.Offset)
				end

				return use(frameProperties.Size)
			end),
			TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		),
		Position = frameProperties.Position,
		AnchorPoint = frameProperties.AnchorPoint,
		[children] = {
			new("ImageButton")({
				Name = "Button",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = tween(
					computed(function(use)
						if use(isHovering) then
							return use(interactiveProperties.HoverColor)
						else
							return use(frameProperties.Color)
						end
					end),
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				),
				BackgroundTransparency = 0,
				Parent = frameProperties.Parent,
				AutomaticSize = props.AutoSize and Enum.AutomaticSize.X,
				[event("MouseEnter")] = function()
					isHovering:set(true)
				end,
				[event("MouseLeave")] = function()
					isHovering:set(false)
				end,
				[event("Activated")] = function(input)
					task.spawn(ripple, {
						Position = Vector2.new(input.Position.X, input.Position.Y),
						Speed = 0.5,
						Frame = peek(parentFrame),
					})

					task.spawn(props.Callback, input)
				end,
				[out("AbsoluteSize")] = absoluteSize,
				[children] = {
					frameProperties.PaddingSize and new("UIPadding")({
						PaddingBottom = UDim.new(0, frameProperties.PaddingSize),
						PaddingTop = UDim.new(0, frameProperties.PaddingSize),
						PaddingLeft = UDim.new(0, frameProperties.PaddingSize),
						PaddingRight = UDim.new(0, frameProperties.PaddingSize),
					}),
					frameProperties.Stroke and new("UIStroke")({
						Thickness = 1,
						Color = frameProperties.Stroke,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					}),
					frameProperties.CornerSize and new("UICorner")({
						CornerRadius = frameProperties.CornerSize,
					}),
					new("TextLabel")({
						Name = "Text",
						Text = textProperties.Text,
						TextSize = textProperties.TextSize,
						TextColor3 = textProperties.TextColor,
						Font = computed(function(use)
							return use(textProperties.Font) or Enum.Font.Gotham
						end),
						AutomaticSize = props.AutoSize and Enum.AutomaticSize.X,
						TextXAlignment = Enum.TextXAlignment.Center,
						Size = UDim2.new(0, 0, 1, 0),
						BackgroundTransparency = 1,
					}),
					props.Icon and new("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, frameProperties.PaddingSize),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					props.Icon and new("ImageLabel")({
						Name = "Icon",
						Image = props.Icon,
						ImageColor3 = textProperties.TextColor,
						Size = UDim2.fromScale(1, 1),
						LayoutOrder = props.IconInFront and 1 or -1,
						BackgroundTransparency = 1,
						[children] = {
							new("UIAspectRatioConstraint")({
								AspectRatio = 1,
							}),
						},
					}),
				},
			}),
		},
		[ref] = parentFrame,
	})

	return button
end
